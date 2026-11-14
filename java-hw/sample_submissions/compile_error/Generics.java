import java.util.List;

/** Reference solution. */
public final class Generics {
    private Generics() {}

    public static <A, B> Pair<B, A> swap(Pair<A, B> p) {
        return new Pair<>(p.second(), p.first());
    }

    public static <T extends Comparable<? super T>> T max(List<? extends T> items) {
        if (items == null || items.isEmpty()) throw new IllegalArgumentException("empty list");
        T best = items.get(0);
        for (T x : items) if (x.compareTo(best) > 0) best = x;
        return best;
    }
}
