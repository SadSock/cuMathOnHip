.PHONY: all

all: iadd3 add.add add.mul add.fmul add.fadd imad fma

iadd3:
	nvcc iadd3.cu -lcuda -o iadd3
	ptxas iadd3.ptx -arch=sm_120 -o iadd3.cubin
	cuobjdump --dump-sass iadd3.cubin > iadd3.sass

add.add:
	nvcc add.add.cu -lcuda -o add.add
	ptxas add.add.ptx -arch=sm_120 -o add.add.cubin
	cuobjdump --dump-sass add.add.cubin > add.add.sass

add.mul:
	nvcc add.mul.cu -lcuda -o add.mul
	ptxas add.mul.ptx -arch=sm_120 -o add.mul.cubin
	cuobjdump --dump-sass add.mul.cubin > add.mul.sass

add.fmul:
	nvcc add.fmul.cu -lcuda -o add.fmul
	ptxas add.fmul.ptx -arch=sm_120 -o add.fmul.cubin
	cuobjdump --dump-sass add.fmul.cubin > add.fmul.sass

add.fadd: add.fadd.cu
		nvcc add.fadd.cu -lcuda -o add.fadd
		ptxas add.fadd.ptx -arch=sm_120 -o add.fadd.cubin
		cuobjdump --dump-sass add.fadd.cubin > add.fadd.sass

imad:
		nvcc imad.cu -lcuda -o imad
		ptxas imad.ptx -arch=sm_120 -o imad.cubin
		cuobjdump --dump-sass imad.cubin > imad.sass

fma: fma.cu
		nvcc fma.cu -lcuda -o fma
		ptxas fma.ptx -arch=sm_120 -o fma.cubin
		cuobjdump --dump-sass fma.cubin > fma.sass

clean:
		rm -rf *.cubin *.sass add.add add.mul add.fmul add.fadd imad fma iadd2 iadd3
