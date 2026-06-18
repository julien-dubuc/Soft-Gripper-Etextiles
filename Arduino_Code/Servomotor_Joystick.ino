#include <Servo.h>

Servo myServo;

// Pins
const int servoPin = 9;
const int joystickPin = A0;

// Continuous servo calibration
int servoStop = 1520;   // Adjust this if the servo still moves at rest
const int servoMin = 1000;
const int servoMax = 2000;

// Joystick calibration
int joystickCenter = 512;
const int deadband = 80;   // Increase this if needed

void setup() {
  Serial.begin(9600);

  myServo.attach(servoPin);

  // Calibrate joystick centre at startup
  // Keep the joystick untouched when powering/resetting Arduino
  long sum = 0;
  const int samples = 100;

  for (int i = 0; i < samples; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }

  joystickCenter = sum / samples;

  Serial.print("Joystick centre calibrated at: ");
  Serial.println(joystickCenter);

  // Stop servo at startup
  myServo.writeMicroseconds(servoStop);
}

void loop() {
  int joystickValue = analogRead(joystickPin);

  int pulseWidth;

  int difference = joystickValue - joystickCenter;

  if (abs(difference) < deadband) {
    pulseWidth = servoStop;
  } else {
    if (difference > 0) {
      pulseWidth = map(difference, deadband, 1023 - joystickCenter, servoStop, servoMax);
    } else {
      pulseWidth = map(difference, -deadband, -joystickCenter, servoStop, servoMin);
    }
  }

  myServo.writeMicroseconds(pulseWidth);

  Serial.print("Joystick: ");
  Serial.print(joystickValue);
  Serial.print(" | Centre: ");
  Serial.print(joystickCenter);
  Serial.print(" | Pulse: ");
  Serial.println(pulseWidth);

  delay(20);
}
