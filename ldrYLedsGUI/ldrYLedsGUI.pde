/*  Copyright 2014 Matías Castillo Felmer

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



import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
Serial myPort;


String inputString = "";         // Almacena los datos entrantes por puerto serial
boolean stringComplete = false;  // Indica si se recibi un comando completo.
boolean programaPrincipalIniciado=false; //flag para la función serialEvent()
//sin este flag, al iniciar el programa, se imprime todo lo que está en el buffer del puerto serial por 0.5 segundos y luego se normaliza a solo una linea cada 0.5 segundos.
//dentro del setup limpiamos el buffer y activamos el flag, de modo que se corrija el bug anterior.


void setup() 
{
size(400,400);
  
println(Serial.list()); //muestra una lista de puertos seriales presentes en máquina que está ejecutando este código.

//recordar seleccionar el puerto serial adecuado. (probablemente /dev/ttyUSB_ o /dev/ttyAMA_ en GNU/Linux y COM_ en Windows)
myPort = new Serial(this, Serial.list()[4], 9600);
  
cp5 = new ControlP5(this);
  
//limpia el buffer del puerto serial
while (myPort.available() > 0) 
      {
      String inBuffer = myPort.readString();   

      }
      
background(102);
programaPrincipalIniciado=true;
}

void draw() 
{
if (stringComplete) {
    background(102);   //borra la pantalla
    text(inputString, 195,195); //imprime en la pantalla
    println(inputString); //imprime en la consola
    inputString = "";
    stringComplete = false;
  }
      
}


void serialEvent(Serial p) { 
  while (p.available()>0 && programaPrincipalIniciado) {
    // get the new byte:
    char inChar = (char)p.read();
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
} 

