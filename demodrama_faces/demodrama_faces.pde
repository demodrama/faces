/*
 Copyright (C) 2012  Enrique Esteban, Ignacio Cossio, Yago Torroja & Eduardo Moriana @ Demodrama Faces
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

import TUIO.*;
import processing.opengl.*;
import codeanticode.gsvideo.*;
import codeanticode.glgraphics.*;
import peasy.org.apache.commons.math.geometry.*;
import java.awt.Rectangle;

int leftSeconds = 2;
int rightSeconds = 3;
int stageSeconds = 10;

// Rendering Objects
DemoScene scene;
Actor rightActor;
Actor leftActor;
Stage stage;

// Sequencer object
Content leftFaceContent; 
Content rightFaceContent; 
Content stageContent; 

// Spotlight images objects
GLTexture leftActorSpotlight;
GLTexture rightActorSpotlight;

// Content indixes
int currentFaceLeftStep = 0;
int currentFaceRightStep = 0;
int currentStageStep = 0;

QuadCalibrator calibrator;
boolean calibMode = false;

PImage maskImg;
float faceZoom = 1.0;


void setup() {

  size(1024, 768, GLConstants.GLGRAPHICS);
  frameRate(30);
  noCursor();  
  
  // renderers initialization
  scene = new DemoScene(this, width, height);
  stage = scene.getStage();
  leftActor = scene.getActor_1();
  rightActor = scene.getActor_2();

  // Spotlights images setup
  leftActorSpotlight  = new MImage(this, DemoConstants.LEFT_SPOTLIGHT_PATH); 
  rightActorSpotlight = new MImage(this, DemoConstants.RIGHT_SPOTLIGHT_PATH);

  String rootFolder = "Scene";

  leftFaceContent = new Content(this);
  leftFaceContent.addSeveralSources(rootFolder + "/" + DemoConstants.LEFT_FACE_FOLDER);
  leftFaceContent.setSource(0);

  rightFaceContent = new Content(this);
  rightFaceContent.addSeveralSources(rootFolder + "/" + DemoConstants.RIGHT_FACE_FOLDER);
  rightFaceContent.setSource(0);

  stageContent = new Content(this);
  stageContent.addSeveralSources(rootFolder + "/" + DemoConstants.STAGE_FOLDER);
  stageContent.setSource(0);

  calibrator = new QuadCalibrator(this, 1024, 768, 1024, 768, 20);
  calibrator.load("calibrator.xml");

  GLTexture auxTex = new GLTexture(this, leftActor.maskWidth, leftActor.maskHeight);  
  maskImg = loadImage("leftMask.png");
}

void movieEvent(GSMovie movie) {
  movie.read();
}

void draw() {
  leftFaceContent.speed(1/(0.1+frameRate*leftSeconds));
  rightFaceContent.speed(1/(0.1+frameRate*rightSeconds));
  stageContent.speed(1/(0.1+frameRate*stageSeconds));

  scene.update();

  if (calibMode) {
    calibDraw();
  }
  else {
    normalDraw();
  }
}

void calibDraw() {
    background(0);
    Vector tuioCursors = scene.tuioClient.getTuioCursors();
    if (tuioCursors.size() == 1) {
      TuioCursor tcur = (TuioCursor) tuioCursors.elementAt(0);
      calibrator.draw(new PVector(tcur.getScreenX(width), 
      tcur.getScreenY(height)));
    } 
    else {
      PVector nullVector = null;
      calibrator.draw(nullVector);
    }
    leftActor.draw(leftFaceContent.getFrame(), leftActorSpotlight);  
}

void normalDraw() {
  stage.draw(stageContent.getFrame());
  leftActor.draw(leftFaceContent.getFrame(), leftActorSpotlight);
  rightActor.draw(rightFaceContent.getFrame(), rightActorSpotlight);
}

void keyPressed() {
  // Change contents
  if (key == 'w') { // change left face 
    currentFaceLeftStep++;
    currentFaceLeftStep = min(currentFaceLeftStep, leftFaceContent.numOfSources()-1);
    leftFaceContent.setSource(currentFaceLeftStep);
    println("left face: "+currentFaceLeftStep);
  }
  else if (key == 'q') {
    currentFaceLeftStep--;
    currentFaceLeftStep = max(currentFaceLeftStep, 0);
    leftFaceContent.setSource(currentFaceLeftStep);
    println("left face: "+ currentFaceLeftStep);
  }
  else if (key == 's') { // change right face
    currentFaceRightStep++;
    currentFaceRightStep = min(currentFaceRightStep, rightFaceContent.numOfSources()-1);
    rightFaceContent.setSource(currentFaceRightStep);
    println("right face: "+ currentFaceRightStep);
  }
  else if (key == 'a') {
    currentFaceRightStep--;
    currentFaceRightStep = max(currentFaceRightStep, 0);
    rightFaceContent.setSource(currentFaceRightStep);    
    println("right face: "+ currentFaceRightStep);
  }
  else if (key == 'x') { // change stage
    currentStageStep++;
    currentStageStep = min(currentStageStep, stageContent.numOfSources()-1);
    stageContent.stop();
    stageContent.setSource(currentStageStep);
    stageContent.play();
    println("stage: "+ currentStageStep);
  }
  else if (key == 'z') {
    currentStageStep--;
    currentStageStep = max(currentStageStep, 0);
    stageContent.stop();
    stageContent.setSource(currentStageStep);
    stageContent.play();
    println("stage: "+ currentStageStep);
  }
  // Enter TUIO calibration screen
  else if (key == 'c') {
    calibMode = !calibMode;
    if (calibMode)
      cursor();
    else {
      calibrator.save("calibrator.xml");
      noCursor();
    }
  }
  // Scale faces
  else if (key == '+') {
    leftActor.mask.scale += 0.01;
    rightActor.mask.scale += 0.01;
  } 
  else if (key == '-') {
    leftActor.mask.scale -= 0.01;
    rightActor.mask.scale -= 0.01;
  }
}

// mouse insteraction: 

public void mousePressed() {
  if (calibMode) {
    calibrator.mousePressed();
  }
}

public void mouseDragged() {  
  if (calibMode) {
    calibrator.mouseDragged();
  }
}

public void mouseReleased() {
  if (calibMode) {
    calibrator.mouseReleased();
  }
}

