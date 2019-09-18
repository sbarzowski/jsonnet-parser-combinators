local pc = import '../parser-combinators.libsonnet';

local int255 = pc.captureWithCheck(pc.int, function(_text, val) if val >= 0 && val <= 255 then [val, null] else [null, "out of range"]);

local ipV4 = pc.seq([int255, '.', int255, '.', int255, '.', int255]);

{
    ipV4: ipV4,
}
