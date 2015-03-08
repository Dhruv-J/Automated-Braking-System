
#include <Servo.h>

/* This project uses an ultrasonic sensor to trigger a brake on a wheel once something gets closer
 * than 3 centimeters.
 * Function targetDistance: This function uses the ultrasonic sensor to find out the distance between
 *   it and the object and displays it in centimeters. 
 * Function servoMeter: this function instructs the arduino moves the servo to a position on the 180 
 *   degree scale. The servo is marked as red, orange, and green for close, medium, and far, 
 *   respectively. 
 * Function brakeDistance: applies a brake to the wheel based on the same scale as the servoMeter
 *   function
*/

int trigPin = 11;  // This pin sends out the ping.
int echoPin = 13;  // This pin recieves the ping and calculates how much time it took for the ping to
                     // come back.
int maxMeasure = 180; 
int linearity = 1;
int meterServoPin = 7;
int brakeServoPin = 8;

Servo meterServo;  //This displays the distance on a meter.
Servo brakeServo;  //This servo applys the brakes to the wheel.

float pingTime;

void setup() {
  Serial.begin(9600);
  meterServo.attach(meterServoPin);
  brakeServo.attach(brakeServoPin);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

long targetDistance() {
  long duration;   // the amount of time in microseconds it takes for the ping to go and come back
  long cms;        // the distance in centimeters to the object in front of the ultrasonic sensor

  // Step 1: Send the pulse
  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(trigPin, OUTPUT);
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(trigPin, LOW);
  
  // Step 2: Recieve the pulse
  // The echoPin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);

  // Step 3: convert the time into a distance
  cms = duration / 58;

  return cms;
}

int servoAngle(long targetDist) {
  
  float unitAngle = (180000) / maxMeasure;
  int currentLinearity;
 
  currentLinearity = linearity;
  while(currentLinearity > 1) {
   unitAngle = sqrt(unitAngle);
   currentLinearity -= 1;
  }
  
  if (targetDist > maxMeasure) {
     targetDist = maxMeasure;             // cap it to max measurable distance
  }

  float meterAngle = targetDist;
  currentLinearity = linearity;
  while(currentLinearity > 1) {
   targetDist = sqrt(targetDist);
   currentLinearity -= 1;
  }
  
  meterAngle = (meterAngle * unitAngle) / 1000;
  
  return meterAngle;
}
 
int applyBrakes(long targetDist) {
  int brakeAngle = 0;
  
  if(targetDist < 10) {
    int unitBrake;
    
    unitBrake = 90 / 10;
    brakeAngle = (10 - targetDist) * unitBrake;
  }
  else {
    brakeAngle = 5;
  }
  
  brakeServo.write(brakeAngle);

}

void loop() {
  float targetDist; 
  char str[100];
  targetDist = targetDistance();
  
  int meterAngle = servoAngle(targetDist);

  meterServo.write(meterAngle);
  applyBrakes(targetDist);
  
  sprintf(str, "The Target Distance is: %d, angle is %d \n", (int)targetDist, meterAngle);
  Serial.print(str);
 
  delay(1000);
}
