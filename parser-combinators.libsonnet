// Parser :: State -> (Value, State)
// State = [Pos, Text, Err or null]

// TODO:
// Implement and describe recognizer pattern
//
// non-progressing recognizer (hack)
//
// Implement value handling
// capture, captureAndRetain
//
// High level:
// lexer, used as `lexer([comment, identifier, operator, string, whatever else])
// some approach for maintaining token positions

local withError(state, err) =
    local pos = state[0], text = state[1], oldErr = state[2];
    assert oldErr == null;
    [null, [pos, text, err]]
    ;

local parseConst(pattern) = function(state)
    local pos = state[0], text = state[1], err = state[2];
    if err != null then
        [null, state]
    else
        local length = std.length(pattern);
        local retrieved = text[pos:pos+length];
        if retrieved == pattern then
            [null, [pos + length, text, null]]
        else
            withError(state, "mismatch")
    ;

local noop = function(state) [null, state];

local
    normalize(protoParser) =
        if std.isString(protoParser) then
            parseConst(protoParser)
        else if std.isArray(protoParser) then
            parseSeq(protoParser) // not sure if good idea to have that implicit
        else if std.isFunction(protoParser) then
            protoParser
        else
            error "Expected a string or a function, got " + std.type(protoParser)
        ,
    parseSeq(parsers) = function(state)
        local length = std.length(parsers);
        local ps = std.map(normalize, parsers);
        local parsers = ps;
        local parseSeqH(pIndex, state, val) =
            local err = state[2];
            if pIndex >= length then
                [if err != null then null else val, state]
            else
                if err != null then
                    [null, state]
                else
                    local parsed = parsers[pIndex](state);
                    parseSeqH(pIndex + 1, parsed[1], val + [parsed[0]])
            ;
        parseSeqH(0, state, [])
    ;

local parseAny(parsers) = function(state)
    // TODO(sbarzowski) handle fatal parsing errors
    local length = std.length(parsers);
    local ps = std.map(normalize, parsers);
    local parsers = ps;
    local err = state[2];
    if err != null then
        [null, state]
    else
        local parseAnyH(pIndex, state) =
            if pIndex >= length then
                withError(state, "no match")
            else
                local parsed = parsers[pIndex](state);
                local newState = parsed[1];
                local err = newState[2];
                if err != null then
                    parseAnyH(pIndex + 1, state)
                else
                    parsed
            ;
        parseAnyH(0, state)
    ;


local capture(parser) =
    local p = normalize(parser);
    local parser = p;
    function(state)
        local startPos = state[0], text = state[1];
        local parsed = parser(state);
        local endPos = parsed[1][0], err = parsed[1][2];
        [text[startPos:endPos], parsed[1]]
    ;

local captureWith(parser, f) =
    local p = normalize(parser);
    local parser = p;
    function(state)
        local startPos = state[0], text = state[1];
        local parsed = parser(state);
        local endPos = parsed[1][0], err = parsed[1][2];
        [f(text[startPos:endPos], parsed[0]), parsed[1]]
    ;

local apply(parser, f) =
    local p = normalize(parser);
    local parser = p;
    function(state)
        local parsed = parser(state);
        [f(parsed[0]), parsed[1]]
    ;

local setValue(parser, val) =
    local p = normalize(parser);
    local parser = p;
    function(state)
        local parsed = parser(state);
        [val, parsed[1]]
    ;

local ignore(parser) = setValue(parser, null);

// TODO(sbarzowski) add support for minimum and maximum number of matches
local parseGreedy(parser, minMatches=null, maxMatches=null) = function(state)
    local p = normalize(parser);
    local parser = p;
    local err = state[2];
    if err != null then
        state
    else
        local parseGreedyH(state, count, vals) =
            local parsed = parser(state);
            local val = parsed[0];
            local newState = parsed[1];
            local err = newState[2];
            if err != null then
                // TODO handle critical
                if minMatches != null && count < minMatches then
                    [null, "not enough matches"]
                else
                    [vals, state]
            else if maxMatches != null && count + 1 == maxMatches then
                [vals + [val], newState]
            else
                parseGreedyH(newState, count + 1, vals + [val]) tailstrict
        ;
        parseGreedyH(state, 0, [])
    ;

local parseCharFiltered(filter) = function(state)
    local startPos = state[0], text = state[1], err = state[2];
    local len = std.length(text);
    if err != null then
        state
    else if startPos < len && filter(text[startPos]) then
        [text[startPos], [startPos + 1, text, null]]
    else
        withError(state, "mismatch")
    ;

// TODO(sbarzowski) better name
local parseCharMap(obj) = function(state)
    local startPos = state[0], text = state[1], err = state[2];
    local len = std.length(text);
    local c = text[startPos];
    if err != null then
        state
    else if startPos < len && std.objectHas(obj, c) then
        [obj[c], [startPos + 1, text, null]]
    else
        withError(state, "mismatch")
    ;

// Batteries

local digit = parseCharFiltered(function(c) c >= '0' && c <= '9');
local alphaLower = parseCharFiltered(function(c) c >= 'a' && c <= 'z');
local alphaUpper = parseCharFiltered(function(c) c >= 'A' && c <= 'Z');
local alpha = parseCharFiltered(function(c) c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z');

local filterNull(parser) = apply(parser, function(arr) std.flatMap(function (x) if x == null then [] else [x], arr));

local lex(parsers, ignoredParsers, captureFunc=capture) =
    local ps = std.map(normalize, parsers);
    local parsers = ps;
    local cParsers = std.map(function(p) captureFunc(p), parsers);
    local iParsers = std.map(ignore, ignoredParsers);
    filterNull(parseGreedy(parseAny(cParsers+iParsers)))
    ;

// High-level stuff

local parseList(elemP, delimP, closeP) = function(state)
    local ep = normalize(elemP), dp = normalize(delimP), cp = normalize(closeP);
    local elemP = ep, delimP = dp, closeP = cp;
    local err = state[2];
    if err != null then
        state
    else
        local parseListH(state) =
            local parsed = elemP(state);
            local state = parsed[1];
            local err = state[2];
            if err != null then
                [null, state]
            else
                // TODO - if parseAny could signify which option it went with, it could be simplified
                local parsedDelim = delimP(state);
                local stateDelim = parsedDelim[1];
                local errDelim = stateDelim[2];
                if errDelim != null then
                    // TODO check if fatal critical
                    local parsedClose = closeP(state);
                    local stateClose = parsedClose[1];
                    [null, stateClose]
                else
                    parseListH(stateDelim)
        ;
        parseListH(state)
    ;

local runParser(parser, text) =
    local p = normalize(parser);
    local parser = p;
    // TODO(sbarzowski) configurable starting position
    local parsed = parser([0, text, null]);
    local result = [parsed[0], parsed[1][2]];
    result
    ;

{
    runParser:: runParser,
    any:: parseAny,
    list:: parseList,
    seq:: parseSeq,
    const:: parseConst,
    greedy:: parseGreedy,
    capture:: capture,
    captureWith:: captureWith,
    apply:: apply,
    setValue:: setValue,
    ignore:: ignore,
    noop:: noop,
    charMap:: parseCharMap,

    // Batteries
    alpha:: alpha,
    alphaLower:: alphaLower,
    alphaUpper:: alphaUpper,
    digit:: digit,

    lex::lex,
}
