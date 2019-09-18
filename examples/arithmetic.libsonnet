local pc = import '../parser-combinators.libsonnet';


local operator1 = pc.capture(pc.any(["*", "/"]));
local operator2 = pc.capture(pc.any(["+", "-"]));

local funcs = {
    "+":: function(x, y) x + y,
    "-":: function(x, y) x - y,
    "/":: function(x, y) x / y,
    "*":: function(x, y) x * y,
};

local calc(exprVal) =
    // expects [value, null] or [value, [operator, value]]
    if exprVal[1] == null then
        exprVal[0]
    else
        funcs[exprVal[1][0]](exprVal[0], exprVal[1][1])
    ;

local applyCalc(p) = pc.apply(p, calc);

local in_paren = pc.apply(["(", expr2, ")"], function(x) x[1]),
      expr0 = pc.in_whitespace(pc.any([in_paren, pc.int])),
      expr1 = pc.in_whitespace(applyCalc([expr0, pc.optional([operator1, expr1])])),
      expr2 = pc.in_whitespace(applyCalc([expr1, pc.optional([operator2, expr2])]))
      ;
local expr = expr2;

{
    expr:: expr,
    expr1:: expr1,
}
