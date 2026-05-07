NVCC ?= nvcc
ARCH ?= sm_120
TARGET := cvt.fp4tofp8.out

.PHONY: all run clean

all: $(TARGET)

$(TARGET): cvt.fp4tofp8.cu
	$(NVCC) -std=c++17 -arch=$(ARCH) $< -o $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
