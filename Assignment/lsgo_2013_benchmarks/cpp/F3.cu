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

/*******************************************************************************
//************Cuda kernel Function for Midterm  test****************************
//************Author Liang Xu***************************************************
//************Dtate 10.26 2016**************************************************
//******************************************************************************
********************************************************************************/
__global__ void testKernel(double* z, int dim,double* d_sum1, double* d_sum2)
{
  printf("Liang XU\n");
/*******************************************************************************
//************ First need to calcuate the X[i]**********************************
********************************************************************************/
/*
    int tid = ( blockDim.x * blockIdx.x ) + threadIdx.x;
    __shared__ double sharedSum1Array[1024]; // size of the share memory is the size of block
    __shared__ double sharedSum2Array[1024]; // size of the share memory is the size of block
    double hat_x;
    double c1;
    double c2;
    int sign;
    double beta = 0.2;
    double alpha = 10;
    double x;
    double sum1;
    double sum2;

    x = z[tid];
    if (x == 0) {
      hat_x = 0;
    }else{hat_x = log(abs(x));}

    if (x>0)
    {
        c1 = 10;
        c2 = 7.9;
        sign = 1;
    }
    else
    {
      c1 = 5.5;
      c2 = 3.1;
      if(x != 0)
      {
        sign  = -1 ;
      }else{sign = 0;}
    }
    x = sign * exp( hat_x + 0.049 * ( sin( c1 * hat_x ) + sin( c2* hat_x )  ) ) ;

    if(x > 0)
    {
      x = pow(x, 1 + beta * tid/((double) (dim-1)) * sqrt(x) );
    }
    x = x * pow(alpha, 0.5 * tid/((double) (dim-1)) );
    sum1 = x * x;
    sum2 = cos(2.0 * PI * x);
*/
    /*******************************************************************************
    //************Secod step is use reduction method calculate the sum**************
    ********************************************************************************/
    // First setp to save the sum1 and sum2 local data to the shard memory
    /*
    sharedSum1Array[threadIdx.x] = (tid < dim) ? sum1 : 0;
    sharedSum2Array[threadIdx.x] = (tid < dim) ? sum2 : 0;
    __syncthreads();
    //Step 2, reduction
    for (int s = blockDim.x/2; s > 0 ; s >>= 1) {
      if(threadIdx.x < s)
        sharedSum1Array[threadIdx.x] += sharedSum1Array[threadIdx.x + s];
        sharedSum2Array[threadIdx.x] += sharedSum2Array[threadIdx.x + s];
        __syncthreads();
    }
    //step 3, annd to the final output
    if(threadIdx.x == 0)
    {
      //atomicAdd((float *)d_sum1,(float)sharedSum1Array[0]);
      //atomicAdd((float *)d_sum2,(float)sharedSum2Array[0]);
      // for Cuda 8.0 it support double atomic add
      atomicAdd(d_sum1,sharedSum1Array[0]);
      atomicAdd(d_sum2,sharedSum2Array[0]);
    }


    */
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

//TODO GPU computing
//fp->GPUcompute(X,resultTest,run);
double F3::GPUcompute(double*x,double resultTest, unsigned run){
  int    i;
  double result = 0;
  double sum1 ;
  double sum2 ;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  float milliseconds = 0;

  printf("\n*****************GPU Computing Result***************************\n\n");
  if(Ovector == NULL) {
    // Ovector = createShiftVector(dimension,minX,maxX);
    Ovector = readOvector();
  }
  for(i = dimension - 1; i >= 0; i--) {
    anotherz[i] = x[i] - Ovector[i];
  }
  // inilize the CUDA

  int threadsPerBlockDim = 512;
  int gridDimSize = (dimension + threadsPerBlockDim - 1) / threadsPerBlockDim;
  printf("GPU is running on Blocksize[%d],gridSize[%d]\n",threadsPerBlockDim,gridDimSize );
  // allocate the memory to device
  double* d_x , *d_sum1 , *d_sum2;
  cudaMalloc(&d_x,dimension * sizeof(double));
  cudaMalloc(&d_sum1,sizeof(double));
  cudaMalloc(&d_sum2,sizeof(double));
  //Event start
  cudaEventRecord(start);
  cudaMemcpy(d_x, x, dimension * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemset(d_sum1, 0.000 , sizeof(double));
  cudaMemset(d_sum2, 0.000 , sizeof(double));

  testKernel<<<gridDimSize, threadsPerBlockDim>>>(d_x,dimension,d_sum1,d_sum2);
  //result = ackley(anotherz,dimension);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  //printf("Liang Xu\n" );
  //cudaMemcpy(&sum1, d_sum1, sizeof(double), cudaMemcpyDeviceToHost);
  //cudaMemcpy(&sum2, d_sum2, sizeof(double), cudaMemcpyDeviceToHost);
  cudaError_t cudaError = cudaGetLastError();
    if(cudaError != cudaSuccess)
    {
        fprintf(stderr, "cudaGetLastError() returned %d: %s\n", cudaError, cudaGetErrorString(cudaError));
        exit(EXIT_FAILURE);
    }

  result = sum1 + sum2;
  printf("Liang Xu\n" );
  if (abs(result - resultTest) > 0.1)
  {
    printf("Result in GPU is %f\n",result );
    printf("result not equal to the previous result in GPU computing\n" );
  }else{printf("GUP return the correct result\n");}
	cudaEventElapsedTime(&milliseconds, start, stop);
	printf("GPU running time is %f ms\n", milliseconds);

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
