import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

/**
 * Visitor over the ANTLR parse tree that builds the student's Expr objects
 * (Num, Add, Sub, Mul, Div). parse() turns a line like "2 + 3 * -4" into
 * Add(Num(2), Mul(Num(3), Sub(Num(0), Num(4)))).
 */
public class ExprBuilder extends ArithBaseVisitor<Expr> {

    /** Thrown for a malformed line in the test file (an instructor-side error). */
    public static class SyntaxError extends RuntimeException {
        SyntaxError(String message) { super(message); }
    }

    public static Expr parse(String text) {
        BaseErrorListener fail = new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                                    int line, int charPositionInLine, String msg, RecognitionException e) {
                throw new SyntaxError("column " + (charPositionInLine + 1) + ": " + msg);
            }
        };
        ArithLexer lexer = new ArithLexer(CharStreams.fromString(text));
        lexer.removeErrorListeners();
        lexer.addErrorListener(fail);
        ArithParser parser = new ArithParser(new CommonTokenStream(lexer));
        parser.removeErrorListeners();
        parser.addErrorListener(fail);
        return new ExprBuilder().visit(parser.prog());
    }

    /** The AST of a line, written with constructor names, for feedback messages. */
    public static String astOf(String text) {
        ArithParser parser = new ArithParser(new CommonTokenStream(new ArithLexer(CharStreams.fromString(text))));
        parser.removeErrorListeners();
        return new ArithBaseVisitor<String>() {
            @Override public String visitProg(ArithParser.ProgContext c) { return visit(c.expr()); }
            @Override public String visitInt(ArithParser.IntContext c) { return "Num(" + c.INT().getText() + ")"; }
            @Override public String visitParens(ArithParser.ParensContext c) { return visit(c.expr()); }
            @Override public String visitNeg(ArithParser.NegContext c) { return "Sub(Num(0), " + visit(c.expr()) + ")"; }
            @Override public String visitMulDiv(ArithParser.MulDivContext c) {
                return (c.op.getText().equals("*") ? "Mul(" : "Div(") + visit(c.expr(0)) + ", " + visit(c.expr(1)) + ")";
            }
            @Override public String visitAddSub(ArithParser.AddSubContext c) {
                return (c.op.getText().equals("+") ? "Add(" : "Sub(") + visit(c.expr(0)) + ", " + visit(c.expr(1)) + ")";
            }
        }.visit(parser.prog());
    }

    @Override
    public Expr visitProg(ArithParser.ProgContext ctx) {
        return visit(ctx.expr());
    }

    @Override
    public Expr visitInt(ArithParser.IntContext ctx) {
        return new Num(Long.parseLong(ctx.INT().getText()));
    }

    @Override
    public Expr visitParens(ArithParser.ParensContext ctx) {
        return visit(ctx.expr());
    }

    @Override
    public Expr visitNeg(ArithParser.NegContext ctx) {
        return new Sub(new Num(0), visit(ctx.expr()));
    }

    @Override
    public Expr visitMulDiv(ArithParser.MulDivContext ctx) {
        Expr l = visit(ctx.expr(0)), r = visit(ctx.expr(1));
        return ctx.op.getText().equals("*") ? new Mul(l, r) : new Div(l, r);
    }

    @Override
    public Expr visitAddSub(ArithParser.AddSubContext ctx) {
        Expr l = visit(ctx.expr(0)), r = visit(ctx.expr(1));
        return ctx.op.getText().equals("+") ? new Add(l, r) : new Sub(l, r);
    }
}
