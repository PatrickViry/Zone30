/** This is Zone30, a simple way to measure vehicle speeds using a webcam. See documentation in readme.txt. */
import processing.video.*;
import java.awt.Rectangle;

Capture video;

String jsonFileName = "zone30.json";

// Default values, you can change them.
// The preferred way to provide default values is to edit zone30.json, to match one of your available cameras. 
// The list of available cameras is printed when launching the program.
int width = 1280;
int height = 960;
int frameRate = 30;
String cameraName = "Logitech HD Webcam C270";

void settings()
{
  try {
    JSONObject json = loadJSONObject(jsonFileName);

    width = json.getInt("width");
    height = json.getInt("height");
    
    frameRate = json.getInt("frameRate");
    cameraName = json.getString("cameraName");
    
    detector1.loadJSON(json.getJSONObject("detector1"));
    detector2.loadJSON(json.getJSONObject("detector2"));

  } catch(Exception e) {
    println(e);
  }
  size(width, height);
}

/** On exit, save all parameters. */
void exit()
{
  writer.close();
  
  JSONObject json = new JSONObject();

  json.setInt("width", width);
  json.setInt("height", height);

  json.setInt("frameRate", frameRate);
  json.setString("cameraName", cameraName);

  json.setJSONObject("detector1", detector1.saveJSON());
  json.setJSONObject("detector2", detector2.saveJSON());

  println("Saving parameters to " + jsonFileName);
  saveJSONObject(json, jsonFileName);
}

void setup() 
{  
  String[] cameras = Capture.list();
  
  if(cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }
  
  video = new Capture(this, width, height, cameraName, frameRate);
  video.start();  
}


// Use two detectors, one for up traffic and one for down traffic (detectors are oriented).
// You can add more detectors if needed, declare them here and add them in draw() 
Detector detector1 = new Detector("Lane1", new Line(100, 100, 100, 300), new Line(700, 100, 700, 300), #FF0000, 750);
Detector detector2 = new Detector("Lane2", new Line(700, 400, 700, 600), new Line(100, 400, 100, 600), #00FF00, 900);


/** Read next frame from webcam, detect movement, show image and superimpose detection results. */ 
void draw() 
{
  video.loadPixels();
  detector1.detect();
  detector2.detect();
  image(video, 0, 0);
  detector1.draw();
  detector2.draw();

  MoveablePoint p = points[currentPointIndex];
  if(p != null) {
    p.draw();
  }
}

/** Called when a new frame is ready. */
void captureEvent(Capture c) {
  c.read();
}

java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd-HHmmss");
String logFileName = "transit-" + java.time.LocalDateTime.now().format(formatter) + ".log";
java.io.PrintWriter writer;
{
  try {
    writer = new PrintWriter(new java.io.FileWriter(logFileName));
  } catch(IOException e) {
    println("Cannot open log file " + logFileName);
    exit();
  }
}
