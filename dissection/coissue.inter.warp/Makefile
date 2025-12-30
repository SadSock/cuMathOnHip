all: fma.mad.biwarp fma.biwarp mad.biwarp

fma.mad.biwarp: fma.mad.biwarp.cu
		nvcc fma.mad.biwarp.cu -arch=sm_120 -lcuda -o fma.mad.biwarp.out
		cuobjdump -sass fma.mad.biwarp.out > fma.mad.biwarp.sass

fma.biwarp: fma.biwarp.cu
		nvcc fma.biwarp.cu -arch=sm_120 -lcuda -o fma.biwarp.out
		cuobjdump -sass fma.biwarp.out > fma.biwarp.sass

mad.biwarp: mad.biwarp.cu
		nvcc mad.biwarp.cu -arch=sm_120 -lcuda -o mad.biwarp.out
		cuobjdump -sass mad.biwarp.out > mad.biwarp.sass

clean:
	rm -rf *.out *.sass *.ncu-rep
