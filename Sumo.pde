/*
Prototipo: Sumo - Datumi724
Autores: Carballo Gonzalo & Mansilla Damián
Fecha 26 / 11 / 2013
*/
#define PIC18F4550
//definición de variables y pines
int led1;	
int pwm1;
int pwm2;
int motor1;
int motor2;								
int tiempo;
int boton1;
int boton2;
int trig;
int echo;
int t1;
int t2;
int t3;
int t4;
int s1;
int s2;
int s3;
int s4;
int tiempo;
int distancia;
int tiempoInicio;
int tiempoActividad;
void configurarPuertos(){
	led1=6;		
	pwm1=11;
	pwm2=12;
	motor1=3;
	motor2=2;
	//botones de control
	boton1 = 5;
	boton2 = 4;
	//ultrasonido
	trig=14;
	echo = 13;
	//transmisores y sensores
	t1=28;
	t2=26;
	t3=9;
	t4=24;
	s1=27;
	s2=25;
	s3=8;
	s4=23;
}

void definicionPinesES(){
	//definición de salidas
	pinMode(pwm1,OUTPUT);
	pinMode(pwm2,OUTPUT);
	digitalWrite(pwm1,LOW);
	digitalWrite(pwm2,LOW);
	pinMode(motor1,OUTPUT);
	pinMode(motor2,OUTPUT);
	pinMode(led1,OUTPUT);
	pinMode(t1,OUTPUT);
	pinMode(t2,OUTPUT);
	pinMode(t3,OUTPUT);
	pinMode(t4,OUTPUT);
	
	//definicion de entradas
	pinMode(s1,INPUT);
	pinMode(s2,INPUT);
	pinMode(s3,INPUT);
	pinMode(s4,INPUT);
	pinMode(trig,OUTPUT);
	pinMode(echo,INPUT);
}

void preparar(){

	digitalWrite(t1,HIGH);
	digitalWrite(t2,HIGH);
	digitalWrite(t3,HIGH);
	digitalWrite(t4,HIGH);
	
}
void setup() 
{

	configurarPuertos();
	definicionPinesES();
	preparar();
	
}

void motoresAdelante(){
//motor 2 derecho
//motor 1 izquierdo
	digitalWrite(motor1,LOW);
	digitalWrite(motor2,HIGH);
	digitalWrite(pwm1,HIGH);
	digitalWrite(pwm2,HIGH);

}

void motoresAtras(){
	digitalWrite(motor1,HIGH);
	digitalWrite(motor2,LOW);
	digitalWrite(pwm1,HIGH);
	digitalWrite(pwm2,HIGH);

}

void motoresGirarIzquierda(){
	digitalWrite(pwm1,LOW);
	digitalWrite(pwm2, HIGH);
	digitalWrite(motor2,HIGH);
}

void motoresGirarDerecha(){
	digitalWrite(pwm2,LOW);
	digitalWrite(pwm1,HIGH);
	digitalWrite(motor1,HIGH);
}
void detenerMotores(){
	digitalWrite(pwm1,LOW);
	digitalWrite(pwm2,LOW);
}
void motoresAtrasIzquierda(){
	
	digitalWrite(motor2,LOW);
	digitalWrite(pwm1,LOW);
	digitalWrite(pwm2,HIGH);
	
}
void motoresAtrasDerecha(){
	digitalWrite(motor1,HIGH);
	digitalWrite(pwm1,HIGH);
	digitalWrite(pwm2,LOW);

}
int medirDistancia(){
	distancia = 0;
	while (digitalRead(echo) == LOW) {//Pin del eco en bajo
		digitalWrite(trig, HIGH);//Activa el disparador
		delayMicroseconds(50);//Espera 50 microsegundos (minimo 10)
		digitalWrite(trig, LOW);//Desactiva el disparador
	}
	while (digitalRead(echo) == HIGH) {//Pin de eco en alto hasta que llegue el eco
		distancia++;//El contador se incrementa hasta llegar el eco
		delayMicroseconds(58);//Tiempo en recorrer dos centimetros 1 de ida 1 de vuelta
	}
	return distancia;
}

int tiempoJuego(){					     // millis() devuelve el tiempo de ejecución del programa
	tiempoActividad = (millis() - tiempoInicio) / 1000; // pasa el tiempo de milisegundos a segundos
	return tiempoActividad;
}
void tiempoAtras(int veces, int tiempo){
	int i = 0;
	for(i=0; i< veces; i++){
	digitalWrite(led1,HIGH);
	delay(tiempo);
	digitalWrite(led1,LOW);
	delay(tiempo);
	}
}
void loop() 
{
int activo=0; //bandera para que el robot busque
	while (1)
	{
		//al tocar boton 2 lado derecho del robot contar hasta 10 y arrancarPartida
		if (digitalRead(boton2)){
			tiempoAtras(10,500);
			activo=1;
			tiempoInicio = millis();
			motoresAdelante();
			
		}
		if (digitalRead(boton1)){
			detenerMotores();
			activo =0;
				
		}
		//si los sensores encuentran linea blanca
		if ( (activo == 1) && (digitalRead(s1) || digitalRead(s2) || digitalRead(s3) || digitalRead(s4)) ){
			//ver cual es y tomar una estrategia de accion
			if(digitalRead(s1)){

				motoresAtrasDerecha();
			}
			if (digitalRead(s2)){
				motoresGirarDerecha();
			}
			if (digitalRead(s3)){
				motoresAtrasIzquierda();
			}
			if (digitalRead(s4)){
				motoresGirarIzquierda();
			}
		}
		if ((medirDistancia() < 25) && (activo==1)){
				tiempoAtras(3,50); //ver esto
				motoresAdelante();
				
			}else{
				if (activo ==1){
				
				digitalWrite(led1,LOW);
				if ((tiempoJuego()%3) == 0){ //Si el resto(%) de dividir tiempoJuego en 3 es igual cero
							     //cada 9 segundos cambia de estrategia
					motoresGirarDerecha();
				}else{
				
					motoresGirarIzquierda(); //nunca se ejecuto, ver video
				}
			}
		}
	}
	
}
