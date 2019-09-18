local ip = import 'ip-parser.libsonnet',
      pc = import '../parser-combinators.libsonnet';

local testutils = import '../test-utils.libsonnet';

local assertParses = testutils.assertParses, assertMismatch = testutils.assertMismatch, assertError = testutils.assertError;

true
&& assertParses([192, null, 168, null, 1, null, 1], ip.ipV4, "192.168.1.1")
&& assertParses([0, null, 0, null, 0, null, 0], ip.ipV4, "0.0.0.0")
&& assertParses([255, null, 255, null, 255, null, 255], ip.ipV4, "255.255.255.255")
&& assertMismatch(ip.ipV4, "192.168..1")
&& assertError("out of range", ip.ipV4, "192.168.1000.1")
&& assertError("out of range", ip.ipV4, "192.168.-1.1")
