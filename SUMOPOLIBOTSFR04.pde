// ROBOT SUMO POLIBOT = Pinguino 18F4550 - Puente en H - Sensor SFR04 - Optoacoplador
// Compilado en PinguinoX.4
// Andrés Cintas 30/11/2013

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

// Para usar sensores de Ultrasonido SFR04
const int triggerPin1 = 23;
const int echoPin1 = 24;

const int triggerPin2 = 22;
const int echoPin2 = 21;

// Bandera de Estado
int flag;
int sensor1;
int sensor2;
int delta;
  
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
  
 pinMode(triggerPin1, OUTPUT); // pin  de disparo sensor SFR04
 pinMode(echoPin1, INPUT);  // pin eco sensor SFR04
 pinMode(triggerPin2, OUTPUT); // pin  de disparo sensor SFR04
 pinMode(echoPin2, INPUT);  // pin eco sensor SFR04
 
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

//Convierte microsegundos a centimetros usando la velocidad del sonido
long microsecondsToCentimeters(long microseconds)
{
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}


//Medir distancia en centimetros
long distancia(int trigger, int echo)
{
  // establish variables for duration of the ping, 
  // and the distance result in centimeters:
  long duration, cm;

  // The SFR04 is triggered by a HIGH pulse of 20 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  
  digitalWrite(trigger, LOW);
  delayMicroseconds(2);
  digitalWrite(trigger, HIGH);
  delayMicroseconds(20);
  digitalWrite(trigger, LOW);

  // The echoPin is used to read the signal from the SFR04, a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  
  duration = pulseIn(echo, HIGH, 10000);

  // convert the time into a distance
 
  cm = microsecondsToCentimeters(duration);
  return cm;
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


//Estrategia
void estrategia(void)
{
            sensor1=distancia(triggerPin1,echoPin1);
            sensor2=distancia(triggerPin2,echoPin2);
            // Comentar las siguientes 2 lineas para usar con el robot
            //CDC.printf("sensor1 = %d cm / sensor2 = %d cm \r\n",sensor1,sensor2);  //Texto no mayor a 16 caracteres
            //delay(500);
            
            delta=(sensor1-sensor2)*(sensor1-sensor2); // elevo al cuadrado , valor absoluto
            
            if (delta < 2)
                {
                adelante();
                }else if (delta>=2 && (sensor1 > sensor2))
                    {
                    giroizquierda();
                    }else
                        {
                        giroderecha();
                        }
}



// PROGRAMA PRINCIPAL

void loop() 
{
    detenido();
    flag = 0; // Bandera de estado del robot
        while (RB0 == HIGH)
        {
            if (RB0 == HIGH && flag == 0) // Llave de Largada en RB0
            {
                    detenido();
                    delay(5200); // Tiempo de Largada 5 segundos, solo se ejecuta una vez
                    flag = 1; // Actualizar bandera
            }
            detectarlinea(RB4,RB5,RB6,RB7);
            estrategia();
         }
}