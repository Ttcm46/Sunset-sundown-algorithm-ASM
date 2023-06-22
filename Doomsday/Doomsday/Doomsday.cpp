// Doomsday.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <stdio.h>
#include <string.h>
#include <iostream>
#include <math.h>
#include <windows.h>
#include <stdlib.h>
#include <cstdlib>
#include <time.h>
#include <sstream>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_native_dialog.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_audio.h>
#include <allegro5/allegro_acodec.h>
#include <fstream>
//using namespace std;
/*
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
*/


extern "C" float sunRS(float lat, float lon, float zen, int dia, int mes, int anho, bool sunset);

    

int main()
{
    //iniciar allegro


    ALLEGRO_DISPLAY* display;
    ALLEGRO_BITMAP* background;
    ALLEGRO_EVENT_QUEUE* cola_eventos;
    background = NULL;
    if (!al_init()) {
        al_show_native_message_box(NULL, "Ventana Emergente", "Error", "No se puede inicializar Allegro", NULL, NULL);
        return -1;
    }
    al_init_font_addon();
    al_init_ttf_addon();
    al_init_image_addon();
    al_init_primitives_addon();
    al_install_keyboard();
    al_install_mouse();

    int e= 0;
    ALLEGRO_MONITOR_INFO monitor;
    al_get_monitor_info(0, &monitor);
    const int RX = monitor.x2 - monitor.x1;
    const int RY = monitor.y2 - monitor.y1;


    ALLEGRO_TIMER* timer = al_create_timer(1.0 / 20);
    display = al_create_display(1200, 800);
    if (!display) {
        al_show_native_message_box(display, "test", "Si vez esto, algo muy malo ocurrio", "Display window", "Acepto", NULL);
    }
    /*
    background = al_load_bitmap("Fondo.png");
    if (!background)
    {
        al_show_native_message_box(display, "Error", "Imagen no cargada", "La imagen no se pudo cargar", "Acepto", NULL);
        return -1;
    }
    */
    ALLEGRO_FONT* Fuente = al_load_font("C:/Users/ttc46/OneDrive/Documentos/ITCR/Sem 3/Arky/Doomsday/Doomsday/SuperMario256.ttf", 40, NULL);
    if (!Fuente) {
       // al_show_native_message_box(display, "Error", "Fuente no cargada", "La fuente no se pudo cargar", "Acepto", NULL);
        //return -1;
    }


    background = al_load_bitmap("C:/Users/ttc46/OneDrive/Documentos/ITCR/Sem 3/Arky/Doomsday/Doomsday/Mapita.png");
    cola_eventos = al_create_event_queue();
    al_register_event_source(cola_eventos, al_get_timer_event_source(timer));
    al_register_event_source(cola_eventos, al_get_display_event_source(display));
    al_register_event_source(cola_eventos, al_get_keyboard_event_source());
    al_register_event_source(cola_eventos, al_get_mouse_event_source());

    al_start_timer(timer);


    if (!background)
    {
        al_show_native_message_box(display, "Error", "Imagen no cargada", "La imagen no se pudo cargar", "Acepto", NULL);
        return -1;
    }
    int mousex = 0;
    int mousey = 0;
    char formateado[] = { 0,0,':',0,0,32, 'A','M',0};
    bool sunset = true;
    al_draw_bitmap(background, 0, 0, 0);
    al_flip_display();
    while (true) {
        ALLEGRO_EVENT eventos;
        al_wait_for_event(cola_eventos, &eventos);
        if (eventos.type == ALLEGRO_EVENT_MOUSE_AXES)
        {
            mousex = eventos.mouse.x;
            mousey = eventos.mouse.y;
        }
        if (eventos.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP) {
            //std::cout << ((mousex*360)/1200)-180 << "  " << (((mousey*180)/800)-90)*-1 << std::endl;
            float a = sunRS(static_cast<float>((mousex * 360) / 1200) - 180, static_cast<float>(((mousey * 180) / 800) - 90) * -1, 90, 21, 6, 2023, sunset);
            int h = round(floor(a));
            int  m = ((a-h)*60)/1;
            formateado[1] = h % 10 + 0x30; h = h / 10;
            formateado[0] = h % 10 + 0x30;
            formateado[4] = m % 10 + 0x30; m = m / 10;
            formateado[3] = m % 10 + 0x30;

            (sunset) ? (formateado[6] = 'P') : (formateado[6] = 'A');
            (sunset) ? (formateado[7] = 'M') : (formateado[7] = 'M');


            al_show_native_message_box(display, "",  + (sunset) ? (" Hora de Puesta") : ("Hora de Salida"), formateado, "Acepto", NULL);
        }
        if (eventos.type == ALLEGRO_EVENT_KEY_DOWN) {
            switch (eventos.keyboard.keycode)
            {
            case ALLEGRO_KEY_S:
                sunset = !sunset;
                break;
            case ALLEGRO_KEY_ESCAPE:
                return 0;
                break;
            default:
                break;
            }
        }
        al_draw_bitmap(background, 0, 0, 0);
        al_draw_textf(Fuente, al_map_rgb(255, 0, 255), 1050, 0, ALLEGRO_ALIGN_CENTRE, "Sunset(S) %i",sunset);
        al_flip_display();
    }
    
    //float a = sunRS(9.9188736, -84.0433664, 90, 21, 6, 2023, sunset);
}