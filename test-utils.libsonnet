local pc = import 'parser-combinators.libsonnet';

local assertParses(expected, parser, input) =
    std.assertEqual([expected, null], pc.runParser(parser, input));

local assertMismatch(parser, input) =
    std.assertEqual([null, "mismatch"], pc.runParser(parser, input));

{
    assertParses:: assertParses,
    assertMismatch:: assertMismatch,
}
