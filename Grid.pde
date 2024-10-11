/* 
Implemented from https://github.com/mangecoeur/optboid/blob/master/simulation.py
*/

import java.util.Deque;
import java.util.ArrayDeque;
import java.util.HashMap;

public class Grid {
    int cellSize;
    int divisions;
    ArrayDeque<Boid> boids;
    HashMap<PVector, ArrayDeque<Boid>> cells;
    
    public Grid(float _width, float cellWidth) {
        cellSize = (int)cellWidth;
        boids = new ArrayDeque<Boid>();
        divisions = (int)floor(_width / cellWidth);
        cells = new HashMap<PVector, ArrayDeque<Boid>>();
        for (int i = 0; i < divisions; i++) {
            for (int j = 0; j < divisions; j++) {
                cells.put(new PVector(i, j), new ArrayDeque<Boid>());
            }
        }
    }
    
    // Bind cells to edges of screen
    private PVector getCellNum(int i, int j) {
        int x = (int)(floor(i / cellSize));
        int y = (int)(floor(j / cellSize));
        x = constrain(x, 0, divisions - 1);
        y = constrain(y, 0, divisions - 1);
        return new PVector(x, y);
    }
    
    public ArrayDeque<Boid> getCellAt(int x, int y) {
        return cells.get(getCellNum(x, y));
    }
    
    public ArrayDeque<Boid> getNeighbourCells(int x, int y) {
        return cells.get(getCellNum(x, y));
    }
    
    public ArrayDeque<Boid> getNearCells(int x, int y, float influence) {
        ArrayDeque<Boid> nearestGroup;
        if (influence == 0) {
            nearestGroup = getCellAt(x, y);
        } else if (influence <= cellSize) {
            nearestGroup = getNeighbourCells(x, y);
        } else {
            nearestGroup = getFarCells(x, y, ceil(influence / cellSize));
        }
        return nearestGroup;
    }
    
    public ArrayDeque<Boid> getFarCells(int x, int y, float influence) {
        PVector cell = getCellNum(x, y);
        int infl = (int)influence;
        ArrayDeque<Boid> group = new ArrayDeque<Boid>();
        for (int i = (int)cell.x - infl; i < (int)cell.x + infl; i++) {
            for (int j = (int)cell.y - infl; j < (int)cell.y + infl; j++) {
                PVector c = new PVector(i, j);
                if (cells.containsKey(c)) {
                    group.addAll(cells.get(c));
                }
            }
        }
        return group;
    }

    // public void process() {
    //     for (ArrayDeque<Boid> boids : cells.values()) {
    //         for (Boid b : boids) {
                
    //         }
    //     }
    // }
    
    public void refreshCells() {
        for (ArrayDeque<Boid> b : cells.values()) {
            b.clear();
        }
        boids.removeIf(b -> b.isCaught);
        for (Boid b : boids) {
            getCellAt((int)b.pos.x,(int)b.pos.y).add(b);
        }
    }
    
    public void drawGrid() {
        for (PVector p : cells.keySet()) {
            fill(255, 100, 50, 20 * cells.get(new PVector(p.x, p.y)).size());
            rect(p.x * cellSize, p.y * cellSize, cellSize, cellSize);
        }
    }

    float roundToN(float x, int n) {
        return ceil(round(x / n)) * n;
    }

    public void reset() {
        boids.clear();
    }
}
