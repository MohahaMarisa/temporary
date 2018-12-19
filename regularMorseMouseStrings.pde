String [] Alphabet = {
  "0012",//A
  "2111",//B
  "2121",//C
  "0021",//D
  "0001",//E
  "1121",//F
  "0221",//G
  "1111",//H
  "0011",//I
  "1222",//J
  "0212",//K
  "1211",//L
  "0022",//M
  "0021",//N
  "0222",//O
  "1221",//P
  "2212",//Q
  "0121",//R
  "0111",//S
  "0002",//T
  "0112",//U
  "1112",//V
  "0122",//W
  "2112",//X
  "2122",//Y
  "2211"// Z
};
String saying = "|";//starts as blinker
String said = "Password: "; //what's been translated
int currentLetter = 0; //currently active signals, adds on 1s and 2s from dits or dahs


boolean currentSignalPending = false; //won't start recieving signal until finger lifted and ready to input
int signalStartFrame = 0;//start of the finger pressed down for 'beep'
int signalEndFrame = 0;//release of finger, is the end of 'beep'
float avgDit = 8;
float avgDah = avgDit + 12;
/*at 60 frames per second, 12 is 0.2 seconds, and IIRC, 
the integration time of photoreceptor cells in the eyes 
is on the order of 0.1-0.2 seconds. That is, the signal 
produced by photoreceptor cells is proportional to the 
number of photons collected by that cell in 0.1-0.2 s*/

double avgBtwnSignals = 0;//how many frames between signals
double avgBtwnLetters = 0;//how many frames between letters?
void setup(){
  size(800,800);
}
void draw(){
  background(0);
  int currentFrame = frameCount;
  displayText(currentFrame);
  
  if(signalEndFrame > signalStartFrame){//current signal finished inputting
    //checkPause(currentFrame);
  }
}
void checkPause(int currentFrame){
  int pauseTime = currentFrame - signalEndFrame;
  if(said.substring(said.length()-1) != " " && 
  (pauseTime > (avgBtwnSignals + 36) || pauseTime >= avgBtwnLetters) ){
    //translate currentLetter
      currentLetter = 0;
      said = said + " ";
  }
}
void displayText(int currentFrame){
  text(said, 0,0,width,height);
  if(currentFrame%50 < 20){//blinker
     text(saying,said.length()*6,0,width, height);
  }
}
void mousePressed(){
  currentSignalPending = true;
  signalStartFrame = frameCount;
  int sinceLastInput = signalStartFrame - signalEndFrame;
  if (avgBtwnSignals == 0) {
    avgBtwnSignals = sinceLastInput;
  } else {
    avgBtwnSignals = 0.5*avgBtwnSignals + sinceLastInput; 
  }
  
}
void mouseReleased() {
  signalEndFrame = frameCount;
  currentSignalPending = false;
  
  int signalElapsed = signalEndFrame - signalStartFrame; 
  int ditDah = ditOrDah(signalElapsed);
  
  if(possible(currentLetter)){//if i can add signal to current letter, do so
    println("dit or Dah: "+ditDah);
    currentLetter = currentLetter*10 + ditDah;
    println("currentLetter: "+currentLetter);
  }else{//but if not, then translate what we have and start a new one
    said = said + translateMorse(currentLetter);
    saying = "|";
    currentLetter = ditDah;
  }
  saying = translateMorse(currentLetter);
}

Boolean possible(int signals){//figures out what it could possibly be..if it is at all
//if we add more to this combo, does it still have potential as a letter
  if (currentLetter*10 < 2212){
    int digitNum = digitCount(signals);
    String temporarySignal = nf(signals,digitNum);
    println("temporarySignal: "+temporarySignal);
    for( int i = 0; i < Alphabet.length; i++){
      String compareLetter = Alphabet[i].substring(0,digitNum);
      if(temporarySignal.equals(compareLetter)){
        saying = str(char(65+i));
        return true;
      }
    }
  }
  return false;
}

int digitCount(int numbr){
  int Count = 0;
  int Number = numbr;
  while(Number > 0){
    Number = Number / 10;
    Count = Count + 1;
  }
  return Count;
}
String translateMorse(int signals){//given number, return corresponding letter
  String what = "?";
  String temporarySignal = nf(signals,4);
  for(int i = 0; i < Alphabet.length; i++){
    String compareLetter = Alphabet[i];
    if(temporarySignal.equals(compareLetter)){
      what = str(char(65+i));
      return what;
    }
  }
  return what;
}
int ditOrDah(int signalTime) {//categorizes signal as . or __, returning 1 or 2
  if (signalTime < avgDit * 2){
    avgDit = 0.8*avgDit + 0.2*signalTime;
    avgDah = 0.7*avgDah + 0.3*(avgDit+18);
    return 1;
  }else{
    avgDah = 0.9*avgDah + 0.1*(signalTime);
    return 2;
  }
}
