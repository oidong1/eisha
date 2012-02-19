class Button
{
  int x, y;
  int size;
  color buttoncolor = color(250);
  color highlight = color(0);
  color currentcolor = color(250);
  boolean over = false;
  boolean locked = false;
  boolean pressed = false;   

  boolean pressed() 
  {
    if(over()) {
      toggled();
      return true;
    } else {
      return false;
    }    
  }

  boolean over() { 
    return true; 
  }  
  
  boolean toggle() {
    toggled();
    return !locked;
  }
  
  void toggled() {
    locked = !locked;
    if(locked) {
      currentcolor = highlight;
    } else {
      currentcolor = buttoncolor;    
    }
  }
  

  boolean overRect(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }
}

class RectButton extends Button
{
  RectButton(int ix, int iy, int isize) 
  {
    x = ix;
    y = iy;
    size = isize;

  }

  boolean over() {
    print("is it over?");
    if( overRect(x, y, size, size) ) {
      print("over!");
      over = true;
      return true;
    } else {
      print("not over!");
      over = false;
      return false;
    }
  }

  void display() 
  {
    stroke(50);
    strokeWeight(5);
    fill(currentcolor);
    rect(x, y, size, size);
  }
}
