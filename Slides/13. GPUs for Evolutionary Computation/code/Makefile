todo: randomgenerator 
randomgenerator: randomgenerator.cu
	nvcc -O3 -gencode arch=compute_52,code=sm_52 randomgenerator.cu -o randomgenerator -lcurand
clean:
	rm randomgenerator 
