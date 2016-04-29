/**
 * Geometry 
 * by Marius Watz. 
 * 
 * Using sin/cos lookup tables, blends colors, and draws a series of 
 * rotating arcs on the screen.
*/
 
// Trig lookup tables borrowed from Toxi; cryptic but effective.
float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION=1.0;
int SINCOS_LENGTH= int((360.0/SINCOS_PRECISION));

String curr = new String();
 
// System data
boolean dosave=false;
int num=1;
float pt[]; // locations rotations etc ?
int style[]; // colors and lines
int frame[]; // records when shape was created (for fade effect)
 
void setup() {
  size(1024, 768, P3D);
  background(255);
  
  // Fill the tables
  sinLUT=new float[SINCOS_LENGTH];
  cosLUT=new float[SINCOS_LENGTH];
  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i]= (float)Math.sin(i*DEG_TO_RAD*SINCOS_PRECISION);
    cosLUT[i]= (float)Math.cos(i*DEG_TO_RAD*SINCOS_PRECISION);
  }
  
  num = 150;
  curr = "";
 
  pt = new float[6*num]; // rotx, roty, deg, rad, w, speed
  style = new int[2*num]; // color, render style
  frame = new int[num]; // frame number at time of shape creation
 
  // Set up arc shapes
  int index=0;
  float prob;
  for (int i=0; i<num; i++) {
    pt[index++] = random(PI*2); // Random X axis rotation
    pt[index++] = random(PI*2); // Random Y axis rotation
 
    pt[index++] = random(60,80); // Short to quarter-circle arcs
    if(random(100)>90) pt[index]=(int)random(8,27)*10;
 
    pt[index++] = int(random(2,50)*5); // Radius. Space them out nicely
 
    pt[index++] = random(4,32); // Width of band
    if(random(100)>90) pt[index]=random(40,60); // Width of band
 
    pt[index++] = radians(random(5,30))/5; // Speed of rotation
 
    // get colors
    prob = random(100);
    if(prob<30) style[i*2]=colorBlended(random(1), 255,0,100, 255,0,0, 210);
    else if(prob<70) style[i*2]=colorBlended(random(1), 0,153,255, 170,225,255, 210);
    else if(prob<90) style[i*2]=colorBlended(random(1), 200,255,0, 150,255,0, 210);
    else style[i*2]=color(255,255,255, 220);

    if(prob<50) style[i*2]=colorBlended(random(1), 200,255,0, 50,120,0, 210);
    else if(prob<90) style[i*2]=colorBlended(random(1), 255,100,0, 255,255,0, 210);
    else style[i*2]=color(255,255,255, 220);

    style[i*2+1]=(int)(random(100))%3;
  }
  
  num = 0;
}
 
void draw() {
  background(0);
  int index=0;
  translate(width/2, height/2, 0);
  rotateX(PI/6);
  rotateY(PI/6);
 
  for (int i = 0; i < num; i++) {
    pushMatrix();
 
    rotateX(pt[index++]);
    rotateY(pt[index++]);
    
    int opacity = 255 + frame[i] - frameCount;
    if(opacity > 0) { // only make shape if opacity is nonzero
      if(style[i*2+1]==0) {
        stroke(style[i*2], opacity);
        noFill();
        strokeWeight(1);
        arcLine(0,0, pt[index++],pt[index++],pt[index++]);
      }
      else if(style[i*2+1]==1) {
        fill(style[i*2], opacity);
        noStroke();
        arcLineBars(0,0, pt[index++],pt[index++],pt[index++]);
      }
      else {
        fill(style[i*2], opacity);
        noStroke();
        arc(0,0, pt[index++],pt[index++],pt[index++]);
      }
    }
    else {
      index+=3;
    }
 
    // increase rotation
    pt[index-5]+=pt[index]/10;
    pt[index-4]+=pt[index++]/20;
 
    popMatrix();
  }
}
 
 
// Get blend of two colors
int colorBlended(float fract, float r, float g, float b, float r2, float g2, float b2, float a) {
  r2 = (r2 - r);
  g2 = (g2 - g);
  b2 = (b2 - b);
  return color(r + r2 * fract, g + g2 * fract, b + b2 * fract, a);
}
 
 
// Draw arc line
void arcLine(float x,float y,float deg,float rad,float w) {
  int a=(int)(min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1));
  int numlines=(int)(w/2);
 
  for (int j=0; j<numlines; j++) {
    beginShape();
    for (int i=0; i<a; i++) { 
      vertex(cosLUT[i]*rad+x,sinLUT[i]*rad+y);
    }
    endShape();
    rad += 2;
  }
}
 
// Draw arc line with bars
void arcLineBars(float x,float y,float deg,float rad,float w) {
  int a = int((min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1)));
  a /= 4;
 
  beginShape(QUADS);
  for (int i=0; i<a; i+=4) {
    vertex(cosLUT[i]*(rad)+x,sinLUT[i]*(rad)+y);
    vertex(cosLUT[i]*(rad+w)+x,sinLUT[i]*(rad+w)+y);
    vertex(cosLUT[i+2]*(rad+w)+x,sinLUT[i+2]*(rad+w)+y);
    vertex(cosLUT[i+2]*(rad)+x,sinLUT[i+2]*(rad)+y);
  }
  endShape();
}
 
void makeshape(String str) {
  if(num >= 150) { //remove first shape, add new one
    int ptlen = pt.length;
    int stlen = style.length;
    int fmlen = frame.length;
    
    float pttemp[] = new float[ptlen];
    for(int i = 6; i < ptlen; i++) {
      pttemp[i-6] = pt[i];
    }
    pt = pttemp;
    
    int styletemp[] = new int[stlen];
    for(int i = 2; i < stlen; i++) {
      styletemp[i-2] = style[i];
    }
    style = styletemp;
    num = 149;
    
    int frametemp[] = new int[fmlen];
     for(int i = 1; i < fmlen; i++) {
       frametemp[i-1] = frame[i];
     }
     frame = frametemp;
     num = 149;
  }
  
  int pi = (num - 1) * 6;
    
  pt[pi++] = random(PI*2); // Random X axis rotation
  pt[pi++] = random(PI*2); // Random Y axis rotation
 
  pt[pi++] = random(60,80); // Short to quarter-circle arcs
  if(random(100)>90) pt[pi]=(int)random(8,27)*10;
 
  pt[pi++] = int(random(2,50)*5); // Radius. Space them out nicely
 
  pt[pi++] = random(4,32); // Width of band
  if(random(100)>90) pt[pi]=random(40,60); // Width of band
 
  pt[pi++] = radians(random(5,30))/5; // Speed of rotation
  
  int si = num - 1;
    
  float prob = random(100);
  if(prob<30) style[si*2]=colorBlended(random(1), 255,0,100, 255,0,0, 210);
  else if(prob<70) style[si*2]=colorBlended(random(1), 0,153,255, 170,225,255, 210);
  else if(prob<90) style[si*2]=colorBlended(random(1), 200,255,0, 150,255,0, 210);
  else style[si*2]=color(255,255,255, 220);

  if(prob<50) style[si*2]=colorBlended(random(1), 200,255,0, 50,120,0, 210);
  else if(prob<90) style[si*2]=colorBlended(random(1), 255,100,0, 255,255,0, 210);
  else style[si*2]=color(255,255,255, 220);

  style[si*2+1]=(int)(random(100))%3;
}

// Draw solid arc
void arc(float x,float y,float deg,float rad,float w) {
  int a = int(min (deg/SINCOS_PRECISION,SINCOS_LENGTH-1));
  beginShape(QUAD_STRIP);
  for (int i = 0; i < a; i++) {
    vertex(cosLUT[i]*(rad)+x,sinLUT[i]*(rad)+y);
    vertex(cosLUT[i]*(rad+w)+x,sinLUT[i]*(rad+w)+y);
  }
  endShape();
}

void keyPressed(){
  if (key == ENTER) {
    if (curr != "") {
      frame[num] = frameCount;
      num++;
      makeshape(curr);
    }
    curr = "";
  }
  else if (key == BACKSPACE && curr.length() > 0 ){
    curr = curr.substring(0, curr.length() - 1);
  }
  else {
    curr = curr + key;
  }
}