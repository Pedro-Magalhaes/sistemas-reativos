#include "event_driven/event_driven.h"
#include "app.h"
#include "../shared/pindefs.h"

unsigned int ledValue = 0;
unsigned short int ledTime = 500;
unsigned long int lastButtonChange = 0;
int lastButtonPressed = -1;

void appinit(void) {
  pinMode(LED1,OUTPUT);
  digitalWrite(LED1, LOW);
  button_listen(BUTTON1);
  button_listen(BUTTON2);
  timer_set(0,ledTime);
  
  
}


void button_changed(int p, int v) {
  unsigned long int now = millis();
  if ( (p != lastButtonPressed) && (now - lastButtonChange < 100)) { // termina o programa
      digitalWrite(LED1, LOW);
      while(1);
  }
  if ( p == BUTTON1 && v == LOW) {     
      ledTime += 250;
  }
  else if ( p == BUTTON2 && v == LOW) {
      ledTime -= 250;
  }
  lastButtonPressed = p;
  lastButtonChange = now;
}


void timer_expired(void) {
  ledValue = !ledValue;
  digitalWrite(LED1, ledValue);
  timer_set(0,ledTime);
}
