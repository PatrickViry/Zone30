class Line
{
  int x1;
  int y1;
  int x2;
  int y2;

  int[] previousPixels = new int[0]; // Previous values of pixels in camera frame along this line

  int threshold = 25; // Detection threshold : anything above this will be considered a detectione vent
  int diff; // latest computed difference
  
  Line(int x1, int y1, int x2, int y2)
  {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    ensureBounds();
  }
  
  void ensureBounds()
  {
    if(x1 < 0) x1 = 0; if(x1 >= width) x1 = width-1;
    if(y1 < 0) y1 = 0; if(y1 >= height) y1 = width-1;
    if(x2 < 0) x2 = 0; if(x2 >= width) x2 = width-1;
    if(y2 < 0) y2 = 0; if(y2 >= height) y2 = width-1;
  }
  
  void loadJSON(JSONObject json)
  {
    x1 = json.getInt("x1");
    y1 = json.getInt("y1");
    x2 = json.getInt("x2");
    y2 = json.getInt("y2");
  }
  
  JSONObject saveJSON()
  {
    JSONObject result = new JSONObject();
    result.setInt("x1", x1);
    result.setInt("y1", y1);
    result.setInt("x2", x2);
    result.setInt("y2", y2);
    return result;
  }
 
  int diff(PImage image)
  {
    long ldiff = 0;
    
    int[] pixels = pixels(image); // Current values of pixels in camera frame along this line
    int len = min(previousPixels.length, pixels.length);
    for(int i=0; i<len; i++) {
      int r1 = (previousPixels[i]&0xFF0000)>>16;
      int v1 = (previousPixels[i]&0x00FF00)>>8;
      int b1 = (previousPixels[i]&0x0000FF);
      int r2 = (pixels[i]&0xFF0000)>>16;
      int v2 = (pixels[i]&0x00FF00)>>8;
      int b2 = (pixels[i]&0x0000FF);
      ldiff += abs(r1-r2) + abs(v1-v2) + abs(b1-b2);    
    }
    diff = len==0 ? 0 : (int)(ldiff/len); // différence moyenne par point
    //println("diff=" + diff);
    previousPixels=pixels;
    return diff;    
  }
  
  boolean detect(PImage image)
  {
    return diff(image) > threshold;
  }
  
  void drawPoint1(color c)
  {
    fill(c);
    stroke(c);
    circle(x1, y1, 10);
  }
    
  void drawPoint2(color c)
  {
    fill(c);
    stroke(c);
    circle(x2, y2, 10);
  }

  void movePoint1(int keyCode, int increment)
  {
    switch(keyCode) {
      case upArrow: y1-=increment; break;
      case downArrow: y1+=increment; break;
      case leftArrow: x1-=increment; break;
      case rightArrow: x1+=increment; break;
    }
    ensureBounds();
  }
  
  void movePoint2(int keyCode, int increment)
  {
    switch(keyCode) {
      case upArrow: y2-=increment; break;
      case downArrow: y2+=increment; break;
      case leftArrow: x2-=increment; break;
      case rightArrow: x2+=increment; break;
    }
    ensureBounds();
  }
  
  void draw(color c, boolean detected, long nano)
  {
    fill(c);
    stroke(c);
    if(detected) {
      strokeWeight(10);
      line(x1,y1,x2,y2);
      circle(x1, y1, 10); 
      circle(x2, y2, 10); 
      textSize(12);
      text(""+nano, (x2-x1)/2, 310);
    } else {
      strokeWeight(1);
      line(x1,y1,x2,y2);
    }
  }
  
  /** Return the pixels in image along this line. */
  int[] pixels(PImage image)
  {
    int[] pixels;
    
    stroke(0,0,255);
    //line(x1,y1,x2,y2);
    boolean horizontal = abs(x2-x1) >= abs(y2-y1);
    int _x1, _y1, _x2, _y2;
    if(horizontal) {
      if(x2<x1) {
        _x1=x2; _x2=x1;
        _y1=y2; _y2=y1;
      } else {
        _x1=x1; _x2=x2;
        _y1=y1; _y2=y2;
      }
      // assert x1 <= x2
      pixels = new int[_x2-_x1+1];
      for(int x=_x1; x<=_x2; x++) {
        int y=_y1+(x-_x1)*(_y2-_y1)/(_x2-_x1);
        pixels[x-_x1] = image.pixels[width*y+x];
      }
      return pixels;
    } else {
      if(y2<y1) {
        _x1=x2; _x2=x1;
        _y1=y2; _y2=y1;
      } else {
        _x1=x1; _x2=x2;
        _y1=y1; _y2=y2;
      }
      // assert y1 <= y2
      pixels = new int[_y2-_y1+1];
      for(int y=_y1; y<=_y2; y++) {
        int x=_x1+(y-_y1)*(_x2-_x1)/(_y2-_y1);
        pixels[y-_y1] = image.pixels[width*y+x];
      }
      return pixels;
    }
  }
}
