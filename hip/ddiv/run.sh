# assert input random file exist
# hipcc ./test.ddiv_rn.cpp -o test.ddiv_rn.out;
hipcc ./test.ddiv_rz.cpp -o test.ddiv_rz.out;
hipcc ./test.ddiv_rd.cpp -o test.ddiv_rd.out;
hipcc ./test.ddiv_ru.cpp -o test.ddiv_ru.out;
# ./test.ddiv_rn.out&
./test.ddiv_rz.out&
./test.ddiv_rd.out&
./test.ddiv_ru.out&
