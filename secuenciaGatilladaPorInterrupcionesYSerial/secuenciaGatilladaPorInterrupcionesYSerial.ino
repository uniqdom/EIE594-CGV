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


#include "TimerOne.h"  // TIMER interrupt

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

//LEDS EN PINES DIGITALES 8 y 9
byte ledVerde = 8;  
byte ledRojo = 9;      //la libreria TimerOne implementa pwm en este pin (usado para parpadear)

//BOTONES EN PINES DIGITALES 2 y 3
byte boton1=3;
byte boton2=2; 
byte interruptBoton1=1;        //necesario para las interrupciones!!, digital pin3
byte interruptBoton2=0;        //necesario para las interrupciones!!, digital pin2
            
byte tick; //Contador de segundos para la secuencia
char data[10];
void setup() 
{
  Serial.begin(9600);
  pinMode(boton1, INPUT);
  pinMode(boton2, INPUT);
  pinMode(ledRojo, OUTPUT);
  pinMode(ledVerde, OUTPUT);
  attachInterrupt(interruptBoton1, trigger, RISING);
    // reserve 200 bytes for the inputString:
  inputString.reserve(200);
}


void loop() 
{

if (stringComplete) {
    Serial.println(inputString);
    if (inputString == "iniciar\n") 
        trigger();
    else if (inputString == "LedVerde\n")    
       {
         digitalWrite(ledVerde,HIGH);
         delay(1000);
         digitalWrite(ledVerde,LOW);
       }
      
    
    // clear the string:
    inputString = "";
    stringComplete = false;
  }

}


void trigger()
{ 
  tick=0;
  digitalWrite(ledVerde,LOW);
  digitalWrite(ledRojo,HIGH);
  detachInterrupt (interruptBoton2);
  Timer1.disablePwm(9);
  Timer1.attachInterrupt(procesadorSecuencia);  // attaches procesadorSecuencia() as a timer overflow interrupt
  Timer1.initialize(1000000);         // initialize timer1, and set a 1 second 
}


void procesadorSecuencia()
{

tick++;

if (tick==2)   // 2 segundos
     digitalWrite(ledVerde,HIGH);

else if (tick==7) // 7 segundos
     digitalWrite(ledVerde,LOW);

if (tick==3 )  // entre 3 s
     attachInterrupt(interruptBoton2, parpadear, CHANGE);
     
else if (tick==10) // 10 segundos
     {
     detachInterrupt (interruptBoton2);
     digitalWrite(ledRojo,LOW);
     Timer1.detachInterrupt();
     Timer1.disablePwm(9);
     }
     
}


void parpadear() //ventana de 3 a 10 segundos
{
 if (digitalRead(boton2)==HIGH) 
     {
     Timer1.pwm(9,512,1000000);
     }

 else
     {
     Timer1.disablePwm(9);
     digitalWrite(ledRojo,HIGH);
     }
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
