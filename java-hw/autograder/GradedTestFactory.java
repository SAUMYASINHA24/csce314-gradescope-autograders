import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.concurrent.Callable;

/**
 * Marks a static method that returns a List of {@link GradedTestFactory.Case}:
 * tests generated at runtime, e.g. one per line of a test-case file.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface GradedTestFactory {

    /** One generated test. The body throws AssertionError to fail. */
    record Case(String name, double points, String visibility, Callable<Void> body) {}
}
