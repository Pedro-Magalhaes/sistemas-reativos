#include "pindefs.h"

#define CLOCK 0
#define ALARM 1
#define BLINK 2
#define BLINK_TIME 400
#define MINUTE 1000
#define BUZZ_TIMER 250
#define BUTTON_WAIT 50

enum States {  timer = 0 , timer_alarm = 1, alarm = 2 , setTime = 3, setAlarm = 4  };

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0X80, 0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1, 0xF2, 0xF4, 0xF8};

byte timeVector[2][4] = { {0, 0, 0, 0}, {0, 0, 0, 0} };
bool timeSet = false;
bool setMinute = true;
bool alarmRinging = false;
bool displayAlarm = false;
unsigned short int buzzStatus = LOW;
int lastButtonPressed = 0;
unsigned long int lastButtonPressedTime = 0;
unsigned int currState = 0;
int blinkDisplay = 0;

void increaseTimeVector(byte myTimeVector[4], int aditionalTime = 1);
void checkAlarm();
void initial_state();
void next_state();
void snooze();

void appinit(void) {
  pinMode(LATCH_DIO, OUTPUT);
  pinMode(CLK_DIO, OUTPUT);
  pinMode(DATA_DIO, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(BUZZER, OUTPUT);
  digitalWrite(BUZZER, HIGH);
  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
  digitalWrite(LED4, HIGH);
  for (int i = 0; i < 4; i++) {
    WriteNumberToSegment(i , timeVector[0][i]);
  }
  button_listen(BUTTON1);
  button_listen(BUTTON2);
  button_listen(BUTTON3);
  timer_set(CLOCK, MINUTE);
  timer_set(BLINK, 1);
  Serial.begin(9600);
}

void button_changed ( int pin, int v) {
  if ( v == HIGH ) { // so vou considerar acionado quando o botão for liberado
    unsigned long int now = millis();
    if ( now <= lastButtonPressedTime + BUTTON_WAIT ) {
      if ((lastButtonPressed == BUTTON1 && pin == BUTTON3) ||
          (lastButtonPressed == BUTTON3 && pin == BUTTON1)) {
        initial_state();
        return;
      }
    }
    if ( pin == BUTTON3) { // troca estado
      next_state();
    } else if ( pin == BUTTON1 ) {
      if (timeSet) {
        setMinute = !setMinute;
      } else if ( alarmRinging ) {
        snooze();
      }
    } else if ( pin == BUTTON2 ) {
      if (timeSet) { // esta ajustando a hora
        unsigned short int type = (currState == States::setTime) ? CLOCK : ALARM;
        int addTime = setMinute ? 1 : 60;
        increaseTimeVector(timeVector[type], addTime);
      } else if (alarmRinging) { // vou parar o alarme e colocar no estado inicial
        initial_state();
      }
    }
    lastButtonPressed = pin;
    lastButtonPressedTime = now;
  }
}

void snooze() {
  clearAlarm();
  for( int i = 0; i < 4; i++ ) { // copiando a hora em que o snooze foi clicado
    timeVector[ALARM][i] = timeVector[CLOCK][i];
  }
  increaseTimeVector(timeVector[ALARM], 5); // + 5 min
}

clearAlarm() {
  alarmRinging = false;
  buzzStatus = HIGH;
  digitalWrite(BUZZER, buzzStatus);
  timer_clear(ALARM);
}

void initial_state() {
  timeSet = false;
  displayAlarm = false;
  currState = States::timer;
  clearAlarm();
  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
  digitalWrite(LED4, HIGH);
}

void next_state() {
  currState = ++currState % 5;
  if ( currState == States::timer ) {
    timeSet = displayAlarm = false;
    digitalWrite(LED1, HIGH);
    digitalWrite(LED2, HIGH);
    digitalWrite(LED3, HIGH);
    digitalWrite(LED4, HIGH);
  } else if ( currState == States::timer_alarm ) {
    digitalWrite(LED1, LOW);
  } else if (currState == States::alarm) {
    displayAlarm = true;
    clearAlarm();
    digitalWrite(LED1, HIGH);
    digitalWrite(LED2, LOW);
  } else if (currState == States::setAlarm) {
    blinkDisplay = 0;
    displayAlarm = true;
    timeSet = setMinute = true;
    digitalWrite(LED3, HIGH);
    digitalWrite(LED4, LOW);
  } else if (currState == States::setTime) {
    blinkDisplay = 0;
    displayAlarm = false;
    timeSet = setMinute = true;
    digitalWrite(LED2, HIGH);
    digitalWrite(LED3, LOW);
  }
}

void timer_expired(int id, unsigned long int now) {
  if (id == CLOCK) { // timer do contador do relogio
    increaseTimeVector(timeVector[CLOCK]);
    timer_set(CLOCK, MINUTE);
    if ( (currState == States::timer_alarm) && !alarmRinging ) {
      checkAlarm();
    }
  }
  else if ( id == ALARM ) { // timer do intervalo de toque do alarme
    buzzStatus = !buzzStatus;
    digitalWrite(BUZZER, buzzStatus);
    timer_set(ALARM, BUZZ_TIMER);
  }
  else if ( id == BLINK ) { // Evento para escrever no display de segmentos
    unsigned short int type = displayAlarm ? ALARM : CLOCK;
    int start = 0;
    int finish = 4;
    if ( timeSet ) {
      blinkDisplay = (blinkDisplay + 1) % BLINK_TIME;
      if ( blinkDisplay > (BLINK_TIME / 2) ) {
        if ( setMinute ) {
          finish = 2; // não vai escrever no minuto
        } else {
          start = 2; // não vai escrever na hora
        }
      }
      if( now >= lastButtonPressedTime + 10000 ) {
        initial_state();
      }
    }
    for (int i = start; i < finish; i++) {
      WriteNumberToSegment(i , timeVector[type][i]);
    }
    timer_set(BLINK, 1);
  }

}

void checkAlarm() {
  for ( int i = 0; i < 4; i++) {
    if ( timeVector[CLOCK][i] != timeVector[ALARM][i] ) {
      return;
    }
  }
  alarmRinging = true;
  timer_set(ALARM, BUZZ_TIMER);
  buzzStatus = LOW;
  digitalWrite(BUZZER, LOW);
}

void increaseTimeVector(byte myTimeVector[4], int aditionalTime) {
  unsigned long int currTime = myTimeVector[0] * 600 + myTimeVector[1] * 60 + myTimeVector[2] * 10 + myTimeVector[3] + aditionalTime;
  mapTimeToVector(currTime, myTimeVector);
}

void mapTimeToVector( unsigned long int currTime, byte myTimeVector[4] ) {
  unsigned long int h = (currTime / 60) % 24;
  unsigned long int m = currTime % 60;
  myTimeVector[0] = h / 10;
  myTimeVector[1] = h % 10;
  myTimeVector[2] = m / 10;
  myTimeVector[3] = m % 10;
}

/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO, LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO, HIGH);
}
