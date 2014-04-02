/*	Copyright 2014 Matias Castillo Felmer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#include "TimerOne.h"  // TIMER1 interrupt

String inputString = "";         // Almacena los datos entrantes por puerto serial
boolean stringComplete = false;  // Indica si se recibi un comando completo.

//LEDS EN PINES DIGITALES 8 y 9
byte ledVerde = 8;  
byte ledRojo = 9;      //la libreria TimerOne implementa pwm en este pin (usado para parpadear)

//BOTONES EN PINES DIGITALES 2 y 3
byte boton1=3;
byte boton2=2; 
byte interruptBoton1=1;        //necesario para las interrupciones!!, digital pin3
byte interruptBoton2=0;        //necesario para las interrupciones!!, digital pin2
            
byte tick=-2; //Contador de segundos para la secuencia
boolean boton2cambio=false; //bandera para el boton2.

void setup() 
{
  Serial.begin(9600);
  pinMode(boton1, INPUT);
  pinMode(boton2, INPUT);
  pinMode(ledRojo, OUTPUT);
  pinMode(ledVerde, OUTPUT);
  attachInterrupt(interruptBoton1, trigger, FALLING);  // enlaza la subrutina trigger a la interrupcion del pin digital 2. 
  Timer1.initialize(1000000);    //Timer1 configurado a 1 segundo.
  inputString.reserve(200);      //reserva memoria
}


void loop() 
{

if (stringComplete) {
    Serial.println(inputString);
    if (inputString == "iniciar\n")   //comando que gatilla la secuencia de leds
        trigger();
    else if (inputString == "LedVerde\n")    //comando que hace parpadear una vez el led verde.
       {
         digitalWrite(ledVerde,HIGH);
         delay(1000);
         digitalWrite(ledVerde,LOW);
       }
      
    inputString = "";
    stringComplete = false;
  }


if(tick==0)
     digitalWrite(ledRojo,HIGH);
  
else if (tick==2)   // 2 segundos
     digitalWrite(ledVerde,HIGH);

else if (tick==7) // 7 segundos
     digitalWrite(ledVerde,LOW);

else if (tick==3 )  // 3 segundos
     {
     if (digitalRead(boton2)==LOW)
         Timer1.pwm(9,512,1000000);
     attachInterrupt(interruptBoton2, cambioEstadoBoton2, CHANGE);   // enlaza la subrutina cambioEstadoBoton2() a la interrupcion del pin digital 3.
     }
     
else if (tick==10) // 10 segundos
     {            //apagar leds y desactivar interrupciones.
     detachInterrupt (interruptBoton2);
     digitalWrite(ledRojo,LOW);
     Timer1.detachInterrupt();
     Timer1.disablePwm(9);
     tick=11;
     }

if(boton2cambio==true && (tick >=3) )
     {
     boton2cambio=false;          //limpiar bandera
      
     if (digitalRead(boton2)==LOW) 
         {
         Timer1.pwm(9,512,1000000);  //activar el parpadeo
         }
  
     else
         {
         Timer1.disablePwm(9);      //desactivar el parpadeo
         digitalWrite(ledRojo,HIGH);
         }
     }
}



void trigger()
{ 
  Timer1.restart(); //reinicia el Timer1
  tick=-1;
  Timer1.attachInterrupt(contar);  // enlaza la subrutina contar() a la interrupcion del Timer1.
}

void contar()
{
tick++;
}


void cambioEstadoBoton2() //flag activado cuando el boton 2 es presionado entre los segundos 3 y 10.
{
boton2cambio=true;
}


void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}
