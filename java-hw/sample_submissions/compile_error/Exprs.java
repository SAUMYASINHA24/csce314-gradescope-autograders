/** Reference solution for Problem 4: each class evaluates itself. */

final class Num implements Expr {
    private final long value;

    Num(long value) { this.value = value; }

    @Override
    public long eval() { return value; }

    @Override
    public String toString() { return "Num(" + value + ")"; }
}

final class Add implements Expr {
    private final Expr left, right;

    Add(Expr left, Expr right) { this.left = left; this.right = right; }

    @Override
    public long eval() { return left.eval() + right.eval(); }

    @Override
    public String toString() { return "Add(" + left + ", " + right + ")"; }
}

final class Sub implements Expr {
    private final Expr left, right;

    Sub(Expr left, Expr right) { this.left = left; this.right = right; }

    @Override
    public long eval() { return left.eval() - right.eval(); }

    @Override
    public String toString() { return "Sub(" + left + ", " + right + ")"; }
}

final class Mul implements Expr {
    private final Expr left, right;

    Mul(Expr left, Expr right) { this.left = left; this.right = right; }

    @Override
    public long eval() { return left.eval() * right.eval(); }

    @Override
    public String toString() { return "Mul(" + left + ", " + right + ")"; }
}

final class Div implements Expr {
    private final Expr left, right;

    Div(Expr left, Expr right) { this.left = left; this.right = right; }

    @Override
    public long eval() {
        long d = right.eval();
        if (d == 0) throw new ArithmeticException("division by zero");
        return left.eval() / d;
    }

    @Override
    public String toString() { return "Div(" + left + ", " + right + ")"; }
}
