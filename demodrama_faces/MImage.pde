//////////////////////////////////////////////////////////////////////////
// Siluets
// V2.0 15/02/12 Copyright (C) 2012 Enrique Esteban & Yago Torroja
 
class MImage extends GLTexture {
  PApplet parent;

  MImage(PApplet p) {
    super(p);
    parent = p;
  }
  
  MImage(PApplet p, String file) {
    super(p);
    parent = p;
    try {
      this.loadTexture(file);
    } catch(Exception e) {
      println("MImage: could not open " + file + " file");
    }
  }
  
  void resize(int w, int h) {
    GLGraphicsOffScreen resized = new GLGraphicsOffScreen(parent, w, h);
    resized.beginDraw();
    resized.image(this, 0, 0, w, h);
    resized.endDraw();
    this.init(w, h);
    this.clear(0, 0);
    this.copy(resized.getTexture());
    resized.delete();
  }
  
}

