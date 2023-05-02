// Doomsday.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
extern "C" void LoadLongLat(float* lat,float* longitude);
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
extern "C" void suntLong(float* M);
extern "C" void sunRAsc(float* m);
extern "C" bool sunsDeclination(float* l, float* a, float* b);
extern "C" void sunLhourAng(bool sunSet, float* dirRet);




float sunsetSunrise(int dia, int mes, int anho, float lat, float longi, bool sunSet) {
    LoadLongLat(&lat, &longi);
    int n = calcularDiaDelAno(dia, mes, anho);
    float timeVar,M,L= 0.0;
    float tmp,tmp2; //ya ni me acuerdo para que ran estas pero se cae sin estas
    lngHourP(n, &longi, sunSet, &timeVar);
    anomPromSol(&timeVar, &M);
    suntLong(&M);
    L = M;
    sunRAsc(&L);
    if (!sunsDeclination(&L, &tmp, &tmp2)) {
        sunLhourAng(sunSet, &M);
        return M;
    }
    else
    {
        return -1.0;
    }




}

    

int main()
{
    std::cout << "Hello World!\n";
    //llamar sunsetSunrise(...) para algoritmo

}