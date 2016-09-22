#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <float.h>
#include <math.h>
#include <iostream>
#include "libarff/arff_parser.h"
#include "libarff/arff_data.h"

#include <pthread.h>
#include <semaphore.h>
#include <time.h>


using namespace std;
sem_t sem_main, sem_threads;
//int* predictions;

void *Calculation(void * arg);

struct Data{
  int* i;
  ArffData* dataset;
  int* predictions;
  int* n_threads;
} ;

int* KNN(ArffData* dataset)
{
    int* predictions = (int*)malloc(dataset->num_instances() * sizeof(int));
    //printf("Number of Data points in the data set is %d",dataset->num_instances());

    for(int i = 0; i < dataset->num_instances(); i++) // for each instance in the dataset
    {
		printf("Number of interation %d \n",i);
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

        predictions[i] = smallestDistanceClass;
    }

    return predictions;
}

void print_prediacton(int* predictions , ArffData* dataset)
{
  for(int i = 0; i < dataset->num_instances();i++){
    printf("i is %d Predictior is %d\n",i,predictions[i] );
  }
}

int* KNN_PARALLEL(ArffData* dataset)
{

    //printf("Number of Data points in the data set is %d",dataset->num_instances());

    int n_threads = 256;
    int thread_ID[n_threads];
    //Initial thread ID
    int* predictions = (int*)malloc(dataset->num_instances() * sizeof(int));
    //printf("Total number is instances is %lu\n",dataset->num_instances() );

    for (int i = 0; i < n_threads; i++) {
        thread_ID[i]=i;
    }
    pthread_t *threads;
    threads = (pthread_t*)malloc(n_threads * sizeof(pthread_t));


    for(int i = 0; i < n_threads; i ++)
    {
      Data* data_pointer = (Data*)malloc(sizeof(Data));
      data_pointer->dataset = dataset;
      data_pointer->i = &thread_ID[i];
      data_pointer->predictions = predictions;
      data_pointer->n_threads = &n_threads;
      //printf("feed in struct i address  is %d, value is %d\n",&thread_ID[i],*data_pointer->i );
      pthread_create(&threads[i],NULL,Calculation,(void*)data_pointer);
    }

    for(int i = 0; i < n_threads; i++)
    {
        pthread_join(threads[i],NULL);
    }
    //print_prediacton(predictions,dataset);
    return predictions;
}

void *Calculation(void * arg)
{
        Data* data = (Data *) arg;

        ArffData* dataset = data->dataset;
        int i = *data->i;
        //cout<<"Thread number input is "<<i<<endl;
        int count = 0;
        //printf("Parallel Number of interation %d \n",*i);
        for(i ; i < data->dataset->num_instances(); i=i+*data->n_threads)
        {
          int smallestDistanceClass;
          float smallestDistance = FLT_MAX;
          //printf("data instance in thread %d is %d\n",*data->i,i );
          count = count + 1;
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
                //cout <<"i is "<< i << "j is "<< j << "The distance is " << distance<<"smallestDistance is "<<smallestDistance << endl;

                //cout <<"i is "<< i << "j is "<< j << "The distance is " << distance << endl;

                if(distance < smallestDistance) // select the closest one
                {
                  //puts("Liang Xu");
                  smallestDistance = distance;
                  smallestDistanceClass = dataset->get_instance(j)->get(dataset->num_attributes() - 1)->operator int32();
                }
            }
        data->predictions[i] = smallestDistanceClass;
        //printf("i is %d Predication is %d\n",i,smallestDistanceClass );
      }
        printf("Finish Thread %d and %d instance have been done \n", *data->i,count);
    pthread_exit(0);
}




int* computeConfusionMatrix(int* predictions, ArffData* dataset)
{
    int* confusionMatrix = (int*)calloc(dataset->num_classes() * dataset->num_classes(), sizeof(int)); // matriz size numberClasses x numberClasses

    for(int i = 0; i < dataset->num_instances(); i++) // for each instance compare the true class and predicted class
    {
        int trueClass = dataset->get_instance(i)->get(dataset->num_attributes() - 1)->operator int32();
        int predictedClass = predictions[i];

        confusionMatrix[trueClass*dataset->num_classes() + predictedClass]++;
    }

    return confusionMatrix;
}


float computeAccuracy(int* confusionMatrix, ArffData* dataset)
{
    int successfulPredictions = 0;

    for(int i = 0; i < dataset->num_classes(); i++)
    {
        successfulPredictions += confusionMatrix[i*dataset->num_classes() + i]; // elements in the diagnoal are correct predictions
    }

    return successfulPredictions / (float) dataset->num_instances();
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
    //data.dataset = dataset;
    struct timespec start, end;

    //predictions = (int*)malloc(dataset->num_instances() * sizeof(int));

    clock_gettime(CLOCK_MONOTONIC_RAW, &start);
    // First step try to paralle this part.
    int* predictions = KNN_PARALLEL(dataset);

    int* confusionMatrix = computeConfusionMatrix(predictions,dataset);

    float accuracy = computeAccuracy(confusionMatrix, dataset);

    clock_gettime(CLOCK_MONOTONIC_RAW, &end);
    uint64_t diff = (1000000000L * (end.tv_sec - start.tv_sec) + end.tv_nsec - start.tv_nsec) / 1e6;

    printf("The 1NN classifier for %lu instances required %llu ms CPU time, accuracy was %.4f\n", dataset->num_instances(), (long long unsigned int) diff, accuracy);
}
