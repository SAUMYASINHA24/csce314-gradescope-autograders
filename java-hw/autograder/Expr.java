/**
 * Provided to students (they do not submit this file).
 * An arithmetic expression that can evaluate itself.
 */
public interface Expr {
    /**
     * Evaluate this expression. Uses Java's long arithmetic, so division
     * rounds toward zero. Throws ArithmeticException on division by zero.
     */
    long eval();
}
