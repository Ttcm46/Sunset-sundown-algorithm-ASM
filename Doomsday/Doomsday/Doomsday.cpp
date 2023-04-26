// Doomsday.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
extern "C" void t_fpu(float* x);
extern "C" int nf1(int m);
extern "C" int nf2(int m);
extern "C" int nf3(int* y);
extern "C" int nfin(int n1, int n2, int n3,int dia);
//union de todas las funciones para calc dia de anho
int calcularDiaDelAno(int dia, int mes, int anho) {
    int n1 = nf1(mes);
    int n2 = nf2(mes);
    int n3 = nf3(&anho);
    int nf = nfin(n1, n2, n3, dia);
    return nf;
}

// manda 1 true para hora de salida de sol, 0 para puesta
extern "C" void lngHourP(int n, float* longi, bool sunSet, float* time);
//calcula la anomalia promedio del sol
extern "C" void anomPromSol(float* entrada, float* salida);
extern "C" void suntLong(float* M,float * salid);
extern "C" void sunRAsc(float* m,float *RA);





void sunsetSunrise(int dia, int mes, int anho, float lat, float longi, int zenith, bool sunSet) {
    int n = calcularDiaDelAno(dia, mes, anho);


}

void test(float lngHour, float N) {
    float t =sin(N);
    float z= 0.9856;
    float a = 3.289;
}
    

int main()
{
    std::cout << "Hello World!\n";
    float a = 1.0;
    float* b = &a;
    for (int i = 0; i < 100; i++)
    {
        t_fpu(&a);
        sunRAsc(&a,&a);
        std::cout << a<<"\n";
        a = a + 1;
    }

    //int y = test(x);
}