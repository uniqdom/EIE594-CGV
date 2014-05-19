// Date and time functions using a DS1307 RTC connected via I2C and Wire lib

#include <Wire.h>
#include "RTClib.h"
#include <LiquidCrystal_I2C.h>
#include <TimerOne.h>

LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE); 
RTC_DS1307 RTC;

String inputString = "";         // guardara los datos que lleguen desde el puerto serial
boolean stringComplete = false;  // bandera que indica que se completo un string recibido (detecta el caracter '\n')
int led=13;
byte boton=2;                 //boton conectado en el pin digital 2 con una resistencia de pull-UP
boolean valorBoton=false;
//byte interruptBoton=0;        //necesario para las interrupciones!!, digital pin2

boolean pantalla = false;

void setup () {
  Timer1.initialize(1000000);
   Timer1.attachInterrupt( timerIsr );
  pinMode(boton, INPUT);
 pinMode(led, OUTPUT);
 //attachInterrupt(interruptBoton, enviarHora, RISING);  // enlaza la subrutina enviarHora() a la interrupcion del pin digital 2. 
  inputString.reserve(200); // reserva 200 bytes para el String inputString:
  Serial.begin(9600);
  Wire.begin();
  RTC.begin();
  lcd.begin(16,2);
  for(int i = 0; i< 3; i++)
  {
    lcd.backlight();
    delay(250);
    lcd.noBacklight();
    delay(250);
  }
  lcd.backlight();
  lcd.setCursor(0,0); //Start at character 4 on line 0
  lcd.print("Prueba RTC");
  delay(1000);

  if (! RTC.isrunning()) {
    Serial.println("RTC is NOT running!");
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("RTC desactivado");
    delay(1000);
    // following line sets the RTC to the date & time this sketch was compiled
    RTC.adjust(DateTime(__DATE__, __TIME__));
    //RTC.adjust(DateTime("Dec 26 2009", "12:34:56"));
  }
  else{
    //RTC.adjust(DateTime(__DATE__, __TIME__));
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("RTC activo");
    delay(1000);
    lcd.clear();
  }
}

void loop () {

  DateTime now = RTC.now();
/*  
  Serial.print(now.year(), DEC);
  Serial.print('/');
  Serial.print(now.month(), DEC);
  Serial.print('/');
  Serial.print(now.day(), DEC);
  Serial.print(' ');
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(':');
  Serial.print(now.second(), DEC);
  Serial.println();
*/  
  
  if (pantalla)
  {
  pantalla=false;
  enviarHoraPantallaLCD();
  }
  //si llegan datos al puerto serial es porque processing quiere configurar una fecha y hora
  if (stringComplete) {

    char sFecha[50],sHora[50];
    inputString.substring(0, inputString.indexOf(',')).toCharArray(sFecha, 50) ;
    inputString.substring(inputString.indexOf(',') + 2).toCharArray(sHora, 50);
    lcd.clear();

    RTC.adjust(DateTime(sFecha, sHora));
 
    // borra el string y la bandera
    inputString = "";
    stringComplete = false;
  }
  
  if( !digitalRead(boton)){
    Serial.print(now.year(), DEC);
    Serial.print('/');
    Serial.print(now.month(), DEC);
    Serial.print('/');
    Serial.print(now.day(), DEC);
    Serial.print(' ');
    Serial.print(now.hour(), DEC);
    Serial.print(':');
    Serial.print(now.minute(), DEC);
    Serial.print(':');
    Serial.print(now.second(), DEC);
    Serial.println(); 
    delay(500);
  }
  



}


void enviarHoraPantallaLCD()
{
  DateTime now = RTC.now();
  lcd.setCursor(0,0);
  lcd.print("Fecha: ");
  if (now.day()<10) lcd.print('0');
  lcd.print(now.day());
  lcd.print('/');
  if (now.month()<10) lcd.print('0');
  lcd.print(now.month());
  lcd.print('/');
  lcd.print(now.year()-2000);
  lcd.setCursor(0,1);
  lcd.print("Hora:  ");
  if (now.hour()<10) lcd.print('0');
  lcd.print(now.hour());
  lcd.print(':');
  if (now.minute()<10) lcd.print('0');
  lcd.print(now.minute());
  lcd.print(':');
  if (now.second()<10) lcd.print('0');
  lcd.print(now.second()); 
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



void timerIsr()
{
pantalla=true;

}
