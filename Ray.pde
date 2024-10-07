/* 
https://www.youtube.com/watch?v=TOEi6T2mtHo
*/

public class Ray {
    PVector pos, dir;
    float extent;
    boolean isColliding;
    public RayCollisionData data;

    public Ray() {}
    public Ray(PVector p, PVector d, float e) {
        lookAt(p, d);
        extent = e;
    }
    public Ray(PVector p, PVector d) {
        lookAt(p, d);
        extent = 1;
    }
    
    public void lookAt(PVector p, PVector d) {
        pos = p;
        lookAt(d);
    }
    
    public void lookAt(PVector d) {
        // if (d.magSq() > 1) {
        //     // normalise direction if unnormalised
        //     dir = PVector.sub(d, pos);
        //     dir.normalize();
        // } else {
        //     dir = d;
        //     dir.normalize();
        // }
        dir = d;
        dir.normalize();
    }
    
    public boolean isCollidingWall(Wall wall) {
        RayCollisionData tdata = null;
        float closestDist = Float.MAX_VALUE;

        for (Boundary b : wall.shape) {
            RayCollisionData ttdata = checkIntersection(b);
            if (ttdata != null) {
                if (ttdata.distance < closestDist) {
                    closestDist = ttdata.distance;
                    tdata = ttdata;
                }
            }
        }

        if (tdata == null) {
            isColliding = false;
        } else {
            data = tdata;
            isColliding = true;
        }
        return isColliding;
    }
    
    public boolean isCollidingWall(Wall wall, float ex) {
        RayCollisionData tdata = null;
        float closestDist = Float.MAX_VALUE;

        for (Boundary b : wall.shape) {
            RayCollisionData ttdata = checkIntersection(b, ex);
            if (ttdata != null) {
                if (ttdata.distance < closestDist) {
                    closestDist = ttdata.distance;
                    tdata = ttdata;
                }
            }
        }

        if (tdata == null) {
            isColliding = false;
        } else {
            data = tdata;
            isColliding = true;
        }
        return isColliding;
    }
    
    public RayCollisionData checkIntersection(Boundary b) {
        float x1 = pos.x, y1 = pos.y, x2 = pos.x + dir.x * extent, y2 = pos.y + dir.y * extent, x3 = b.start.x, y3 = b.start.y, x4 = b.end.x, y4 = b.end.y;
        
        float divisor = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4); // denominator
        if (divisor == 0) {
            // ray and line are parallel
            return null;
        };
        
        float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / divisor;
        float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / divisor;
        boolean isIntersecting = t >= 0 && t <= 1 && u >= 0 && u <= 1;
        if (!isIntersecting) {
            return null;
        }
        
        PVector coll = new PVector(
            x1 + t * (x2 - x1),
            y1 + t * (y2 - y1)
           );
        data = new RayCollisionData(b, t, coll);
        return data;
    }
    
    public RayCollisionData checkIntersection(Boundary b, float ex) {
        float x1 = pos.x, y1 = pos.y, x2 = pos.x + dir.x * ex, y2 = pos.y + dir.y * ex, x3 = b.start.x, y3 = b.start.y, x4 = b.end.x, y4 = b.end.y;
        
        float divisor = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4); // denominator
        if (divisor == 0) {
            // ray and line are parallel
            return null;
        };
        
        float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / divisor;
        float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / divisor;
        boolean isIntersecting = t >= 0 && t <= 1 && u >= 0 && u <= 1;
        if (!isIntersecting) {
            return null;
        }
        
        PVector coll = new PVector(
            x1 + t * (x2 - x1),
            y1 + t * (y2 - y1)
           );
        data = new RayCollisionData(b, t, coll);
        return data;
    }
    
    public void update(PVector np) {
        pos = np;
    }
    
    public void show() {
        line(pos.x, pos.y, pos.x + dir.x * extent, pos.y + dir.y * extent);
    }
    
    public void show(color c) {
        pushMatrix();
        stroke(c);
        line(pos.x, pos.y, pos.x + dir.x * extent, pos.y + dir.y * extent);
        popMatrix();
    }
    
    public void showColliding() {
        if (isColliding) line(pos.x, pos.y, data.collidingPoint.x, data.collidingPoint.y);
    }
}

public class RayCollisionData {
    Boundary boundary;
    float distance;
    PVector collidingPoint;
    RayCollisionData(Boundary boundary, float distance, PVector collidingPoint) {
        this.boundary = boundary;
        this.distance = distance;
        this.collidingPoint = collidingPoint;
    }
    RayCollisionData() {}
}
