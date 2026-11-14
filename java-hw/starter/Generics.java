import java.util.List;

/** Problem 2 (generic methods and bounded types). */
public final class Generics {

    private Generics() {}

    /** Return a new Pair with the two components swapped. */
    public static <A, B> Pair<B, A> swap(Pair<A, B> p) {
        throw new UnsupportedOperationException("TODO");
    }

    /**
     * Return the largest element of a non-empty list.
     * Throw IllegalArgumentException if the list is null or empty.
     */
    public static <T extends Comparable<? super T>> T max(List<? extends T> items) {
        throw new UnsupportedOperationException("TODO");
    }
}
