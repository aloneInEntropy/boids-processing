// Scene Manager class

public static class SM {
    public static HashMap<BoidType, Integer> boidTypeCounts = new HashMap<>();
    public static float delta = 1/60;
    public static boolean showRays = false;

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
