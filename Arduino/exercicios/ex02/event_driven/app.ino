#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

#define WAIT_TIME 20 // tempo de espera para definir se 2 botões foram clicados ao mesmo tempo
#define MIN_TIME 100
#define MAX_TIME 3000
#define TIME_STEP 250

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
  if ( (p != lastButtonPressed) && (now - lastButtonChange < WAIT_TIME)) { // termina o programa
      digitalWrite(LED1, LOW);
      while(1);
  }
  if ( p == BUTTON1 && v == LOW) {
      if ( ledTime < MAX_TIME - TIME_STEP ) {
      ledTime += TIME_STEP;
      } else {
      ledTime = MAX_TIME;
    }
  }
  else if ( p == BUTTON2 && v == LOW) {
      if ( ledTime > MIN_TIME + TIME_STEP ) {
        ledTime -= TIME_STEP;
      } else {
        ledTime = MIN_TIME;
      }      
  }
  lastButtonPressed = p;
  lastButtonChange = now;
}


void timer_expired(void) {
  ledValue = !ledValue;
  digitalWrite(LED1, ledValue);
  timer_set(0,ledTime);
}
