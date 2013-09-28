/* 
  Stage class 
  Simple class for drawing images on the background
*/
 
/*
 Copyright (C) 2012 Enrique Esteban, Ignacio Cossio & Yago Torroja @ Faces
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

class Stage
{
  PApplet parent;
  int screenWidth;
  int screenHeight; 
  int x;
  int y;
  
  float scaleFactor = 1;
  
  Stage(PApplet parent, int screenWidth, int screenHeight)
  {
    this.parent = parent;
    this.screenWidth = int(screenWidth * scaleFactor);
    this.screenHeight = int(screenHeight * scaleFactor); 
    x =  (width - this.screenWidth)/2; 
    y = (height - this.screenHeight)/2; 
  }
     
   void draw(GLTexture scenery)
   {
     pushStyle();
     imageMode(CORNER);
     image(scenery, 0, 0, screenWidth, screenHeight);
     popStyle();
   }   
}
