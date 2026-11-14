// Buggy: no threads at all, int accumulator overflows, and loops forever
// when nThreads is 0 instead of throwing.
public final class ParallelSum {
    private ParallelSum() {}

    public static long sum(int[] data, int nThreads) throws InterruptedException {
        while (nThreads < 1) { /* oops */ }
        int total = 0;
        for (int x : data) total += x;
        return total;
    }
}
