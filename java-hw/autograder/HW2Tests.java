import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Path;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Random;

/** Test cases for HW2 (generics, reflection, concurrency). */
public class HW2Tests {

    // ---------------------------------------------------------------- helpers

    static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    static void checkEquals(Object expected, Object actual, String what) {
        if (expected == null ? actual != null : !expected.equals(actual)) {
            throw new AssertionError(what + ": expected " + expected + " but got " + actual);
        }
    }

    static void checkThrows(Class<? extends Throwable> type, Runnable r, String what) {
        try {
            r.run();
        } catch (Throwable t) {
            if (type.isInstance(t)) return;
            throw new AssertionError(what + ": expected " + type.getSimpleName()
                    + " but got " + t.getClass().getSimpleName());
        }
        throw new AssertionError(what + ": expected " + type.getSimpleName() + " but nothing was thrown");
    }

    // ------------------------------------------------------- P1 GenericStack

    @GradedTest(name = "P1 GenericStack: push/pop is LIFO", points = 2)
    public void stackLifo() {
        GenericStack<String> s = new GenericStack<>();
        s.push("a"); s.push("b"); s.push("c");
        checkEquals("c", s.pop(), "first pop");
        checkEquals("b", s.pop(), "second pop");
        checkEquals("a", s.pop(), "third pop");
        check(s.isEmpty(), "stack should be empty after popping everything");
    }

    @GradedTest(name = "P1 GenericStack: peek, size, isEmpty", points = 1)
    public void stackPeekSize() {
        GenericStack<Integer> s = new GenericStack<>();
        check(s.isEmpty(), "new stack should be empty");
        checkEquals(0, s.size(), "size of new stack");
        s.push(7); s.push(9);
        checkEquals(9, s.peek(), "peek");
        checkEquals(2, s.size(), "peek must not remove the element; size");
    }

    @GradedTest(name = "P1 GenericStack: empty pop/peek throw NoSuchElementException", points = 1)
    public void stackEmptyThrows() {
        GenericStack<Object> s = new GenericStack<>();
        checkThrows(NoSuchElementException.class, s::pop, "pop on empty stack");
        checkThrows(NoSuchElementException.class, s::peek, "peek on empty stack");
    }

    @GradedTest(name = "P1 GenericStack: grows past 10,000 elements and allows null", points = 2,
                visibility = "after_published")
    public void stackLarge() {
        GenericStack<Integer> s = new GenericStack<>();
        for (int i = 0; i < 10_000; i++) s.push(i);
        s.push(null);
        checkEquals(null, s.pop(), "popping a pushed null");
        for (int i = 9_999; i >= 0; i--) checkEquals(i, s.pop(), "pop #" + (10_000 - i));
        check(s.isEmpty(), "stack should be empty");
    }

    @GradedTest(name = "P1 GenericStack: design rules (reflection check)", points = 1)
    public void stackDesign() {
        Class<?> c = GenericStack.class;
        checkEquals(1, c.getTypeParameters().length, "number of type parameters on GenericStack");
        for (Field f : c.getDeclaredFields()) {
            if (f.isSynthetic()) continue;
            check(Modifier.isPrivate(f.getModifiers()), "field '" + f.getName() + "' must be private");
            String type = f.getType().getName();
            check(!type.startsWith("java.util.") || type.equals("java.util.NoSuchElementException"),
                    "field '" + f.getName() + "' uses " + type + "; build the stack yourself");
        }
    }

    // ----------------------------------------------------------- P2 Generics

    @GradedTest(name = "P2 swap: swaps components and keeps types", points = 1)
    public void swapWorks() {
        Pair<String, Integer> p = new Pair<>("x", 1);
        Pair<Integer, String> q = Generics.swap(p);
        checkEquals(new Pair<>(1, "x"), q, "swap((x, 1))");
    }

    @GradedTest(name = "P2 max: integers and strings", points = 1)
    public void maxWorks() {
        checkEquals(9, Generics.max(Arrays.asList(3, 9, -2, 9, 0)), "max of integers");
        checkEquals("pear", Generics.max(List.of("apple", "pear", "fig")), "max of strings");
    }

    @GradedTest(name = "P2 max: empty or null list throws IllegalArgumentException", points = 1)
    public void maxEmpty() {
        checkThrows(IllegalArgumentException.class, () -> Generics.max(Collections.<Integer>emptyList()), "max([])");
        checkThrows(IllegalArgumentException.class, () -> Generics.max(null), "max(null)");
    }

    @GradedTest(name = "P2 max: matches Collections.max on random lists", points = 2,
                visibility = "after_published")
    public void maxRandom() {
        Random r = new Random(314);
        for (int t = 0; t < 200; t++) {
            List<Integer> xs = new ArrayList<>();
            int n = 1 + r.nextInt(50);
            for (int i = 0; i < n; i++) xs.add(r.nextInt(2001) - 1000);
            checkEquals(Collections.max(xs), Generics.max(xs), "max of " + xs);
        }
    }

    // ------------------------------------------------------ P3 ParallelSum

    @GradedTest(name = "P3 ParallelSum: small example", points = 1)
    public void sumSmall() throws Exception {
        checkEquals(15L, ParallelSum.sum(new int[] {1, 2, 3, 4, 5}, 2), "sum([1..5], 2 threads)");
    }

    @GradedTest(name = "P3 ParallelSum: more threads than elements, and empty array", points = 1)
    public void sumEdges() throws Exception {
        checkEquals(6L, ParallelSum.sum(new int[] {1, 2, 3}, 8), "sum([1,2,3], 8 threads)");
        checkEquals(0L, ParallelSum.sum(new int[] {}, 4), "sum([], 4 threads)");
        checkThrows(IllegalArgumentException.class, () -> {
            try { ParallelSum.sum(new int[] {1}, 0); } catch (InterruptedException e) { throw new RuntimeException(e); }
        }, "sum(..., 0 threads)");
    }

    @GradedTest(name = "P3 ParallelSum: large array, no overflow, no data race", points = 2,
                visibility = "after_published", timeoutMs = 5000)
    public void sumLarge() throws Exception {
        int[] data = new int[2_000_000];
        Arrays.fill(data, Integer.MAX_VALUE);
        long expected = 2_000_000L * Integer.MAX_VALUE;
        for (int threads : new int[] {1, 3, 7, 16}) {
            checkEquals(expected, ParallelSum.sum(data, threads), "sum with " + threads + " threads");
        }
    }

    @GradedTest(name = "P3 ParallelSum: really uses multiple threads", points = 1)
    @SuppressWarnings("deprecation")
    public void sumUsesThreads() throws Exception {
        // Every new Thread gets the next id, so the id gap shows how many
        // threads (or executor workers) the student's code created.
        long before = new Thread(() -> {}).getId();
        ParallelSum.sum(new int[10_000], 4);
        long after = new Thread(() -> {}).getId();
        long created = after - before - 1;
        check(created >= 2, "expected at least 2 worker threads for nThreads = 4, but saw " + created);
    }

    // ------------------------------------------- P4 Expr / dynamic dispatch

    static final String[] EXPR_CLASSES = {"Num", "Add", "Sub", "Mul", "Div"};

    @GradedTest(name = "P4 Expr: hand-built expression trees", points = 2)
    public void exprBasics() {
        checkEquals(14L, new Add(new Num(2), new Mul(new Num(3), new Num(4))).eval(), "2 + 3 * 4");
        checkEquals(-1L, new Sub(new Num(2), new Num(3)).eval(), "2 - 3");
        checkEquals(-3L, new Div(new Num(-7), new Num(2)).eval(), "-7 / 2 (rounds toward zero)");
        checkThrows(ArithmeticException.class,
                () -> new Add(new Num(1), new Div(new Num(1), new Num(0))).eval(), "1 + 1 / 0");
    }

    @GradedTest(name = "P4 Expr: every class implements Expr and overrides eval (reflection check)", points = 1)
    public void exprDesign() throws Exception {
        for (String name : EXPR_CLASSES) {
            Class<?> c = Class.forName(name);
            check(Expr.class.isAssignableFrom(c), name + " must implement Expr");
            check(c.getDeclaredMethod("eval").getDeclaringClass() == c, name + " must override eval()");
        }
    }

    @GradedTest(name = "P4 Expr: uses dynamic dispatch, not instanceof/getClass", points = 1)
    public void exprNoTypeTests() throws Exception {
        String src = Files.readString(Path.of(System.getProperty("exprs.source", "Exprs.java")));
        String code = src.replaceAll("(?s)/\\*.*?\\*/", "").replaceAll("//[^\\n]*", "");
        for (String banned : new String[] {"instanceof", "getClass", "switch"}) {
            check(!code.contains(banned), "Exprs.java uses '" + banned
                    + "'; let each class override eval() and rely on dynamic dispatch instead");
        }
    }

    /** One test per line of eval_cases.txt, parsed with the ANTLR grammar Arith.g4. */
    @GradedTestFactory
    public static List<GradedTestFactory.Case> evalCases() throws Exception {
        List<String> lines = Files.readAllLines(Path.of(System.getProperty("eval.cases", "eval_cases.txt")));
        List<GradedTestFactory.Case> cases = new ArrayList<>();
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i).trim();
            if (line.isEmpty() || line.startsWith("#")) continue;
            int lineNo = i + 1;
            int arrow = line.indexOf("=>");
            String lhs = (arrow < 0 ? line : line.substring(0, arrow)).trim();
            String rhs = (arrow < 0 ? "" : line.substring(arrow + 2)).trim();
            cases.add(new GradedTestFactory.Case(
                    "P4 eval (eval_cases.txt line " + lineNo + "): " + lhs, 0.5, "visible", () -> {
                Expr e;
                try {
                    e = ExprBuilder.parse(lhs);
                } catch (ExprBuilder.SyntaxError err) {
                    System.out.println("AUTOGRADER CONFIG ERROR in eval_cases.txt line " + lineNo + ": " + err.getMessage());
                    throw new AssertionError("This test is misconfigured; please tell the instructor (eval_cases.txt line " + lineNo + ").");
                }
                if (rhs.equals("error")) {
                    checkThrows(ArithmeticException.class, e::eval, lhs + "\n  parsed as: " + ExprBuilder.astOf(lhs));
                } else {
                    long want;
                    try {
                        want = Long.parseLong(rhs);
                    } catch (NumberFormatException nfe) {
                        System.out.println("AUTOGRADER CONFIG ERROR in eval_cases.txt line " + lineNo + ": bad expected value " + rhs);
                        throw new AssertionError("This test is misconfigured; please tell the instructor (eval_cases.txt line " + lineNo + ").");
                    }
                    long got = e.eval();
                    if (got != want) {
                        throw new AssertionError("Expected " + want + " but got " + got + "\n  parsed as: " + ExprBuilder.astOf(lhs));
                    }
                }
                return null;
            }));
        }
        return cases;
    }
}
