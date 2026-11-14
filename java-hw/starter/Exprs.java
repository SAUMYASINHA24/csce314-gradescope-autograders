/**
 * Problem 4 (interfaces, overriding, dynamic dispatch).
 *
 * Implement the five expression classes below. Each one implements the
 * provided Expr interface and overrides eval().
 *
 * Rules:
 *  - Do NOT use instanceof, getClass() or a switch on the type anywhere.
 *    Each class evaluates itself; which eval() runs is decided by dynamic
 *    dispatch on the object's runtime class.
 *  - Keep the class names and constructor signatures exactly as given.
 *  - Division by zero must throw ArithmeticException.
 */

final class Num implements Expr {
    Num(long value) {
        // TODO
    }

    @Override
    public long eval() {
        throw new UnsupportedOperationException("TODO");
    }
}

final class Add implements Expr {
    Add(Expr left, Expr right) {
        // TODO
    }

    @Override
    public long eval() {
        throw new UnsupportedOperationException("TODO");
    }
}

final class Sub implements Expr {
    Sub(Expr left, Expr right) {
        // TODO
    }

    @Override
    public long eval() {
        throw new UnsupportedOperationException("TODO");
    }
}

final class Mul implements Expr {
    Mul(Expr left, Expr right) {
        // TODO
    }

    @Override
    public long eval() {
        throw new UnsupportedOperationException("TODO");
    }
}

final class Div implements Expr {
    Div(Expr left, Expr right) {
        // TODO
    }

    @Override
    public long eval() {
        throw new UnsupportedOperationException("TODO");
    }
}
