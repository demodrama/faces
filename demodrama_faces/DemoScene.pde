/* 
 DemoScene class 
 Creates the two actors and the scene and updates the actor faces position 
 when receiving TUIO messages
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

class DemoScene
{ 

  Actor actor_1;
  Actor actor_2;
  Stage stage;

  TuioProcessing tuioClient;
  List <TuioCursor>cursores;
  int sceneWidth, sceneHeight;

  float centerDistance = 200;

  PApplet parent;

  boolean virtualPoint;

  PVector c1;
  PVector c2;

  DemoScene(PApplet parent, int w, int h)
  {   
    this.parent = parent;
    tuioClient  = new TuioProcessing(parent);
    sceneWidth  = w;
    sceneHeight = h;
    actor_1 = new Actor(parent, sceneWidth, sceneHeight);
    actor_1.loadMask(DemoConstants.LEFT_MASK_PATH);
    actor_1.maskMode(DemoConstants.MASK_CENTER);
    actor_2 = new Actor(parent, sceneWidth, sceneHeight);
    actor_2.loadMask(DemoConstants.RIGHT_MASK_PATH);
    actor_2.maskMode(DemoConstants.MASK_CENTER);
    stage = new Stage(parent, sceneWidth, sceneHeight);
    c1 = new PVector(0, 0.5, 0);
    c2 = new PVector(1, 0.5, 0);

    virtualPoint = false;
  }

  Actor getActor_1()
  {
    return actor_1;
  }

  Actor getActor_2()
  {
    return actor_2;
  }

  Stage getStage()
  {
    return stage;
  }

  public class PointXComparator implements Comparator {

    public int compare(Object o1, Object o2) {
      TuioCursor amigo1 = (TuioCursor) o1;
      TuioCursor amigo2 = (TuioCursor) o2;

      if (amigo1.getX() < amigo2.getX())
        return -1;
      else if (amigo1.getX() > amigo2.getX())
        return 1;
      else
        return 0;
    }
  }

  private List agrupaSimple(Vector cursores) {
    List todos = new ArrayList(cursores);
    Collections.sort(todos, new PointXComparator());
    return todos;
  }


  void update()
  {
    Vector tuioCursorList;
    tuioCursorList = tuioClient.getTuioCursors();
    Vector ccvTuioCursorList = tuioClient.getTuioCursors();
    tuioCursorList = new Vector();
    for (int i = 0; i < ccvTuioCursorList.size(); i++) {
      TuioCursor tcur = (TuioCursor) ccvTuioCursorList.get(i);
      PVector posTcur = calibrator.getScreenCoords(
      tcur.getScreenX(width), tcur.getScreenY(height));
      TuioCursor newTCur = new TuioCursor(tcur.getSessionID(), 
      tcur.getCursorID(), posTcur.x / width, posTcur.y / height);
      tuioCursorList.add(newTCur);
    }

    actor_1.mask.detected = false;
    actor_2.mask.detected = false;

    cursores = agrupaSimple(tuioCursorList);

    agrupaKMeans(tuioCursorList);

    if (cursores.size() == 5) {  
      TuioCursor izq = (TuioCursor) cursores.get(1);
      TuioCursor der = (TuioCursor) cursores.get(3); // cursores.size()-1);
      float maxDistance = dist(izq.getScreenX(sceneWidth), izq.getScreenY(sceneHeight), der.getScreenX(sceneWidth), der.getScreenY(sceneHeight)); 

      if (maxDistance < centerDistance) {
        // Remove intermediate point (0, 1, ->2<- , 3, 4) to avoid identification problems
        cursores.remove(2);
        if (virtualPoint) {
          // Create a centra point based on points 1 and 2 (0, ->(1, 2)<- , 3) to simulate a one big mask  
          float halfX= (cursores.get(1).getScreenX(sceneWidth)  + cursores.get(2).getScreenX(sceneWidth) ) / 2;
          float halfY= (cursores.get(1).getScreenY(sceneHeight) + cursores.get(2).getScreenY(sceneHeight)) / 2;
          cursores.remove(2);
          cursores.get(1).remove(TuioTime.getSessionTime());
          cursores.get(1).update(TuioTime.getSessionTime(), halfX/sceneWidth, halfY/sceneHeight);
        }
      }
    }

    if (cursores.size() == 6)
    {
      Vector grupo1 = new Vector(cursores.subList(0, 3)); 
      actor_1.mask.detected = true;
      try {
        actor_1.mask.update(grupo1);
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }     

      Vector grupo2 = new Vector(cursores.subList(3, 6));
      actor_2.mask.detected = true;
      try {
        actor_2.mask.update(grupo2);
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }
    } 
    else if (cursores.size() == 3) { 
      actor_1.mask.detected = true;
      try {
        actor_1.mask.update(new Vector(cursores));
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }
    }
    else if (cursores.size() < 3)
    {
      try {
        actor_1.mask.update(new Vector(cursores));
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }
    }
    else if (cursores.size() > 3)
    {
      try {
        actor_1.mask.update(new Vector(cursores));
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }
      try {
        actor_2.mask.update(new Vector(cursores));
      } 
      catch (ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException) {
      }
    }
  }

  void drawCursors() {
    Vector tuioCursorList;
    tuioCursorList = tuioClient.getTuioCursors();

    for (int i = 0; i < tuioCursorList.size(); i++) {
      TuioCursor c = (TuioCursor)tuioCursorList.get(i);
      pushStyle();
      stroke(255, 255, 0);
      float x = c.getScreenX(sceneWidth);
      float y = c.getScreenY(sceneHeight);
      line(x - 20, y, x + 20, y);
      line(x, y - 20, x, y + 20);
      fill(255, 0, 255);
      text(nfc(c.getSessionID(), 0), x + 5, y - 5);
      popStyle();
    }
  }

  Vector[] agrupaKMeans(Vector <TuioCursor>cursores) {
    final float minErr = 0.001;
    final int iterations_limit = 20;

    float  maxErr = 1000;
    int    iterations = 0;
    float  speed = 0.01;

    Vector[] todos = new Vector[2];

    todos[0] = new Vector<TuioCursor>();
    todos[1] = new Vector<TuioCursor>();

    if (cursores.size() == 0) return todos;

    /*   
     if (cursores.size() == 3) {
     c1 = new PVector(cursores.get(0).getX(), cursores.get(0).getY(), 0);
     c2 = new PVector(1000, 1000, 0);
     }
     
     if (cursores.size() == 6) {
     c1 = new PVector(cursores.get(0).getX(), cursores.get(0).getY(), 0);
     c2 = new PVector(cursores.get(cursores.size()-1).getX(), cursores.get(cursores.size()-1).getY(), 0);
     }
     */

    // Compute sets assigment
    while (maxErr > minErr && iterations++ < iterations_limit) {

      PVector nc1 = new PVector();
      PVector nc2 = new PVector();
      int n1 = 0;
      int n2 = 0;
      for (int i = 0; i < cursores.size(); i++) {
        float d1 = dist(c1.x, c1.y, cursores.get(i).getX(), cursores.get(i).getY());
        float d2 = dist(c2.x, c2.y, cursores.get(i).getX(), cursores.get(i).getY());
        if (d1 < d2) {
          nc1.add(new PVector(cursores.get(i).getX(), cursores.get(i).getY(), 0));
          n1++;
        } 
        else {
          nc2.add(new PVector(cursores.get(i).getX(), cursores.get(i).getY(), 0));
          n2++;
        }
      }
      nc1.div(n1);
      nc2.div(n2);
      maxErr = max(dist(c2.x, c2.y, nc2.x, nc2.y), dist(c1.x, c1.y, nc1.x, nc1.y));
      c1.add(PVector.mult(PVector.sub(nc1, c1), speed));
      c2.add(PVector.mult(PVector.sub(nc2, c2), speed));
    }

    float d12 = 0;
    float d22 = 0;

    // Make sets
    for (int i = 0; i < cursores.size(); i++) {
      float d1 = dist(c1.x, c1.y, cursores.get(i).getX(), cursores.get(i).getY());
      float d2 = dist(c2.x, c2.y, cursores.get(i).getX(), cursores.get(i).getY());
      if (d1 < d2) {
        pushStyle();
        stroke(255, 255, 0);
        noFill();
        ellipse(cursores.get(i).getX()*sceneWidth, cursores.get(i).getY()*sceneHeight, 30, 30);
        popStyle();
        todos[0].add(cursores.get(i));
        d12 += d1*d1; // Cuadratic error
      } 
      else {
        pushStyle();
        stroke(0, 255, 255);
        noFill();
        ellipse(cursores.get(i).getX()*sceneWidth, cursores.get(i).getY()*sceneHeight, 30, 30);
        popStyle();
        todos[1].add(cursores.get(i));
        d22 += d2*d2; // Cuadratic error
      }
    }

    return todos;
  }
}

