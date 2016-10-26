#include "Benchmarks.h"

extern "C"
double GPUcompute(double* x,double resultTest, unsigned run);

/*******************************************************************************
   //************Cuda kernel Function for Midterm  test****************************
   //************Author Liang Xu***************************************************
   //************Dtate 10.26 2016**************************************************
   //******************************************************************************
 ********************************************************************************/
 __global__ void ackley_kernel(double *d_x, double *sum1, double *sum2, int dim){
  //int BLOCK_SIZE = 512;
 	__shared__ double sm[512];
 	__shared__ double sm_cos[512];

 	int global_tid = blockDim.x * blockIdx.x + threadIdx.x;
 	int tid = threadIdx.x;

 	sm[tid] = d_x[global_tid];

 	// initialization of sign, hat, c1, c2
 	int sign;
 	if( sm[tid] == 0 )
 		sign = 0;
 	else
 		sign = sm[tid]>0 ? 1:-1;

 	double hat;
 	if(sm[tid] == 0)
 		hat = 0;
 	else
 		hat = log(abs(sm[tid]));

 	double c1;
 	if(sm[tid]>0)
 		c1 = 10;
 	else
 		c1 = 5.5;

 	double c2;
 	if( sm[tid]>0 )
 		c2 = 7.9;
 	else
 		c2=3.1;

 	// transform osz
 	sm[tid] = sign * exp(hat + 0.049 * (sin(c1*hat) + sin(c2*hat)));

 	// transform asy
 	if(sm[tid]>0)
 		sm[tid] = pow(sm[tid], 1+0.2* global_tid/(double)(dim-1) * sqrt(sm[tid]));

 	// lambda
 	sm[tid] = sm[tid] * pow( 10.0, 0.5* global_tid/((double)(dim-1)) );

 	// cos(2.0 * pi * x[i])
 	sm_cos[tid] = cos(2.0 * PI * sm[tid]);

 	// x square
 	sm[tid] = sm[tid]*sm[tid];

 	__syncthreads();

 	// reduction
 	for( int i=512/2; i>0; i>>=1 ){
 		if(tid<i){
 			sm[tid] += sm[tid+i];
 			sm_cos[tid] += sm_cos[tid+i];
 		}
 	}
 	__syncthreads();

 	// get the value from first element of shared memory
 	if(tid == 0){
 		sum1[blockIdx.x] = sm[tid];
 		sum2[blockIdx.x] = sm_cos[tid];
 	}
 }

__global__ void ackleyKernel(double* z, int dim,double* d_sum1, double* d_sum2){
  printf("Liang XU in kernel\n");
/*******************************************************************************
   //************ First need to calcuate the X[i]**********************************
 ********************************************************************************/

    int tid = ( blockDim.x * blockIdx.x ) + threadIdx.x;
    __shared__ double sharedSum1Array[1024]; // size of the share memory is the size of block
    __shared__ double sharedSum2Array[1024]; // size of the share memory is the size of block
/*
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

void cudaErrorCheck(cudaError_t cudaError)
{
        if(cudaError != cudaSuccess)
        {
                fprintf(stderr, "cudaGetError returned %d: %s\n", cudaError, cudaGetErrorString(cudaError));
                //exit(EXIT_FAILURE);
        }else
        {
                printf("--> PASS\n");
        }

}


//TODO GPU computing
//fp->GPUcompute(X,resultTest,run);
double GPUcompute(double* anotherz,double resultTest, unsigned run){

        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        float milliseconds = 0;
        cudaError_t cudaError;
        double sum1;
        double sum2;
        double result = 0;
        int dimension = 1000000;

        printf("\n*****************GPU Computing Result***************************\n\n");

        // inilize the CUDA
        int threadsPerBlockDim = 512;
        int gridDimSize = (dimension + threadsPerBlockDim - 1) / threadsPerBlockDim;

        dim3 blockSize(threadsPerBlockDim);
        dim3 gridSize (gridDimSize);


        printf("GPU is running on Blocksize[%d],gridSize[%d]\n",threadsPerBlockDim,gridDimSize );
        // allocate the memory to device
        double *d_x, *d_sum1, *d_sum2;

        cudaError =  cudaMalloc(&d_x,dimension * sizeof(double));
        printf("cudaMalloc(&d_x,dimension * sizeof(double));"); cudaErrorCheck(cudaError);
        cudaError =  cudaMalloc(&d_sum1,sizeof(double));
        printf("cudaMalloc(&d_sum1,sizeof(double));"); cudaErrorCheck(cudaError);
        cudaError =  cudaMalloc(&d_sum2,sizeof(double));
        printf("cudaMalloc(&d_sum2,sizeof(double));"); cudaErrorCheck(cudaError);

        //Event start
        cudaEventRecord(start);
        cudaError =  cudaMemcpy(d_x, anotherz, dimension * sizeof(double), cudaMemcpyHostToDevice);
        printf(" cudaMemcpy(d_x, anotherz, dimension * sizeof(double), cudaMemcpyHostToDevice);"); cudaErrorCheck(cudaError);
        cudaError =  cudaMemset(d_sum1, 0.000, sizeof(double));
        printf("cudaMemset(d_sum1, 0.000, sizeof(double));"); cudaErrorCheck(cudaError);
        cudaError =  cudaMemset(d_sum2, 0.000, sizeof(double));
        printf("cudaMemset(d_sum2, 0.000, sizeof(double));"); cudaErrorCheck(cudaError);

        //ackleyKernel<<<gridSize, blockSize>>>(d_x,dimension,d_sum1,d_sum2);
        //ackleyKernel<<<gridSize, blockSize>>>();

        cudaError = cudaGetLastError();cudaErrorCheck(cudaError);
        ackley_kernel<<< gridSize, blockSize >>>(d_x, d_sum1, d_sum2, dimension);
        cudaError = cudaGetLastError();cudaErrorCheck(cudaError);
        //result = ackley(anotherz,dimension);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        //printf("Liang Xu\n" );
        cudaMemcpy(&sum1, d_sum1, sizeof(double), cudaMemcpyDeviceToHost);
        cudaMemcpy(&sum2, d_sum2, sizeof(double), cudaMemcpyDeviceToHost);


        result = sum1 + sum2;
        printf("Liang Xu\n" );
        if (abs(result - resultTest) > 0.1)
        {
                printf("Result in GPU is %f\n",result );
                printf("result not equal to the previous result in GPU computing\n" );
        }else{printf("GUP return the correct result\n"); }
        cudaEventElapsedTime(&milliseconds, start, stop);
        printf("GPU running time is %f ms\n", milliseconds);
        return(result);
}
