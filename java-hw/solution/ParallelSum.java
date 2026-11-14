/** Reference solution: one thread per chunk, each writes its own slot. */
public final class ParallelSum {
    private ParallelSum() {}

    public static long sum(int[] data, int nThreads) throws InterruptedException {
        if (nThreads < 1) throw new IllegalArgumentException("nThreads must be >= 1");
        if (data.length == 0) return 0L;
        int n = Math.min(nThreads, data.length);
        long[] partial = new long[n];
        Thread[] workers = new Thread[n];
        int chunk = (data.length + n - 1) / n;
        for (int i = 0; i < n; i++) {
            final int id = i;
            final int from = i * chunk;
            final int to = Math.min(data.length, from + chunk);
            workers[i] = new Thread(() -> {
                long s = 0;
                for (int j = from; j < to; j++) s += data[j];
                partial[id] = s;
            });
            workers[i].start();
        }
        long total = 0;
        for (int i = 0; i < n; i++) {
            workers[i].join(); // join also makes partial[i] visible to this thread
            total += partial[i];
        }
        return total;
    }
}
