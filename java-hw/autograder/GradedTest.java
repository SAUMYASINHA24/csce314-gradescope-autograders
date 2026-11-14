import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Marks a method as an autograder test. The runner finds these methods by
 * reflection, so adding a test is just writing one annotated method.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface GradedTest {
    String name();
    double points();
    /** "visible" or "after_published" (hidden until grades are released). */
    String visibility() default "visible";
    /** Per-test time limit in milliseconds. */
    long timeoutMs() default 3000;
}
