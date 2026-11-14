// Compile error: missing type parameter and a wrong return type.
public class GenericStack {
    private Object[] items = new Object[8];
    private int size;

    public void push(T item) { items[size++] = item; }
    public T pop() { return items[--size]; }
    public T peek() { return items[size - 1]; }
    public boolean isEmpty() { return size == 0; }
    public int size() { return size; }
}
