local pc = import '../parser-combinators.libsonnet';

local whitespace = pc.parseGreedy(pc.parseConst(" "));
local in_whitespace(p) = pc.apply(pc.parseSeq([whitespace, p, whitespace]), function(x) x[1]);

local int = pc.captureWith(pc.parseGreedy(pc.digit), function(c, o) std.parseInt(c));
local operator1 = pc.capture(pc.parseAny(["*", "/"]));
local operator2 = pc.capture(pc.parseAny(["+", "-"]));

local optional(parser) = pc.parseAny([parser, pc.noop]);

// local expr2 = pc.parseSeq(expr1 )

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

local in_paren = pc.apply(pc.parseSeq(["(", expr2, ")"]), function(x) x[1]),
      expr0 = in_whitespace(pc.parseAny([in_paren, int])),
      expr1 = in_whitespace(applyCalc(pc.parseSeq([expr0, optional(pc.parseSeq([operator1, expr1]))]))),
      expr2 = in_whitespace(applyCalc(pc.parseSeq([expr1, optional(pc.parseSeq([operator2, expr2]))])))
      ;
local expr = expr2;

{
    expr:: expr,
    expr1:: expr1,
}