/*
  code name : eisha
  license   : GNU GPL v3
*/

import android.content.Context;
import android.hardware.Camera.Size;
import android.hardware.Camera;
import android.hardware.Camera.PreviewCallback;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import java.util.List;
import java.io.File;
import android.view.Surface;
import android.hardware.Camera.Parameters;

String app_status = "In preparation...";
PImage photo;

/*  static data and settings  */

String question1;
String[] answer1 = new String[3];
String question2;
String answer2;

void setup()
{

  frameRate(15);
  //画面の向きを固定(横)
  orientation(LANDSCAPE);
  
  question1 = "Q1";
  answer1[0] = "A1";
  answer1[1] = "A2";
  answer1[2] = "A3";
  question2 = "Q2";
  answer2 = "A2";
  
  fill(255);
  textSize(40);
}

 public String sketchRenderer() {
   return P2D;
 }
/*  end  */


  
void draw()
{
  text(app_status,150,380,500,300);
}


//画面をタッチしたとき
void mousePressed()
{
  try {
    gBuffer.save("//sdcard//eisha/"+year()+month()+day()+hour()+minute()+second()+".png");
  } catch(NullPointerException e) {
    println(e); 
  }
  toggleCamera();
  println("saved:"+year()+month()+day()+hour()+minute()+second()+".png");
  println("mouseX:"+mouseX);
  println("mouseY:"+mouseY);
  photo = gBuffer;
  getfilelist("//sdcard//eisha/");
}


// Setup camera globals:
CameraSurfaceView gCamSurfView = null; // CHANGE: declare as null
//Context appContext = null;
// This is the physical image drawn on the screen representing the camera:
PImage gBuffer;

void onResume() {
  super.onResume();
  println("onResume()!");
  // Sete orientation here, before Processing really starts, or it can get angry:
  //orientation(PORTRAIT);
  //appContext = this.getApplicationContext();

  // Create our 'CameraSurfaceView' objects, that works the magic:
  if (gCamSurfView == null) // So it doesnt make a new one everytime you resume.
  {
    gCamSurfView = new CameraSurfaceView(this.getApplicationContext());
    println("Made a new CameraSurfaceView");
  }
}

void onPause()
{
  super.onPause();
  println("onPause()!");
  stopCamera();
}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

public class CameraSurfaceView extends SurfaceView implements SurfaceHolder.Callback, Camera.PreviewCallback {
  // Object that accesses the camera, and updates our image data
  // Using ideas pulled from 'Android Wireless Application Development', page 340

  SurfaceHolder mHolder;
  Camera cam = null;
  Camera.Size prevSize;
  boolean cameraPaused = false;

  // SurfaceView Constructor:  : ---------------------------------------------------
  CameraSurfaceView(Context context) {
    super(context);

    mHolder = getSurfaceHolder();
  }
  
  void cameraStart()
  {
    app_status = "tap to shot";
    
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
      app_status = "saved!";
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

  //  Camera.PreviewCallback stuff: ------------------------------------------------------
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
