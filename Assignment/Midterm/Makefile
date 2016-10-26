todo: Ackley
Ackley: Ackley.cu
	nvcc -O3 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 Ackley.cu -o Ackley
clean:
	rm Ackley
