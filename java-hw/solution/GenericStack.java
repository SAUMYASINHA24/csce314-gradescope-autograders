import java.util.NoSuchElementException;

/** Reference solution: array-backed generic stack. */
public class GenericStack<T> {
    private Object[] items;
    private int size;

    public GenericStack() {
        items = new Object[8];
    }

    public void push(T item) {
        if (size == items.length) {
            Object[] bigger = new Object[items.length * 2];
            System.arraycopy(items, 0, bigger, 0, size);
            items = bigger;
        }
        items[size++] = item;
    }

    @SuppressWarnings("unchecked")
    public T pop() {
        if (size == 0) throw new NoSuchElementException("stack is empty");
        T top = (T) items[--size];
        items[size] = null; // let the GC reclaim it
        return top;
    }

    @SuppressWarnings("unchecked")
    public T peek() {
        if (size == 0) throw new NoSuchElementException("stack is empty");
        return (T) items[size - 1];
    }

    public boolean isEmpty() { return size == 0; }

    public int size() { return size; }
}
