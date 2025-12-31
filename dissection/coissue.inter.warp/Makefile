all: fma.mad.biwarp fma2.mad.biwarp

fma.mad.biwarp: fma.mad.biwarp.cu
		nvcc fma.mad.biwarp.cu -arch=sm_120 -lcuda -o fma.mad.biwarp.out
		cuobjdump -sass fma.mad.biwarp.out > fma.mad.biwarp.sass

fma2.mad.biwarp: fma2.mad.biwarp.cu
		nvcc fma2.mad.biwarp.cu -arch=sm_120 -lcuda -o fma2.mad.biwarp.out
		cuobjdump -sass fma2.mad.biwarp.out > fma2.mad.biwarp.sass

clean:
	rm -rf *.out *.sass *.ncu-rep
