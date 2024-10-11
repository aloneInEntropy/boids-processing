// Scene Manager class

public static class SM {
    public static HashMap<BoidType, Integer> boidTypeCounts = new HashMap<>();
    public static float delta = 1/60;
    public static boolean showRays = false; // show raycasts for each boid
    public static boolean canAttack = false; // can boids attack prey (and prey run away)?
    public static boolean showGrid = false; // show grid partition
    public static boolean showDebug = true; // show debug menu
    public static boolean showBoids = true; // show boids

    private static long lastTime = System.nanoTime();
    public SM () {boidTypeCounts = new HashMap<>(); }

    public static void updateDelta() {
        long currTime = System.nanoTime();
        delta = (currTime - lastTime) / 1e9;
        lastTime = currTime;
    }
    
    public static void reset() {
        boidTypeCounts = new HashMap<>();
    }

    public static void countBoidTypes(Flock flock) {
        reset();
        for (Boid b : flock.swarm.boids) {
            boidTypeCounts.put(b.info.type, boidTypeCounts.containsKey(b.info.type) ? boidTypeCounts.get(b.info.type) + 1 : 1);
        }
    }

    public static float wrap(float x, float lo, float hi) {
        if (x < lo) x = hi - abs(x);
        if (x > hi) x = hi - x;
        return x;
    }

    public static int sign(float a) {
        if (a > 0) return 1;
        else if (a < 0) return -1;
        return 0;
    }
}
