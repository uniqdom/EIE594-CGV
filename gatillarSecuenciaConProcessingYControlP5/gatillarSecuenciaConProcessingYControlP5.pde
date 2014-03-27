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


 
import controlP5.*;
import processing.serial.*;

ControlP5 cp5;

Serial myPort;

void setup() {
  size(400,400);
  
  
  cp5 = new ControlP5(this);
  
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[4], 9600);
  

  cp5.addButton("Iniciar_Secuencia")
     .setValue(0)
     .setPosition(100,100)
     .setSize(200,19)
     ;
     
  cp5.addButton("Led_Verde")
     .setValue(0)
     .setPosition(100,150)
     .setSize(200,19)
     ;
  
}

void draw() 
{

}

public void controlEvent(ControlEvent theEvent) 
{
println("botón presionado"); 
}

public void Iniciar_Secuencia(int theValue)
{
myPort.write("iniciar\n");
}

public void Led_Verde(int theValue)
{
myPort.write("LedVerde\n");
}

