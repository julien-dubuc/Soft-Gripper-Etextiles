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

// --- TEST 3 ADDITIONS ---
bool manualMode = true; // Toggle between Joystick and Test commands
const int CLOSE_SPEED = servoMin; 
const int OPEN_SPEED = servoMax; 
// -----------------------------

void setup() {
  Serial.begin(9600);

  myServo.attach(servoPin);

  // Calibrate joystick center at startup
  long sum = 0;
  const int samples = 100;

  for (int i = 0; i < samples; i++) {
    sum += analogRead(joystickPin);
    delay(5);
  }

  joystickCenter = sum / samples;

  Serial.print("Joystick center calibrated at: ");
  Serial.println(joystickCenter);

  // Stop servo at startup
  myServo.writeMicroseconds(servoStop);
  
  // Instructions on Serial Monitor
  Serial.println("\n=== SYSTEM READY ===");
  Serial.println("Use the Joystick to move the gripper.");
  Serial.println("\n--- TEST 3 COMMANDS (Keyboard) ---");
  Serial.println("Type 'd' -> DETACH servo (0W pull-out test)");
  Serial.println("Type 'o' -> FULL OPEN (Current peak test)");
  Serial.println("Type 'm' -> Return to JOYSTICK control");
}

void loop() {
  
  // --- 1. READ TEST 3 COMMANDS ---
  if (Serial.available() > 0) {
    char command = Serial.read();
    
    if (command == 'd') {
      manualMode = false; // Disable joystick
      myServo.detach();
      Serial.println("\n[TEST] Servo DETACHED. Signal cut.");
      Serial.println("-> Disconnect VCC and pull with dynamometer!");
    } 
    else if (command == 'o') {
      manualMode = false; // Disable joystick
      if (!myServo.attached()) myServo.attach(servoPin);
      myServo.writeMicroseconds(OPEN_SPEED);
      Serial.println("\n[TEST] MAXIMUM OPENING! Check the multimeter!");
    }
    else if (command == 'm') {
      manualMode = true; // Enable joystick
      if (!myServo.attached()) myServo.attach(servoPin);
      myServo.writeMicroseconds(servoStop);
      Serial.println("\n[RETURN] Joystick mode active.");
    }
  }

  // --- 2. MANUAL MODE (JOYSTICK) ---
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

    // Serial.print("Joystick: ");
    // Serial.print(joystickValue);
    // Serial.println(pulseWidth);
  }

  delay(20);
}