// ROBOT SUMO POLIBOT = Pinguino 18F4550 - Puente en H - Sensor SFR04 - Optoacoplador
// Compilado en PinguinoX.3 y Pinguino 9.05
// Andrés Cintas 30/11/2013
// Prueba la funcion de detectar linea

#define PIC18F4550
//Declaración de variables

// Para manejar el Puente H
int RD4 = 25;				// RD4 es un entero ( Pin )
int RD5 = 26;				// RD5 es un entero ( Pin )
int RD6 = 27;				// RD6 es un entero ( Pin )
int RD7 = 28;				// RD7 es un entero ( Pin )

// Para sensores que detectan línea blanca
int RB7 = 7;				// RB7 es un entero ( Pin )
int RB6 = 6;				// RB6 es un entero ( Pin )
int RB5 = 5;				// RB5 es un entero ( Pin )
int RB4 = 4;				// RB4 es un entero ( Pin )

// Para manejo de interruptores de largada y estrategia
int RB1 = 1;				// RB1 es un entero ( Pin )
int RB0 = 0;				// RB0 es un entero ( Pin )

// Para usar sensor de Ultrasonido SFR04
const int triggerPin = 21;
const int echoPin = 22;

// Bandera de Estado
int flag;
  
//Configuración de puertos

void setup() 
{
 pinMode(RD4,OUTPUT);		// pin RD4 es una salida
 pinMode(RD5,OUTPUT);		// pin RD5 es una salida
 pinMode(RD6,OUTPUT);		// pin RD6 es una salida
 pinMode(RD7,OUTPUT);		// pin RD7 es una salida

 pinMode(RB7,INPUT);		// pin RB7 es una entrada
 pinMode(RB6,INPUT);		// pin RB6 es una entrada
 pinMode(RB5,INPUT);		// pin RB5 es una entrada
 pinMode(RB4,INPUT);		// pin RB4 es una entrada

 pinMode(RB1,INPUT);		// pin RB1 es una entrada
 pinMode(RB0,INPUT);		// pin RB0 es una entrada
  
 pinMode(triggerPin, OUTPUT); // pin  de disparo sensor SFR04
 pinMode(echoPin, INPUT);  // pin eco sensor SFR04
 
 //Apagar motores
 digitalWrite(RD4,0);
 digitalWrite(RD5,0);
 digitalWrite(RD6,0);
 digitalWrite(RD7,0);
}


// DECLARACION DE SUBRUTINAS


//Función para ejecutar un movimiento
void detenido()
{
 digitalWrite(RD4,0);
 digitalWrite(RD5,0);
 digitalWrite(RD6,0);
 digitalWrite(RD7,0);
}

//Función para ejecutar un movimiento
void atras()
{
 digitalWrite(RD4,0);
 digitalWrite(RD5,1);
 digitalWrite(RD6,1);
 digitalWrite(RD7,0);
}


//Función para ejecutar un movimiento
void adelante()
{
 digitalWrite(RD4,1);
 digitalWrite(RD5,0);
 digitalWrite(RD6,0);
 digitalWrite(RD7,1);
}

//Función para ejecutar un movimiento
void giroderecha()
{
 digitalWrite(RD4,0);
 digitalWrite(RD5,1);
 digitalWrite(RD6,0);
 digitalWrite(RD7,1);
}

//Función para ejecutar un movimiento
void giroizquierda()
{
 digitalWrite(RD4,1);
 digitalWrite(RD5,0);
 digitalWrite(RD6,1);
 digitalWrite(RD7,0);
}



//Detectar línea blanca
void detectarlinea(int sensor4,int sensor5,int sensor6,int sensor7)
{
 		// Consulta SI los sensores digitales están en nivel HIGH mediante una función OR
		if (digitalRead(sensor4) || digitalRead(sensor5) || digitalRead(sensor6) || digitalRead(sensor7))
  {
			// Detecta cual sensor se activo y toma una acción en consecuencia
			if(digitalRead(sensor4))
			{
				atras();
				delay(1000);
			}
			if (digitalRead(sensor5))
			{
				atras();
				delay(1000);
			}
			if (digitalRead(sensor6))
			{
				adelante();
				delay(1000);
			}
			if (digitalRead(sensor7))
			{
				adelante();
				delay(1000);
			}
		}
}


// PROGRAMA PRINCIPAL

void loop() 
{
	adelante();
    detectarlinea(RB4,RB5,RB6,RB7);
}
