/* 
 Content class 
 A simple interface for loading and getting images from video, sequences or image files 
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

class Content
{
  int VIDEO_SOURCE = 0;
  int IMAGE_SOURCE = 1;
  int IMAGE_SEQUENCE_SOURCE = 2;
  int LIVE_VIDEO_SOURCE = 3;

  ArrayList sources;
  int type = -1;
  int index;
  float seqFrameIndex;
  float seqFrameInc;
  GLTexture currentFrame;
  GLGraphicsOffScreen resizer;

  Boolean playing = true;
  Boolean paused = false;

PImage img = null;

  PApplet parent;

  Content(PApplet parent)
  {
    this.parent = parent;
    index = 0;
    seqFrameIndex = 0.0;
    seqFrameInc = 1.0;
    sources = new ArrayList();
    currentFrame = new GLTexture(parent, width, height); 
    resizer      = new GLGraphicsOffScreen(parent, width, height);
  }

  int numOfSources()
  {
    return sources.size();
  }

  void addSeveralSources(String path)
  {
    String extendedPath = sketchPath + "/data/" + path;
    File file = new File(extendedPath);
    if (file.isDirectory()) {
      String fotogramas[] = file.list();
      for (int i = 0; i < fotogramas.length; i++)
      {
        addSource(path + "/"+ fotogramas[i]);
      }
    }
  }
  /*
  void setSourceImage(String path) {
   if(index < sources.size())
   {
   if(sources.get(index) implements MImage) {
   MImage img = (MImage)sources.get(index);
   img.loadTexture(file);
   }
   else {
   println("Content ERROR: setSourceImage : source is not a image");
   } 
   }
   else {
   println("Content ERROR: setSourceImage : index is out of bounds"); 
   }
   
   }
   */

  Boolean addSource(String path)
  {
    if (path == null)
    {
      sources.add(null);
    }
    else if (path.indexOf(".png") > 0 || path.indexOf(".jpg") > 0 || path.indexOf(".jpeg") > 0)
    { 
      MImage newImage = new MImage(parent, path);
      sources.add(newImage);
      println(this + " image " + path + " loaded");
    }
    else if ( (path.indexOf(".mov") > 0) || (path.indexOf(".mp4") > 0) || (path.indexOf(".avi") > 0) || (path.indexOf(".ogg") > 0) )
    {
      GSMovie movie = new GSMovie(parent, path);
      movie.noLoop();
      movie.stop();
      //movie.pause();
      sources.add(movie);
      println(this + " video " + path + " loaded");
    }
    else 
    {
      String extendedPath = sketchPath + "/data/" + path;
      File file = new File(extendedPath);
      if (file.isDirectory()) {
        // Solo pngs!!
        FilenameFilter pngfilter = new FilenameFilter() {
          public boolean accept(File dir, String name) {
            return (name.endsWith(".png") || name.endsWith(".jpg")|| name.endsWith(".jpeg"));
          }
        };
        String fotogramas[] = file.list(pngfilter);
        MImage[] sequence = new MImage[fotogramas.length];
        for (int i = 0; i < fotogramas.length; i++)
        {
          sequence[i] = new MImage(parent, path + "/"+ fotogramas[i]);
        }
        sources.add(sequence);
        println(this + " sequence " + path + " loaded");
      } 
      else {
        println(this + " " + path + "no es un directorio de imagenes!");
      }
    }
    return false;
  }

  void setSource(int index)
  {
    img = null;
    if (sources.size() > 0)
    {

      if ( sources.get(this.index) instanceof GSMovie)
      {
        type = VIDEO_SOURCE;
        GSMovie movie = (GSMovie) sources.get(this.index);
        movie.stop();
      }

      if (index >= sources.size())
      {
        this.index = sources.size() - 1;
      }
      else if (index < 0)
      {
        index = 0;
      }
      else
      {
        this.index = index;
      }

      if ( sources.get(this.index) instanceof GSMovie)
      {
        type = VIDEO_SOURCE;
        GSMovie movie = (GSMovie) sources.get(this.index);
        movie.loop();
        movie.play();
        playing = true;
        paused = false;
      }
      else if ( sources.get(this.index) instanceof MImage)
      {
        type = IMAGE_SOURCE;
      }
      else if ( sources.get(this.index) instanceof MImage[])
      {
        type = IMAGE_SEQUENCE_SOURCE;
      }
      else 
        type = -1;
    }
  }

  void clearSources()
  {
    ;
  }

  void play()
  {
    playing = true;
    paused = false;
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.play();
    }
  }

  void stop()
  {
    playing = false;
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.stop();
    }
    else if (type == IMAGE_SEQUENCE_SOURCE)
    {
      seqFrameIndex = 0;
    }
  }

  void pause()
  {
    paused = true;
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.pause();
    }
  }

  void speed(float rate)
  {
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.speed(rate);
    }
    seqFrameInc = rate;
  }

  void jump(int frame)
  {
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.jump(frame);
    }
    seqFrameIndex = frame;
  }

  void jumpFrames(int frames)
  {
    if (type == VIDEO_SOURCE)
    {
      GSMovie video = (GSMovie) sources.get(index);
      video.jump(video.frame()+frames);
    }
    seqFrameIndex += frames;
  }


  public GLTexture getFrame() {
    if (!playing) {
      return null;
    } 
    else {
      if (type == VIDEO_SOURCE) {
        GSMovie video = (GSMovie) sources.get(index);
        if (img == null) {
          img = video.get();
        }
        // img.init(video.width, video.height, PApplet.RGB);
        img.copy(video, 0, 0, video.width, video.height, 0, 0, 
        (int) video.width, 
        (int) video.height);
        currentFrame.putImage(img);
      } 
      else if (type == IMAGE_SOURCE) {
        MImage img = (MImage) sources.get(index);
        currentFrame.putImage(img);
      } 
      else if (type == IMAGE_SEQUENCE_SOURCE) {
        MImage[] imgSeq = (MImage[]) sources.get(index);
        if (seqFrameIndex >= imgSeq.length) {
          int factor = PApplet.parseInt(seqFrameIndex)
            / imgSeq.length;
          seqFrameIndex -= factor * imgSeq.length;
        }
        int roundIndex = PApplet.parseInt(seqFrameIndex);
        MImage currentImage = imgSeq[roundIndex];
        currentFrame.putImage(currentImage);
        if (!paused) {
          seqFrameIndex += seqFrameInc;
        }
      }

      return currentFrame;
    }
  }

  public GLTexture getFrame(int x, int y, int w, int h) {
    if (!playing) {
      return null;
    } 
    else {
      if (type == VIDEO_SOURCE) {
        GSMovie video = (GSMovie) sources.get(index);
        if (img == null) {
          //img = video.get();
          img = createImage(w, h, RGB);
        }
        // img.init(video.width, video.height, PApplet.RGB);

        //img.copy(video, 0, 0, video.width, video.height, 35, 2,
        //		(int) (video.width * 1.3f),
        //		(int) (video.height * 1.3f));

        img.copy(video, x, y, w, h, 0, 0, w, h);

        currentFrame.putImage(img);
      } 
      else if (type == IMAGE_SOURCE) {
        MImage img = (MImage) sources.get(index);
        currentFrame.putImage(img);
      } 
      else if (type == IMAGE_SEQUENCE_SOURCE) {
        MImage[] imgSeq = (MImage[]) sources.get(index);
        if (seqFrameIndex >= imgSeq.length) {
          int factor = PApplet.parseInt(seqFrameIndex)
            / imgSeq.length;
          seqFrameIndex -= factor * imgSeq.length;
        }
        int roundIndex = PApplet.parseInt(seqFrameIndex);
        MImage currentImage = imgSeq[roundIndex];
        currentFrame.putImage(currentImage);
        if (!paused) {
          seqFrameIndex += seqFrameInc;
        }
      }

      return currentFrame;
    }
  }




  /*
  GLTexture getFrame()
   {
   if (!playing)
   {
   return null;
   }
   else
   {
   if (type == VIDEO_SOURCE)
   {
   GSMovie video = (GSMovie) sources.get(index);
   currentFrame.putImage(video);
   }
   else if (type == IMAGE_SOURCE)
   {
   MImage img = (MImage) sources.get(index);
   currentFrame.putImage(img);
   }
   else if (type == IMAGE_SEQUENCE_SOURCE)
   {
   MImage[] imgSeq = (MImage[]) sources.get(index);
   if (seqFrameIndex >= imgSeq.length)
   {
   int factor = int(seqFrameIndex)/imgSeq.length;
   seqFrameIndex -= factor * imgSeq.length;
   }
   int roundIndex = int(seqFrameIndex);
   MImage currentImage = imgSeq[roundIndex];
   currentFrame.putImage(currentImage);
   if (!paused)
   {
   seqFrameIndex += seqFrameInc;
   }
   }
   
   return currentFrame;
   }
   }*/
}

