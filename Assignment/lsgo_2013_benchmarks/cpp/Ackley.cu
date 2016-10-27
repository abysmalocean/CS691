#include "Benchmarks.h"
extern "C"
double GPUcompute(double* x,double resultTest, unsigned run);

/*******************************************************************************
   //************Cuda kernel Function for Midterm  test****************************
   //************Author Liang Xu***************************************************
   //************Dtate 10.26 2016**************************************************
   //******************************************************************************
 ********************************************************************************/

__global__ void ackleyKernel(double* z, int dim,double * d_sum1, double * d_sum2,int stream, int numberElementsPerStream ){
        //printf("Liang XU in kernel\n");
        /*******************************************************************************
           //************ First need to calcuate the X[i]**********************************
         ********************************************************************************/

        int tid = ( blockDim.x * blockIdx.x ) + threadIdx.x;
        __shared__ double sharedSum1Array[512]; // size of the share memory is the size of block
        __shared__ double sharedSum2Array[512]; // size of the share memory is the size of block
        dim = numberElementsPerStream;
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
        //x =1;
        if (x == 0) {
                hat_x = 0;
        }else{hat_x = log(abs(x)); }

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
                        sign  = -1;
                }else{sign = 0; }
        }
        x = sign * exp( hat_x + 0.049 * ( sin( c1 * hat_x ) + sin( c2* hat_x )  ) );

        if(x > 0)
        {
                x = pow(x, 1 + beta * tid/((double) (dim-1)) * sqrt(x) );
        }
        x = x * pow(alpha, 0.5 * tid/((double) (dim-1)) );
        sum1 = x * x;
        sum2 = cos(2.0 * PI * x);
        //printf("block dim is [%d]threadID is [%d] sum1 is [%f] sum2 is [%f]\n",blockDim.x,tid,sum1,sum2 );
        //printf("block dim is [%d] threadIdx[%d]\n",blockDim.x,threadIdx.x );
        /*******************************************************************************
           //************Secod step is use reduction method calculate the sum**************
         ********************************************************************************/
        // First setp to save the sum1 and sum2 local data to the shard memory

        sharedSum1Array[threadIdx.x] = (tid < dim) ? sum1 : 0;
        sharedSum2Array[threadIdx.x] = (tid < dim) ? sum2 : 0;
        __syncthreads();
        //printf("Liang\n" );
        //Step 2, reduction
        for (int s = (blockDim.x)/2; s > 0; s >>= 1) {
                //printf("s = [%d]\n",s );
                //printf("threadIdx.x  = [%d]\n",threadIdx.x  );

                if(threadIdx.x < s)
                {
                        //printf("threadIdx.x + s = [%d]\n",threadIdx.x + s );
                        sharedSum1Array[threadIdx.x] += sharedSum1Array[threadIdx.x + s];
                        sharedSum2Array[threadIdx.x] += sharedSum2Array[threadIdx.x + s];
                }
                //printf("Liang\n" );
                __syncthreads();
        }
        //step 3, annd to the final output
        if(threadIdx.x == 0)
        {
                //atomicAdd((float *)d_sum1,(float)sharedSum1Array[0]);
                //atomicAdd((float *)d_sum2,(float)sharedSum2Array[0]);
                // for Cuda 8.0 it support double atomic add
                //atomicAdd(d_sum1,sharedSum1Array[0]);
                //atomicAdd(d_sum2,sharedSum2Array[0]);
                //printf(" sum1[%f]--> [%f] sum2 [%f]-->[%f]\n", *d_sum1,*d_sum1-sharedSum1Array[0],*d_sum2 ,*d_sum2-sharedSum2Array[0]);
                d_sum1[blockIdx.x] = sharedSum1Array[0];
                d_sum2[blockIdx.x] = sharedSum2Array[0];
        }
}



void cudaErrorCheck(cudaError_t cudaError)
{
        if(cudaError != cudaSuccess)
        {
                fprintf(stderr, "cudaGetError returned %d: %s\n", cudaError, cudaGetErrorString(cudaError));
                //exit(EXIT_FAILURE);
        }else
        {
                printf("--> No error PASS\n");
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

        int numStreams = 1;
        cudaStream_t *streams = (cudaStream_t*) malloc (numStreams * sizeof(cudaStream_t));
        for (int i = 0; i < numStreams; i++)
                cudaStreamCreate(&streams[i]);

        //printf("\n*****************GPU Computing Result***************************\n\n");

        // inilize the CUDA
        int threadsPerBlockDim = 512;
        int numberElementsPerStream = (dimension + numStreams - 1) / numStreams;
        int gridDimSize_orig = (dimension + threadsPerBlockDim - 1) / threadsPerBlockDim;
        int gridDimSize = (numberElementsPerStream + threadsPerBlockDim - 1) / threadsPerBlockDim;

        dim3 blockSize(threadsPerBlockDim);
        dim3 gridSize (gridDimSize);


        //printf("GPU is running on Blocksize[%d],gridSize[%d]\n",threadsPerBlockDim,gridDimSize );
        // allocate the memory to device
        double *d_x;
        double *d_sum1, *d_sum2;
        double *h_sum1, *h_sum2;
        h_sum1 = (double *)malloc(gridDimSize_orig * sizeof(double));
        h_sum2 = (double *)malloc(gridDimSize_orig * sizeof(double));

        cudaError =  cudaMalloc(&d_x,dimension * sizeof(double));
        //printf("cudaMalloc(&d_x,dimension * sizeof(double));                    "); cudaErrorCheck(cudaError);
        cudaError =  cudaMalloc(&d_sum1,gridDimSize_orig*sizeof(double));
        //printf("cudaMalloc(&d_sum1,sizeof(double));                             "); cudaErrorCheck(cudaError);
        cudaError =  cudaMalloc(&d_sum2,gridDimSize_orig*sizeof(double));
        //printf("cudaMalloc(&d_sum2,sizeof(double));                             "); cudaErrorCheck(cudaError);


        //Event start
        cudaEventRecord(start);
        for (int i = 0; i < numStreams; i++)
        {

                cudaError =  cudaMemcpyAsync(&d_x[i*numberElementsPerStream], &anotherz[i*numberElementsPerStream], numberElementsPerStream * sizeof(double), cudaMemcpyHostToDevice,streams[i]);
                //printf(" cudaMemcpy(d_x, anotherz, dimension * sizeof(double), cudaMemcpyHostToDevice);"); cudaErrorCheck(cudaError);
                //cudaError =  cudaMemset(d_sum1, 0.000, sizeof(float));
                //printf("cudaMemset(d_sum1, 0.000, sizeof(double));"); cudaErrorCheck(cudaError);
                //cudaError =  cudaMemset(d_sum2, 0.000, sizeof(float));
                //printf("cudaMemset(d_sum2, 0.000, sizeof(double));"); cudaErrorCheck(cudaError);

                ackleyKernel<<<gridSize, blockSize, 0, streams[i]>>>(d_x,dimension,d_sum1,d_sum2,i,numberElementsPerStream);

                //result = ackley(anotherz,dimension);

                cudaError = cudaGetLastError();
                //printf("Kernek Function                                                 ");cudaErrorCheck(cudaError);
                cudaError = cudaMemcpyAsync(&h_sum1[i*gridDimSize], d_sum1, gridDimSize*sizeof(double), cudaMemcpyDeviceToHost,streams[i]);
                //printf("cudaMemcpy(&sum1, d_sum1, sizeof(float), cudaMemcpyDeviceToHost)"); cudaErrorCheck(cudaError);
                cudaError = cudaMemcpyAsync(&h_sum2[i*gridDimSize], d_sum2, gridDimSize*sizeof(double), cudaMemcpyDeviceToHost,streams[i]);
                //printf("cudaMemcpy(&sum2, d_sum2, sizeof(float), cudaMemcpyDeviceToHost)"); cudaErrorCheck(cudaError);
                //printf(" cpoy from kernel is %f\n",sum1 );
        }

        for(int i = 0; i < gridDimSize; i++)
        {
                sum1 = sum1 + h_sum1[i];
                sum2 = sum2 + h_sum2[i];
        }

        result = -20.0 * exp(-0.2 * sqrt(sum1/dimension)) - exp(sum2/dimension) + 20.0 + E;

        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        // Testing the result
        if (abs(result - resultTest) > 0.00001)
        {
                printf("Result in GPU is %f\n",result );
                printf("result not equal to the previous result in GPU computing\n" );
        }else{printf("GUP return the correct result\n"); }

        printf("GUP result is = %1.20E\n", result );
        cudaEventElapsedTime(&milliseconds, start, stop);
        printf("========================================> GPU running time is %f ms\n", milliseconds);

        cudaFree(d_x);
        cudaFree(d_sum1);
        cudaFree(d_sum2);
        free(h_sum1);
        free(h_sum2);
        return(result);
}
