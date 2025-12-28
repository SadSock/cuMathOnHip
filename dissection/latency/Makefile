all: fma_uniwarp fma_quadwarp fadd_quadwarp fmac_uniwarp

fma_uniwarp: fma.uniwarp.cu
		nvcc fma.uniwarp.cu -lcuda -o fma.uniwarp.out
		cuobjdump -sass fma.uniwarp.out > fma.uniwarp.sass

fmac_uniwarp: fmac.uniwarp.cu
		nvcc fmac.uniwarp.cu -lcuda -o fmac.uniwarp.out
		cuobjdump -sass fmac.uniwarp.out > fmac.uniwarp.sass

fma_quadwarp: fma.quadwarp.cu
		nvcc fma.quadwarp.cu -lcuda -o fma.quadwarp.out
		cuobjdump -sass fma.quadwarp.out > fma.quadwarp.sass

fadd_quadwarp: fadd.quadwarp.cu
		nvcc fadd.quadwarp.cu -lcuda -o fadd.quadwarp.out
		cuobjdump -sass fadd.quadwarp.out > fadd.quadwarp.sass
clean:
	rm -rf *.out *.sass *.ncu-rep
