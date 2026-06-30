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
const int servoMin = 2000; // Closing direction
const int servoMax = 1000; // Opening direction

int joystickCenter = 512;
const int deadband = 80;

// --- AUTOMATIC TEST 2 SETTINGS ---
const int CLOSE_SPEED = 2000; 
const int OPEN_SPEED = 1000; 

bool manualMode = true; 

// Timer for live display
unsigned long lastDisplay = 0;

void setup() {
  Serial.begin(9600);
  
  myServo.attach(servoPin);

  // Joystick calibration at startup
  long sum = 0;
  for (int i = 0; i < 100; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }
  joystickCenter = sum / 100;

  // HX711 initialization
  scale.begin(DOUT, CLK);
  
  // ---> MODIFY THIS LINE FOR CALIBRATION:
  scale.set_scale(11400.f); 
  
  scale.tare(); // Set force to 0 at startup

  myServo.writeMicroseconds(servoStop);

  Serial.println("\n=== SYSTEM READY ===");
  Serial.println("-> Joystick ACTIVE.");
  Serial.println("-> Displaying live force for calibration...");
  Serial.println("-> Type 'c' to start Automatic Cycle.");
}

void loop() {
  
  // --- 1. READ COMMANDS (Start Test 2) ---
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    
    if (cmd == 'c') {
      manualMode = false; 
      executeCycle();    
      
      scale.tare();       
      manualMode = true;  
      Serial.println("\n[RETURN] Joystick mode active. Resuming live display.");
    }
  }

  // --- 2. MANUAL MODE (JOYSTICK + LIVE DISPLAY) ---
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

    // --- Live force display twice per second ---
    if (millis() - lastDisplay > 500) {
      float currentForce = scale.get_units(5); // Average over 5 readings for stability
      Serial.print("Calibration | Current force: ");
      Serial.println(currentForce);
      lastDisplay = millis();
    }
  }
}

// --- AUTOMATIC CYCLE FUNCTION ---
void executeCycle() {
  unsigned long startTime = millis();

  Serial.println("\n--- PHASE 1: CLOSING ---");
  myServo.writeMicroseconds(CLOSE_SPEED);
  while(millis() - startTime < 2000) { 
     logData(startTime);
  }

  Serial.println("--- PHASE 2: HOLD (5s) ---");
  myServo.writeMicroseconds(CLOSE_SPEED); 
  unsigned long holdStart = millis();
  while(millis() - holdStart < 5000) {
     logData(startTime);
  }

  Serial.println("--- PHASE 3: OPENING ---");
  myServo.writeMicroseconds(OPEN_SPEED);
  unsigned long openStart = millis();
  while(millis() - openStart < 2000) {
     logData(startTime);
  }

  myServo.writeMicroseconds(servoStop);
  Serial.println("--- END OF CYCLE ---");
}

// --- DATA LOGGING FUNCTION ---
void logData(unsigned long zeroTime) {
   float force = scale.get_units(1); 
   unsigned long t = millis() - zeroTime;
   
   Serial.print(t); 
   Serial.print(",");
   Serial.println(force); 
   delay(50); 
}