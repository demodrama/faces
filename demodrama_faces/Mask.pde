/* 
 Mask class 
 This class stores the position of the physical mask on the screen.
 It's used by the actor class for rendering its face image.
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

class Mask {

  boolean detected = false;

  PVector leftMarkPos;
  PVector rightMarkPos;
  PVector upMarkPos;

  PVector center;
  int trailLength = 500;
  float[] trailX;
  float[] trailY;
  int lastIndex = 0;

  PVector upLeftPos;
  PVector upRightPos;
  PVector downRightPos;
  PVector downLeftPos;

  int sceneWidth;
  int sceneHeight;
  
  float scale = 1.0;

  boolean leftMarkUpdated  = false;
  boolean rightMarkUpdated = false;
  boolean upMarkUpdated    = false;
      
  boolean firstTimeError = true;

  Rotation r; 

  Mask(int w, int h)
  {
    center = new PVector(0, 0);
    leftMarkPos  = new PVector(0, 0);
    rightMarkPos = new PVector(0, 0);
    upMarkPos    = new PVector(0, 0);
    upLeftPos    = new PVector(0, 0);
    upRightPos   = new PVector(0, 0);
    downRightPos = new PVector(0, 0);
    downLeftPos  = new PVector(0, 0);

    sceneWidth  = w;
    sceneHeight = h;
    trailX = new float[trailLength];
    trailY = new float[trailLength];

    r = new Rotation(Vector3D.plusK, -PI/3);
   
  }
  
  void setScale(float s) {
    scale = s;
  }

  void clearHistory() {
    leftMarkPos  = new PVector(0, 0, 0);
    rightMarkPos = new PVector(0, 0, 0);
    upMarkPos    = new PVector(0, 0, 0);
  }
  
  void update(Vector tuioCursorList) throws java.lang.ArrayIndexOutOfBoundsException
  {
      

    PVector lastRightMark = new PVector(0, 0);
    PVector lastLeftMark  = new PVector(0, 0);
    PVector lastUpMark    = new PVector(0, 0);

    if (true) {  // If already detected in previous frames
      // First, try to get already assigned points based on tuio session ID
      
      leftMarkUpdated  = false;
      rightMarkUpdated = false;
      upMarkUpdated    = false;

      lastLeftMark  = leftMarkPos;
      lastRightMark = rightMarkPos;
      lastUpMark    = upMarkPos;

      for (int i = 0; i < tuioCursorList.size(); i++)
      {
        TuioCursor t = (TuioCursor) tuioCursorList.get(i);
        if (leftMarkPos.z == t.getSessionID())
        {
          leftMarkPos = new PVector(t.getScreenX(sceneWidth), t.getScreenY(sceneHeight), t.getSessionID());
          leftMarkUpdated = true;
          detected = true;
        }
        else if (rightMarkPos.z == t.getSessionID())
        {
          rightMarkPos = new PVector(t.getScreenX(sceneWidth), t.getScreenY(sceneHeight), t.getSessionID());
          rightMarkUpdated = true;
          detected = true;
        }
        else if (upMarkPos.z == t.getSessionID())
        {
          upMarkPos = new PVector(t.getScreenX(sceneWidth), t.getScreenY(sceneHeight), t.getSessionID());
          upMarkUpdated = true;
          detected = true;
        }
      } 
      
    }

    // Then we try to update non already updated points
    if (tuioCursorList.size() == 3)
    {
    
      // Ordenamos los puntos: Arriba, derecha e izquierda
      TuioCursor arriba = (TuioCursor) tuioCursorList.elementAt(0);
      TuioCursor izq = null;
      TuioCursor der = null;
      int pos = 0;
      for (int i = 0; i < tuioCursorList.size(); i++) {
        TuioCursor tcur = (TuioCursor) tuioCursorList.elementAt(i);
        if (arriba.getScreenY(sceneHeight) > tcur.getScreenY(sceneHeight)) {
          arriba = tcur;
          pos = i;
        }
      }
      pos = (pos + 1) % 3;
      izq = (TuioCursor) tuioCursorList.elementAt(pos);
      pos = (pos + 1) % 3;
      der = (TuioCursor) tuioCursorList.elementAt(pos);
      if (izq.getScreenX(sceneWidth) > der.getScreenX(sceneWidth)) {
        TuioCursor temp = izq;
        izq = der;
        der = temp;
      }

      if (!leftMarkUpdated) {
        leftMarkPos  = new PVector(izq.getScreenX(sceneWidth), izq.getScreenY(sceneHeight), izq.getSessionID());
        leftMarkUpdated  = true;
      }      
      if (!rightMarkUpdated) {
        rightMarkPos = new PVector(der.getScreenX(sceneWidth), der.getScreenY(sceneHeight), der.getSessionID());
        rightMarkUpdated  = true;
      }      
      if (!upMarkUpdated) {
        upMarkPos    = new PVector(arriba.getScreenX(sceneWidth), arriba.getScreenY(sceneHeight), arriba.getSessionID());
        upMarkUpdated  = true;
      }      
      
      firstTimeError = false;

    } 
    else 
    {

      PVector diff;
      
      if (upMarkUpdated && rightMarkUpdated && !leftMarkUpdated)
      {
        leftMarkPos = estimatePoint(lastRightMark, rightMarkPos, lastUpMark, upMarkPos, lastLeftMark);
      }
      else if (upMarkUpdated && !rightMarkUpdated && leftMarkUpdated)
      {
        rightMarkPos = estimatePoint(lastLeftMark, leftMarkPos, lastUpMark, upMarkPos, lastRightMark);
      }
      else if (!upMarkUpdated && rightMarkUpdated && leftMarkUpdated)
      {
        upMarkPos = estimatePoint(lastLeftMark, leftMarkPos, lastRightMark, rightMarkPos, lastUpMark);
      }
      else if (!upMarkUpdated && rightMarkUpdated && !leftMarkUpdated)
      {
        diff = PVector.sub(rightMarkPos, lastRightMark);  
        upMarkPos.add(diff);
        leftMarkPos.add(diff);
      }
      else if (!upMarkUpdated && !rightMarkUpdated && leftMarkUpdated)
      {
        diff = PVector.sub(leftMarkPos, lastLeftMark);  
        rightMarkPos.add(diff);
        upMarkPos.add(diff);
      }
      else if (upMarkUpdated && !rightMarkUpdated && !leftMarkUpdated)
      {
        diff = PVector.sub(upMarkPos, lastUpMark);  
        rightMarkPos.add(diff);
        leftMarkPos.add(diff);
      }
      
    }   
    // Extraemos punto central
    center = PVector.div(PVector.add(leftMarkPos, rightMarkPos), 2F);

    // Cola de puntos anteriores
    trailX[lastIndex] = center.x;
    trailY[lastIndex] = center.y;
    lastIndex++;
    lastIndex %= 100;

    // Sacamos los cuatro vértices con escalado
    PVector refA = PVector.sub(upMarkPos, center);
    refA.mult(scale);
    PVector refB = PVector.sub(leftMarkPos, center);
    refB.mult(scale);
    PVector refC = PVector.sub(rightMarkPos, center);
    refC.mult(scale);
    upLeftPos = PVector.add(PVector.add(refB, center), refA);
    upRightPos = PVector.add(PVector.add(refC, center), refA);
    downLeftPos = PVector.sub(PVector.add(refB, center), refA);
    downRightPos = PVector.sub(PVector.add(refC, center), refA);
  }
  
  void draw() {
    pushStyle();
    
    stroke(255, 0, 0);
    line(upLeftPos.x, upLeftPos.y, upRightPos.x, upRightPos.y);
    line(upRightPos.x, upRightPos.y, downRightPos.x, downRightPos.y);
    line(downRightPos.x, downRightPos.y, downLeftPos.x, downLeftPos.y);
    line(downLeftPos.x, downLeftPos.y, upLeftPos.x, upLeftPos.y);
    
    fill((upMarkUpdated ? 0 : 255), 255, 0); 
    ellipse(upMarkPos.x, upMarkPos.y, 10, 10);
    line(upMarkPos.x, upMarkPos.y, center.x, center.y);
    text(nfc(upMarkPos.z, 0), upMarkPos.x - 15, upMarkPos.y - 10);

    fill((rightMarkUpdated ? 0 : 255), 255, 0); 
    ellipse(rightMarkPos.x, rightMarkPos.y, 10, 10);
    line(rightMarkPos.x, rightMarkPos.y, center.x, center.y);
    text(nfc(rightMarkPos.z, 0), rightMarkPos.x - 15, rightMarkPos.y - 10);
    
    fill((leftMarkUpdated ? 0 : 255), 255, 0); 
    ellipse(leftMarkPos.x, leftMarkPos.y, 10, 10);
    line(leftMarkPos.x, leftMarkPos.y, center.x, center.y);
    text(nfc(leftMarkPos.z, 0), leftMarkPos.x - 15, leftMarkPos.y - 10);
   
    popStyle();
  }

  PVector estimatePoint(PVector lastRef, PVector ref, PVector lastKnown, PVector known, PVector lastUnknown)
  {
    Vector3D v1;
    Vector3D v2;
    Vector3D v3;
    Vector3D v4; 
    PVector vect1;
    PVector vect2;
    PVector vect3;

    PVector retVal = lastUnknown;

    vect1 =  PVector.sub(lastKnown, lastRef);
    vect1.z = 0;
    vect2 =  PVector.sub(known, ref);
    vect2.z = 0;
    vect3 =  PVector.sub(lastUnknown, lastRef);  
    vect3.z = 0;

    if ((vect1.mag() == 0)||(vect2.mag() == 0)||(vect3.mag() == 0))
    {
      ;
    }
    else
    {
      vect1.normalize();
      v1 = new Vector3D(vect1.x, vect1.y, 0);

      vect2.normalize();
      v2 = new Vector3D(vect2.x, vect2.y, 0);

      float v3Norm = vect3.mag();
      v3 = new Vector3D(vect3.x, vect3.y, 0); 

      r = new Rotation(v1, v2);
      v4 = r.applyTo(v3);

      float id = 0; // lastUnknown.z;
      retVal = new PVector((float)v4.getX() + ref.x, (float)v4.getY() + ref.y, id); 
    }  

    return retVal;
  }
}

