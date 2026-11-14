import java.util.List;

// Buggy: max ignores the last element and crashes on empty lists.
public final class Generics {
    private Generics() {}

    public static <A, B> Pair<B, A> swap(Pair<A, B> p) {
        return new Pair<>(p.second(), p.first());
    }

    public static <T extends Comparable<? super T>> T max(List<? extends T> items) {
        T best = items.get(0);
        for (int i = 0; i < items.size() - 1; i++) {
            if (items.get(i).compareTo(best) > 0) best = items.get(i);
        }
        return best;
    }
}
