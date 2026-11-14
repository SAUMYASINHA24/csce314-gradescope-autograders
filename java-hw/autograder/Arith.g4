// ANTLR 4 grammar for the arithmetic test cases of Problem 4.
//
// ANTLR generates the lexer (from the UPPERCASE rules) and an ALL(*)
// parser plus a visitor interface (from the lowercase rules). ANTLR 4
// rewrites the left-recursive `expr` rule itself; precedence is the order
// of the alternatives (earlier = binds tighter) and binary operators are
// left-associative by default:
//   - unary minus binds tightest:   2 * -3     = 2 * (0 - 3)
//   - * and / before + and -:       2 + 3 * 4  = 2 + (3 * 4)
//   - left-associative:             10 - 4 - 3 = (10 - 4) - 3
//
// ExprBuilder (a visitor) turns the parse tree into the student's own Expr
// objects, so the test file describes exactly what the student evaluates.

grammar Arith;

prog : expr EOF ;

expr : '-' expr                      # Neg
     | expr op=('*' | '/') expr      # MulDiv
     | expr op=('+' | '-') expr      # AddSub
     | '(' expr ')'                  # Parens
     | INT                           # Int
     ;

INT : [0-9]+ ;
WS  : [ \t\r\n]+ -> skip ;
