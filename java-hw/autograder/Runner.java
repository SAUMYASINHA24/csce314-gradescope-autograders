import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Finds every @GradedTest method by reflection, runs each with its own time
 * limit, and writes Gradescope's results.json.
 */
public class Runner {

    /** Everything the runner needs to know about one test. */
    record Spec(String name, double points, String visibility, long timeoutMs, Callable<?> body) {}

    record Result(Spec meta, boolean passed, String message) {}

    @SuppressWarnings("unchecked")
    public static void main(String[] args) throws Exception {
        Path out = Path.of(args.length > 0 ? args[0] : "results.json");

        // 1. @GradedTest methods, found by reflection and sorted by name.
        List<Method> methods = new ArrayList<>(Arrays.asList(HW2Tests.class.getDeclaredMethods()));
        List<Spec> specs = new ArrayList<>();
        methods.stream()
               .filter(m -> m.isAnnotationPresent(GradedTest.class))
               .sorted(Comparator.comparing((Method m) -> m.getAnnotation(GradedTest.class).name()))
               .forEach(m -> {
                   GradedTest g = m.getAnnotation(GradedTest.class);
                   specs.add(new Spec(g.name(), g.points(), g.visibility(), g.timeoutMs(), () -> {
                       m.invoke(new HW2Tests());
                       return null;
                   }));
               });

        // 2. Tests generated at runtime by @GradedTestFactory methods.
        for (Method m : methods) {
            if (!m.isAnnotationPresent(GradedTestFactory.class)) continue;
            for (GradedTestFactory.Case c : (List<GradedTestFactory.Case>) m.invoke(null)) {
                specs.add(new Spec(c.name(), c.points(), c.visibility(), 3000, c.body()));
            }
        }

        List<Result> results = new ArrayList<>();
        for (Spec spec : specs) {
            Result r = run(spec);
            System.out.println((r.passed() ? "[PASS] " : "[FAIL] ") + spec.name());
            results.add(r);
        }

        Files.writeString(out, toJson(results), StandardCharsets.UTF_8);
        System.out.println("Score: " + fmt(score(results, true)) + " / " + fmt(score(results, false)));
        System.exit(0); // don't wait for any thread a student left running
    }

    static Result run(Spec meta) {
        ExecutorService ex = Executors.newSingleThreadExecutor(r -> {
            Thread t = new Thread(r, "test-runner");
            t.setDaemon(true);
            return t;
        });
        Future<?> f = ex.submit(meta.body());
        try {
            f.get(meta.timeoutMs(), TimeUnit.MILLISECONDS);
            return new Result(meta, true, "Passed.");
        } catch (TimeoutException e) {
            f.cancel(true);
            return new Result(meta, false, "Timed out after " + meta.timeoutMs() + " ms (infinite loop or deadlock?).");
        } catch (Exception e) {
            Throwable cause = e.getCause();
            if (cause instanceof InvocationTargetException ite) cause = ite.getCause();
            if (cause instanceof AssertionError) {
                return new Result(meta, false, cause.getMessage());
            }
            String where = "";
            for (StackTraceElement el : cause.getStackTrace()) {
                String cls = el.getClassName();
                if (STUDENT_CLASSES.contains(cls)) {
                    where = " at " + el.getFileName() + ":" + el.getLineNumber();
                    break;
                }
            }
            return new Result(meta, false, "Your code threw " + cause.getClass().getSimpleName()
                    + (cause.getMessage() == null ? "" : ": " + cause.getMessage()) + where);
        } finally {
            ex.shutdownNow();
        }
    }

    static final java.util.Set<String> STUDENT_CLASSES =
            java.util.Set.of("GenericStack", "Generics", "ParallelSum", "Num", "Add", "Sub", "Mul", "Div");

    static double score(List<Result> rs, boolean earnedOnly) {
        return rs.stream().filter(r -> !earnedOnly || r.passed()).mapToDouble(r -> r.meta().points()).sum();
    }

    static String fmt(double d) {
        return d == Math.rint(d) ? String.valueOf((long) d) : String.valueOf(d);
    }

    static String json(String s) {
        StringBuilder b = new StringBuilder("\"");
        for (char c : (s == null ? "" : s).toCharArray()) {
            switch (c) {
                case '"' -> b.append("\\\"");
                case '\\' -> b.append("\\\\");
                case '\n' -> b.append("\\n");
                case '\t' -> b.append("\\t");
                default -> { if (c < ' ') b.append(' '); else b.append(c); }
            }
        }
        return b.append('"').toString();
    }

    static String toJson(List<Result> rs) {
        StringBuilder tests = new StringBuilder();
        for (Result r : rs) {
            if (tests.length() > 0) tests.append(',');
            tests.append("{\"name\":").append(json(r.meta().name()))
                 .append(",\"score\":").append(fmt(r.passed() ? r.meta().points() : 0))
                 .append(",\"max_score\":").append(fmt(r.meta().points()))
                 .append(",\"output\":").append(json(r.message()))
                 .append(",\"visibility\":").append(json(r.meta().visibility()))
                 .append('}');
        }
        String summary = "Autograder score: " + fmt(score(rs, true)) + " / " + fmt(score(rs, false))
                + ". Tests marked hidden are revealed after grades are published.";
        return "{\"score\":" + fmt(score(rs, true))
                + ",\"output\":" + json(summary)
                + ",\"visibility\":\"visible\",\"stdout_visibility\":\"hidden\""
                + ",\"tests\":[" + tests + "]}\n";
    }
}
