local pc = import 'parser-combinators.jsonnet';
true
&& std.assertEqual([null, null], pc.runParser(pc.parseConst("foo"), "foo"))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.parseConst("foo"), "fo"))
&& std.assertEqual([null, null], pc.runParser(pc.parseConst(["f", "o", "o"]), ["f", "o", "o"]))
&& std.assertEqual([null, null], pc.runParser(pc.parseSeq([pc.parseConst("aaa"), pc.parseConst("bbb")]), "aaabbb"))
&& std.assertEqual([null, null], pc.runParser(pc.parseSeq(["aaa", "bbb"]), "aaabbb"))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.parseSeq(["aaa", "bbb"]), "aaa"))
&& std.assertEqual([null, null], pc.runParser(pc.parseAny(["aaa", "bbb"]), "aaa"))
&& std.assertEqual([null, null], pc.runParser(pc.parseAny(["aaa", "bbb"]), "bbb"))
&& std.assertEqual([null, "no match"], pc.runParser(pc.parseAny(["aaa", "bbb"]), "bb"))
&& std.assertEqual([null, null], pc.runParser(pc.parseGreedy("a"), "aaaaaa"))
&& std.assertEqual([null, null], pc.runParser(pc.parseSeq([pc.parseGreedy("a"), "b"]), "aaaaaab"))
&& std.assertEqual([null, null], pc.runParser(pc.parseList("a", ",", "."), "a,a,a,a."))
&& std.assertEqual([null, "mismatch"], pc.runParser(pc.parseList("a", ",", "."), "a,a,a,a,."))
&& std.assertEqual(["aaa", null], pc.runParser(pc.capture(pc.parseConst("aaa")), "aaa"))
&& std.assertEqual([["aaa", null], null], pc.runParser(pc.captureWith(pc.parseConst("aaa"), function(c, orig) [c, orig]), "aaa"))
&& std.assertEqual([42, null], pc.runParser(pc.setValue(pc.noop, 42), "aaa"))
&& std.assertEqual([42, null], pc.runParser(pc.apply(pc.setValue(pc.noop, 21), function(x) x * 2), "aaa"))
