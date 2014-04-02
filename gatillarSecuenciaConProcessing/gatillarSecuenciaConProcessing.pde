/*  Copyright 2014 Matias Castillo Felmer

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

//Usar junto al sketch de arduino "secuenciaGatilladaPorInterrupcionesYSerial"



import processing.serial.*;
Serial myPort;


int value = 0, value2=0;

void setup() {
  size(320, 300);
  println(Serial.list());  //muestra una lista de puertos seriales presentes en máquina que está ejecutando este código.
  
  //recordar seleccionar el puerto serial adecuado. (probablemente /dev/ttyUSB_ o /dev/ttyAMA_ en GNU/Linux y COM_ en Windows)
  myPort = new Serial(this, Serial.list()[4], 9600);  
}

void draw() {  //dibuja dos rectángulos emulando botones y los colorea.
   fill(value);
   rect(80, 80, 40, 40);
   
   fill(value2);
   rect(80, 140, 40, 40);
}

void mousePressed()
{
 if ((mouseX>=80) && (mouseX<=120) && (mouseY>=80 ) && (mouseY<=120)) {   //si hace click sobre el rectángulo 1, cambia el color
     value=200;
     println("botón presionado.");
     myPort.write("iniciar\n");
  }
  
 if ((mouseX>=80) && (mouseX<=120) && (mouseY>=140 ) && (mouseY<=180)) { //si hace click sobre el rectángulo 2, cambia el color
     value2=200;
     println("botón presionado.");
     myPort.write("LedVerde\n");
  }
  
}

void mouseReleased()
{
value=0;
value2=0;
}


void mouseMoved()
{
if ((mouseX>=80) && (mouseX<=120) && (mouseY>=80 ) && (mouseY<=120))    //si el puntero del mouse está dentro del primer rectángulo, cambia el color
     value=80; 
else if   ((mouseX>=80) && (mouseX<=120) && (mouseY>=140 ) && (mouseY<=180)) //si el puntero del mouse está dentro del segundo rectángulo, cambia el color
     value2=80;
else      //si el puntero del mouse está fuera de los rectángulos limpiar color.
     {
     value=0;
     value2=0;
     }
}

