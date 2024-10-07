/* 
DONE: combine cohesion(), separation(), and alignment() to avoid looping over boids multiple times
DONE: implement boids using Ray class
DONE: prevent boids stuck at corners from moving into corners
DONE: use normal of colliding wall to further determine angle sign
*: Increasing the viewCone value causes an immediate snap away from the boid's direction, because if an earlier point in the clockwise list is found to be valid (e.g., (0, 1)), it will immediately take that point. Instead, the can must be traversed at increasing angles from the direction. In order for this to work, the list must be replaced with an immediate raycast from the position.
*: It is possible to instead find the closest angle in the list of rays and expand from that eightfold, but that seems needlessly complex.
DONE: replace Ray list with a single Ray that performs the list-like collision check upon collision detection.
TODO: Fix boids moving towards origin
*/

import java.util.Set;
import java.util.stream.*;
import java.util.HashSet;

public enum BoidType {
    PRED_1,
    PRED_2,
    FISH_1,
    FISH_2,
    FISH_3,
    PLANKTON;
};

public class Boid {
    static final int familyRange = 100; /* the distance the boid will check for other boids */
    static final int MAX_SPEED = 200; /* the maximum speed of the boid */
    static final int MAX_CHASE_SPEED = 800; /* the maximum speed of the boid */
    final float originalViewCone = 180; /* view angle */

    PVector pos; /* position */
    PVector velocity; /* current velocity of boid */
    PVector dir; /* current direction of boid; always equal to normalised velocity */
    PVector lastVelocity; /* last velocity of boid, before movement transformations */
    PVector home; /* location of safe area */
    boolean updateHistory = true; /* update the history of this boid? (for drawing trails) */
    boolean isCaught = false; /* was this boid caught by a predator? :( */
    boolean inPursuit = false;
    float viewCone = originalViewCone; /* view angle */
    float speed = MAX_SPEED; /* current speed of the boid */
    float acceleration; /* coming soon */
    ArrayList<ArrayList<PVector>> history;
    int ID; /* ID of boid [can be replaced by with glInstance_ID in GLSL] */
  
    BoidInfo info;

    // public Boid(float x, float y, float dx, float dy, boolean isPrey, color c, int id) {
    //     pos = new PVector(x, y);
    //     velocity = new PVector(dx, dy);
    //     dir = velocity.copy().normalize();
    //     lastVelocity = velocity;
    //     velocity.normalize();
    //     history = new ArrayList<>();
    //     boidCol = c;
    //     prey = isPrey;
    //     ID = id;
    // }
    
    public Boid(float x, float y, float dx, float dy, BoidType t, int id) {
        pos = new PVector(x, y);
        velocity = new PVector(dx, dy);
        dir = velocity.copy().normalize();
        lastVelocity = velocity;
        velocity.normalize();
        history = new ArrayList<>();
        info = new BoidInfo(t);
        ID = id;
    }
    
    void process(ArrayDeque<Boid> boids, ArrayList<Wall> walls) {
        dir = velocity.copy().normalize();
        move(boids);
        avoidCollisions(walls);
        limitSpeed();
        updateBoid();
        drawBoid();
    }
    
    public void avoidCollisions(ArrayList<Wall> walls) {
        boolean obstructed = false;
        Ray r = raycast();
        if (SM.showRays) r.show(#000000);
        for (Wall w : walls) {
            obstructed = obstructed || r.isCollidingWall(w, info.rayExtent);
        }
        if (obstructed) {
            float angle = atan2(lastVelocity.y, lastVelocity.x);
            for (int ang = 0; ang < viewCone; ang += 4) {
                Ray dpos = raycast(PVector.fromAngle(angle + radians(ang)));
                Ray dneg = raycast(PVector.fromAngle(angle - radians(ang)));
                boolean posObs = false, negObs = false;
                for (Wall w : walls) {
                    posObs = posObs || dpos.isCollidingWall(w, info.rayExtent);
                    negObs = negObs || dneg.isCollidingWall(w, info.rayExtent);
                }
                if (!posObs && negObs) {
                    // positive direction free, negative blocked
                    velocity = dpos.dir;
                    if (SM.showRays) dpos.show(#aaff88);
                    return;
                } else if (posObs && !negObs) {
                    // negative direction free, positive blocked
                    velocity = dneg.dir;
                    if (SM.showRays) dneg.show(#aaff88);
                    return;
                } else if (!posObs && !negObs) {
                    // negative and positive direction free, pick random
                    velocity = random(1) < 0.5 ? dpos.dir : dneg.dir;
                    if (SM.showRays) dpos.show(#aaff88);
                    if (SM.showRays) dneg.show(#aaff88);
                    return;
                } else {
                    // negative and positive direction blocked
                    if (SM.showRays) dpos.show(#ffaa88);
                    if (SM.showRays) dneg.show(#ffaa88);
                    continue;
                }
            }
            // if here, all paths are blocked, so halve speed and ray distance and try again
            info.rayExtent = constrain(info.rayExtent/2, 0, info.originalRayExtent);
            speed /= 2;
            // viewCone += 45;
        } else {
            info.rayExtent = info.originalRayExtent;
            speed = MAX_SPEED;
            // viewCone = originalViewCone;
        }
    }
    
    // Move the boid according to the rules of boids
    void move(ArrayDeque<Boid> boids) {
        int numNeighbors = boids.size() - 1;

        // alignment variables
        float avgXVel = 0;
        float avgYVel = 0;

        // separation variables
        float moveX = 0;
        float moveY = 0;
        
        // cohesion variables
        int centerX = 0;
        int centerY = 0;

        for (Boid otherBoid : boids) {
            if (otherBoid.ID != this.ID) {
                // alignment
                avgXVel += otherBoid.velocity.x;
                avgYVel += otherBoid.velocity.y;

                // cohesion
                centerX += otherBoid.pos.x;
                centerY += otherBoid.pos.y;

                // separation
                float distFromBoid = bdist(otherBoid);
                // if (prey == otherBoid.prey) {
                if (isFamily(otherBoid)) {
                    // stay within group of same boid type
                    if (distFromBoid < info.minSepDistance) {
                        moveX += pos.x - otherBoid.pos.x;
                        moveY += pos.y - otherBoid.pos.y;
                    }
                } else {
                    // different boid types
                    inPursuit = distFromBoid <= info.minEnemyChaseDistance;
                    if (isPreyTo(otherBoid)) {
                        if (distFromBoid <= info.eatDistance && frameCount > 100 /* grace period */) {
                            isCaught = true;
                            SM.boidTypeCounts.put(info.type, SM.boidTypeCounts.get(info.type) - 1);
                            println(info.name + " CAUGHT BY " + otherBoid.info.name);
                            info.boidCol = color(0,0,0,0);
                        } else if (distFromBoid <= info.minEnemyInterceptDistance) {
                            // run away from predator
                            moveX += (pos.x - otherBoid.pos.x) * info.fearFactor;
                            moveY += (pos.y - otherBoid.pos.y) * info.fearFactor;
                        }
                    } else if (isPredatorTo(otherBoid)) {
                        if (inPursuit) {
                            // move towards goal
                            moveX -= (pos.x - otherBoid.pos.x) * info.goalWeight;
                            moveY -= (pos.y - otherBoid.pos.y) * info.goalWeight;
                        } else if (distFromBoid <= info.minEnemyInterceptDistance) {
                            // intercept goal
                            // doing it like this means predators are drawn towards larger groups more than single prey
                            moveX -= (pos.x - (otherBoid.pos.x + otherBoid.dir.x * otherBoid.speed)) * info.goalWeight;
                            moveY -= (pos.y - (otherBoid.pos.y + otherBoid.dir.y * otherBoid.speed)) * info.goalWeight;
                        }
                    }
                }
            }
        }
        
        if (numNeighbors != 0) {
            // alignment
            avgXVel = avgXVel / numNeighbors;
            avgYVel = avgYVel / numNeighbors;
            
            velocity.x += (avgXVel - velocity.x) * info.matchingFactor;
            velocity.y += (avgYVel - velocity.y) * info.matchingFactor;
            
            // cohesion
            centerX = centerX / numNeighbors;
            centerY = centerY / numNeighbors;
            
            velocity.x += (centerX - pos.x) * info.centeringFactor;
            velocity.y += (centerY - pos.y) * info.centeringFactor;
            
            // separation
            velocity.x += moveX * info.avoidFactor;
            velocity.y += moveY * info.avoidFactor;
        }
    }

    void limitSpeed() {
        float tspeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        float mSpeed = inPursuit ? MAX_SPEED : MAX_CHASE_SPEED;
        if (tspeed > mSpeed) {
            velocity.x = (velocity.x / tspeed) * mSpeed;
            velocity.y = (velocity.y / tspeed) * mSpeed;
        }
    }
    
    void drawBoid() {
        float angle = atan2(velocity.y, velocity.x);
        pushMatrix();
        stroke(0);
        translate(pos.x, pos.y);
        rotate(angle);
        translate(-pos.x, -pos.y);
        fill(info.boidCol);
        triangle(pos.x - 15, pos.y + 5, pos.x - 15, pos.y - 5, pos.x, pos.y);
        popMatrix();
    }
    
    // Update the position based on the current velocity
    void updateBoid() {
        velocity.normalize();
        pos.add(velocity.mult(SM.delta).mult(speed));
        lastVelocity = velocity;
        if (updateHistory) {
            ArrayList<PVector> newHist = new ArrayList<>();
            newHist.add(pos);
            history.add(newHist);
            int historyStart = history.size() > 50 ? history.size() - 50 : 0;
            history = new ArrayList<>(sublist(historyStart, history.size(), history));
        }
    }

    Ray raycast() {
        return new Ray(pos, velocity, info.rayExtent);
    }
    
    Ray raycast(PVector d) {
        return new Ray(pos, d, info.rayExtent);
    }

    boolean isPreyTo(Boid otherBoid) {
        return info.predators.contains(otherBoid.info.type);
    }
    
    boolean isPredatorTo(Boid otherBoid) {
        return info.prey.contains(otherBoid.info.type);
    }

    boolean isFamily(Boid otherBoid) {
        return info.type == otherBoid.info.type;
    }

    boolean isNeutral(Boid otherBoid) {
        return isFamily(otherBoid) || (!isPredatorTo(otherBoid) && !isPreyTo(otherBoid));
    }

    ArrayList<ArrayList<PVector>> sublist(int low, int high, ArrayList<ArrayList<PVector>> vals) {
        ArrayList<ArrayList<PVector>> copy = new ArrayList<>();
        for (int i = low; i < high; i++) {
            copy.add(vals.get(i));
        }
        return copy;
    }
    
    Float bdist(Boid b) {
        return pos.dist(b.pos);
    }
}

class BoidInfo {
    // alignment variables
    float matchingFactor = 0.01; // Adjust by this % of average velocity

    // separation variables
    float minSepDistance = 20; // The distance to stay away from other boids
    float eatDistance = 5; // The max distance from predators need to be from prey in order to eat them
    float minEnemyChaseDistance = 10; // The distance to stay away from enemies, or for predators to chase prey
    float minEnemyInterceptDistance = 150; // The distance to stay away from enemies
    float avoidFactor = 0.05; // Adjust velocity by this %
    float goalWeight = 0.05; // How strongly to chase predators
    float fearFactor = 1; // How far away to run from predators
    HashMap<BoidType, Float> fearFactorMapping;

    // cohesion variables
    float centeringFactor = 0.01; // adjust velocity by this %

    int familyRange = 100; /* the distance the boid will check for other boids */
    int MAX_SPEED = 200; /* the maximum speed of the boid */
    int MAX_CHASE_SPEED = 800; /* the maximum speed of the boid */
    float originalViewCone = 180; /* view angle */
    float originalRayExtent = 50; /* distance to check collisions */

    color boidCol; /* colour of the boid */
    float viewCone = originalViewCone; /* view angle */
    float speed = MAX_SPEED; /* current speed of the boid */
    float acceleration; /* coming soon */
    float rayExtent; /* distance to check collisions */

    // ?: Maybe instead of mapping sets of what is considered prey and predator, use maps for determining fear factor?
    HashSet<BoidType> prey; /* prey for this boid */
    HashSet<BoidType> predators; /* predators for this boid */

    BoidType type;
    String name;

    public BoidInfo(BoidType bt) {
        type = bt;
        setupBoidInfo();
        rayExtent = originalRayExtent;
    }

    void setupBoidInfo() {
        // define above traits for each boid
        switch (type) {
            case PRED_1 :
                name = "Shark 1";
                minSepDistance = 20;
                prey = initSet(
                    BoidType.FISH_1, BoidType.FISH_2, BoidType.FISH_3, BoidType.PLANKTON);
                predators = new HashSet<>();
                boidCol = color(#f54c14);
            break;	
            case PRED_2 :
                name = "Shark 2";
                minSepDistance = 30;
                minEnemyChaseDistance = 150;
                prey = initSet(
                    BoidType.FISH_1, BoidType.FISH_2, BoidType.FISH_3, BoidType.PLANKTON);
                predators = new HashSet<>();
                boidCol = color(#f54cc4);
                
            break;	
            case FISH_1 :
                name = "Fish 1";
                prey = initSet(
                    BoidType.PLANKTON
                );
                predators = initSet(
                    BoidType.PRED_1, BoidType.PRED_2
                );
                boidCol = color(#558cd4);
                
            break;	
            case FISH_2 :
                name = "Fish 2";
                prey = initSet(
                    BoidType.PLANKTON
                );
                predators = initSet(
                    BoidType.PRED_1, BoidType.PRED_2
                );
                boidCol = color(#558ce4);
                
            break;	
            case FISH_3 :
                name = "Fish 3";
                prey = initSet(
                    BoidType.PLANKTON
                );
                predators = initSet(
                    BoidType.PRED_1, BoidType.PRED_2, BoidType.FISH_2 /* scared of fish 2 */
                );
                boidCol = color(#558cf4);
                
            break;	
            case PLANKTON :
                fearFactor = 3;
                familyRange = 50;
                name = "Plankton";
                prey = new HashSet<>();
                predators = initSet(
                    BoidType.PRED_1, BoidType.PRED_2, BoidType.FISH_1, BoidType.FISH_2, BoidType.FISH_3
                );
                boidCol = color(#ffffff);
                
            break;	
            default :
                println("INVALID BOID TYPE");
            break;	
        }
    }

    // java has variable arguments now. woohoo
    HashSet<BoidType> initSet(BoidType... bs) { 
        HashSet<BoidType> set = new HashSet<BoidType>();
        for (BoidType b : bs) {
            set.add(b);
        }
        return set;
    }
}