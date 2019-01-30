import processing.net.*; 
//import org.json.*;
Client myClient; 
String dataIn; 
float qx = 0;
float qy = 0;
float qz = 0;
float qw = 0;

float pqz = 0;
float pqy = 0;
String activation;
boolean clicked = false;
 
void setupConnection() { 
  myClient = new Client(this, "127.0.0.1", 13375); 
  println("connecting..");
} 
 
void parseData() { 
  if (myClient.available() > 0) { 
    dataIn = myClient.readString(); 
  } 
  try{
      JSONObject data = JSONObject.parse(dataIn);
  JSONObject filteredFrames = data.getJSONObject("filteredFrames");
  JSONObject motionSilencer = filteredFrames.getJSONObject("MotionSilencer");
  JSONArray yValues = motionSilencer.getJSONArray("channels");
  JSONObject imu = data.getJSONObject("imuQuat");
  pqy = qy;
  pqz = qz;
  qx = imu.getFloat("qx");
  qy = imu.getFloat("qy");
  qz = imu.getFloat("qz");
  qw = imu.getFloat("qw");
  activation = data.getString("activation");
  //println(qx + " " + qy + " " + qz + " " + activation);
  //println(data.getString("activation"));
  if(activation.equals("HOLD"))
  {
    print("lifted");
    if(!activated){
      activation();
    }else if (currentSignalPending){
      fingerUp();
    }
  }else{
    print("tapping ");
    if(!currentSignalPending && activated){
      fingerDown();
    }
  }
  }catch (Exception e)
  {
  }

} 
