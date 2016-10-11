todo: vectorAdd_multigpu 
vectorAdd_multigpu: vectorAdd_multigpu.cu
	nvcc -O3 -gencode arch=compute_52,code=sm_52 vectorAdd_multigpu.cu -o vectorAdd_multigpu
clean:
	rm vectorAdd_multigpu 
