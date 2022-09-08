# assert input random file exist
nvcc ./debug_ddiv_rn.cu -arch=sm_75 -o debug_ddiv_rn.out;
nvcc ./debug_ddiv_rz.cu -arch=sm_75 -o debug_ddiv_rz.out;
nvcc ./debug_ddiv_rd.cu -arch=sm_75 -o debug_ddiv_rd.out;
nvcc ./debug_ddiv_ru.cu -arch=sm_75 -o debug_ddiv_ru.out;
./debug_ddiv_rn.out&
./debug_ddiv_rz.out&
./debug_ddiv_rd.out&
./debug_ddiv_rn.out&