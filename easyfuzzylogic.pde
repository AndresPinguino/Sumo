/*
Fuzzy Obstacle Avoidance Module - FOAM
by Richard Morrow
Research Media & Cybernetics
http://www.rmcybernetics.com/
*/

#include <NewPing.h>      // Ping Library for SRF04

// PORTS - INPUT
#define SONAR_LEFT_ECHO 7
#define SONAR_RIGHT_ECHO 13
#define SONAR_FRONTLEFT_ECHO 15
#define SONAR_FRONTRIGHT_ECHO 17
#define SONAR_BACK_ECHO A5

// PORTS - OUTPUT
#define MOTOR_SPD_L 10  // Left Motor PWM out
#define MOTOR_SPD_R 11  // Right Motor PWM out
#define MOTOR_DIR_L 8  // Left Motor Direction
#define MOTOR_DIR_R 9  // Right Motor Direction
#define SONAR_LEFT_TRIG 6
#define SONAR_RIGHT_TRIG 12
#define SONAR_FRONTLEFT_TRIG 14
#define SONAR_FRONTRIGHT_TRIG 16
#define SONAR_BACK_TRIG A4

// VARIABLES - INPUT
int sonarLeftVAL = 0;
int sonarRightVAL = 0;
int sonarFrontLeftVAL = 0;
int sonarFrontRightVAL = 0;
int sonarBackVAL = 0;
  
// VARIABLES - OUTPUT
int motorSPD_L = 0;
int motorSPD_R = 0;

// VARIABLES - SYSTEM
int newMotorSPD_L = 0;
int newMotorSPD_R = 0;
int maxPing = 100; // Limit sensors to reading 100cm
NewPing SONARLeft(SONAR_LEFT_TRIG, SONAR_LEFT_ECHO, maxPing); // TRIG, ECHO, MaxDistance
NewPing SONARRight(SONAR_RIGHT_TRIG, SONAR_RIGHT_ECHO, maxPing);
NewPing SONARFrontLeft(SONAR_FRONTLEFT_TRIG, SONAR_FRONTLEFT_ECHO, maxPing);
NewPing SONARFrontRight(SONAR_FRONTRIGHT_TRIG, SONAR_FRONTRIGHT_ECHO, maxPing);
NewPing SONARBack(SONAR_BACK_TRIG, SONAR_BACK_ECHO, maxPing);
int basicVelocity = 0;  // How much the CI feels like it should be moving forward
int urgTurn_L = 0;   // urge to turn to the Lefteft
int urgTurn_R = 0;   // urge to turn to the Right
int urgMotor_L = 0;   // urge to move Left motor forward
int urgMotor_R = 0;   // urge to move Right motor forward
int urgFatigue = 0; // Determines motor acceleration rate

// ------------- SYSTEM SETUP -------------
void setup() {
  // SETUP I/O
  pinMode(MOTOR_DIR_L, OUTPUT); 
  pinMode(MOTOR_DIR_R, OUTPUT);
  //pinMode(SONAR_BACK_TRIG, OUTPUT);
   
  Serial.begin(9600);
  ResetSystem();
}


// // ------------- MAIN LOOP -------------
void loop() {
  ReadSensors();
  AvoidWalls();  // Determine actuator speeds based on sensor data
  SetMotors();   // Convert L&R speeds to motor control data
  SerialDebug(); // OUTPUT SERIAL DEBUGGING INFO
}


void ResetSystem() { // ----------- STOP -----------
  digitalWrite(MOTOR_DIR_L, LOW);     // MOTOR FORWARD DIRECTION
  digitalWrite(MOTOR_DIR_R, LOW);   // MOTOR FORWARD DIRECTION
  analogWrite(MOTOR_SPD_L, 0);       // MOTOR SPEED ZERO
  analogWrite(MOTOR_SPD_R, 0);       // MOTOR SPEED ZERO
  delay(10);
}


// ------------- READ SENSOR VALUES AND STORE -------------
void ReadSensors() {

  // ----- SONAR -----
  delay(5); // delay to avoid echos between sensors
  sonarLeftVAL = SONARLeft.ping_cm();  // Get distance in cm from sonar device
  if (SONARLeft.check_timer() == 0) sonarLeftVAL = maxPing;  // set measurment to max instead of 0 if distance is large.
  delay(5); // delay to avoid echos between sensors
  sonarFrontRightVAL = SONARFrontRight.ping_cm();
  if (SONARFrontRight.check_timer() == 0) sonarFrontRightVAL = maxPing;
  delay(5); // delay to avoid echos between sensors
  sonarRightVAL = SONARRight.ping_cm();
  if (SONARRight.check_timer() == 0) sonarRightVAL = maxPing;
  delay(5); // delay to avoid echos between sensors
  sonarFrontLeftVAL = SONARFrontLeft.ping_cm();
  if (SONARFrontLeft.check_timer() == 0) sonarFrontLeftVAL = maxPing;
  sonarBackVAL = SONARBack.ping_cm();
  if (SONARBack.check_timer() == 0) sonarBackVAL = maxPing;
}


// ------------- PROCESS AND INTERPRET SENSOR DATA -------------
void AvoidWalls() {
  
  // GET/SET URGE VALUES
  basicVelocity = 150; // Set above 0 to make it continuously move forward
  urgMotor_L = 0;
  urgMotor_R = 0;
  urgFatigue = 0;

  // AVOID WALLS AT SIDE
  urgTurn_L += maxPing*maxPing - ((maxPing-sonarRightVAL) * (maxPing-sonarRightVAL)); //inverse proportional to square of rightval
  urgTurn_R += maxPing*maxPing - ((maxPing-sonarLeftVAL) * (maxPing-sonarLeftVAL));
  urgMotor_L -= 0.1*(maxPing*maxPing - ((maxPing-sonarRightVAL) * (maxPing-sonarRightVAL)));
  urgMotor_R -= 0.1*(maxPing*maxPing - ((maxPing-sonarLeftVAL) * (maxPing-sonarLeftVAL)));
  
  // AVOID OBJECTS IN FRONT
  urgMotor_L += maxPing*maxPing - 0.5*((maxPing-sonarFrontLeftVAL) * (maxPing-sonarFrontLeftVAL)) - ((maxPing-sonarFrontRightVAL) * (maxPing-sonarFrontRightVAL));
  urgMotor_R += maxPing*maxPing - 0.5*((maxPing-sonarFrontRightVAL) * (maxPing-sonarFrontRightVAL)) - ((maxPing-sonarFrontLeftVAL) * (maxPing-sonarFrontLeftVAL));
  
  // SCALE URGES TO PWM output values (255)
  urgTurn_L = 255 - map(urgTurn_L, 0, 1.8*maxPing*maxPing, -255, 255);  // Scale to within PWM output limits
  urgTurn_R = 255 - map(urgTurn_R, 0, 1.8*maxPing*maxPing, -255, 255);
  urgMotor_L = map(urgMotor_L, 0, 1.8*maxPing*maxPing, -255, 255);  // Scale to within PWM output limits
  urgMotor_R = map(urgMotor_R, 0, 1.8*maxPing*maxPing, -255, 255);

 // SET MOTOR SPEED 
  newMotorSPD_L = basicVelocity + urgMotor_L + (urgTurn_R/4) - (urgTurn_L/2) + 60; 
  newMotorSPD_R = basicVelocity + urgMotor_R + (urgTurn_L/4) - (urgTurn_R/2) + 60; 
  
  // Clip to 255/-255 (negative value means reverse direction)
  if (newMotorSPD_L > 255) newMotorSPD_L = 255;
  if (newMotorSPD_L < -255) newMotorSPD_L = -255;  
  if (newMotorSPD_R > 255) newMotorSPD_R = 255;
  if (newMotorSPD_R < -255) newMotorSPD_R = -255;
  
}


// ------------- SET MOTOR DIRECTION AND PWM OUTPUTS -------------
void SetMotors() { // Convert calculated speed changes to actuator control data
  int lrgSpdDelta = 0; //Used to store largest change in speed
  
  // SET MOTOR DIRECTION
  if (newMotorSPD_L < 0) {
    digitalWrite(MOTOR_DIR_L, LOW); // MOTOR L REVERSE
  } else {
    digitalWrite(MOTOR_DIR_L, HIGH); // MOTOR L FWD
  }
  if (newMotorSPD_R < 0) {
    digitalWrite(MOTOR_DIR_R, LOW); // MOTOR L REVERSE
  } else {
    digitalWrite(MOTOR_DIR_R, HIGH); // MOTOR R FWD
  }
  
  if (urgFatigue > 0) { // If using acceleration
    // CALCULATE SPEED CHANGES
    int dltaSpd_L = newMotorSPD_L - motorSPD_L;
    int dltaSpd_R = newMotorSPD_R - motorSPD_R;
    // Find largest speed difference
    if (abs(dltaSpd_L) >= abs(dltaSpd_L)) {
      lrgSpdDelta = abs(dltaSpd_L);
    } else {
      lrgSpdDelta = abs(dltaSpd_R);
    }
    
    // ACCELERATE MOTORS
    for (int i=0; i<lrgSpdDelta; i++) {
     if (newMotorSPD_L < motorSPD_L) motorSPD_L--;
     if (newMotorSPD_L > motorSPD_L) motorSPD_L++;
     if (newMotorSPD_R < motorSPD_R) motorSPD_R--;
     if (newMotorSPD_R > motorSPD_R) motorSPD_R++;
     analogWrite(MOTOR_SPD_L, abs(motorSPD_L));
     analogWrite(MOTOR_SPD_R, abs(motorSPD_R));
     delay(urgFatigue);// Determines Acceleration
    }
  } else {
    motorSPD_L = newMotorSPD_L;
    motorSPD_R = newMotorSPD_R;
    analogWrite(MOTOR_SPD_L, abs(motorSPD_L));
    analogWrite(MOTOR_SPD_R, abs(motorSPD_R));
  }
  
}// END SetMotors


// ------------- SEND DEBUG INFO ON SERIAL PORT -------------
void SerialDebug() {   
  Serial.print("Sonar LEFT = ");      
  Serial.println(sonarLeftVAL);
}
