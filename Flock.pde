public class Flock {
    Grid swarm;
    int padding = 50, nBoids = 0;
    float fSize;
    ArrayList<Wall> walls;
    public Flock (int numBoids, float fieldSize, ArrayList<Wall> walls) {
        float realFieldSize = fieldSize + 2*padding;
        this.swarm = new Grid(realFieldSize, Boid.familyRange - 20);
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
        // swarm.drawGrid();
        for (Boid b : swarm.boids) {
            ArrayDeque<Boid> closeBoids = swarm.getNearCells((int)b.pos.x, (int)b.pos.y, (float)Boid.familyRange);
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
        if (chance < 4) return BoidType.PLANKTON; // 0 - 3.999 (13%)
        else if (chance < 13) return BoidType.FISH_1; // 4 - 12.999 (27%)
        else if (chance < 20) return BoidType.FISH_2; // 13 - 19.999 (23%)
        else if (chance < 29.5) return BoidType.FISH_3; // 20 - 29.499 (32%)
        else if (chance < 29.8) return BoidType.PRED_1; // 29.5 - 29.799 (1%)
        return BoidType.PRED_2; // 29.8 - 29.999 (< 1%)
        
        // also todo: https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github
    }
}
