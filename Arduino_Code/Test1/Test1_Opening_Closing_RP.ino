#include <Servo.h>
Servo myServo;

// --- PINS ---
const int servoPin = 9;
const int joystickPin = A0;

// --- SERVO & JOYSTICK SETTINGS ---
int servoStop = 1520;  
const int servoMin = 2000; // Closing direction
const int servoMax = 1000; // Opening direction

int joystickCenter = 512;
const int deadband = 80;

// --- TEST 1 R&P SETTINGS (10% INCREMENTS) ---
const int CLOSE_SPEED = 2000;
const int OPEN_SPEED = 1000;

// Adjust times so 10 steps correspond to full opening
const int STEP_TIME_CLOSE = 450;
const int STEP_TIME_OPEN = 430;

int positionPercent = 0; // 0% = Gripper CLOSED
bool manualMode = true;

void setup() {
  Serial.begin(9600);
  myServo.attach(servoPin);
  myServo.writeMicroseconds(servoStop);

  long sum = 0;
  for (int i = 0; i < 100; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }
  joystickCenter = sum / 100;

  Serial.println("\n=== TEST BENCH: TEST 1 (HOMING CLOSED) ===");
  Serial.println("-> Joystick ACTIVE. Use it to fully CLOSE the gripper.");
  Serial.println("-> Type '+' to OPEN by 10% (Forward)");
  Serial.println("-> Type '-' to CLOSE by 10% (Backward)");
  Serial.println("-> Type 'o' for FULL OPEN (100%)");
  Serial.println("-> Type 'f' for FULL CLOSE (0%)");
  Serial.println("-> Type 'j' to return to Joystick mode");
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();

    if (cmd == '+') {
      manualMode = false;
      if (positionPercent < 100) {
        positionPercent += 10;
        myServo.writeMicroseconds(OPEN_SPEED);
        delay(STEP_TIME_OPEN);
        myServo.writeMicroseconds(servoStop);
      } else {
        Serial.println("! Gripper already at 100% !");
      }
      displayState();
    }
    else if (cmd == '-') {
      manualMode = false;
      if (positionPercent > 0) {
        positionPercent -= 10;
        myServo.writeMicroseconds(CLOSE_SPEED);
        delay(STEP_TIME_CLOSE);
        myServo.writeMicroseconds(servoStop);
      } else {
        Serial.println("! Gripper already at 0% !");
      }
      displayState();
    }
    else if (cmd == 'o' || cmd == 'O') {
      manualMode = false;
      if (positionPercent < 100) {
        int remainingSteps = (100 - positionPercent) / 10;
        unsigned long travelTime = remainingSteps * STEP_TIME_OPEN;
        positionPercent = 100;
        myServo.writeMicroseconds(OPEN_SPEED);
        delay(travelTime);
        myServo.writeMicroseconds(servoStop);
        Serial.println("\n[ACTION] Full open completed.");
      } else {
        Serial.println("! Gripper already at 100% !");
      }
      displayState();
    }
    else if (cmd == 'f' || cmd == 'F') {
      manualMode = false;
      if (positionPercent > 0) {
        int remainingSteps = positionPercent / 10;
        unsigned long travelTime = remainingSteps * STEP_TIME_CLOSE;
        positionPercent = 0;
        myServo.writeMicroseconds(CLOSE_SPEED);
        delay(travelTime);
        myServo.writeMicroseconds(servoStop);
        Serial.println("\n[ACTION] Full close completed.");
      } else {
        Serial.println("! Gripper already at 0% !");
      }
      displayState();
    }
    else if (cmd == 'j' || cmd == 'J') {
      manualMode = true;
      Serial.println("\n[RETURN] Joystick mode active.");
    }
  }

  if (manualMode) {
    int joystickValue = analogRead(joystickPin);
    int pulseWidth;
    int difference = joystickValue - joystickCenter;

    if (abs(difference) < deadband) {
      pulseWidth = servoStop;
    } else {
      pulseWidth = (difference > 0) ? map(difference, deadband, 1023 - joystickCenter, servoStop, servoMax) : 
                                      map(difference, -deadband, -joystickCenter, servoStop, servoMin);
    }
    myServo.writeMicroseconds(pulseWidth);
  }
}

void displayState() {
  Serial.println("\n-----------------------------------------");
  Serial.print("Current position: ");
  Serial.print(positionPercent);
  Serial.println(" %");
  Serial.println("-> [PAUSE] Record via OptiTrack.");
  Serial.println("-----------------------------------------");
}