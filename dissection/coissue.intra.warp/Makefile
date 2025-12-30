all: fma.mad.uniwarp

fma.mad.uniwarp: fma.mad.uniwarp.cu
		nvcc fma.mad.uniwarp.cu -arch=sm_120 -lcuda -o fma.mad.uniwarp.out
		cuobjdump -sass fma.mad.uniwarp.out > fma.mad.uniwarp.sass

clean:
	rm -rf *.out *.sass *.ncu-rep
