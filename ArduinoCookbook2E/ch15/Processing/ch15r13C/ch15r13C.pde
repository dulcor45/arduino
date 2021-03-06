// Processing UDPTest
// Demo sketch sends & receives data to Arduino using UDP

import hypermedia.net.*;

UDP udp;  // define the UDP object

HScrollbar[] scroll = new HScrollbar[6];  //see: topics/gui/scrollbar

void setup() {
  size(256, 200);
  noStroke();
  for(int i=0; i < 6; i++) // create the scroll bars
    scroll[i] = new HScrollbar(0, 10 + (height / 6) * i, width, 10, 3*5+1);

  udp = new UDP( this, 6000 );  // create datagram connection on port 6000
  //udp.log( true );            // <-- print out the connection activity
  udp.listen( true );           // and wait for incoming message
}

void draw()
{
  background(255);
  fill(255);
  for(int i=0; i < 6; i++) {
    scroll[i].update();
    scroll[i].display();
  }
}

void keyPressed() {
  String ip       = "192.168.1.177";    // the remote IP address
  int port        = 8888;               // the destination port
  byte[] message = new byte[6] ;

  for (int i=0; i < 6; i++){
    message[i] = byte(scroll[i].getPos());
    println(int(message[i]));
  }
  println();
  udp.send( message, ip, port );

}

void receive( byte[] data ) {                           // <-- default handler
//void receive( byte[] data, String ip, int port ) {    // <-- extended handler

  println("incoming data is:");
  for(int i=0; i < 6; i++){
     scroll[i].setPos(data[i]);
     println((int)data[i]);
  }
}

class HScrollbar
{
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  int sposMin, sposMax;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (int xp, int yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (over()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
    mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    fill(255);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(153, 102, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    return spos * ratio;
  }

  void setPos(int value) {
    spos = value / ratio;
  }
}
