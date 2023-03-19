// Doomsday.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
extern "C" void t_fpu(float* x, float *y);
extern "C" int nf1(int m);
extern "C" int nf2(int m);
extern "C" int nf3(int* y);
extern "C" int nfin(int n1, int n2, int n3,int dia);
//union de todas las funciones para c
int calcularDiaDelAno(int dia, int mes, int anho) {
    int n1 = nf1(mes);
    int n2 = nf2(mes);
    int n3 = nf3(&anho);
    int nf = nfin(n1, n2, n3, dia);
    return nf;
}

// manda 1 true para hora de salida de sol, 0 para puesta
extern "C" void lngHourP(int n, float* longi, bool sunSet, float* time);

void test(float x, float y) {
    int z = 22;
    x = float(z);
}

int main()
{
    std::cout << "Hello World!\n";
    float a = 5.6;
    float b = 6.5;

    test(a,b);
    //int y = test(x);
}