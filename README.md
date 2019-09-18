# Parser Combinators for Jsonnet

It is sometimes useful to validate a piece of text or extract data from it. A common way to do this is with regular expressions. Jsonnet does not support them at the moment, though.
This library implements a more powerful approach - parser combinators.

Let's start with a small example - parsing IPv4 addresses, such as `192.168.1.1`. This task is doable with regexps, [but a bit tricky and the result in not very readable](https://stackoverflow.com/questions/5284147/validating-ipv4-addresses-with-regexp).
With this library, you can do it like this:

```
local int255 = pc.captureWithCheck(pc.int, function(_text, val) if val >= 0 && val <= 255 then [val, null] else [null, "out of range"]);

local ipV4 = pc.seq([int255, '.', int255, '.', int255, '.', int255]);

pc.runParser(ipV4, "192.168.1.1")
```

A more elaborate example, which shows how to parse and evaluate arithmetic expressions (e.g. `(2 + 2) * 2 + 2`) is available in `examples/` directory.

## State of the project and future work

It reached a stage when it can be useful, but it is still fairly minimal.
Its primary limitation is that error reporting is still very primitive in the included parsers and parser combinators.
The set of provided parsers is quite minimal, it makes sense to add more.
Potentially this can even grow beyond the parser combinators to a more general text processing library.
