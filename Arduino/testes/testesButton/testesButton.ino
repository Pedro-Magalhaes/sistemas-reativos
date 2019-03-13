
int state = HIGH;
unsigned long old = 0;
unsigned short int timeout = 1000;
unsigned short int maxTimeout = 4000;
unsigned short int minTimeout = 500;

void increaseTimeout() {
  unsigned short int newTimeout = timeout + minTimeout;
  timeout = (newTimeout < maxTimeout)? newTimeout : maxTimeout;
}

void decreaseTimeout() {
  unsigned short int newTimeout = timeout - minTimeout;
  timeout = (newTimeout > minTimeout)? newTimeout : minTimeout;
}

void swapState() {
  state = state == HIGH? LOW : HIGH;
}

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  unsigned long now = millis();
  int button1 =  analogRead(A1);
  int button2 =  analogRead(A2);
  if (button1 == HIGH) {
    increaseTimeout();
  }
  if (button2 == HIGH) {
    decreaseTimeout();
  }
  if ( now >= old + timeout ) {
    old = now;
    swapState();
    digitalWrite(LED_BUILTIN, state);   // turn the LED on or off
  }
  
  
  
}
