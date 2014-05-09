//grupo 1: 
//Matías Castillo Felmer
//Adrián Gallardo Aros
//Francisco Vega Contreras


#include "TimerOne.h"  // TIMER1 interrupt

//calibracion del valor 0g (cero gravedad)
//#define VALOR_0G 143

const int ejeX = A0; 
//const int ejeY = A1; 
//const int ejeZ = A2; 

byte valorEjeX;
//byte valorEjeY;
//byte valorEjeZ;

byte boton=2;
byte interruptBoton=0;        //necesario para las interrupciones!!, digital pin2

//byte coordenada=0;

void setup() 
{
  Serial.begin(115200); 
  pinMode(boton, INPUT);
  attachInterrupt(interruptBoton, botonPulsado, FALLING);  // enlaza la subrutina trigger a la interrupcion del pin digital 2. 
  analogReference(EXTERNAL);
  Timer1.initialize(40000);
  Timer1.attachInterrupt(enviar); 
} 

void loop() 
{
  valorEjeX=map(analogRead(ejeX), 0, 1023, 0, 255);  //lee y mapea los valores del acelerometro
  //valorEjeY=map(analogRead(ejeY), 0, 1023, 0, 255);
  //valorEjeZ=map(analogRead(ejeZ), 0, 1023, 0, 255);
}



void botonPulsado()
{   
  Serial.print("Q\n"); 
}


void enviar()
{
//envia una coordenada a la vez
//  if (coordenada==0)
//    {
    //coordenada++; 
    Serial.print("X" ); 
    Serial.write(valorEjeX); 
    Serial.print("\n");
//    }
//  else if (coordenada==1)
//    {
//    coordenada++;  
//    Serial.print("Y"); 
//    Serial.write(valorEjeY); 
//    Serial.print("\n"); 
//    }
//  else if (coordenada==2)
//    {
//    coordenada=0;
//    Serial.print("Z"); 
//    Serial.write(valorEjeZ); 
//    Serial.print("\n");
//    }

}


