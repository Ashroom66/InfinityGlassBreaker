import gab.opencv.*; // opencv for Processing

// properties:tB[h?W?e?l
float hue_div = 100;                // FpBt?FJ
float checkval = 1000;              // checkval?check?x????
float setupPrepareDistance = 7000;  // ?IuWFNg??
float objRangeX = 1200;             // zuIuWFXW??
float objRangeY = 1300;
float objMitsudo_n = 11;           // 100sNZboxIuWF??(?)
float objMitsudo_b = 3;            // 100sNZboxIuWF??(j?\)
float cycleRange = 500;            // N_AIuWFzu???B(a)
float absCycleRange = 100;         // ??zu??(a)(_???_??????)

// cam?A
float cam_spd = 9;    // J?x
float cam_y = -0.10;  // J?(Y)

// ball?A
float ballsize = 10;
float ballV_baseY = -7;   // (?l??)
float ballV_baseZ = 25;   // O
float throwMousePw = 10;  // ?}EX??fx
color ballcolor = (200);  // ?F

// fragment?A
float fsize = 80;         // j?TCY
float reduction = 3;      // TCYk?x
char throwKey = ' ';      // (A)L[
int coolTime = 3;         // (A)?u

// tB^
int usingFilterMode = 2;  // gptB^?[hB0:gp?A1:Wu[A2:OpenCVu[A3:?u[B
int usingFilterSize = 7;  // tB^gp???ptB^TCY
float ikichi = 200;       // bloom?l

// p
float ruiseki = 0;  // J?i????
float check = 0;    // IuWFNg`FbNp
ArrayList<BreakableBox> bBoxes = new ArrayList<BreakableBox>();
ArrayList<NormalBox> nBoxes = new ArrayList<NormalBox>();
ArrayList<Ball> balls = new ArrayList<Ball>();
float generateDistanceDiff = setupPrepareDistance-checkval;  // ?IuWF`FbN?p

int interval=0;  // (A)?pJEgp?

void setup() {
  // screen setup
  size(600, 500, P3D);
  colorMode(HSB);  // {IHSB?FIBRGBp???XKXHSB???
  // cam
  camera(0,0,0,0,cam_y,1,0,1,0);
  perspective(PI/2, float(width)/float(height),100,5000 );
  //hint(ENABLE_DEPTH_SORT);    // IuWFNg?Y?`?B    // SUGOI OMOI
  
  noStroke();
  smooth();
  
  // generate objects
  setObjects(0,setupPrepareDistance);
}

void draw() {
  ruiseki += cam_spd;
  check += cam_spd;
  
  // obj-generateCheck
  if(check >= checkval) {
    check -= checkval;
    setObjects(int(ruiseki/checkval)*checkval+generateDistanceDiff, checkval);
  }
  
  // cam
  camera(0,0,ruiseki, 0,cam_y,ruiseki+1, 0,1,0);
  
  // background
  background(40);
  drawBackGround();
  
  blendMode(BLEND);
  // lighting: configue manually
  float camhue = (ruiseki/hue_div)%255;
  ambientLight(camhue, 20, 60);
  lightSpecular(0,0,60);
  directionalLight(camhue, 40, 40, 0, 1, 0.1);
  lightSpecular(0,0,120);
  directionalLight(camhue, 80, 90, 0, -1, 0.2);

  // throw ball
  interval--;
  if((keyPressed==true) && (key==throwKey) && interval<=0){
    mousePressed(); // (mousePressed??o?l?)
    interval = coolTime;
  }
  for(int i=0; i<balls.size(); i++) {
    if(balls.get(i).disappear) {balls.remove(i);}  // del check
    if(i>=balls.size()) break;
    balls.get(i).update();                         // draw
  }
  for(int i=0; i<bBoxes.size(); i++) {
    if(bBoxes.get(i).disappear) {bBoxes.remove(i); }  // del check
    if(i>=bBoxes.size()) break;
    bBoxes.get(i).update();                           // draw
  }
  for(int i=0; i<nBoxes.size(); i++) {
    if(nBoxes.get(i).disappear) {nBoxes.remove(i);}  // del check
    if(i>=nBoxes.size()) break;
    nBoxes.get(i).update();                          // draw
  }
  
  // filter
  if(usingFilterMode!=0) bloomFilter(ikichi, usingFilterSize);
}

void mousePressed() {
  PVector mouseposes = new PVector(mouseX - width/2, mouseY - height/2);
  float d = mouseposes.x*mouseposes.x + mouseposes.y*mouseposes.y;
  float[] pos = {-mouseposes.x/2, mouseposes.y/2, ruiseki+100};
  balls.add(new Ball(pos[0],pos[1],pos[2],
                     -mouseposes.normalize().x*throwMousePw*d/30000, mouseposes.normalize().y*throwMousePw*d/30000+ballV_baseY, ballV_baseZ,
                     ballsize, ballcolor));
}

void drawBackGround() {
  color c1,c2, c;
  float cr_hue = (ruiseki/hue_div)%255;
  c1 = color(cr_hue, 255, 0);
  c2 = color(cr_hue, 160,120);
  loadPixels();
  for(int i=0; i<height; i++){
    c = lerpColor(c1, c2, i*1.0/(height*1.0));
    c = color(cr_hue, saturation(c), brightness(c));
    for(int j=0; j<width; j++) {
      pixels[i*width+j] = c;
    }
  }
  //bg.updatePixels();
  updatePixels();
}

void setObjects(float origin, float dist) {
  // origin pxdist pxIuWFNg??
  float x,y,z, calctmp;
  color crtmp;
  for(int i=0; i<dist*objMitsudo_n/100; i++) {
    // ?IuWF
    while(true) {
      x = random(-objRangeX, objRangeX); y = random(-objRangeY, objRangeY);
      calctmp = x*x+y*y;
      if(calctmp >cycleRange*cycleRange) {
        break;
      } else if(calctmp>(absCycleRange+100)*(absCycleRange+100) && random(0.0,1.0) < 0.05) {
        break;
      }
    }
    z = random(origin, origin+dist);
    crtmp = color((z/hue_div)%255, random(0,255), random(0,255));
    // zu
    float ys;
    if(y>0) ys = random(300,700);  // ???B
    else ys = random(20,100);      // ?
    nBoxes.add(new NormalBox(x,y,z, random(100,256),ys,random(50,300), crtmp));
  }
  for(int i=0; i<dist*objMitsudo_b/100; i++) {
    // j?\IuWF
    while(true) {
      x = random(-objRangeX, objRangeX); y = random(-objRangeY, objRangeY);
      calctmp = x*x+y*y;
      if(calctmp >cycleRange*cycleRange) {
        break;
      } else if(calctmp>absCycleRange*absCycleRange && random(0.0,1.0) < 0.4) {
        break;
      }
    }
    z = random(origin, origin+dist);
    crtmp = color((z/hue_div)%255, random(50,255), random(100,255));
    // zu
    bBoxes.add(new BreakableBox(x,y,z, random(60,256),random(40,256),random(5,256), crtmp, color(hue(crtmp), (saturation(crtmp)+510)/3, 255)));
  }
}

////////////////////
//     filter     //
////////////////////
void bloomFilter(float iki, float blur_size) {
  colorMode(RGB);
  PImage filtered = createImage(width, height, RGB);
  // focus to apply by ikichi
  for(int i=0; i<height; i++) {
    for(int j=0; j<width; j++) {
      color c = get(j, i);
      if(brightness(c) >= iki) { filtered.pixels[i*filtered.width + j] = color(c); }
    }
  }
  
  // apply blur, update
  filtered.updatePixels();
  if(usingFilterMode==1) {
    filtered.filter(BLUR, blur_size);      // Wu[BdY
  } else if(usingFilterMode==2) {
    filtered = ocv_blur(filtered, blur_size);// OpenCV?u[By?Y???B
  } else if(usingFilterMode==3) {
    filtered = filtering(filtered, gaussian(10, int(blur_size)), int(blur_size));  // ?KEVAtB^BtJ[x
  }
  // gousei
  blendMode(ADD);
  
  // muriyari
  loadPixels();
  for(int i=0; i<width*height -1; i++) {
    color sc_c, fi_c;
    fi_c = filtered.pixels[i];
    if((keyPressed==false) || (key!='x'))
      if(brightness(fi_c) ==0) {continue;}
    sc_c = pixels[i];
    float cr_r = red(sc_c) + red(fi_c);     if(cr_r>255) {cr_r=255;}
    float cr_g = green(sc_c) + green(fi_c); if(cr_g>255) {cr_g=255;}
    float cr_b = blue(sc_c) + blue(fi_c);   if(cr_b>255) {cr_b=255;}
    //pixels[i] = color(cr_r, cr_g, cr_b);
    if((keyPressed==true) && (key=='x')) pixels[i] = filtered.pixels[i];
    else pixels[i] = color(cr_r, cr_g, cr_b);
  }
  updatePixels();
  colorMode(HSB);
}
PImage ocv_blur(PImage pic, float size) {
  OpenCV opencv = new OpenCV(this,pic, true);
  //opencv.loadImage(pic);
  opencv.blur(int(size));
  return opencv.getSnapshot();
}

PImage filtering(PImage img, float f[][], int w) {
  int hw = int(w/2);
  PImage filteredImg = createImage(img.width, img.height, RGB);
  img.loadPixels();
  for(int j=hw; j<img.height-hw; j++) {  // base image scanning
    for(int i=hw; i<img.width-hw; i++) {
      float sum_r = .0, sum_g = .0, sum_b = .0;
      for(int l=-hw; l<=hw; l++) {  // filter scanning
        for(int k=-hw; k<=hw; k++) {
          int p=(j+l) * img.width + i+k;  // scanning point
          sum_r += f[l+hw][k+hw] * red(img.pixels[p]);
          sum_g += f[l+hw][k+hw] * green(img.pixels[p]);
          sum_b += f[l+hw][k+hw] * blue(img.pixels[p]);
        }
      }
      filteredImg.pixels[j*img.width + i] = color(sum_r, sum_g, sum_b);
    }
  }
  filteredImg.updatePixels();
  return(filteredImg);
}
float [][] gaussian(float s, int w) {
  int hw = int(w/2);
  float[][] filter = new float[w][w];
  float sum = 0;
  for(int j=-hw; j<=hw; j++) {
    for(int i=-hw; i<=hw; i++) {  // keisu mushi
      sum += filter[j+hw][i+hw] = exp(-(i*i+j*j)/2./s/s);  // i=x, j=y
    }
  }
    for(int i=0; i<w*w; i++) {
      filter[int(i/w)][i%w] /= sum;
    }
    return filter;
}

////////////////////
//    materials   //
////////////////////
void zaishitsu_normal() {
  emissive(0);
  specular(0,0,10);
  shininess(2);
}
void zaishitsu_metal() {
  emissive(0);
  specular(0,0,255);
  shininess(30);
}
void zaishitsu_plastic() {
  emissive(0);
  specular(0,0,255);
  shininess(10);
}

////////////////////
//    objects     //
////////////////////
class Ball {
  float delheight = 1000;  // disappear when the sphere go below
  float[] g = {0,0.3,0};    // gravity(accerelate)
  float[] pos = new float[3];
  float[] spd = new float[3];
  float r;
  color cr;
  boolean disappear = false;
  // ?p
  float[] bp = new float[3];  // Box Positons
  float[] bs = new float[3];  // box Sizes
  // bBoxes?L[uIuWFNgN???B??
  Ball(float posx, float posy, float posz, float vx, float vy, float vz, float size, color cr) {
    this.pos[0] = posx; this.pos[1] = posy; this.pos[2] = posz;  // W
    this.spd[0] = vx; this.spd[1] = vy; this.spd[2] = vz;        // 
    this.r = size;  // a
    this.cr = cr;   // F
  }
  void update() {
    if(disappear) return;
    // 
    for(int i=0; i<3; i++) {
      pos[i] += spd[i];
      spd[i] += g[i];
    }
    // W?
    if(pos[1]>delheight){ this.destroy(); return; }
    // ?
    for(BreakableBox b: bBoxes) {
      if(b.destroyed) continue;  // ????O
      this.bp = b.getpos();
      this.bs = b.getsize();
      if(this.checkSphere()) {this.destroy(); b.destroy(); return;} 
    }
    // `
    zaishitsu_metal();
    pushMatrix();
    translate(pos[0], pos[1], pos[2]);
    ambient(cr);
    sphere(r);
    popMatrix();
  }
  void destroy() {
    this.disappear = true;
  }
  boolean checkSphere() {  // ?lp??
    // box??W?A?B
    float sqlength = .0;
    for(int i=0; i<3; i++) {
      float rp = pos[i]-bp[i];  // ?W
      float bpmin = -bs[i]/2;
      float bpmax = bs[i]/2;
      if(rp < bpmin) { sqlength += (rp-bpmin)*(rp-bpmin); }
      if(rp > bpmax) { sqlength += (rp-bpmax)*(rp-bpmax); }
    }
    if(sqlength==0) return true;
    return sqlength <= r*r;
  }
}

class NormalBox {
  float[] pos = new float[3];
  float[] size = new float[3];
  color body;
  boolean disappear = false;  // 
  NormalBox(float posx, float posy, float posz, float sizex, float sizey, float sizez, color body) {
    this.pos[0] = posx; this.pos[1] = posy; this.pos[2] = posz;
    this.size[0] = sizex; this.size[1] = sizey; this.size[2] = sizez;
    this.body = body;
  }
  void update() {
    // disappear??
    if(disappear) return;
    // ??O`FbN
    if(this.pos[2] < ruiseki) {this.disappear = true; return;}
    if(this.pos[2] > ruiseki+5500) {return;}  // `??O
    // box`
    zaishitsu_normal();
    ambient(body);
    noStroke();
    blendMode(BLEND);
    pushMatrix();
    translate(pos[0], pos[1], pos[2]);
    box(size[0], size[1], size[2]);
    popMatrix();
  }
}

class BreakableBox {
  float[] pos = new float[3];
  float[] size = new float[3];
  color body, frame;
  ArrayList<DisappearFragment> frag = new ArrayList<DisappearFragment>();
  boolean destroyed = false;  // j
  boolean disappear = false;  // 
  
  BreakableBox(float posx, float posy, float posz, float sizex, float sizey, float sizez, color body, color frame) {
    this.pos[0] = posx; this.pos[1] = posy; this.pos[2] = posz;
    this.size[0] = sizex; this.size[1] = sizey; this.size[2] = sizez;
    this.body = body; this.frame = frame;
  }
  
  void update() {
    // disappear??
    if(disappear) return;
    // destroy?l??o?}`?
    if(destroyed) {
      this.drawfrag();
    } else {
      this.drawbox();
    }
  }
  void drawbox() {
    // ??O`FbN
    if(this.pos[2] < ruiseki) {this.disappear = true; return;}
    if(this.pos[2] > ruiseki+5500) {return;}  // `??O
    // box`
    zaishitsu_plastic();
    ambient(body);
    stroke(frame);
    strokeWeight(1);
    blendMode(SCREEN);
    pushMatrix();
    translate(pos[0], pos[1], pos[2]);
    box(size[0], size[1], size[2]);
    popMatrix();
    blendMode(BLEND);
    noStroke();
  }
  void drawfrag() {
    for(int i=0; i<frag.size(); i++) {
      // del check
      if(frag.get(i).del) {frag.remove(i);}
      if(i>=frag.size()) break;
      // draw
      frag.get(i).update();
    }
  }
  void destroy() {
    // destroyedtO?fragmentZbg
    if(this.destroyed) return;
    this.destroyed = true;
    // x
    for(int i=0; i*fsize<size[1]; i++) {
      for(int j=0; j*fsize<size[2]; j++) {
        frag.add(new DisappearFragment(size[0]/2+pos[0],(fsize+0.5)*i-size[1]/2+pos[1],(fsize+0.5)*j-size[2]/2+pos[2], 0,90,0, fsize,fsize, reduction, body, frame, 3));
        frag.add(new DisappearFragment(-size[0]/2+pos[0],(fsize+0.5)*i-size[1]/2+pos[1],(fsize+0.5)*j-size[2]/2+pos[2], 0,90,0, fsize,fsize, reduction, body, frame, 0));
      }
    }
    // y
    for(int i=0; i*fsize<size[0]; i++) {
      for(int j=0; j*fsize<size[2]; j++) {
        frag.add(new DisappearFragment((fsize+0.5)*i-size[0]/2+pos[0],size[1]/2+pos[1],(fsize+0.5)*j-size[2]/2+pos[2], 90,0,0, fsize,fsize, reduction, body, frame, 4));
        frag.add(new DisappearFragment((fsize+0.5)*i-size[0]/2+pos[0],-size[1]/2+pos[1],(fsize+0.5)*j-size[2]/2+pos[2], 90,0,0, fsize,fsize, reduction, body, frame, 1));
      }
    }
    // z
    for(int i=0; i*fsize<size[0]; i++) {
      for(int j=0; j*fsize<size[1]; j++) {
        frag.add(new DisappearFragment((fsize+0.5)*i-size[0]/2+pos[0],(fsize+0.5)*j-size[1]/2+pos[1],size[2]/2+pos[2], 0,0,0, fsize,fsize, reduction, body, frame, 5));
        frag.add(new DisappearFragment((fsize+0.5)*i-size[0]/2+pos[0],(fsize+0.5)*j-size[1]/2+pos[1],-size[2]/2+pos[2], 0,0,0, fsize,fsize, reduction, body, frame, 2));
      }
    }
  }
  // ?pQb^[
  float[] getpos() {
    return this.pos;
  }
  float[] getsize() {
    return this.size;
  }
}

class DisappearFragment {
  float[] positions = new float[3];
  float[] speeds = new float[3];
  float[] rotations = new float[3];
  float[] rots = new float[3];
  float[] sizes = new float[2];
  color body, frame;
  float dspd;
  boolean del = false;
  DisappearFragment(float posx, float posy, float posz, float rotx, float roty, float rotz, float sizex, float sizey, float d_spd, color b_cr, color f_cr, int dir) {
    // RXgN^FWA@pxATCYA?x(TCY?ATCY0??)A{?F?{?gAe
    // x?]?lq??œ???B
    this.positions[0] = posx; this.positions[1] = posy; this.positions[2] = posz;  // ?u
    this.rotations[0] = rotx; this.rotations[1] = roty; this.rotations[2] = rotz;  // px
    this.sizes[0] = sizex; this.sizes[1] = sizey; this.dspd = d_spd * (1+random(-0.2,0.2));  // TCY?A
    this.body = b_cr; this.frame = f_cr;  // F
    
    for(int i=0; i<3; i++) {
      this.speeds[i] = random(-4.0, 4.0);
      this.rots[i] = random(-30.0, 30.0);
    }
    int force = 10;
    force *= dir>=3 ? -1 : 1;
    speeds[dir%3] -= force;  // O?e
  }
  void update() {
    // update data, and draw this rect
    // size
    if(del) return;
    for(int i=0; i<2; i++) {
      this.sizes[i] -= this.dspd * random(0.92, 1.08);
      if(sizes[i] <= 0) { this.del = true; return; }  // size underflow, delete this.
    }
    for(int i=0; i<3; i++) {
      this.positions[i] += speeds[i];
      this.rotations[i] += rots[i];
      
      // 
      this.speeds[i] *= random(0.85, 0.9);
      this.rots[i] *= random(0.95, 0.99);
    }
    
    // `
    ambient(body);
    stroke(frame);
    strokeWeight(2);
    pushMatrix();
    translate(positions[0], positions[1], positions[2]);
    rotateX(radians(rotations[0]));
    rotateY(radians(rotations[1]));
    rotateZ(radians(rotations[2]));
    blendMode(SCREEN);
    rect(-sizes[0]/2, -sizes[1]/2, sizes[0], sizes[1]);
    blendMode(BLEND);
    popMatrix();
    noStroke();
  }
}
