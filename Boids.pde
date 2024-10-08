/* 
Implemented from https://github.com/beneater/boids/blob/master/boids.js
*/

/* 
DONE: use Wall class instead of PVectors to use Boids with Rays
TODO: optimisations 
DONE: 1. combine speed and direction functions in Boid.pde
TODO: 2. use quadtree instead of grid partitioning
TODO: 3. use single points for Wall vertices to half vertices stored and check collisions in clockwise order of points
TODO: 4. use only wall vertices intersecting boid's surrounding cells to check collisions
*/

int numBoids = 3000;

Flock flock;
ArrayList<Boid> boids = new ArrayList<Boid>();
ArrayList<PVector> walls = new ArrayList<>();
ArrayList<Wall> bwalls = new ArrayList<>();

void setup() {
    fullScreen();
    // size(2560, 1600);
    // size(1024, 512);
    // frameRate(60);

    bwalls = new ArrayList<>();
    bwalls.add(new Wall(0, 0, width, height)); // border
    bwalls.add(new Wall(width/2, 0, 20, 80)); // guard
    bwalls.add(new Wall(width/2, height - 80, 20, 80)); // guard
    bwalls.add(new Wall(0, height/2, 80, 20)); // guard
    bwalls.add(new Wall(width - 80, height/2, 80, 20)); // guard
    for (int i = 0; i < 50; i++) {
        Wall wall = new Wall(int(random(1) * width), int(random(1) * height), int(random(1) * 100) + 10, int(random(1) * 100) + 10);
        bwalls.add(wall);
    }
    flock = new Flock(numBoids, width, bwalls);
}

void draw() {
    SM.updateDelta();
    background(150);
    for (int i = 0; i < bwalls.size(); i++) {
        Wall w = bwalls.get(i);
        w.drawShape(i == 0 ? color(255, 0) : #ffffff);
    }
    if (bwalls.size() > 1) {
        bwalls.set(
            bwalls.size() - 1, new Wall(mouseX, mouseY, (int)bwalls.get(bwalls.size() - 1).extents.x, 
            (int)bwalls.get(bwalls.size() - 1).extents.y));
    }
    flock.update(bwalls);
    
    fill(0);
    textSize(20);
    float textXPos = width - 200;
    text(frameRate, textXPos, 50);
    // update text every short while
    if (frameCount % 10 == 0) {
        SM.countBoidTypes(flock);
    }
    for (int i = 0; i < SM.boidTypeCounts.size(); i++) {
        BoidType bt = BoidType.values()[i];
        text(bt.name() + " Count: " + Integer.valueOf(SM.boidTypeCounts.getOrDefault(bt, 0)), textXPos, 100 + (i * 20));
    }
    text("Show Rays: " + (SM.showRays ? "ON" : "OFF"), textXPos, 220);
    text("Frame: " + Integer.valueOf(frameCount), textXPos, 240);
}

void keyPressed() {
    if (key == ' ') {
        flock.reset();
    }
    if (keyCode == TAB) {
        SM.showRays = !SM.showRays;
    }
}