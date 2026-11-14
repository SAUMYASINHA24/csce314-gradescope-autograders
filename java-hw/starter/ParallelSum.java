/**
 * Problem 3 (concurrency). Sum an array using several threads.
 *
 * Split the array into nThreads roughly equal chunks, sum each chunk in
 * its own Thread, then combine the partial sums. Avoid data races: each
 * thread should write only its own slot of a results array (or use
 * another safe approach).
 *
 * If nThreads is greater than data.length, use at most data.length threads.
 * Throw IllegalArgumentException if nThreads < 1.
 */
public final class ParallelSum {

    private ParallelSum() {}

    public static long sum(int[] data, int nThreads) throws InterruptedException {
        throw new UnsupportedOperationException("TODO");
    }
}
