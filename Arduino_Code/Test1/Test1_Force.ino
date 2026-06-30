#include <Servo.h>
#include "HX711.h"

Servo myServo;
HX711 scale;

// --- PINS ---
const int servoPin = 9;
const int joystickPin = A0;
const int DOUT = 3;
const int CLK = 2;

// --- SERVO & JOYSTICK SETTINGS ---
int servoStop = 1520;  
const int servoMin = 2000; // Closing direction (pressing sensor)
const int servoMax = 1000; // Opening direction (releasing)

int joystickCenter = 512;
const int deadband = 80;

// --- MICRO-STEPS FOR FORCE ADJUSTMENT ---
const int PUSH_SPEED = 1600;
const int RETRACT_SPEED = 1440;  
const int MS_MICRO_STEP = 15;    

bool manualMode = true;
float currentForce = 0.0; // Stores force reading

void setup() {
  Serial.begin(9600);
  
  myServo.attach(servoPin);
  myServo.writeMicroseconds(servoStop);

  // Joystick calibration (DO NOT TOUCH JOYSTICK DURING STARTUP)
  long sum = 0;
  for (int i = 0; i < 100; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }
  joystickCenter = sum / 100;

  // Load Cell initialization
  scale.begin(DOUT, CLK);
  scale.set_scale(11400.f);
  scale.tare();

  Serial.println("\n=== TEST BENCH: TEST 1 (STIFFNESS + LOAD CELL) ===");
  Serial.println("-> Joystick ACTIVE: Move gripper near sensor.");
  Serial.println("-> Type '+' to increase force slightly");
  Serial.println("-> Type '-' to decrease force slightly");
  Serial.println("-> Type 't' to TARE (0 N)");
  Serial.println("-> Type 'j' to return to Joystick mode");
}

void loop() {
 
  // 1. READ FORCE WITHOUT BLOCKING ARDUINO
  if (scale.is_ready()) {
    currentForce = scale.get_units(1); // Read once when ready
  }

  // 2. PERIODIC DISPLAY
  static unsigned long previousTime = 0;
  if (millis() - previousTime > 300) {
    Serial.print("Active force: ");
    Serial.print(currentForce);
    Serial.println(" N  [Press + / - to adjust]");
    previousTime = millis();
  }

  // --- 3. SERIAL COMMANDS ---
  if (Serial.available() > 0) {
    char cmd = Serial.read();

    if (cmd == '+') {
      manualMode = false; // Disable joystick to avoid interference
      myServo.writeMicroseconds(PUSH_SPEED);
      delay(MS_MICRO_STEP);
      myServo.writeMicroseconds(servoStop);
    }
    else if (cmd == '-') {
      manualMode = false;
      myServo.writeMicroseconds(RETRACT_SPEED);
      delay(MS_MICRO_STEP);
      myServo.writeMicroseconds(servoStop);
    }
    else if (cmd == 't' || cmd == 'T') {
      scale.tare();
      Serial.println("\n[TARE DONE] Sensor at 0.00 N.");
    }
    else if (cmd == 'j' || cmd == 'J') {
      manualMode = true;
      Serial.println("\n[RETURN] Joystick mode active.");
    }
  }

  // --- 4. JOYSTICK MODE ---
  if (manualMode) {
    int joystickValue = analogRead(joystickPin);
    int pulseWidth;
    int difference = joystickValue - joystickCenter;

    if (abs(difference) < deadband) {
      pulseWidth = servoStop; // Immediate stop
    } else {
      pulseWidth = (difference > 0) ? map(difference, deadband, 1023 - joystickCenter, servoStop, servoMax) : 
                                      map(difference, -deadband, -joystickCenter, servoStop, servoMin);
    }
    myServo.writeMicroseconds(pulseWidth);
  }
}