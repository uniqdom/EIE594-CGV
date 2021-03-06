//Desafio 2
//Grupo 1:
//Matías Castillo
//Adrián Gallardo
//Francisco Vega

import processing.serial.*;


//librería necesaria para reproducir sonido
import ddf.minim.* ;
Minim minim;

//variables para cargar sonidos
AudioPlayer sonidoRuedaPinchada, sonidoNuevaRueda, sonidoBocinaMolesta, sonidoAplausos;


Serial myPort;  //variable para abrir el dispositivo serial
boolean stringComplete=false; //flag que indica que se recibió un string completo.
String inputString=""; //string entrante desde el puerto serie

//valores recibidos en cada eje
int valorX;
//int valorY;
//int valorZ;

//calibración de los ejes:
static final char CALIBRACION_X=129; //143;
//static final char CALIBRACION_Y=128; //146;
//static final char CALIBRACION_Z=157; //172;





//variables para cargar imágenes
PImage imgAuto;  
PImage imgRueda;
PImage imgRuedaPinchada;
PImage imgClavos;


//variable para definir un tipo de fuente
PFont f;  


//controla la pantalla que se mostrará
byte pantalla=0; /* pantalla = 0  -> Pantalla de inicio
                  * pantalla = 1  -> Juego
                  * pantalla = 2  -> Game Over
                  */
                  
  
int coordXauto,coordYauto; //coordenadas del auto
float startTimeRetardo,mejorTiempo=0,tiempoInicio, tiempoDeJuego ; //variables que controlan el tiempo del juego. 
boolean boolMejorTiempo=false; // indica si se superó el record del mejor tiempo
boolean noMasRuedas=false; //para controlar la dificultad
int ruedasDeRepuesto=1;  //si llega a -1 el juego acaba, dando a entender que se pinchó una rueda y no hay repuestos.
char dificultad=4;    //disminuir para hacer que el juego sea mas dificil
int retardo_ms=200;  //tiempo en milisegundos que debe pasar para que un objeto baje 10 pixeles. Disminuir para hacer que sea mas dificil


//matriz de juego, 14 columnas x 26 filas
//cada casilla de la matriz, representa un rectangulo de 50*10 pixeles.
int[][] matriz=new int[14][26];  /*  matriz[n][m] = 0 -> nada
                                    *  matriz[n][m] = 1 -> rueda   ->  simula las monedas
                                    *  matriz[n][m] = 2 -> clavo   ->  somula las bombas
                                    */
                                   
                                 

void setup() {
  size(700, 400); //tamaño de la pantalla
  
  //Esta fuente es válida para GNU/Linux. quizá en Windows los textos se vean desformes.
  f = createFont("DejaVu Sans Bold",16,true); // nombre del tipo de letra, tamaño 16, anti-aliasing on
  
  println(Serial.list()); //muestra una lista de puertos seriales presentes en máquina que está ejecutando este código.

  //recordar seleccionar el puerto serial adecuado. (probablemente /dev/ttyUSB_ o /dev/ttyAMA_ en GNU/Linux y COM_ en Windows)
  myPort = new Serial(this, Serial.list()[4], 115200);
    
  //cargar las imágenes  
  imgAuto           = loadImage("auto.png");           // Load the image into the program
  imgRueda          = loadImage("rueda.png");          // Load the image into the program 
  imgClavos         = loadImage("clavos.png");         // Load the image into the program 
  imgRuedaPinchada  = loadImage("ruedaPinchada.png");  // Load the image into the program
  
  minim = new Minim(this) ; //  inicializa la librería de sonido
  //cargar los archivos de audio
  sonidoRuedaPinchada  = minim.loadFile("ruedaPinchada.wav") ; 
  sonidoNuevaRueda     = minim.loadFile("nuevaRueda.mp3") ;
  sonidoBocinaMolesta  = minim.loadFile("bocinaMolesta.mp3") ;
  sonidoAplausos       = minim.loadFile("aplausos.mp3") ;
}

void draw() {
  background(255); //fondo de pantalla en blanco
  
  if (pantalla==0)  //pantalla de inicio 
    {  
    dibujarPantallaDeInicio();
    }
    
  else if (pantalla==1) //juego
    {  
      
    pintarRuedasYclavos();
    pintarTableroSuperior();
    pintarTableroInferior();
    moverYpintarAuto();
    comprobarSiTocaObjeto();
    
    //si supera el tiempo dado por retardo_ms, avanza 10 pixeles (se actualiza la matriz)
    if (millis() - startTimeRetardo > retardo_ms) 
      {
         startTimeRetardo=millis();   //reinicia el contador
         avanzarJuego();              //avanza 10 pixeles
         objetoAleatorio();           //pide un objeto aleatorio (puede o no ocurrir)        
      }

  //cambios de dificultad!!
  tiempoDeJuego=millis()-tiempoInicio;
  if (tiempoDeJuego > 15*1000 && dificultad==4)  //si supera los 15 segundos de juego, aumentar dificultad
      {
        dificultad=3; //aumenta la dificultad
      }
  if (tiempoDeJuego > 30*1000 && dificultad==3)  //si supera los 30 segundos de juego, aumentar dificultad
      {
        noMasRuedas=true;   //ya no aparecerán mas ruedas
      }   
  if (tiempoDeJuego > 45*1000 ) 
      {
        dificultad=2;
      }  
  if (tiempoDeJuego > 60*1000 )  
      {
        retardo_ms=100;
      }
  if (tiempoDeJuego > 70*1000) 
      {
        retardo_ms=70;
      } 
  if (tiempoDeJuego > 80*1000)  
      {
        retardo_ms=60;
      }    
  if (tiempoDeJuego > 90*1000)  
      {
        retardo_ms=50;
      }   
   if (tiempoDeJuego > 100*1000)  
      {
        retardo_ms=40;
      }    
   if (tiempoDeJuego > 110*1000)  
      {
        retardo_ms=35;
      }      
   if (tiempoDeJuego > 120*1000)  
      {
        dificultad=1;
      }   


  if (ruedasDeRepuesto<0) //game over. En realidad debió ser if (ruedasDeRepuesto<=0), pero se dejó así para ser coherente con el juego.
        {
            pantalla=2; // ir a la pantalla de game over
            tiempoDeJuego=millis()-tiempoInicio;   //calcula el tiempo de juego
            if( tiempoDeJuego > mejorTiempo)  //ve si fue un record
                {
                sonidoAplausos.rewind();  //rebobinar sonido
                sonidoAplausos.play() ;   //sonido de aplausos
                mejorTiempo=tiempoDeJuego;  
                boolMejorTiempo=true;      //flag de mejor tiempo
                }
            else    //no fue el mejor tiempo
              {
                sonidoBocinaMolesta.rewind();
                sonidoBocinaMolesta.play() ;
                boolMejorTiempo=false;
              }
        }
  }
  else if (pantalla==2) // Game Over
  {  
    dibujarPantallaGameOver();
  }
  
  
  //llegó un comando completo desde Arduino
  if(stringComplete)
  {
      if (inputString.charAt(0)== 'X')   //coordenada x recibida
        {  
        valorX=inputString.charAt(1);
        valorX=int(map(valorX,0,255,0,100)); //mapeo, porque no se va a ocupar todo el rango
        } 
//      else if (inputString.charAt(0)== 'Y')  //coordenada y recibida
//        { 
//        valorY=inputString.charAt(1);
//        } 
//      else if (inputString.charAt(0)== 'Z')  //coordenada z recibida
//        {  
//        valorZ=inputString.charAt(1);
//        }  
      else if (inputString.charAt(0)== 'Q')  //coordenada z recibida
        {  
        reiniciarJuego();     //reinicia todas las variables para jugar de nuevo
        
        if (pantalla==1)     //si estabamos jugando salimos a la pantalla de inicio
          pantalla=0;
        else                 //si no, vamos a jugar
          pantalla=1;
        }  
        
    
    inputString = ""; //borramos la variable que ocupamos de buffer  
    stringComplete = false;  //borramos el flag
  }
}
  
  
  
  
  
void dibujarPantallaDeInicio()
{

    image(imgAuto,50,80, 100, 200);  //dibuja la imagen
    textFont(f,12);  //cambia el tamaño de letra
    fill(0); //cambia a color negro
    text("Mejor record: " +mejorTiempo/1000 +" segundos",300,20);   //mejorTiempo dividido por mil, porque se guardan los valores en milisegundos
    textFont(f,17);
    text("- Recoge ruedas de repuesto",200,150);
    text("\n- Evita los clavos porque pinchan dos ruedas. ",200,150);
    text("\n\n- Si te quedas sin ruedas, pierdes.",200,150);
    textFont(f,25);
    text("Para iniciar, presiona el boton START",50,300);
    textFont(f,12);
    text("Grupo1: Matías Castillo, Adrián Gallardo, Francisco Vega",50,350); 
  
}






  
void dibujarPantallaGameOver()
{
 
    image(imgRuedaPinchada, 0, 0,700,400);  //muestra un auto con una rueda pinchada
    
    textFont(f,18); //cambia tamaño de letra
    text("Mejor record: " +mejorTiempo/1000 +" segundos",300,20);
    
    textFont(f,48);
    fill(0,255,255);  //cambia el color
    text("GAME OVER",200,100);
    textFont(f,30);
    if(boolMejorTiempo)  //¿Es un nuevo record?
      {
      text("Felicitaciones, fué un nuevo record.",50,200);
      }
    else  //no fue nuevo record
      {
       textFont(f,22);
       text("Tu tiempo fue de " +tiempoDeJuego/1000+ " segundos",100,200);
      }
    textFont(f,30);
    text("Para iniciar, presiona el boton START",50,300);
    textFont(f,12);
    text("Grupo1: Matías Castillo, Adrián Gallardo, Francisco Vega",50,385); 
}





void pintarRuedasYclavos()
{

  for (int i=0;i<14;i++)       //pinta ruedas y clavos en las posiciones dadas por la matriz
      for(int j=0;j<26;j++)
         {
           if (matriz[i][j]==1)
           image(imgRueda, i*50, j*10); //pinta rueda
           
           if (matriz[i][j]==2)
           image(imgClavos, i*50, j*10);//pinta clavos
         }
}         




  
//comprueba si el auto tocó una rueda, o los clavos
void comprobarSiTocaObjeto()
{
  for (int i=0;i<14;i++)       
    for(int j=0;j<26;j++)
      {
        if(matriz[i][j]==1 && coordXauto==i && j==25)   //si el auto tocó una rueda
          {
          ruedasDeRepuesto++;
          matriz[i][j]=0;                //hacemos desaparecer la rueda
          sonidoNuevaRueda.rewind();     //reiniciamos el sonido
          sonidoNuevaRueda.play() ;      //play al sonido
          }
        else if(matriz[i][j]==2 && coordXauto==i && j==25)  //si el auto tocó los clavos
          {
          ruedasDeRepuesto-=2;
          matriz[i][j]=0;
          sonidoRuedaPinchada.rewind();
          sonidoRuedaPinchada.play() ;
          }
      }
}
  
  



  
//reinicia todas las variables necesarias para jugar de nuevo
void reiniciarJuego()
{
  noMasRuedas=false;
  dificultad=4;
  retardo_ms=200;
  ruedasDeRepuesto=1;   
  for (int i=0;i<14;i++)       //borra el contenido de toda la matriz
    for(int j=0;j<25;j++)
       matriz[i][j]=0;
  coordXauto=6;//centrar auto en eje X, es columna, no pixel
  coordYauto=300;//al inferior de la pantalla, pixel
  tiempoInicio = millis();  //tiempo donde se inicia el juego, util para calcular el tiempo total de juego
  startTimeRetardo = millis();  //variable usada para hacer avanzar los objetos
}
  
  
  
  
  
  
  
//desplaza todos los objetos de la matriz hacia abajo una posición
void avanzarJuego()
{  
  for (int i=13;i>=0;i--)       
    for(int j=25;j>=1;j--)
      {
        matriz[i][j]=matriz[i][j-1]; 
        matriz[i][j-1]=0; 
      }
}
  
  
  
  
  
  
  
  

void pintarTableroSuperior()
{
  fill(0); //color negro
  rect(0,0,700,50); //rectángulo
  fill(255); //color blanco
  textFont(f,15); 
  text("Juego grupo 1 " ,5,35);
  text("Ruedas de repuesto: " + String.valueOf(ruedasDeRepuesto),500,35);
  text("Tiempo actual: " + tiempoDeJuego/1000 ,200,35);
}







void pintarTableroInferior()
{
  fill(255); //color blanco
  noStroke();  //quita los bordes para el rectangulo
  rect(1,300,700,400); //dibuja un rectangulo
  fill(0); //color negro
  stroke(1);  //un pixel de ancho para la linea
  line(0,299,700,299); //dibuja una línea  
 }
 
 
 
 
 
 

//mueve y pinta el auto
void moverYpintarAuto()
{
 coordXauto=(300-(valorX-50)*50)/50;  //coordenada X del auto, en columnnas. NO ES EN PIXELES
 if (coordXauto<0) 
     coordXauto=0;
 if (coordXauto>650) 
     coordXauto=13;
 image(imgAuto, coordXauto*50, coordYauto); //pinta el auto. coordXauto*50 es el valor en pixeles
}
  
  
  
  
  
  
//Agrega objetos aleatorios en el borde superior (los agrega a la matriz)  
void objetoAleatorio()
{
int i;
//solo si se cumple que el random sea cero creará un objeto aleatorio
if (int(random(0,dificultad))==0)
  {
  //busca una columna libre de objetos en los primeros 50pixeles de arriba  
  do { 
       i = int(random(0,13)); //seleccionamos una columna aleatoria
     }while(matriz[i][0]!=0||matriz[i][1]!=0||matriz[i][2]!=0||matriz[i][3]!=0||matriz[i][4]!=0);
  
  if (!noMasRuedas)
      {
      matriz[i][0] = int(random(1,3)); //seleccionamos una objeto aleatorio y se agrega a la matriz
      }
  else //ya no hay mas ruedas, porque se aumentó la dificultad
      matriz[i][0] = 2;
  }
}
  
  
  
  
  
  
void serialEvent(Serial p) 
{ 
  while (p.available()>0)  //mientras haya datos en el buffer 
    {
    char inChar = (char)p.read();  //obtiene un byte del puerto serial
    inputString += inChar;   //lo agrega al final de inputString
    
    if (inChar == '\n') //fin de los datos de un comando 
      { 
      stringComplete = true; //activa la bandera para el loop()
      }
    }
} 
