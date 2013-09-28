/* 
 Content class 
 Loads the contents for the left mask, right mask and stage 
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

class ContentManager
{
  Content leftFaceContent;
  Content rightFaceContent;
  Content stageContent;  
  Content titleContent;  

  ContentManager(PApplet parent, String rootFolder)
  {
    leftFaceContent = new Content(parent);
    leftFaceContent.addSeveralSources(rootFolder + "/" + DemoConstants.LEFT_FACE_FOLDER);
    leftFaceContent.setSource(0);

    rightFaceContent = new Content(parent);
    rightFaceContent.addSeveralSources(rootFolder + "/" + DemoConstants.RIGHT_FACE_FOLDER);
    rightFaceContent.setSource(0);

    stageContent = new Content(parent);
    stageContent.addSeveralSources(rootFolder + "/" + DemoConstants.STAGE_FOLDER);
    stageContent.setSource(0);

    titleContent = new Content(parent);
    titleContent.addSeveralSources(rootFolder);
    titleContent.setSource(0);
  }

  Content getLeftFaceContent()
  {
    return leftFaceContent;
  }

  Content getRightFaceContent()
  {
    return rightFaceContent;
  }

  Content getStageContent()
  {
    return stageContent;
  }

  Content getTitleContent()
  {
    return titleContent;
  }
}

