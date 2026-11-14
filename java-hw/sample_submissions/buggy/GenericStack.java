import java.util.ArrayList;

// Buggy: uses ArrayList (banned), public field, returns null on empty pop.
public class GenericStack<T> {
    public ArrayList<T> items = new ArrayList<>();

    public void push(T item) { items.add(item); }

    public T pop() {
        if (items.isEmpty()) return null;
        return items.remove(items.size() - 1);
    }

    public T peek() { return items.get(items.size() - 1); }

    public boolean isEmpty() { return items.isEmpty(); }

    public int size() { return items.size(); }
}
