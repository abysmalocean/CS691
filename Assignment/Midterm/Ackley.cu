/*
   Liang Xu 2016
 */
 #define PI (3.141592653589793238462643383279)
#define E  (2.718281828459045235360287471352)
#define L(i) ((int64_t)i)
#define D(i) ((double)i)

#include <string>
#include <iostream>
#include <cstring>
#include <cstdio>
#include <fstream>
#include <sstream>
#include <sys/time.h>
#include <cstdio>
#include <unistd.h>
#include <stdio.h>
#include <sstream>
#include <vector>
#include <fstream>
#include <string>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <ctime>
int dimension = 1000000;
using namespace std;

__global__ void matrixAdd(float *A, float *B, float *C, int numElements)
{


}

double** readOvectorVec()
{
  int dimension_fileread = 1000;
  double* d = new double[dimension];
  stringstream ss;
  ss<< "cdatafiles/" << "F3" << "-xopt.txt";
  ifstream file (ss.str());
  string value;
  string line;
  int c=0;

  if (file.is_open())
    {
      stringstream iss;
      while ( getline(file, line) )
        {
          iss<<line;
          while (getline(iss, value, ','))
            {
              d[c++] = stod(value);
            }
          iss.clear();
          // if (c==dimension)
          //   {
          //     break;
          //   }
          // printf("%d\n",c);
        }
      file.close();
    }
  else
    {
      cout<<"Cannot open datafiles"<<endl;
    }
  int tid = 0;
  for (int i = 1; i < 1000; i++) {
    tid = i * 1000;
    for (int j = 0; j < dimension_fileread; j++) {
      d[tid+j] = d[j];
      //printf("d[%d] = d[%d] ---> %f\n",tid+j,j,d[tid+j] );
    }
  }
  return d;
}

AckleyCompute(double*x)
{
        int i;
        double result;
        anotherz = new double[dimension];
        Ovector = NULL;
        minX = -32;
        maxX = 32;
        ID = 3;

        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        float milliseconds = 0;

        if(Ovector == NULL) {
                // Ovector = createShiftVector(dimension,minX,maxX);
                Ovector = readOvector();
        }
/*
        for(i = dimension - 1; i >= 0; i--) {
                anotherz[i] = x[i] - Ovector[i];
                //printf("%d\n",dimension );
        }
        cudaEventRecord(start);
        result = ackley(anotherz,dimension);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&milliseconds, start, stop);
        printf("CPU running time (Only the calculation not include the inilization) %f ms\n", milliseconds);
*/
        return(result);
}

int main(int argc, char* argv[])
{
        double* X;
        double resultTest;
        unsigned dim = 1000000;
        unsigned run = 1;
        char *p;
        if (argc == 2)
        {
                run = (unsigned)strtol(argv[1], &p, 10);
        }
        X = new double[dim];
        for (unsigned i=0; i<dim; i++) {
                X[i]=0;
        }
        printf("Ackley Function value = %1.20E\n", resultTest = AckleyCompute(X));

/*
    gettimeofday(&start, NULL);
    for (unsigned j=0; j < run; j++){
      if (fp->compute(X) - resultTest > 0.1)
      {
        printf("result not equal to the previous result\n" );
      }
    }
    gettimeofday(&end, NULL);

    seconds  = end.tv_sec  - start.tv_sec;
    useconds = end.tv_usec - start.tv_usec;

    mtime = (((seconds) * 1000 + useconds/1000.0) + 0.5)/1000;

    runTimeVec.push_back(mtime);
    //printf ( "F %d, Running Time = %f s\n\n", fp->getID(), mtime);

    //TODO GPU Computing
    fp->GPUcompute(X,resultTest,run);

    delete fp;

   delete []X;

   // for (unsigned i=0; i<runTimeVec.size(); i++){
   //   printf ( "%f\n", runTimeVec[i] );
   // }
 */
        return 0;
        return 0;
}
