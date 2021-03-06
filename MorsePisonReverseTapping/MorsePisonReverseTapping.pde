/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////

This program relies on a pison device with exec running in the background to work. DeviceData get's input from exec
and calls the approriate finger up and finger down functions here.

This is a demo of inputting finger movement for morse signals. It takes in the finger input, and determines based
off time elapsed and how it compares to a running average of expected time amounts, whether the user has inputted
a 'dit' (the short signal in morse) or a 'Daaaaah' (the long signal). Based off a unique combination of dits and
dahs this program translates that into the string equivalent

It does so by adding either digits 1 or 2 to a currentLetter counter, which get's converted into a string and
compared to the String [] Alphabet to see if there's a match. The match's index value determines the ascii value
of the approriate character.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

/*How to test:
Try it out with hello world in dits and dahs:
1. Run this program by pressing play
2. Notice the black screen? 'Wake' it up by pointing and holding up the index finger until black fades away
3. Begin tapping in morse code with your index finger! 
    Lift quickly for a 'dit' (1), hold a little longer for a 'dah' (2)
    Try with "hello world"
    hello world = 1111 1 1211 1211 222 (pause and eventually a space will be added) 122 222 121 1211 211
*/
String [] Alphabet = {
  "0012",//A
  "2111",//B
  "2121",//C
  "0211",//D
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
String saying = "|";//this is what displays what you're currently trying to type, starts as a blinker
String said = "*"; //what's been translated
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

/* for sound effects */
import processing.sound.*;
SinOsc sine;
float sinFreq = 900;

boolean activated = false; //for connection to device, must start by lifting pointer finger up for a time limit
int activationFrames = 0; //how many frames you lifted your finger for
boolean activating = false;// in the process of activating?

void setup(){
  setupConnection();//to pison device
  
  size(800,800);
  PFont mono;
  // The font ttf file must be located in the sketch's "data" directory to load successfully
  mono = createFont("RubikMonoOne-Regular.ttf", 32);
  textFont(mono);
  /* for sound effects, initiate a sin oscillator from the sound library */
  sine = new SinOsc(this);
  sine.freq(sinFreq); 
}


void draw(){ 
  parseData();//from pison device
  background(0);//start the background off as black
  
  noStroke();
  fill(225,90,70,activationFrames);
  rect(0,0,width, height);
  
  if(activated){ //if user has lifted finger up for long enough to 'wake' the program
    background(255,90,70); //the background is a brighter color (given in RGB values out of 255)
    int currentFrame = frameCount;
  
    displayPreviousDots(currentLetter);
    displayText(currentFrame);
  
    if(currentSignalPending){//if we're in a middle of a signal, the sound should play —
      float elapsedFrames = frameCount - signalStartFrame+1;
      soundEffect(signalStartFrame, elapsedFrames); // pitch is determined by how long input is (the longer the lower)
      displayCurrentDot(elapsedFrames);
    }else{ //otherwise interpret the silence as either time to translate, or time to add a 'space'
      checkPause(currentFrame);
    }
  }
}

void activation(){
  activationFrames +=1;
  activating = true;
}

//was the time pausing between signals long enough to be considered a space? Can we translate it?
void checkPause(int currentFrame){ 
  int pauseTime = currentFrame - signalEndFrame;
  String ending = said.substring(said.length()-1);
  boolean endingSpace = ending.contains("_") || ending.contains("*");
  
  /*if you paused long enough between signals, and your current combination of signals is a valid letter,
  then it gets confirmed and we wait for a new set of signals*/
  if (currentLetter > 0 && pauseTime > 60 && translateable(currentLetter)){
        said = said + translateMorse(currentLetter);
        saying = "|";
        currentLetter = 0;
  }else if( !endingSpace  
          && (pauseTime > 360)
          && currentLetter == 0){
      said = said + "_";
      saying = "|";
      currentLetter = 0;
  }  /* but otherwise if there hasn't already been a space added and you paused long enough, then
  we assume that the user intended to add a space to the sentence*/
}

// Visual effects for the currently not yet translated combination of dits and dahs
void displayCurrentDot(float elapsedFrames){
  float sizeOfDot = 0.08*width;
     strokeCap(ROUND);
     strokeWeight(sizeOfDot);
     stroke(193, 255, 239);
     //float lengthOfSignal = pow(elapsedFrames, 1/4)/2;
     float lengthOfSignal = constrain(pow(1.5*(float) Math.cbrt(elapsedFrames-5), 4), 0,width*0.055);
     line(width/2-lengthOfSignal, height/2, width/2+lengthOfSignal,height/2);
}
void displayPreviousDots(int signal){
  float sizeOfDot = 0.08*width;
  int totalCount = digitCount(signal);
  float startX = width/2;
  for (int i = 0; i < totalCount; i++){
    int ditOrDah = digitAtIndex(signal, i);
    stroke(255, 151, 104);
    if (ditOrDah == 1){
      line(startX-0.5, height/2, startX+0.5,height/2);
      startX -= width*0.135+1;
    }else{
      line(startX-width*0.055, height/2, startX+width*0.055,height/2);
      startX -= width*0.19;
    }
  }
}

void displayText(int currentFrame){
  fill(255);
  text(said, 20,20,width,height);
  
  fill(255,170,120);
  if(currentFrame%50 < 20){//blinker
     text(saying,said.length()*27+20,20,width, height);
  }
}
void soundEffect(int startFrame, float elapsedFrames){
  float newFreq = 1/(elapsedFrames/40)*20+500; //formula allows for sound to change from a dit to a dah signal
  sine.amp(0.8);
  sine.freq(newFreq);
}

/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////
These are the functions that recieve user input 
(key point is that lifting the finger is the equivalent of pressing down on the mouse, so it's 'reverse' tapping)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
void fingerUp(){
  currentSignalPending = true;
  sine.play();
  
  signalStartFrame = frameCount;
  int sinceLastInput = signalStartFrame - signalEndFrame;
  if (avgBtwnSignals == 0) {
    avgBtwnSignals = sinceLastInput;
  } else {
    avgBtwnSignals = 0.5*avgBtwnSignals + sinceLastInput; 
  }
}
void fingerDown(){
  sine.stop();
  
  signalEndFrame = frameCount;
  currentSignalPending = false;
  
  int signalElapsed = signalEndFrame - signalStartFrame; 
  int ditDah = ditOrDah(signalElapsed);
  
  if(possibleToContinue(currentLetter)){//if i can add signal to current letter, do so
    currentLetter = currentLetter*10 + ditDah;
  }else{//but if not, then translate what we have and start a new one
    said = said + translateMorse(currentLetter);
    saying = "|";
    currentLetter = ditDah;
  }
  saying = translateMorse(currentLetter);
}

void mousePressed(){//equivalent of lifting finger up with the Pison device
  currentSignalPending = true;
  sine.play();
  
  signalStartFrame = frameCount;
  int sinceLastInput = signalStartFrame - signalEndFrame;
  if (avgBtwnSignals == 0) {
    avgBtwnSignals = sinceLastInput;
  } else {
    avgBtwnSignals = 0.5*avgBtwnSignals + sinceLastInput; 
  }
}

void mouseReleased() {//equivalwent of relaxing the finger
  sine.stop();
  
  signalEndFrame = frameCount;
  currentSignalPending = false;
  
  int signalElapsed = signalEndFrame - signalStartFrame; 
  int ditDah = ditOrDah(signalElapsed);
  
  if(possibleToContinue(currentLetter)){//if i can add signal to current letter, do so
    currentLetter = currentLetter*10 + ditDah;
  }else{//but if not, then translate what we have and start a new one
    said = said + translateMorse(currentLetter);
    saying = "|";
    currentLetter = ditDah;
  }
  saying = translateMorse(currentLetter);
}


/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////
These are the functions that have to do with translating morse signals. If the signal processing coming from 
the device can't be improved, then implementing lanugage based probability here could help (much like the methods
used in autocorrect or android's speed no-lift keyboard)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

Boolean possibleToContinue(int signals){//figures out what the ditdah combo could possibly be..if it is at all
//if we add more to this combo, does it still have potential as a letter
  if (currentLetter*10 < 2212){
    int digitNum = digitCount(signals);
    for( int i = 0; i < Alphabet.length; i++){//go through the entire alphabet and compare
      int compareLetter = Integer.parseInt(Alphabet[i]);
      compareLetter = digitChop(compareLetter, digitNum);
      if(signals == compareLetter){
        saying = str(char(65+i));
        return true;
      }
    }
  }
  return false;
}
Boolean translateable(int signals){ // is the current combination of dits and dahs a valid letter? 
  String temporarySignal = nf(signals,4);
  for(int i = 0; i < Alphabet.length; i++){
    String compareLetter = Alphabet[i];
    if(temporarySignal.equals(compareLetter)){
      return true;
    }
  }
  return false;
}
String translateMorse(int signals){//given number, return corresponding letter
  String what = "_";
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

//boring number helper functions ************************************************************
int digitAtIndex(int numbr, int index){//given a number, find it's nth digit, starting with n is 0 for the ones place
  int answer = (numbr % (int)(Math.pow(10,index+1))) / (int)(Math.pow(10,index));
  return answer;
}
int digitChop(int numbr, int count){//given a number, and the number of desired digits, chop the first number and return it as a digit count of count
  int digitCountOfNumbr = digitCount(numbr);
  if(digitCountOfNumbr >= count){
    int divideBy10 = (int)(Math.pow(10,digitCountOfNumbr-count));
    return numbr/divideBy10;
  }else{
    return numbr;
  }
}
int digitCount(int numbr){//how many digits in a number
  int Count = 0;
  int Number = numbr;
  while(Number > 0){
    Number = Number / 10;
    Count = Count + 1;
  }
  return Count;
}
