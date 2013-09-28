public class CalibPoint {
  public float x;  // x screen coordinate 
  public float y;  // y screen coordinate
  public float u;  // x camera coordinate
  public float v;  // y camera coordinate

  CalibPoint(float x, float y, float u, float v) {
    this.x = x;
    this.y = y;
    this.u = u;
    this.v = v;
  }

  CalibPoint interpolateTo(CalibPoint p, float f) {
    float nX = this.x + (p.x - this.x) * f;
    float nY = this.y + (p.y - this.y) * f;
    float nU = this.u + (p.u - this.u) * f;
    float nV = this.v + (p.v - this.v) * f;
    return new CalibPoint(nX, nY, nU, nV);
  }

  void interpolateBetween(CalibPoint start, CalibPoint end, float f) {
    this.x = start.x + (end.x - start.x) * f;
    this.y = start.y + (end.y - start.y) * f;
    this.u = start.u + (end.u - start.u) * f;
    this.v = start.v + (end.v - start.v) * f;
  }
}

