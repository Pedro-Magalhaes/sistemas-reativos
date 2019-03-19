
#include "event_driven.h"
#include "app.h"
#include "pindefs.h"
#define B_TIMEOUT 300

bool listenButtons[3] = { false,false,false };
int lastButtonRead[3] = { HIGH, HIGH, HIGH };
unsigned short int buttonsTimeout[] = { B_TIMEOUT, B_TIMEOUT, B_TIMEOUT };
unsigned short int buttonsCurrTime[] = { 0, 0, 0 };
unsigned int timer = 0;
unsigned long int whenTimeWasSet = 0;


void button_listen (int pin) {
  if( pin == BUTTON1 ){
     listenButtons[0] = true;
  }  
  else if( pin==BUTTON2 ){
    listenButtons[1] = true;
  }
  else if( pin == BUTTON3 ) {
    listenButtons[2] = true;
  }
}
void timer_set (int n,int ms) {
  whenTimeWasSet = millis();
  timer = ms;
}

void setup() {
  // put your setup code here, to run once:
  pinMode(BUTTON1,INPUT_PULLUP);
  pinMode(BUTTON2,INPUT_PULLUP);
  pinMode(BUTTON3,INPUT_PULLUP);  
  appinit();

}

void loop() {
  // put your main code here, to run repeatedly:
  int but1 = digitalRead(BUTTON1);
  int but2 = digitalRead(BUTTON2);
  int but3 = digitalRead(BUTTON3);
  unsigned long now = millis(); 
  if( listenButtons[0] && ( but1 != lastButtonRead[0] ) && ( now >= buttonsCurrTime[0] + buttonsTimeout[0] )  ) {
    lastButtonRead[0] = but1;
    buttonsCurrTime[0] = now;
    button_changed(BUTTON1,but1);
  }
  if( listenButtons[1] && ( but2 != lastButtonRead[1] ) && ( now >= buttonsCurrTime[1] + buttonsTimeout[1] )  ) {
    lastButtonRead[1] = but2;
    buttonsCurrTime[1] = now;
    button_changed(BUTTON2,but2);
  }
  if( listenButtons[2] && ( but3 != lastButtonRead[2] ) && ( now >= buttonsCurrTime[2] + buttonsTimeout[2] )  ) {
    buttonsCurrTime[2] = now;
    lastButtonRead[2] = but3;
    button_changed(BUTTON2,but3);
  }
  if( timer && ( now >= whenTimeWasSet + timer) ) {
     timer_expired();
  }
  
  
  
}
