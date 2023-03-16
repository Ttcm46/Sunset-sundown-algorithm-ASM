// Doomsday.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
extern "C" int Adder(int a, int b);
extern "C" void t_fpu(float* x, float *y);
extern "C" int nf1(int m);
extern "C" int nf2(int m);
extern "C" int nf3(int* y);
extern "C" int nfin(int n1, int n2, int n3,int dia);

int enes(int dia, int mes, int anho) {
    int n1 = nf1(mes);
    int n2 = nf2(mes);
    int n3 = nf3(&anho);
    int nf = nfin(n1, n2, n3, dia);
    return nf;
}

int test(int x) {
    return x - 30;
}

int main()
{
    std::cout << "Hello World!\n";
    int y = enes(31, 12, 2001);
    int x = 2;
    //int y = test(x);
}