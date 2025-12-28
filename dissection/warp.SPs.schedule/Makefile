all:  exe sass

exe: warp_scheduler.cu
	nvcc -arch=sm_120  warp_scheduler.cu  -o warp_scheduler

sass: warp_scheduler.cu
	nvcc -cubin -arch=sm_120  warp_scheduler.cu  -o warp_scheduler.cubin
	nvdisasm -c warp_scheduler.cubin > warp_scheduler.sass

clean:
	rm -rf warp_scheduler.cu warp_scheduler.cubin warp_scheduler.sass
