
static final int upArrow = 38;
static final int downArrow = 40;
static final int leftArrow = 37;
static final int rightArrow = 39;

static final int spaceBar = 32;

// Points that can be moved by the user must implement this interface
abstract class MoveablePoint
{
  abstract void draw();
  abstract void move(int keyCode, int increment);
}

int currentPointIndex = 0;

MoveablePoint[] points = new MoveablePoint[]{
  null,
  new MoveablePoint() { 
    void draw() { detector1.line1.drawPoint1(detector1.c); }
    void move(int keyCode, int increment) { detector1.line1.movePoint1(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector1.line1.drawPoint2(detector1.c); }
    void move(int keyCode, int increment) { detector1.line1.movePoint2(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector1.line2.drawPoint1(detector1.c); }
    void move(int keyCode, int increment) { detector1.line2.movePoint1(keyCode, increment); }
  },
  new MoveablePoint() {
    void draw() { detector1.line2.drawPoint2(detector1.c); }
    void move(int keyCode, int increment) { detector1.line2.movePoint2(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector2.line1.drawPoint1(detector2.c); }
    void move(int keyCode, int increment) { detector2.line1.movePoint1(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector2.line1.drawPoint2(detector2.c); }
    void move(int keyCode, int increment) { detector2.line1.movePoint2(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector2.line2.drawPoint1(detector2.c); }
    void move(int keyCode, int increment) { detector2.line2.movePoint1(keyCode, increment); }
  },
  new MoveablePoint() { 
    void draw() { detector2.line2.drawPoint2(detector2.c); }
    void move(int keyCode, int increment) { detector2.line2.movePoint2(keyCode, increment); }
  },
};

int increment = 1;
long lastKeyPressedMillis;

boolean shifted = false;

void keyPressed() {
  if(keyCode == 16) {
    shifted = true;
    return;
  }

  println("pressed '" + key + "' (" + (int)key + ") " + keyCode + ", shifted = " + shifted);

  long millis = System.currentTimeMillis();
  if(keyCode == spaceBar) {
    if(shifted) {
      currentPointIndex = (points.length + currentPointIndex-1) % points.length;
    } else {
      currentPointIndex = (currentPointIndex+1) % points.length;
    }
  }
  MoveablePoint p = points[currentPointIndex];
  if(p != null) {
    // Accelerate movement after a while
    if(millis - lastKeyPressedMillis < 200) {
       if(increment < 10) increment++;
    } else {
      increment = 1;
    }
    p.move(keyCode, increment);
  }
  lastKeyPressedMillis = millis;
}

void keyReleased() {
  //println("released '" + key + "' (" + (int)key + ") " + keyCode);
  
  if(keyCode == 16) {
    shifted = false;
    return;
  }
}
