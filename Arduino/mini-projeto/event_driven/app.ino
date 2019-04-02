/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
#define CLOCK 0
#define ALARM 1
#define BLINK 2
#define BLINK_TIME 400
#define MINUTE 1000
 
/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

byte timeVector[4] = { 0,0,0,0 }; 
 

void appinit(void) {
    pinMode(LATCH_DIO,OUTPUT);
    pinMode(CLK_DIO,OUTPUT);
    pinMode(DATA_DIO,OUTPUT);
    for (int i = 0; i < 4; i++) {
      WriteNumberToSegment(i , timeVector[i]);
    }
    timer_set(CLOCK,MINUTE);
    timer_set(BLINK,10);
//    Serial.begin(9600);
}
void button_changed ( int pin, int v);


void timer_expired(int id) {
  if(id == CLOCK) {
    updateTimeVector();    
    timer_set(CLOCK,MINUTE);
  }
  else if( id == ALARM ){
    //beep
  }
  else if( id == BLINK ){
    // call to blink
    for (int i = 0; i < 4; i++) {
      WriteNumberToSegment(i , timeVector[i]);
      timer_set(BLINK,10);
    }
  }
    
}


void updateTimeVector() {
    unsigned long int currTime = timeVector[0] * 600 + timeVector[1] * 60 + timeVector[2] * 10 + timeVector[3] + 1;
    mapTimeToVector(currTime);
    
}

void mapTimeToVector( unsigned long int currTime ) {
    unsigned long int h = currTime / 60;
    unsigned long int m = currTime % 60; 

    timeVector[0] = h/10;
    timeVector[1] = h%10;
    timeVector[2] = m/10;
    timeVector[3] = m%10;  
//    Serial.println( String(currTime) + "    " + String(h) + "    " + String(m));delay(10);
}
 
/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}


