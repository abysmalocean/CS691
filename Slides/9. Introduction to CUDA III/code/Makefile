todo: matrixMul matrixTranspose add_array
matrixMul: matrixMul.cu
	nvcc -Xptxas="-v" -O3 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 matrixMul.cu -o matrixMul
matrixTranspose: matrixTranspose.cu
	nvcc -Xptxas="-v" -O3 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 matrixTranspose.cu -o matrixTranspose
add_array: add_array.cu
	nvcc -Xptxas="-v" -O3 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 add_array.cu -o add_array
clean:
	rm matrixMul matrixTranspose add_array
