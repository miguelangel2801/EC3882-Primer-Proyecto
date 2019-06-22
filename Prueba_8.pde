/////////////////////////////////////////////

import processing.serial.*;         // Importamos la libreria Serial


//Variables de impresión
// Declara e inciializza variables para graficar
int cha0, cha1, cha2, cha3, cha01=300,cha11=300, cha21=300,cha31=300,alto=1000, ancho;
float x1=10,x2=10;
String[] lines;

//Variables para adquisición de datos
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

//variables selectoras de niveles de amplitud
// SI se escoge arreglos con i=0 se tiene escala 1v, i=1:3v, i=2:0.3v
// Lo arreglos contienen las escalas que se usan para convertir un numero
// de una escala a otra por medio de la funcion map
int k=0;
boolean boton1presionado=false;
float SNA1 []={0, 0, 1092};    //valor mas pequeño de la escala actual 
float SNA2 []={4096, 4096, 3004};  // Valor más grande de la escala actual
float SNA3 []={189, 263.5, 10};  // Valor más pequeño de la escala deseada
float SNA4 []={411, 336.5, 590}; //Valor más grande de la escala deseada 
char SND[]={590, 408, 590};
String Amplitud[]= {"1 V", "3 V", "0.3 V"};
String Frec[]= {"0.1 s", "10ms", "1 ms"};

//Variables para selector de escala de tiempo
//Calibramos con una señal de 10Hz 
//ts[0] es la escala de 0.1s
//ts[1] e la escala de 0.01s
//ts[2] es la escala de 1ms
//float[] ts={10*92/2000,10*920/2000,10*9200/2000};
int j=0; 
float[] ts={0.7,7,70};
int[] tl={999,99,9};
int[] ne={1000,100,10};//Fin de contador
//Variables de Stop
boolean stop=true;
//Variables CH1 y CH2
boolean ch1=true;
boolean ch2=false;
boolean ch3=false;
boolean ch4=false;
//boolean ch3=true;
//boolean ch4=true;
char[] AD1=new char[2]; //Arreglo donde guardaré lo correspondiente al canal analogico 1
char[] AD2=new char[2]; //Arreglo donde guardaré lo correspondiente al canal analogico 1
char Dig1;
char Dig2;
 int n; //Contador
int[] nivel=new int[2];
byte [][] datos= new byte[2000][4];
byte[] clear= {0,0,0,0};
int counter=0;
int[] ANALOGICO1=new int[2000];
int[] ANALOGICO2=new int[2000];
int[] DIGITAL1=new int[2000];
int[] DIGITAL2=new int[2000];
int flag=0;
int n1;
void setup()
{
  
  size(810, 600);
  alto = height;
  ancho= width;
  background(255,255,255);
  dibujo();
  
  //String portName = Serial.list()[0];   //Se abre el puerto serial el numero 3 puede variar cada vez
  String portName = Serial.list()[0]; 
  myPort = new Serial(this, portName, 115200);  //se configura el puerto y la velocidad en baudios

}
  
void draw() {


    byte[] inBuffer = new byte[4];   // Se determinan la cantidad de bytes esperados: tamaño de buffer
      if(stop == true){  
      for(n=0;n<=1999;n=n+1)
       { 
       datos[n]=clear;  
       ANALOGICO1[n]=0;
       ANALOGICO2[n]=0;
       DIGITAL1[n]=0;
       DIGITAL2[n]=0;
       }
    
      
     }
      
       
        
            //Si el Buffer esta lleno
        for(counter=0;counter<=ne[j];n1=0)
          {
            while (myPort.available() > 0 && flag==0) {  // Cada vez que haya algo en el puerto se lee
            inBuffer = myPort.readBytes();  // Y se guarda en inBuffer
             myPort.readBytes(inBuffer);
            
            if (inBuffer != null) {
            
            datos[counter]=inBuffer;
          // println(binary(datos[counter][0]),binary(datos[counter][1]),binary(datos[counter][2]),binary(datos[counter][3]));
            counter=counter+1;
               
            }
            }
            }

      //Guardo ahora lo que leo en 8 bits en 2 arreglos de 16 bits (uno para cada AD)
       
      
      //Traduccion de datos 
      counter=0;
      flag=1;
      if(stop==false)n=ne[j]+1; else n=0;
      while(n<=ne[j]){ //ciclo para Traducir protocolo de comunicacion
            AD1[0]=char(datos[n][0]);   //Guarda primera mitad del canal 1
            AD1[1]=char(datos[n][1]); //Guarda segunda mitad del canal 1
            AD2[0]=char(datos[n][2]); //Guarda primera mitad del canal 2
            AD2[1]=char(datos[n][3]); //Guarda segunda mitad del canal 2
            Dig1= AD1[1];
            Dig1=char(int(Dig1) & (64));   // saco el bit que importa  canal digital 1  
            Dig2= AD2[0];
            Dig2=char(int(Dig2) & (64));  //saco el bit que importa canal digital 2 
            AD1[0]=char(int(AD1[0] & 63)*64); //pone los dos primeros bits del char en 0 y hago corrimiento de 6 bits a la izquierda
            AD1[1]=char(int(AD1[1] & 63));    //pone los dos primeros bits del char en 0
            AD2[0]=char(int(AD2[0] & 63)*64); //pone los dos primeros bits del char en 0 y hago corrimiento de 6 bits a la izquierda
            AD2[1]=char(int(AD2[1] & 63));    //pone los dos primeros bits del char en 0
            //print(binary(AD1[0])+' '+binary(AD1[1])+' '+binary(AD2[0])+' '+binary(AD2[1])+'\n');
            nivel[0]=((int(AD1[0])+int(AD1[1])));  //Concateno los bits para hallar el valor leído en adc a 12 bits Canal 1
            nivel[1]=((int(AD2[0])+int(AD2[1])));  //Concateno los bits para hallar el valor leído en adc a 12 bits Canal 2
              if(Dig1==0) Dig1 = 300; else Dig1=char(int(SND[k]));
              if(Dig2==0) Dig2 = 300; else Dig2=char(int(SND[k]));
         
                  ANALOGICO1[counter]= int(map(nivel[0],SNA1[k],SNA2[k], SNA3[k], SNA4[k]));//Se convierte la data de niveles de 0 a 4095 hacia 10 a alto-10
                  ANALOGICO1[counter]=600-ANALOGICO1[counter];
                  ANALOGICO2[counter]= int(map(nivel[1],SNA1[k],SNA2[k], SNA3[k], SNA4[k]));    // Se guarda en cha0 y cha1 los canales analogicos 
                  ANALOGICO2[counter]=600-ANALOGICO2[counter];
                  DIGITAL1[counter]= 600-int(Dig1);
                  DIGITAL2[counter]= 600-int(Dig2); 
                  counter=counter+1;
                 // Las variables SNA1 determinan que escala de amplitud estamos usando
      n=n+1;
           }
               println(ANALOGICO1[100],ANALOGICO1[101],ANALOGICO1[102]);

                        //Gaficar en pantalla 
                        flag=1;
                        x1=10;
                       // x2=10+ts[j];
                        dibujo();
                        int cursor=0;
                        
             while(cursor<= tl[j])
             {
                  
                       //if (flag de stop == 0) cursor=tl[j];
                      // si se presiona el boton stop no imprimie si se presiona otra vez sigue imprimiendo despues de refrescar
                       stroke(#FF00FF); //Imprime linea magenta.
                       if(ch1 != false && (ANALOGICO1[cursor]>=10 && ANALOGICO1[cursor]<=alto-10) ) line(x1, ANALOGICO1[cursor],x1+ts[j], ANALOGICO1[cursor+1]);  //Si se presiona ch1 se muestra o se oculta la señal despues de refrescar o
                                                                                                    //point(x1,ANALOGICO1[cursor]);
                                                                                                    //si la señal se va a salir de la pantalla no la imprime
                       //                                                                           // La señal se imprime como lineas que unen dos puntos
                       stroke(255, 255, 0); //Imprime linea amarilla
                       if(ch2 != false && (ANALOGICO2[cursor]>=10 && ANALOGICO2[cursor]<=alto-10) ) line(x1, ANALOGICO2[cursor], x1+ts[j], ANALOGICO2[cursor+1]);
                       
                       stroke(255, 0, 0); //Imprime linea roja
                       if(ch3!=false && (DIGITAL1[cursor]>=10 && DIGITAL1[cursor]<=alto-10) ) line(x1, DIGITAL1[cursor], x1+ts[j], DIGITAL1[cursor+1]);
                       
                       stroke(0, 255, 0); //Imprime linea Verde
                       if(ch4!=false && (DIGITAL2[cursor]>=10 && DIGITAL2[cursor]<=alto-10) ) line(x1, DIGITAL2[cursor], x1+ts[j], DIGITAL2[cursor+1]);
                       
                      
                       x1=x1+ts[j];  //ts es la variable que determina que escala de tiemp estamos usando
                      // x2=x1+ts[j]; //0.7 wscala de 0.1s
                                      
                                 
               
                    cursor=cursor+1;
                    
       }
  
      flag=0;
//x2=10+ts[j];
}
    
     
     


//Funciones usadas en Draw

void mouseClicked()  // Cada vez que se hace click se llama esta funcion y se evalua que boton fue presionaso y se despliega su funconalidad
{
  //Boton1    
  if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,35,85)==true)
  {
   if(k==2) k=0;
   else k++;
       x1=10;
       x2=10;
       dibujo(); 
  }
  //Boton 2
  if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,115,165)==true){
    if(j==2) j=0;
      else j++;
         x1=10;
         x2=10;
         dibujo();         
  }
  //Boton3
  if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,195,245)==true)
  {
   if(stop==true){
     stop=false;}else if(stop==false){
                         stop=true;
                         x1=10;
                         x2=10;
                         dibujo();
                          }                      
  }
  //Boton4
    if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,275,325)==true)
  {
   if(ch1==true){
       ch1=false;}else if(ch1==false) ch1=true;
       x1=10;
       x2=10;
       dibujo();
   }
   //Boton5
    if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,355,405)==true)
  {
   if(ch2==true){
       ch2=false;}else if(ch2==false) ch2=true;
       x1=10;
       x2=10;
       dibujo();
   }
      //Boton6
    if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,435,485)==true)
  {
   if(ch3==true){
       ch3=false;}else if(ch3==false) ch3=true;
       x1=10;
       x2=10;
       dibujo();
   }
      //Boton7
    if(buttomPressed(mouseX, mouseY,ancho-50-35,ancho-50+35,515,565)==true)
  {
   if(ch4==true)
       ch4=false;
else if(ch4==false) ch4=true;
  
       x1=10;
       x2=10;
       dibujo();
   }
}

// Funcion encargada de todos los objetos mostrados en pantalla
void dibujo()
{
  clear();
  background(0);
  stroke(255, 255, 255);
  line(ancho-100, 10, ancho-100, alto-10); //Linea vertical derecha
  line(10, 10, 10, alto-10); //Linea vertical izquierda
  line(10, 10, ancho-100, 10); // Linea horizontal izquierda
  line(10, alto-10, ancho-100, alto-10); //Linea Horzontal derecha
    
  
 //Lineas de escala
    stroke(0, 255, 255); 
    for(int i = 1; i<=7; i++)
    {
        line(10, 10+72.5*i, ancho-100, 10+72.5*i);
    }
    for(int i = 1; i<=9; i++)
    {
        line(10+70*i, 10, 10+70*i, alto-10);
    }
    
//Lineas centrales 
   stroke(255,255,255);
   line(10+350, 10, 10+350, alto-10);
   line(10, 10+290, ancho-100, 10+290);
  //for(int i = 0; i<div; i++)
  //{
  //  line(ini, ((alto-30)/(div-1))*i+10, ini+10, ((alto-30)/(div-1))*i+10);
  //  text(5-i/2.0+"v", 0, ((alto-30)/(div-1))*i+15);
  //  line(((ancho-35)/(div-1))*i+25, alto-15, ((ancho-35)/(div-1))*i+25, alto-25);
  //  text(/*nf((ancho-30)/(div-1)*0.03*i, 1, 2)*/(i*2)+"s", ((ancho-35)/(div-1))*i+15, alto-0);
  //}
  stroke(0);
  fill(0,116,255);
  rect(ancho-50,50,84, 24);
  boton(ancho-50,50,"VOLT/DIV",ancho-80,55);
  stroke(0);
  fill(0,116,255);
  rect(ancho-50,130,84, 24);
  boton(ancho-50,130,"SEC/DIV", ancho-75, 135);
  stroke(0);
  fill(0,116,255);
  rect(ancho-50,210,84, 24);
  boton(ancho-50,210,"STOP", ancho-65, 215);
  stroke(0);
  fill(255, 0, 255);
  rect(ancho-50,290,84, 24);
  boton(ancho-50,290,"CH1", ancho-63, 295);
  stroke(0);
  fill(255, 255, 0);
  rect(ancho-50,370,84, 24); 
  boton(ancho-50,370,"CH2", ancho-63, 375);
  stroke(0);
  fill(255, 0, 0);
  rect(ancho-50,450,84, 24);
  boton(ancho-50,450,"CH3", ancho-63, 455);
  stroke(0);
  fill(0, 255, 0);
  rect(ancho-50,530,84, 24);
  boton(ancho-50,530,"CH4", ancho-63, 535);
  //Amplitud
  textSize(32);
  text(Amplitud[k], 15, 42); 
  //Frecuencia
  textSize(32);
  text(Frec[j], 15, 580); 
}



boolean buttomPressed(int mousex , int mousey, int mx, int x, int my, int y){ // Esta funcion evalua en qué boton te paraste al momento de clickear
   if((mousey>=my && mousey<= y) && (mousex>=mx && mousex<=x)) return true;  
     else return false;
}




void boton(int x, int y, String texto, int xt, int yt)  //dibujar un bonton
{
  stroke(0);
  fill(0,116,255);
  ellipse(x,y,70,70);
  fill(255);
  textSize(12);
  text(texto,xt,yt);
}
