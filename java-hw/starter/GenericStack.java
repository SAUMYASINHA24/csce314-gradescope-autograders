import java.util.NoSuchElementException;

/**
 * Problem 1 (generics, classes). A generic LIFO stack.
 *
 * Rules:
 *  - Do not use java.util.Stack, Deque or any other collection class.
 *    Store elements in your own array or linked nodes.
 *  - All fields must be private.
 *  - pop() and peek() on an empty stack throw NoSuchElementException.
 */
public class GenericStack<T> {

    public GenericStack() {
        // TODO
    }

    /** Add an element to the top. Null elements are allowed. */
    public void push(T item) {
        throw new UnsupportedOperationException("TODO");
    }

    /** Remove and return the top element. */
    public T pop() {
        throw new UnsupportedOperationException("TODO");
    }

    /** Return the top element without removing it. */
    public T peek() {
        throw new UnsupportedOperationException("TODO");
    }

    public boolean isEmpty() {
        throw new UnsupportedOperationException("TODO");
    }

    public int size() {
        throw new UnsupportedOperationException("TODO");
    }
}
