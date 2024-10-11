public class Flock {
    Grid swarm;
    int padding = 50, nBoids = 0;
    float fSize;
    ArrayList<Wall> walls;
    public Flock (int numBoids, float fieldSize, ArrayList<Wall> walls) {
        float realFieldSize = fieldSize + 2*padding;
        this.swarm = new Grid(realFieldSize, Boid.familyRange - 70);
        this.walls = walls;
        this.nBoids = numBoids;
        this.fSize = realFieldSize;
        for (int i = 0; i < nBoids; i++) {
            BoidType bt = getRandomBoidType();
            swarm.boids.add(new Boid(
                width/2,
                height/2,
                random(-1, 1),
                random(-1, 1),
                bt,
                i));
            SM.boidTypeCounts.put(bt, SM.boidTypeCounts.get(bt) == null ? 1 : SM.boidTypeCounts.get(bt) + 1);
        }
        swarm.refreshCells();
    }

    public void update() {
        if (SM.showGrid) swarm.drawGrid();
        for (Boid b : swarm.boids) {
            ArrayDeque<Boid> closeBoids = swarm.getNearCells((int)b.pos.x, (int)b.pos.y, (float)b.info.familyRange);
            b.process(closeBoids, walls);
        }
        swarm.refreshCells();
    }
    
    public void update(ArrayList<Wall> nwalls) {
        walls = nwalls;
        update();
    }

    public void reset() {
        swarm.reset();
        SM.reset();
        for (int i = 0; i < nBoids; i++) {
            BoidType bt = getRandomBoidType();
            swarm.boids.add(new Boid(
                width/2,
                height/2,
                random(-1, 1),
                random(-1, 1),
                bt,
                i));
            SM.boidTypeCounts.put(bt, SM.boidTypeCounts.get(bt) == null ? 1 : SM.boidTypeCounts.get(bt) + 1);
        }
        swarm.refreshCells();
    }

    BoidType getRandomBoidType() {
        float chance = random(0, 30);
        if (chance < 8) return BoidType.PLANKTON; // 0 - 7.999 (26%)
        else if (chance < 16) return BoidType.FISH_1; // 8 - 15.999 (26%)
        else if (chance < 23) return BoidType.FISH_2; // 16 - 22.999 (23%)
        else if (chance < 29.5) return BoidType.FISH_3; // 23 - 29.499 (22%)
        else if (chance < 29.8) return BoidType.PRED_1; // 29.5 - 29.799 (1%)
        return BoidType.PRED_2; // 29.8 - 29.999 (< 1%)
    }
}
