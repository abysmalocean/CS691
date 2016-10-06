todo: vectorAdd_nostreams vectorAdd_streams
vectorAdd_nostreams: vectorAdd_nostreams.cu
	nvcc -O3 -gencode arch=compute_52,code=sm_52 vectorAdd_nostreams.cu -o vectorAdd_nostreams
vectorAdd_streams: vectorAdd_streams.cu
	nvcc -O3 -gencode arch=compute_52,code=sm_52 vectorAdd_streams.cu -o vectorAdd_streams
clean:
	rm vectorAdd_nostreams vectorAdd_streams
