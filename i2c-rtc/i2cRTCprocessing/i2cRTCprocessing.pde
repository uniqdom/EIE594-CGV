import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
Serial myPort;
ColorPicker cp;
Textarea textoLed1,textoLed2;

String inputString="" ;         // Almacena los datos entrantes por puerto serial
boolean stringComplete = false;  // Indica si se recibi un comando completo.
boolean programaPrincipalIniciado=false; //flag para la función serialEvent()
//sin este flag, al iniciar el programa, se imprime todo lo que está en el buffer del puerto serial por 0.5 segundos y luego se normaliza a solo una linea cada 0.5 segundos.
//dentro del setup limpiamos el buffer y activamos el flag, de modo que se corrija el bug anterior.

char led1Intensidad=255,  led2Intensidad=255;

String sFecha="hola";
String sHora;
String horaRecibida = "Aún no se ha recibido datos desde el RTC";

void setup() {
  size(400, 600);
  println(Serial.list()); //muestra una lista de puertos seriales presentes en máquina que está ejecutando este código.

//recordar seleccionar el puerto serial adecuado. (probablemente /dev/ttyUSB_ o /dev/ttyAMA_ en GNU/Linux y COM_ en Windows)
myPort = new Serial(this, Serial.list()[4], 9600);
//myPort = new Serial(this, "/dev/pts/3", 9600);


//  noStroke();
  cp5 = new ControlP5(this);

    PFont font = createFont("arial",20);
    
  cp5.addTextfield("fecha")
     .setPosition(20,50)
     .setSize(320,40)
     .setValue("May 7 2014")
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
     
    cp5.addTextfield("hora")
     .setPosition(20,150)
     .setSize(320,40)
     .setValue("12:40:55")
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
     
       cp5.addButton("Ajustar")
     .setValue(0)
     .setPosition(20,240)
     .setSize(320,40)
     ;     
       
          
          
          
//limpia el buffer del puerto serial
//while (myPort.available() > 0) 
//      {
//      String inBuffer = myPort.readString();   
//
//      }
      

programaPrincipalIniciado=true;

          
}

void draw() {
  background(0);
  fill(255);
  
  text("Formato fecha: Mmm DD YYYY", 20,10); 
  text("Mmm: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", 20,30);
  text("Formato hora:  HH:MM:SS", 20,135);  
  text(horaRecibida, 20,340);

  
  if (stringComplete) {
    horaRecibida=inputString;
    
         

    inputString = "";
    stringComplete = false;
  }
}






public void hora(String theText) {
  // automatically receives results from controller input
  sHora=theText;
}

public void fecha(String theText) {
  // automatically receives results from controller input
  sFecha=theText;
}


public void Ajustar(int theValue) {

  myPort.write(cp5.get(Textfield.class,"fecha").getText()+ ", " + cp5.get(Textfield.class,"hora").getText() + "\n");
  
 
 
  println("Hora enviada a Arduino: " + cp5.get(Textfield.class,"fecha").getText() + ", " + cp5.get(Textfield.class,"hora").getText());
}



void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
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


