// Wall class. In the form of a rect.
public class Wall {
    PVector pos, extents;
    ArrayList<Boundary> shape;
    public Wall (int x, int y, int xl, int yl) {
        pos = new PVector(x, y);
        extents = new PVector(xl, yl);
        shape = new ArrayList<>();
        shape.add(new Boundary(new PVector(x, y), new PVector(x+xl, y)));
        shape.add(new Boundary(new PVector(x, y), new PVector(x, y+yl)));
        shape.add(new Boundary(new PVector(x+xl, y), new PVector(x+xl, y+yl)));
        shape.add(new Boundary(new PVector(x, y+yl), new PVector(x+xl, y+yl)));
    }
    public Wall (PVector _position, PVector _size) {
        pos = _position;
        extents = _size;
    }

    public void drawShape(color c) {
        fill(c);
        rect(pos.x, pos.y, extents.x, extents.y);
    }

    public boolean isPointInside(PVector p) {
        return p.x >= pos.x 
            && p.x < pos.x + extents.x
            && p.y >= pos.y
            && p.y < pos.y + extents.y;
    }
}

// Boundary class. In the form of a line segment.
public class Boundary {
    PVector start, end;
    boolean isVertical, isHorizontal, isDiagonal;
    public Boundary(PVector start, PVector end) {
        this.start = start;
        this.end = end;
        isVertical = start.x == end.x;
        isHorizontal = start.y == end.y;
        isDiagonal = !isVertical && !isHorizontal;
    }

    public void show() {
        line(start.x, start.y, end.x, end.y);
    }
}