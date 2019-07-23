local pc = import 'parser-combinators.libsonnet';

local assertParses(expected, parser, input) =
    std.assertEqual([expected, null], pc.runParser(parser, input));

true
&& std.assertEqual([null, null], pc.runParser(pc.const("foo"), "foo"))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.const("foo"), "fo"))
&& std.assertEqual([null, null], pc.runParser(pc.const(["f", "o", "o"]), ["f", "o", "o"]))
&& std.assertEqual([[null, null], null], pc.runParser(pc.seq([pc.const("aaa"), pc.const("bbb")]), "aaabbb"))
&& std.assertEqual([[null, null], null], pc.runParser(pc.seq(["aaa", "bbb"]), "aaabbb"))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.seq(["aaa", "bbb"]), "aaa"))
&& std.assertEqual([null, null], pc.runParser(pc.any(["aaa", "bbb"]), "aaa"))
&& std.assertEqual([[null, null], null], pc.runParser(["aaa", "bbb"], "aaabbb"))

&& std.assertEqual([null, null], pc.runParser(pc.any(["aaa", "bbb"]), "bbb"))
&& std.assertEqual([null, "no match"], pc.runParser(pc.any(["aaa", "bbb"]), "bb"))
&& std.assertEqual([[null, null, null, null, null, null], null], pc.runParser(pc.greedy("a"), "aaaaaa"))
&& std.assertEqual([[null, null], null], pc.runParser(pc.seq([pc.ignore(pc.greedy("a")), "b"]), "aaaaaab"))
&& std.assertEqual([null, null], pc.runParser(pc.list("a", ",", "."), "a,a,a,a."))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.list("a", ",", "."), "a,a,a,a,."))
&& std.assertEqual(["aaa", null], pc.runParser(pc.capture(pc.const("aaa")), "aaa"))
&& std.assertEqual([["aaa", null], null], pc.runParser(pc.captureWith(pc.const("aaa"), function(c, orig) [c, orig]), "aaa"))
&& std.assertEqual([42, null], pc.runParser(pc.setValue(pc.noop, 42), "aaa"))
&& std.assertEqual([42, null], pc.runParser(pc.apply(pc.setValue(pc.noop, 21), function(x) x * 2), "aaa"))



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