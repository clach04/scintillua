-- Copyright 2025 Chris Clark
-- todo.txt https://github.com/too-much-todotxt/spec LPeg lexer.

local lexer = lexer
local P, S = lpeg.P, lpeg.S

local lex = lexer.new('todotxt')

local punct_not_colon = lpeg.R('!/', ';@', '[\'', '{~')  -- same as lexer.punct without colon ':'

-- None of these lexer.any - lexer.space patterns work :-(
--local not_whitespace = lexer.any - lexer.space
--local not_whitespace = (lexer.any - lexer.space)^0
--local not_whitespace = (lexer.any - lexer.space)^-0
--local not_whitespace = (lexer.any - lexer.space)^1
--local not_whitespace = (lexer.any - lexer.space)^-1

-- where as these patterns work great!
--local not_whitespace = lexer.alnum + P('_') + P('-') + P('+') + P('@')
local not_whitespace = lexer.alnum + punct_not_colon  -- this does not work for non-ascii characters :-(

local not_whitespace_word = not_whitespace * not_whitespace^0

-- Experiments that did not work at the time of testing (before had working not_whitespace_word pattern)
--local keyvalue_key = lexer.range(not_whitespace, ':', true)
--local keyvalue_value = lexer.range(not_whitespace, lexer.space, true)
--local keyvalue_key = lexer.range(lexer.space, ':', false)
--local keyvalue_value = lexer.range(lexer.space, lexer.space, false)


-- Done/Complete items, map to comment style
lex:add_rule('done', lex:tag(lexer.COMMENT, lexer.starts_line(lexer.to_eol('x '))))

-- Priority, for now map to number - TODO map A, B, C to unique style colors?
lex:add_rule('priority', lex:tag(lexer.NUMBER, lexer.starts_line(P('(') * lexer.upper * P(') '))))

-- good
--lex:add_rule('priority', lex:tag(lexer.NUMBER, lexer.starts_line('(A) ')))
--lex:add_rule('priority', lex:tag(lexer.NUMBER, lexer.starts_line('(A) ') + lexer.starts_line('(B) ') + lexer.starts_line('(C) ') ))




-- key:value
-- https://github.com/too-much-todotxt/spec/issues/23
-- TODO see if can/should use; patt1 - patt2	Matches patt1 if patt2 does not also match
--      lexer.any - lexer.space
-- as word may be too restrictive according to spec
-- below fails to match; due:2025-01-31 hide:1 rec:1b rec2:+2w p:2
--lex:add_rule('key_value', lex:tag(lexer.NUMBER, lexer.word*P(':')*lexer.word))

-- matches single char as expected
--lex:add_rule('key_value', lex:tag(lexer.NUMBER, not_whitespace*P(':')*not_whitespace))




-- does whole line so getting closer
--lex:add_rule('key_value', lex:tag(lexer.NUMBER, keyvalue_key*keyvalue_value))


-- fails
--lex:add_rule('key_value', lex:tag(lexer.NUMBER, not_whitespace^1*P(':')*not_whitespace^1))
lex:add_rule('key_value', lex:tag(lexer.NUMBER, not_whitespace_word*P(':')*not_whitespace_word))


-- date - any context, for now treat due and complete (or anywhere in string) the same
-- map to operator? - sort of bold
-- map to keyword? - different color
-- TODO avoid numbers more than 4 digits? P(' ') prefix won't work for start of line
-- this one explictly only matches 4 digits, then 2, then 2 - but could be part of a longer number that is NOT a date, need some sort of prefix and postfix marker
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))  -- too aggressive
lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*#lexer.space))  -- seems to work perfectly but I do not understand why prefix does not

-- Seems to work? unclear about count 
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit^4*P('-')*lexer.digit^2*P('-')*lexer.digit^2))  -- too aggressive
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit^-4*P('-')*lexer.digit^-2*P('-')*lexer.digit^-2))  -- too aggressive

-- does NOT work
--lex:add_rule('date', lex:tag(lexer.KEYWORD, #lexer.space*lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.space*lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))


-- Project and Context last, as same characters can show up in key:value

-- Project +
lex:add_rule('project', lex:tag(lexer.LABEL, lexer.range('+', lexer.space, true)))
--lex:add_rule('project', lex:tag(lexer.TYPE, lexer.range('+', lexer.space, true)))
-- Context @
--lex:add_rule('context', lex:tag(lexer.NUMBER, P('@')))
lex:add_rule('context', lex:tag(lexer.STRING, lexer.range('@', lexer.space, true)))


return lex
