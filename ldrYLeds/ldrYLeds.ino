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


byte ledVerde = 13;  
byte ledRojo = 9;      
boolean tiempo=false;

void setup() 
{
pinMode(9,OUTPUT);
pinMode(13,OUTPUT);
Serial.begin(9600);
Timer1.attachInterrupt( trigger);  // enlaza la subrutina trigger a la interrupcion del pin digital 2. 
Timer1.initialize(500000);    //Timer1 configurado a 0.5 segundo.
}


void loop() 
{
int sensorValue = analogRead(A0);
  
if(tiempo==true)
  {
  if (sensorValue>900)
    {
    digitalWrite(ledVerde,HIGH);
    digitalWrite(ledRojo,LOW);
    }
  if (sensorValue<300)
    {
    digitalWrite(ledRojo,HIGH);
    digitalWrite(ledVerde,LOW);
    }
  
  Serial.println(sensorValue);
  tiempo=false;
  
}

}

void trigger(){
tiempo=true;  
}
