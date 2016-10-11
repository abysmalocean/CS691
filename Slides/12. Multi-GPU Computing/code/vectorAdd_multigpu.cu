#include <stdio.h>

__global__ void vectorAdd(float *A, float *B, float *C, int numElements)
{
	int tid = blockDim.x * blockIdx.x + threadIdx.x;

	if (tid < numElements)
		C[tid] = A[tid] + B[tid];
}

int main(int argc, char* argv[])
{
	int numElements = pow(2,20); // 2^20 approximately 1M elements

	// Allocate host memory
	float *h_A, *h_B, *h_C;

	cudaMallocHost(&h_A, numElements * sizeof(float));
	cudaMallocHost(&h_B, numElements * sizeof(float));
	cudaMallocHost(&h_C, numElements * sizeof(float));

	// Initialize the host input vectors
	for (int i = 0; i < numElements; ++i)
	{
		h_A[i] = rand()/(float)RAND_MAX;
		h_B[i] = rand()/(float)RAND_MAX;
	}

	float *d_A1, *d_A2, *d_B1, *d_B2, *d_C1, *d_C2;
	cudaEvent_t start1, stop1, start2, stop2;
	cudaStream_t stream1, stream2;

	float milliseconds1, milliseconds2;

	int threadsPerBlock = 256;
	int blocksPerGrid = (numElements/2 + threadsPerBlock - 1) / threadsPerBlock;

	cudaSetDevice(0);

	cudaMalloc(&d_A1, numElements/2 * sizeof(float));
	cudaMalloc(&d_B1, numElements/2 * sizeof(float));
	cudaMalloc(&d_C1, numElements/2 * sizeof(float));

	cudaStreamCreate(&stream1);
	cudaEventCreate(&start1);
	cudaEventCreate(&stop1);

	cudaSetDevice(1);

	cudaMalloc(&d_A2, numElements/2 * sizeof(float));
	cudaMalloc(&d_B2, numElements/2 * sizeof(float));
	cudaMalloc(&d_C2, numElements/2 * sizeof(float));

	cudaStreamCreate(&stream2);
	cudaEventCreate(&start2);
	cudaEventCreate(&stop2);

	cudaSetDevice(0);

	cudaEventRecord(start1, stream1);

	cudaMemcpyAsync(d_A1, h_A, numElements/2 * sizeof(float), cudaMemcpyHostToDevice, stream1);
	cudaMemcpyAsync(d_B1, h_B, numElements/2 * sizeof(float), cudaMemcpyHostToDevice, stream1);

	vectorAdd<<<blocksPerGrid, threadsPerBlock, 0, stream1>>>(d_A1, d_B1, d_C1, numElements/2);

	cudaMemcpyAsync(h_C, d_C1, numElements/2 * sizeof(float), cudaMemcpyDeviceToHost, stream1);

	cudaEventRecord(stop1, stream1);

	cudaSetDevice(1);

	cudaEventRecord(start2, stream2);

	cudaMemcpyAsync(d_A2, &h_A[numElements/2], numElements/2 * sizeof(float), cudaMemcpyHostToDevice, stream2);
	cudaMemcpyAsync(d_B2, &h_B[numElements/2], numElements/2 * sizeof(float), cudaMemcpyHostToDevice, stream2);

	vectorAdd<<<blocksPerGrid, threadsPerBlock, 0, stream2>>>(d_A2, d_B2, d_C2, numElements/2);

	cudaMemcpyAsync(&h_C[numElements/2], d_C2, numElements/2 * sizeof(float), cudaMemcpyDeviceToHost, stream2);

	cudaEventRecord(stop2, stream2);

	cudaSetDevice(0);
	cudaEventSynchronize(stop1);
	//cudaStreamSynchronize(stream1);
	cudaSetDevice(1);
	cudaEventSynchronize(stop2);
	//cudaStreamSynchronize(stream2);

	cudaEventElapsedTime(&milliseconds1, start1, stop1);
	cudaEventElapsedTime(&milliseconds2, start2, stop2);

	printf("GPU %d time %f ms\n", 0, milliseconds1);
	printf("GPU %d time %f ms\n", 1, milliseconds2);

	cudaError_t cudaError = cudaGetLastError();

	if(cudaError != cudaSuccess)
	{
		fprintf(stderr, "cudaGetLastError() returned %d: %s\n", cudaError, cudaGetErrorString(cudaError));
		exit(EXIT_FAILURE);
	}

	// Verify that the result vector is correct
	for (int i = 0; i < numElements; i++)
		if (fabs(h_A[i] + h_B[i] - h_C[i]) > 1e-5)
		{
			fprintf(stderr, "Result verification failed at element %d!\n", i);
			exit(EXIT_FAILURE);
		}

	printf("Sum of the vectors was OK\n");

	cudaSetDevice(0);
	cudaFree(d_A1);
	cudaFree(d_B1);
	cudaFree(d_C1);

	cudaSetDevice(1);
	cudaFree(d_A2);
	cudaFree(d_B2);
	cudaFree(d_C2);

	// Free host memory
	cudaFreeHost(h_A);
	cudaFreeHost(h_B);
	cudaFreeHost(h_C);

	return 0;
}

