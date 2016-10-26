#include "F3.h"

/**
 * Shifted Ackley's Function
 *
 * as defined in "Benchmark Functions for the CEC'2010 Special Session
 * and Competition on Large-Scale Global Optimization" by Ke Tang,
 * Xiaodong Li, P. N. Suganthan, Zhenyu Yang, and Thomas Weise
 * published as technical report on January 8, 2010 at Nature Inspired
 * Computation and Applications Laboratory (NICAL), School of Computer
 * Science and Technology, University of Science and Technology of China,
 * Hefei, Anhui, China.
 */

F3::F3():Benchmarks(){
  Ovector = NULL;
  minX = -32;
  maxX = 32;
  ID = 3;
  anotherz = new double[dimension];

}

F3::~F3(){
  delete[] Ovector;
  delete[] anotherz;
}

double F3::compute(double*x){
  int    i;
  double result;
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float milliseconds = 0;

  if(Ovector == NULL) {
    // Ovector = createShiftVector(dimension,minX,maxX);
    Ovector = readOvector();
  }
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
  return(result);
}


// ackley function for single group non-separable
double Benchmarks::ackley(double*x,int dim){
  double sum1 = 0.0;
  double sum2 = 0.0;
  double sum;
  int    i;

  // T_{osz}
  transform_osz(x,dim);

  // T_{asy}^{0.2}
  transform_asy(x, 0.2, dim);

  // lambda
  Lambda(x, 10, dim);

  for(i = dim - 1; i >= 0; i--) {
    sum1 += (x[i] * x[i]);
    sum2 += cos(2.0 * PI * x[i]);
  }

  sum = -20.0 * exp(-0.2 * sqrt(sum1 / dim)) - exp(sum2 / dim) + 20.0 + E;
  return(sum);
}

// ackley function for m-group non-separable
double Benchmarks::ackley(double *x, int dim, int k)
{
  double sum1=0.0;
  double sum2=0.0;
  double result=0.0;
  int i;

  for(i=dim/k-1;i>=0;i--)
    {
      sum1+=x[Pvector[dim/k+i]]*x[Pvector[dim/k+i]];
      sum2+=cos(2.0*PI*x[Pvector[dim/k+i]]);
    }

  result=-20.0*exp(-0.2*sqrt(sum1/(dim/k)))-exp(sum2/(dim/k))+20.0+E;

  return(result);
}
