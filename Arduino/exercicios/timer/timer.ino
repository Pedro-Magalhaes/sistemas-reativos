#include "pindefs.h"
#define DIFFTIME 500
byte state = HIGH;
volatile int counter = 0;
unsigned long int tempoB1 = 0;
unsigned long int tempoB2 = 600;
bool stopBlink = false;
void timerSetup () {
   TIMSK2 = (TIMSK2 & B11111110) | 0x01;
   TCCR2B = (TCCR2B & B11111000) | 0x07;
}

volatile int buttonChanged = 0;

void pciSetup (byte pin) {
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));  // enable pin
    PCIFR  |= bit (digitalPinToPCICRbit(pin)); // clear any outstanding interruptjk
    PCICR  |= bit (digitalPinToPCICRbit(pin)); // enable interrupt for the group
}

void disable (byte pin) {
  *digitalPinToPCMSK(pin) &= ~bit (digitalPinToPCMSKbit(pin)); 
}

 


void setup() {
   pinMode(LED1, OUTPUT); digitalWrite(LED1, state);
   pinMode(LED2, OUTPUT); digitalWrite(LED2, state);
   pinMode(LED3, OUTPUT); digitalWrite(LED3, state);
   pinMode(LED4, OUTPUT); digitalWrite(LED4, state);
   pinMode (BUTTON1, INPUT_PULLUP); 
   pinMode (BUTTON2, INPUT_PULLUP);
   pciSetup(BUTTON1);
   pciSetup(BUTTON2);
   timerSetup();
   Serial.begin(9600);
}
 
void loop() {
  if(stopBlink) {
    digitalWrite(LED1, HIGH);
  }
  else {
    if(buttonChanged) {
      if(digitalRead(BUTTON1) == LOW) {
        tempoB1 = millis();
      }
      if(digitalRead(BUTTON2) == LOW) {        
        tempoB2 = millis();
      }
      buttonChanged = 0;
      if( abs( tempoB1 - tempoB2 ) < DIFFTIME ) {
        stopBlink = true;
      }
    }  
    if (counter > 50) {
      state = !state;
      digitalWrite(LED1, state);
      counter = 0;
    }
  }  
}
 
ISR(TIMER2_OVF_vect){
   counter++;
}

ISR(PCINT1_vect) { // handle pin change interrupt for A0 to A5 here
  buttonChanged = 1;  
} 

