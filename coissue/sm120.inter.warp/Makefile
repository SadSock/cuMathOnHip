all: fma

fma: fma.cu
		nvcc fma.cu -lcuda -o fma.out
		cuobjdump -sass fma.out > fma.sass

clean:
	rm -rf *.out *.sass
