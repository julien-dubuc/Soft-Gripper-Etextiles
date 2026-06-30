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
const int servoMin = 2000;
const int servoMax = 1000;
int joystickCenter = 512;
const int deadband = 80;

// --- FATIGUE TEST SETTINGS ---
const int CLOSE_SPEED = 2000; // Full power to close
const int OPEN_SPEED_REDUCED = 1200; // Softer opening speed
const int OPEN_TIME = 800; // Time in milliseconds
const int TOTAL_CYCLES = 500;
int currentCycle = 0;
bool manualMode = true;

void setup() {
  Serial.begin(9600);
  
  myServo.attach(servoPin);
  myServo.writeMicroseconds(servoStop);

  // Joystick calibration at startup
  long sum = 0;
  for (int i = 0; i < 100; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }
  joystickCenter = sum / 100;

  scale.begin(DOUT, CLK);
  scale.set_scale(11400.f);
  scale.tare();

  Serial.println("\n=== TEST BENCH: TEST 5 (FATIGUE) ===");
  Serial.println("-> Joystick ACTIVE.");
  Serial.println("-> Type 's' to start the fatigue test.");
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    if (cmd == 's') {
      manualMode = false;
      runFatigueTest();
      manualMode = true;  
      scale.tare();       
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
void runFatigueTest() {
  Serial.println("\nSTARTING TEST");
  Serial.println("Cycle,Max_Force_N");
 
  for (currentCycle = 1; currentCycle <= TOTAL_CYCLES; currentCycle++) {
   
    // 1. CLOSING PHASE (1.5 seconds)
    myServo.writeMicroseconds(CLOSE_SPEED);
    unsigned long closeStart = millis();
    float maxForceThisCycle = 0;
   
    while (millis() - closeStart < 1500) {
      float currentForce = scale.get_units(1);
      if (currentForce > maxForceThisCycle) {
        maxForceThisCycle = currentForce;
      }
    }
    // 2. OPENING PHASE (Recalibrated)
    myServo.writeMicroseconds(OPEN_SPEED_REDUCED);
    delay(OPEN_TIME);
   
    // 3. REST PERIOD (0.5 seconds)
    myServo.writeMicroseconds(servoStop);
    delay(500);
   
    // 4. DISPLAY RESULTS
    Serial.print(currentCycle);
    Serial.print(",");
    Serial.println(maxForceThisCycle);
   
    // 5. THERMAL SAFETY (Pause every 100 cycles)
    if (currentCycle % 100 == 0 && currentCycle < TOTAL_CYCLES) {
      Serial.println("# [PAUSE] Servo thermal safety: 30s break... #");
      delay(30000);
      scale.tare();
    }
  }

  Serial.println("END");
}