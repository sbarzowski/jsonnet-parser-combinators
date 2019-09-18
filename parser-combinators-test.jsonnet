local pc = import 'parser-combinators.libsonnet';
local testutils = import 'test-utils.libsonnet';

local assertParses = testutils.assertParses, assertMismatch = testutils.assertMismatch;

true
&& assertParses(null, pc.const("foo"), "foo")
&& assertMismatch(pc.const("foo"), "fo")
&& assertParses(null, pc.const(["f", "o", "o"]), ["f", "o", "o"])
&& assertParses([null, null], pc.seq([pc.const("aaa"), pc.const("bbb")]), "aaabbb")
&& assertParses([null, null], pc.seq(["aaa", "bbb"]), "aaabbb")
&& assertMismatch(pc.seq(["aaa", "bbb"]), "aaa")
&& assertParses(null, pc.any(["aaa", "bbb"]), "aaa")
&& assertParses([null, null], ["aaa", "bbb"], "aaabbb")
&& assertParses(null, pc.any(["aaa", "bbb"]), "bbb")
&& assertMismatch(pc.any(["aaa", "bbb"]), "bb")
&& assertParses([null, null, null, null, null, null], pc.greedy("a"), "aaaaaa")
&& assertParses([null, null], pc.seq([pc.ignore(pc.greedy("a")), "b"]), "aaaaaab")
&& assertParses(null, pc.list(pc.noop, "a", ",", "."), "a,a,a,a.")
&& assertMismatch(pc.list("", "a", ",", "."), "a,a,a,a,.")
&& assertParses(null, pc.list("[", "a", ",", "]"), "[a,a,a,a]")
&& assertParses("aaa", pc.capture(pc.const("aaa")), "aaa")
&& assertParses(["aaa", null], pc.captureWith(pc.const("aaa"), function(c, orig) [c, orig]), "aaa")
&& assertParses(42, pc.setValue(pc.noop, 42), "aaa")
&& assertParses(42, pc.apply(pc.setValue(pc.noop, 21), function(x) x * 2), "aaa")



&& (
    // Lexer tests:
    local
        lexer = pc.lex([identifier, operator, string], [whitespace]),
        identifier = pc.greedy(pc.alpha, minMatches=1),
        whitespace = pc.greedy(" ", minMatches=1),
        operator = pc.any(["==", "=", "+"]),
        string = ['"', pc.greedy(pc.any(["=", "+", " ", pc.alpha])), '"'];
    true
    && assertParses(["a"], lexer, "a")
    && assertParses(["a", "=", "b"], lexer, "a=b")
    && assertParses(["a", "=", "b"], lexer, "a       =            b")
    && assertParses(["a", "=", '"xxx"'], lexer, 'a = "xxx"')
    && assertParses(["a", "=", '"x x x"'], lexer, 'a = "x x x"')
)


&& (
    // Batteries
    true
    && assertParses(123, pc.int, "123")
    && assertMismatch(pc.int, "foo")

)
