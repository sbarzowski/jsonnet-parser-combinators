local a = import 'arithmetic.libsonnet';
local pc = import '../parser-combinators.jsonnet';

true
&& std.assertEqual([4, null], pc.runParser(a.expr, "2+2"))
&& std.assertEqual([42, null], pc.runParser(a.expr, "40+2"))
&& std.assertEqual([4, null], pc.runParser(a.expr1, "2 * 2"))
&& std.assertEqual([4, null], pc.runParser(a.expr, "2 * 2"))
&& std.assertEqual([5, null], pc.runParser(a.expr, "1 + 2 * 2"))
&& std.assertEqual([6, null], pc.runParser(a.expr, "(1 + 2) * 2"))