#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <float.h>
#include <math.h>
#include <mpi.h>
#include <iostream>
#include "libarff/arff_parser.h"
#include "libarff/arff_data.h"

#define MIN(a,b) (((a)<(b))?(a):(b))

using namespace std;

int KNN(ArffData* dataset, int rank, int ntasks)
{
    int instancesPerTask = (dataset->num_instances() + ntasks) / ntasks;
    int beginInstance = rank * instancesPerTask;
    int endInstance = MIN((rank + 1) * instancesPerTask, dataset->num_instances());
    int localSuccessfulPredictions = 0;
    
    for(int i = beginInstance; i < endInstance; i++)
    {
        float smallestDistance = FLT_MAX;
        int smallestDistanceClass;

        for(int j = 0; j < dataset->num_instances(); j++) // target each other instance
        {
            if(i == j) continue;
            
            float distance = 0;
            
            for(int k = 0; k < dataset->num_attributes() - 1; k++) // compute the distance between the two instances
            {
                float diff = dataset->get_instance(i)->get(k)->operator float() - dataset->get_instance(j)->get(k)->operator float();
                distance += diff * diff;
            }
            
            distance = sqrt(distance);
            
            if(distance < smallestDistance) // select the closest one
            {
                smallestDistance = distance;
                smallestDistanceClass = dataset->get_instance(j)->get(dataset->num_attributes() - 1)->operator int32();
            }
        }
        
        if(smallestDistanceClass == dataset->get_instance(i)->get(dataset->num_attributes() - 1)->operator int32())
            localSuccessfulPredictions++;
    }
    
    return localSuccessfulPredictions;
}

int main(int argc, char *argv[])
{
    if(argc != 2)
    {
        cout << "Usage: ./main datasets/datasetFile.arff" << endl;
        exit(0);
    }
    
    ArffParser parser(argv[1]);
    ArffData *dataset = parser.parse();
    struct timespec start, end;
    
    int  rank, ntasks, i;
   
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &ntasks);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    
    int  local_tp = KNN(dataset, rank, ntasks);
    int global_tp;
    
    MPI_Reduce(&local_tp, &global_tp, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    
    float accuracy = global_tp / (float) dataset->num_instances();
    
    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    
    uint64_t diff = (1000000000L * (end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec) / 1e6;
    
    if(rank == 0)
        printf("The 1NN classifier for %lu instances required %llu ms CPU time, accuracy was %.4f\n", dataset->num_instances(), (long long unsigned int) diff, accuracy);
    
    MPI_Finalize();
}
