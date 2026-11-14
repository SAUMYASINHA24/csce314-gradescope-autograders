// Buggy: evaluates with instanceof checks instead of dynamic dispatch,
// Sub has its operands swapped, and division by zero returns 0.

final class Num implements Expr {
    final long value;
    Num(long value) { this.value = value; }
    public long eval() { return Evaluator.run(this); }
}

final class Add implements Expr {
    final Expr left, right;
    Add(Expr left, Expr right) { this.left = left; this.right = right; }
    public long eval() { return Evaluator.run(this); }
}

final class Sub implements Expr {
    final Expr left, right;
    Sub(Expr left, Expr right) { this.left = left; this.right = right; }
    public long eval() { return Evaluator.run(this); }
}

final class Mul implements Expr {
    final Expr left, right;
    Mul(Expr left, Expr right) { this.left = left; this.right = right; }
    public long eval() { return Evaluator.run(this); }
}

final class Div implements Expr {
    final Expr left, right;
    Div(Expr left, Expr right) { this.left = left; this.right = right; }
    public long eval() { return Evaluator.run(this); }
}

final class Evaluator {
    static long run(Expr e) {
        if (e instanceof Num n) return n.value;
        if (e instanceof Add a) return a.left.eval() + a.right.eval();
        if (e instanceof Sub s) return s.right.eval() - s.left.eval();
        if (e instanceof Mul m) return m.left.eval() * m.right.eval();
        Div d = (Div) e;
        long r = d.right.eval();
        return r == 0 ? 0 : d.left.eval() / r;
    }
}
