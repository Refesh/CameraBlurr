import processing.video.*; 
import gab.opencv.*;
import java.awt.Rectangle;


Capture cam;
PImage frame;
OpenCV opencv;
int pixelMeshSize = 4;
boolean blurrFace = true;

void setup() {
  size(640,480);
  cam = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  cam.start();
  frameRate(25);
  textSize(6);
}

void draw() {
  scale(2);

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  frame = cam.get();
  opencv.loadImage(frame);
  Rectangle[] faces = opencv.detect();
  if (faces.length > 0){
    cam.loadPixels();
    if (blurrFace) blurrFace(faces);
    else blurrEyes(faces);
    image(frame, 0, 0);
  }else {
    image(frame, 0, 0);
  }
  text("Click + to add more blurr to your face", 0, 10);
  text("Click - to reduce blurr", 0, 20);
  text("Click c to change blurr mode", 0, 30);
}

void keyPressed(){
  if(key == '+'){
    pixelMeshSize  = min(pixelMeshSize + 1, 11);
  }
  if(key == '-'){
    pixelMeshSize  = max(pixelMeshSize - 1, 1);
  }
  if(key == 'c' || key == 'C') blurrFace =  (! blurrFace);
}


void blurrFace(Rectangle [] faces){
  for(int i = faces[0].x ; i < faces[0].x + faces[0].width ; i++){
      for(int j = faces[0].y; j < faces[0].y + faces[0].height; j++){
        blurr(i, j);
      }
    }
}

void blurrEyes(Rectangle [] faces){
  for(int i = faces[0].x ; i < faces[0].x + faces[0].width ; i++){
      for(int j = int(faces[0].y + faces[0].height*0.25); j < faces[0].y + faces[0].height * 0.55 ; j++){
        blurr(i, j);
      }
    }
}

void blurr(int i, int j){
  float totalRed = 0;
  float totalBlue = 0;
  float totalGreen = 0;
  int totalInfluence = 0;
  for(int k = max(0, i-pixelMeshSize) ; k <= min(i+pixelMeshSize, 640) ; k++){
    for(int l = max(0, j-pixelMeshSize) ; l <= min(j+pixelMeshSize, 480) ; l++){
      int influence = (2 * pixelMeshSize - abs(k - i) + abs(l - j)) * 5;
      totalInfluence += influence;
      totalRed += influence * red(cam.pixels[k+l*width/2]);
      totalBlue += influence * blue(cam.pixels[k+l*width/2]);
      totalGreen += influence * green(cam.pixels[k+l*width/2]);
            
    }
  }
  frame.pixels[i+j*width/2] = color(totalRed/totalInfluence, totalGreen/totalInfluence, totalBlue/totalInfluence);
}
void captureEvent(Capture c) {
  c.read();
}
