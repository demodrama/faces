/* 
 Actor class 
 draws the face and the body image according to the physical 
 mask position. Actor class provide methods for set and apply a black & white mask 
 image to the face image  
 */

/*
 Copyright (C) 2012 Enrique Esteban, Ignacio Cossio, Yago Torroja & Eduardo Moriana  @ Demodrama Faces
 All rights reserved.
 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

class Actor
{

  int DEFAULT_WIDTH = 200;
  int DEFAULT_HEIGHT = 200;

  int DEFAULT_BODY_WIDTH = 300;
  int DEFAULT_BODY_HEIGHT = 200;

  PApplet parent;

  Mask mask;
  GLTexture face;
  GLTexture body;
 
  int maskMode = DemoConstants.MASK_CENTER;

  int sourceX;
  int sourceY;
  int sourceWidth;
  int sourceHeight;

  int bodyWidth = 450;
  int bodyHeight = 600;
  int bodyDistance = 100;

  int maskWidth = 320;
  int maskHeight = 240;
  
  GLTexture maskedTex;
  GLTexture maskingTex;
  GLTexture auxTex;
  GLTextureFilter maskFilter;

  Actor(PApplet parent, int screenWidth, int screenHeight)
  { 
    this.parent = parent;
    mask = new Mask(screenWidth, screenHeight);
    face    = new GLTexture(parent, bodyWidth, bodyHeight);
    body    = new GLTexture(parent, bodyWidth, bodyHeight);

    maskFilter = new GLTextureFilter(parent, "Mask.xml");
    maskedTex  = new GLTexture(parent, maskWidth, maskHeight);
    maskingTex = new GLTexture(parent, maskWidth, maskHeight);
    auxTex     = new GLTexture(parent, maskWidth, maskHeight);  
  }

  void draw(GLTexture face, GLTexture body)
  {
    noStroke();
    if (body != null) drawBody(body);
    if (face != null) drawFace(face);
  } 

  void draw(GLTexture face)
  {
    noStroke();
    if (face != null) drawFace(face);
  } 

  void drawBody(GLTexture body)
  {
    if (mask.detected)
    {
      pushMatrix();
      translate(mask.center.x, mask.center.y + bodyDistance);

      /*
      maskFilter.setParameterValue("mask_factor", 0.4);
      auxTex.clear(255, 255);
      maskFilter.apply(new GLTexture[] { auxTex, body }, maskedTex);
      image(maskedTex, -bodyWidth/2, -bodyHeight/2, bodyWidth, bodyHeight);
      */
      image(body, -bodyWidth/2, -bodyHeight/2, bodyWidth, bodyHeight);
      
      popMatrix();
    }
  }

  void drawFace(GLTexture face)
  {
    if (mask.detected && face != null)
    {

      //GLTexture auxImg = null;
      if (false) // (maskImg != null)
      {
        /*
        if (maskMode == DemoConstants.MASK_RESIZE)
        {
          auxMask = createImage(face.width, face.height, ARGB);
          auxMask.copy(face, 0, 0, face.width, face.height, 0, 0, face.width, face.height);
          auxMask.resize(maskImg.width, maskImg.height);
          auxMask.mask(maskImg);
        }
        else if (maskMode == DemoConstants.MASK_CENTER)
        {
          auxMask = createImage(maskImg.width, maskImg.height, ARGB);
          auxMask.copy(face, (face.width - maskImg.width)/2, (face.height - maskImg.height)/2, 
          maskImg.width, maskImg.height, 0, 0, maskImg.width, maskImg.height);
          auxMask.mask(maskImg);
        }
        else if (maskMode == DemoConstants.MASK_CORNER)
        {
          auxMask = createImage(maskImg.width, maskImg.height, ARGB);
          auxMask.copy(face, 0, 0, maskImg.width, maskImg.height, 0, 0, maskImg.width, maskImg.height);
          auxMask.mask(maskImg);
        }
        else if (maskMode == DemoConstants.MASK_CUSTOM)
        {
          
          auxMask = createImage(maskImg.width, maskImg.height, ARGB);
          auxMask.copy(face, sourceX, sourceY, sourceWidth, sourceHeight, 0, 0, maskImg.width, maskImg.height);
          auxMask.mask(maskImg);
          
        }
        */
      }
      else
      {
        if (maskMode == DemoConstants.MASK_CENTER)
        {
          int hTarget = face.height;
          int wTarget = (int) (maskWidth * ((float) face.height) / maskHeight);           
          auxTex.putPixelsIntoTexture(face, (face.width - wTarget)/2 , (face.height - hTarget)/2  , wTarget, hTarget);
        } else {
          auxTex.putImage(face);
        }
      }
            
      // Apply mask filter using the mask texture just generated.
      maskFilter.setParameterValue("mask_factor", 1.0);
      maskFilter.apply(new GLTexture[] { auxTex, maskingTex }, maskedTex);

      // Apply texture to polygon
      beginShape();
      texture(maskedTex);
      PVector upLeft_0 = PVector.sub(mask.upLeftPos, mask.center);
      PVector upRight_0 = PVector.sub(mask.upRightPos, mask.center); 
      PVector downRight_0 = PVector.sub(mask.downRightPos, mask.center); 
      PVector downLeft_0 = PVector.sub(mask.downLeftPos, mask.center); 
      vertex(mask.upLeftPos.x, mask.upLeftPos.y, 0.0F, 0.0F);  // arriba
      vertex(mask.upRightPos.x, mask.upRightPos.y, maskedTex.width, 0.0F); // izda
      vertex(mask.downRightPos.x, mask.downRightPos.y, maskedTex.width, maskedTex.height); // abajo
      vertex(mask.downLeftPos.x, mask.downLeftPos.y, 0F, maskedTex.height); // derecha
      endShape();
      
    }
  }

  void loadMask(String path)
  {
    maskWidth = 320;
    maskHeight = 240;
    maskingTex.clear(255, 255);
    try {
      maskingTex.loadTexture(path);
      maskWidth = maskingTex.width;
      maskHeight = maskingTex.height;
    } catch (Exception e) {
      println("Demodrama Actor: Could not open " + path + " mask file");
    }
    
  }

  void maskMode( int mode )
  {
    if (mode == DemoConstants.MASK_CENTER)
    {
      maskMode = DemoConstants.MASK_CENTER;
    }
    else if (mode == DemoConstants.MASK_CORNER)
    {
      maskMode = DemoConstants.MASK_CORNER;
    }
    else if (mode == DemoConstants.MASK_RESIZE)
    {
      maskMode = DemoConstants.MASK_RESIZE;
    }
    else
    {
      println("Demodrama Actor: Mask mode not recognized");
    }
  }

  void maskMode(int x, int y, int width, int height)
  {
    maskMode = DemoConstants.MASK_CUSTOM;
    sourceX = x;
    sourceY = y;
    sourceWidth = width;
    sourceHeight = height;
  }
  
}

