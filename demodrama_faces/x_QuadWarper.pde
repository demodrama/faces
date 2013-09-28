import javax.media.jai.PerspectiveTransform;
import javax.media.jai.WarpPerspective;

public class QuadWarper {

  WarpPerspective warpPerspective = null;

  static final int TL = 0; // Top left index
  static final int TR = 1; // Top right index
  static final int DR = 2; // Down right index
  static final int DL = 3; // Down left index

  CalibPoint[] points; 


  public QuadWarper(float xSrcTL, float ySrcTL, float xSrcTR, float ySrcTR, float xSrcDR, float ySrcDR, float xSrcDL, float ySrcDL, 
  float xDestTL, float yDestTL, float xDestTR, float yDestTR, float xDestDR, float yDestDR, float xDestDL, float yDestDL) {			
    points = new CalibPoint[4];
    points[TL] = new CalibPoint(xDestTL, yDestTL, xSrcTL, ySrcTL);
    points[TR] = new CalibPoint(xDestTR, yDestTR, xSrcTR, ySrcTR);
    points[DR] = new CalibPoint(xDestDR, yDestDR, xSrcDR, ySrcDR);
    points[DL] = new CalibPoint(xDestDL, yDestDL, xSrcDL, ySrcDL);
    calculateMesh();
  }

  public void calculateMesh() {

    // Calculate 4 point warping from source and destination quads
    PerspectiveTransform transform = PerspectiveTransform.getQuadToQuad(
    points[TL].u, points[TL].v, // source to
    points[TR].u, points[TR].v, 
    points[DR].u, points[DR].v, 
    points[DL].u, points[DL].v, 
    points[TL].x, points[TL].y, 
    points[TR].x, points[TR].y, 
    points[DR].x, points[DR].y, 
    points[DL].x, points[DL].y); // dest
    warpPerspective = new WarpPerspective(transform);
  }

  // Calculate destination (screen) coordinates from generic source (camera) point
  public PVector getTransformedCursor(int cx, int cy) {
    Point2D point = warpPerspective.mapSourcePoint(new Point(cx, cy));
    return new PVector((int) point.getX(), (int) point.getY());
  }

  // Calculate source (camera) coordinates from screen coordinates
  public PVector getInvTransformedCursor(int cx, int cy) {
    Point2D p = warpPerspective.mapDestPoint(new Point((int) cx, cy));
    p.setLocation(p.getX(), p.getY());
    return new PVector((int) p.getX(), (int) p.getY());
  }

  public void setPoints(CalibPoint[] points) {
    this.points = points;
  }

  public CalibPoint[] getPoints() {
    return points;
  }
}

