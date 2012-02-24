/*
  code name : eisha
  license   : GNU GPL v3
  
*/
import java.awt.image.BufferedImage;
import javax.imageio.*;
import android.app.Activity;
import android.os.*;
import android.content.Context;
import android.hardware.Camera.Size;
import android.hardware.Camera;
import android.hardware.Camera.PreviewCallback;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import java.util.List;
import java.util.Timer;
import java.io.File;
import android.view.Surface;
import android.view.WindowManager;
import android.hardware.Camera.Parameters;

String app_status = "In preparation...";
File directory = new File("//sdcard//eisha/");
File directory2 = new File("//sdcard//eisha/enq/");
PImage photo;
long utime;
File dir = new File("//sdcard//eisha/");
File[] files;

String question1;
String[] answer1 = new String[4];
String question2;
String[] answer2 = new String[2];
RectButton rect1, rect2, rect3, rect4, rect5, rect6;

void setup() {
  frameRate(10);
  orientation(LANDSCAPE);
  size(768,432);
  question1 = "Q1 Was this watch expensive?";
  answer1[0] = "Yes";
  answer1[1] = "No";
  answer1[2] = "maybe";
  answer1[3] = "-----";
  question2 = "Q2 Do you study English everyday?";
  answer2[0] = "Yes";
  answer2[1] = "No";  
  fill(255);
  println("setting done!!!!!!");
}

public String sketchRenderer() {
   return P2D;
}


float posx;
float posy;

PImage slideimage1;
PImage slideimage2;

void draw()
{
  if(app_status=="menu to shot"){
      textSize(40);
      text(app_status,400,80);
      
  } else if(app_status=="enq") {
      background(255);
      textSize(20);
      fill(0);
      text(question1,30,50);
      text(question2,30,300);
      textSize(30);
      text(answer1[0],80,130);
      text(answer1[1],450,130);
      text(answer1[2],80,210);
      text(answer1[3],450,210);
      text(answer2[0],80,360);
      text(answer2[1],450,360);
      rect(600,10,150,50);
      fill(255);
      text("submit",625,45);
      rect1.display();
      rect2.display();
      rect3.display();
      rect4.display();
      rect5.display();
      rect6.display();
      
  } else if(app_status=="slideshow") {
    background(255);
    image(slideimage1,0,0);
    timer++;
  } 
}


void mousePressed() {
  if(app_status=="menu to shot"){
    toggleCamera();
    app_status = "RAKUGAKI";
    photo = gBuffer;
    
  } else if(app_status=="enq") {
    println("push!!!");
    if(rect1.pressed()) println(rect1.locked);
    if(rect2.pressed()) println(rect2.locked);
    if(rect3.pressed()) println(rect3.locked);
    if(rect4.pressed()) println(rect4.locked);
    if(rect5.pressed()){
      rect6.toggled();
    }
    if(rect6.pressed()) {
      rect5.toggled();
    }
    if(mouseX>600 && mouseY>=10 && mouseX<=750 && mouseY <=60){
      String[] lines = new String[5];
      lines[0] = String.valueOf(rect1.locked);
      lines[1] = String.valueOf(rect2.locked);
      lines[2] = String.valueOf(rect3.locked);
      lines[3] = String.valueOf(rect4.locked);
      lines[4] = String.valueOf(rect5.locked); 
      
      if(!directory2.isDirectory()){
        directory2.mkdir();
       }
      saveStrings("//sdcard//eisha/data/"+utime+".txt", lines);
      
      //error
      app_status="slideshow";
    }
  }
}
void keyPressed() {
  if(key == CODED) {
    if(keyCode == MENU) {
      if(app_status=="RAKUGAKI"){
        try {
          if(!directory.isDirectory()){
            directory.mkdir();
          }
          utime = System.currentTimeMillis();
          save("//sdcard//eisha/"+utime+".png");
          println("saved:"+utime+".png");
        } catch(NullPointerException e) {
          println(e); 
        }
        println("mouseX:"+motionX);
        println("mouseY:"+motionY);
        photo = gBuffer;
        app_status="enq";
        rect1 = new RectButton(30, 100, 40);
        rect2 = new RectButton(400, 100, 40);
        rect3 = new RectButton(30, 180, 40);
        rect4 = new RectButton(400, 180, 40);
        rect5 = new RectButton(30, 330, 40);
        rect5.toggled();
        rect6 = new RectButton(400, 330, 40);
        getfilelist("//sdcard//eisha/");
        background(255);
      }
    }
  }
}


public boolean surfaceTouchEvent(MotionEvent event) {
    if(app_status=="RAKUGAKI"){
      if(event.getAction()==MotionEvent.ACTION_DOWN){
        posx=motionX;
        posy=motionY;
        println("movedX:"+posx+" -> "+motionX);
        println("click");
      }else if(event.getAction()==MotionEvent.ACTION_MOVE){
        if(abs(motionX-posx)<100){
          if(abs(motionY-posy)<100){
            println("movedX:"+posx+" -> "+motionX);
            strokeWeight(motionPressure*200);
            line(posx, posy, motionX, motionY); 
            println("dragg");
          }
        }
        posx=motionX;
        posy=motionY;
      }else if(event.getAction()==MotionEvent.ACTION_UP){
        println("release");
      }
    }
  return super.surfaceTouchEvent(event);
}

// Setup camera globals:
CameraSurfaceView gCamSurfView = null;
PImage gBuffer;


void onResume() {
  super.onResume();
  text(app_status,150,380,500,300);
  if (gCamSurfView == null) // So it doesnt make a new one everytime you resume.
  {
    gCamSurfView = new CameraSurfaceView(this.getApplicationContext());
    println("Made a new CameraSurfaceView");
    toggleCamera();
  }
}

void onPause()
{
  super.onPause();
  println("onPause()!");
  stopCamera();
}



//-----------------------------------------------------------------------------------------

public class CameraSurfaceView extends SurfaceView implements SurfaceHolder.Callback, Camera.PreviewCallback {

  SurfaceHolder mHolder;
  Camera cam = null;
  Camera.Size prevSize;
  boolean cameraPaused = false;

  CameraSurfaceView(Context context) {
    super(context);
    mHolder = getSurfaceHolder();
  }
  
  void cameraStart()
  {    
    println("cameraStart");
    mHolder.addCallback(this);
    if (cam == null) cam = Camera.open();
    cam.setPreviewCallback(this);
    
    Camera.Parameters parameters = cam.getParameters();
    prevSize = parameters.getPreviewSize();

    gBuffer = createImage(prevSize.width, prevSize.height, RGB);
    
    cam.startPreview();
    println("startPreview");
  }
  
  void cameraStop()
  {
    println("cameraStop");
    cam.stopPreview();
    cam.setPreviewCallback(null);
    mHolder.removeCallback(this);
    cam.release();
    cam = null;
  }
  
  void cameraToggle()
  {
    println("cameraToggle");
    if (cam == null) {
      cameraStart();
    } else {
      cameraStop();
    }
  }
  
  void cameraPause()
  {
    if (!cameraPaused)
    {
      cam.stopPreview();
      cameraPaused = true;
    }
  }
  
  void cameraResume()
  {
    if (cameraPaused)
    {
      try
      {
        println("cameraResume");
        cam.setPreviewCallback(this);
        cam.startPreview();
        cameraPaused = false;
      }
      catch (NullPointerException e)
      {
        cameraStart();
        cameraResume();
      }
    }
  }


  void surfaceCreated (SurfaceHolder holder) {
    println("Surface Created");
    cameraStart();
  }  

  void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
    // Start our camera previewing:
    println("Surface Changed");
     Camera.Parameters parameters = cam.getParameters();
    parameters.setPreviewSize(w, h);
    cameraStart();
  }

  void surfaceDestroyed (SurfaceHolder holder) {
    // Give the cam back to the phone:
    println("Surface Destroyed");
    cameraStop();
  }


  void onPreviewFrame(byte[] data, Camera cam) {
      gBuffer.loadPixels();
      decodeYUV420SP(gBuffer.pixels, data, prevSize.width, prevSize.height);
      gBuffer.updatePixels();

      image(gBuffer, (width-gBuffer.width)/2, (height-gBuffer.height)/2);
  }

  void decodeYUV420SP(int[] rgb, byte[] yuv420sp, int width, int height) {
    final int frameSize = width * height;

    for (int j = 0, yp = 0; j < height; j++) {
      int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
      for (int i = 0; i < width; i++, yp++) {
        int y = (0xff & ((int) yuv420sp[yp])) - 16;
        if (y < 0)
          y = 0;
        if ((i & 1) == 0) {
          v = (0xff & yuv420sp[uvp++]) - 128;
          u = (0xff & yuv420sp[uvp++]) - 128;
        }

        int y1192 = 1192 * y;
        int r = (y1192 + 1634 * v);
        int g = (y1192 - 833 * v - 400 * u);
        int b = (y1192 + 2066 * u);

        if (r < 0)
           r = 0;
        else if (r > 262143)
           r = 262143;
        if (g < 0)
           g = 0;
        else if (g > 262143)
           g = 262143;
        if (b < 0)
           b = 0;
        else if (b > 262143)
           b = 262143;

        rgb[yp] = 0xff000000 | ((r << 6) & 0xff0000) | ((g >> 2) & 0xff00) | ((b >> 10) & 0xff);
      }
    }
  }
}

void stopCamera()
{
  try
  {
    gCamSurfView.cameraStop();
  }
  catch (NullPointerException e)
  {
    println(e);
  }
}

void toggleCamera() {
  app_status = "menu to shot";
  gCamSurfView.cameraToggle();
}

void pauseCamera() {
  gCamSurfView.cameraPause();
}

void resumeCamera() {
  gCamSurfView.cameraResume();
}

void getfilelist(String path) {
  File dir = new File(path);
  File[] files = dir.listFiles();
  for (int i = 0; i < files.length; i++) {
    File file = files[i];
    System.out.println((i + 1) + ":    " + file);
  }
}
