
#include "event_driven.h"
#include "pindefs.h"
#include "app.h"
#define B_TIMEOUT 50
#define MAX_TIMERS 3
#define N_BUTTONS 3

typedef struct timer {
  unsigned long int whenTimeWasSet = 0;
  unsigned int timer = 0;
  bool inUse = false;
} Timer;

typedef struct eventButtons {
  int buttonPin;
  int lastButtonRead = HIGH;
  unsigned short int buttonCurrTime = 0;
  bool isListen = false;
} EventButtons;

Timer timers[MAX_TIMERS];
EventButtons buttons[N_BUTTONS];

// Inicializa os buttons e coloca o pin mode de cada pra PULLUP
void setup_buttons() {
  int b_pins[] = { BUTTON1, BUTTON2, BUTTON3 }; // [0] == bt1, [1] == bt2, [2] == bt3

  for ( int i = 0; i < N_BUTTONS; i++) {
    buttons[i].buttonPin = b_pins[i];
    buttons[i].buttonCurrTime = 0;
    buttons[i].lastButtonRead = HIGH;
    buttons[i].isListen = false;
    pinMode(buttons[i].buttonPin, INPUT_PULLUP);
  }
}

// Cria um listener para um botão
void button_listen (int pin) {
  for (int i = 0; i < N_BUTTONS; i++) {
    if ( pin == buttons[i].buttonPin) {
      buttons[i].isListen = true;
    }
  }
}

void timer_set (int timerId, int ms) {
  timers[timerId].inUse = true;
  timers[timerId].whenTimeWasSet = millis();
  timers[timerId].timer = ms;
}

void timer_clear (int timerId) {
  timers[timerId].inUse = false;
}

void setup() {
  setup_buttons();
  appinit();
}

void loop() {

  int curr_button_read[N_BUTTONS];
  unsigned long now;
  for (int i = 0; i < N_BUTTONS; i++) {
    curr_button_read[i] = digitalRead(buttons[i].buttonPin);
  }

  now = millis();
  // Check dos buttons
  for (int i = 0; i < N_BUTTONS; i++) {
    if (( buttons[i].isListen ) && // está sendo "monitorado?"
        ( curr_button_read[i] != buttons[i].lastButtonRead ) &&  // Mudou de estado?
        ( now >= buttons[i].buttonCurrTime + B_TIMEOUT )) { // Não é ruido?

      buttons[i].lastButtonRead = curr_button_read[i];
      buttons[i].buttonCurrTime = now;
      button_changed(buttons[i].buttonPin, curr_button_read[i]);
    }
  }
  // Check dos timers
  for (int i = 0; i < MAX_TIMERS; i++) {
    if ( timers[i].inUse && ( now >= timers[i].whenTimeWasSet + timers[i].timer) ) {
      timers[i].timer = 0;
      timers[i].inUse = false;
      timer_expired(i,now);
    }
  }
}
