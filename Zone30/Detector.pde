/** A Detector is an oriented couple of lines that detects movement from the first line to the second. */
class Detector
{
  // Persisted parameters
  String name = "";
  color c; // color to use when displaying this detector
  int histoy; // position of the histogram on screen
  float distance = 4; // meters between two lines (default value, provide actual value in zone30.json)
  long detectionWindow = 3000000000L; // Duration of detection window (ns), namely vehicle must move from line1 to line2 within this interval in order to be detected
  long displayTime = 1000000000L; // Duration of display (ns) after a detection event, the next detection phase will start when display is over.

  // Fields

  Line line1;
  Line line2;
  
  boolean detectedStart = false; // True if detected movement on line1 within detectionWindow 
  long startNanos; // Time of this detection (ns)

  boolean displayingResult = false;
  long displayStart; // Start time of display (ns)


  long travelTime = 0; // Measured travel time between line1 and line2 (ns)
  int kmph; // Computed speed in km/h (requires setting the distance)
  int mps; // Computed speed in m/s (requires setting the distance)

  int hmax = 150; // Max speed stored in the histogram
  int[] histo = new int[hmax]; // Histogram of speeds (km/h)
  int count = 0; // Count of detection events (number of vehicles detected)

  boolean detect1;
  boolean detect2;

  Detector(String name, Line line1, Line line2, color c, int histoy)
  {
    this.name = name;
    this.line1 = line1;
    this.line2 = line2;
    this.c = c;
    this.histoy = histoy;
  }
  
  void loadJSON(JSONObject json)
  {
     line1.loadJSON(json.getJSONObject("line1"));
     line2.loadJSON(json.getJSONObject("line2"));
     name = json.getString("name");
     c = 0xFF000000 | (0xFFFFFF & Integer.parseInt(json.getString("color").substring(1), 16));
     distance = json.getFloat("distance");
     detectionWindow = json.getLong("detectionWindow");
  }
  
  JSONObject saveJSON()
  {
    JSONObject result = new JSONObject();
    result.setJSONObject("line1", line1.saveJSON());
    result.setJSONObject("line2", line2.saveJSON());
    result.setString("name", name);
    result.setString("color", String.format("#%06X", 0xFFFFFF & c));
    result.setFloat("distance", distance);
    result.setLong("detectionWindow", detectionWindow);
    return result;
  }
  
  void detect()
  {
    detect1 = line1.detect(video);
    detect2 = line2.detect(video);
    
    long nanos = System.nanoTime();
    if(displayingResult) {
      // do not start measuring while displaying result
      if(nanos - displayStart < displayTime) {
      } else {
        displayingResult = false;
      }    
    } else {
      if(!detectedStart) {
        // not currently measuring an interval
        if(detect1) {
          detectedStart = true;
          startNanos = nanos;
        } else if(detect2) {
          //detectedStart = 2;
          //startNanos = nanos;
        }
      } else {
        // currently measuring interval starting
        if(nanos > startNanos + detectionWindow) {
          // second pass not seen, stop detecting
          detectedStart = false;
        } else {
          if(detectedStart && detect2) {
            detectedStart = false;
            travelTime = nanos - startNanos;
            
            kmph = (int)((distance/1000) / (1.0*travelTime/1000000000/60/60));
            mps = (int)(distance / (1.0*travelTime/1000000000));
            
            //println((distance/1000) + "km / " +  
            
            count++;
            if(kmph < 0) {
              histo[0]++;
            } else if(kmph >= hmax) {
              histo[hmax-1]++;
            } else {
              histo[kmph]++;
            }
            
            displayingResult = true;
            displayStart = nanos;

            println(name + " detected transit in " + travelTime/1000000 + " ms (" + travelTime + " ns)");
            log(name, kmph); 
          }
        }
      }
    }
  }
  
  java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
  
  void log(String name, int kmph)
  {
    String timeStamp = java.time.LocalDateTime.now().format(formatter);
    writer.println(name + ", " + timeStamp + ", " + kmph + "km/h");
    writer.flush();
  }
  
  void draw()
  {
    line1.draw(c, detect1, startNanos);
    line2.draw(c, detect2, startNanos);
  
   int midx1 = (line1.x1+line1.x2)/2; 
   int midy1 = (line1.y1+line1.y2)/2;
   int midx2 = (line2.x1+line2.x2)/2;
   int midy2 = (line2.y1+line2.y2)/2;
   
   if(displayingResult) {
        strokeWeight(3);
        stroke(c);
        line(midx1, midy1, midx2, midy2);
        textSize(14);
        fill(c);
        text((int)(1.0*travelTime/1000000) + "ms " + kmph + "km/h " + mps + "m/s", (line1.x1+line2.x1)/2 - 100, (line1.y1+line1.y2+line2.y1+line2.y2)/4 - 4);
    } else {
        strokeWeight(1);
        stroke(c);
        line(midx1, midy1, midx2, midy2);
        strokeWeight(10);
        stroke(c);
        
        int xp = (10*midx2+midx1)/11;
        int yp = (10*midy2+midy1)/11;
        line(midx2, midy2, xp, yp);
    }
    
    textSize(14);
    fill(c);
    text(""+count, 100, histoy+20);
  
    strokeWeight(3);
    stroke(c);
    for(int i=0; i<hmax; i++) {
      line(100+i*4, histoy, 100+i*4, histoy-4*histo[i]);
    }
  }
}
