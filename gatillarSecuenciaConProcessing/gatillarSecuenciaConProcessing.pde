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
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[4], 9600);
}

void draw() {
   fill(value);
   rect(80, 80, 40, 40);
   
   fill(value2);
   rect(80, 140, 40, 40);
}

void mousePressed()
{
 if ((mouseX>=80) && (mouseX<=120) && (mouseY>=80 ) && (mouseY<=120)) {
     value=200;
     println("botón presionado.");
     myPort.write("iniciar\n");
  }
  
 if ((mouseX>=80) && (mouseX<=120) && (mouseY>=140 ) && (mouseY<=180)) {
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
if ((mouseX>=80) && (mouseX<=120) && (mouseY>=80 ) && (mouseY<=120)) 
     value=80;
else if   ((mouseX>=80) && (mouseX<=120) && (mouseY>=140 ) && (mouseY<=180))
     value2=80;
else
     {
     value=0;
     value2=0;
     }
}

