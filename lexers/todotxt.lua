-- Copyright 2025 Chris Clark
-- todo.txt https://github.com/too-much-todotxt/spec LPeg lexer.

local lexer = lexer
local P, S = lpeg.P, lpeg.S

local lex = lexer.new('todotxt')

--local punct_not_colon = lpeg.R('!/', ';@', '[\'', '{~')  -- same as lexer.punct without colon ':'

local not_whitespace = lexer.any - lexer.space - P(':')

-- Alternative patterns
--local not_whitespace = lexer.alnum + P('_') + P('-') + P('+') + P('@')
--local not_whitespace = lexer.alnum + punct_not_colon  -- this does not work for non-ascii characters :-(

local not_whitespace_word = not_whitespace * not_whitespace^0

-- Experiments that did not work at the time of testing (before had working not_whitespace_word pattern)
--local keyvalue_key = lexer.range(not_whitespace, ':', true)
--local keyvalue_value = lexer.range(not_whitespace, lexer.space, true)
--local keyvalue_key = lexer.range(lexer.space, ':', false)
--local keyvalue_value = lexer.range(lexer.space, lexer.space, false)


-- Done/Complete items, map to comment style
lex:add_rule('done', lex:tag(lexer.COMMENT, lexer.starts_line(lexer.to_eol('x '))))

-- Priority, trest A, B, C as unique, D+ same style
lex:add_rule('priority_A', lex:tag(lexer.ERROR, lexer.starts_line('(A) ')))
lex:add_rule('priority_B', lex:tag(lexer.PREPROCESSOR, lexer.starts_line('(B) ')))
lex:add_rule('priority_C', lex:tag(lexer.NUMBER, lexer.starts_line('(C) ')))
lex:add_rule('priority', lex:tag(lexer.BOLD, lexer.starts_line(P('(') * lexer.upper * P(') '))))

-- Idea, lump some priority styles together
--lex:add_rule('priority', lex:tag(lexer.NUMBER, lexer.starts_line('(A) ') + lexer.starts_line('(B) ') + lexer.starts_line('(C) ') ))



-- key:value
-- https://github.com/too-much-todotxt/spec/issues/23
-- TODO different style for key and value so they are clearly marked?
lex:add_rule('key_value', lex:tag(lexer.NUMBER, not_whitespace_word*P(':')*not_whitespace_word))
-- word too restrictive according to todo.txt spec
-- below works for alpha words but fails to match; due:2025-01-31 hide:1 rec:1b rec2:+2w p:2
--lex:add_rule('key_value', lex:tag(lexer.NUMBER, lexer.word*P(':')*lexer.word))




-- date - any context, for now treat due and complete (or anywhere in string) the same
-- TODO avoid numbers more than 4 digits? P(' ') prefix won't work for start of line but does for postfix, still unclear why https://github.com/orbitalquark/scintillua/discussions/135
-- this one explictly only matches 4 digits, then 2, then 2
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))  -- too aggressive
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*#lexer.space))  -- seems to work perfectly but I do not understand why prefix does not

-- works great, see if we can improve on this
lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit^4*P('-') * lexer.digit^2 * P('-') * lexer.digit^2 * #lexer.space))

-- Seems to work but too greedy
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit^4*P('-')*lexer.digit^2*P('-')*lexer.digit^2))  -- too aggressive
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.digit^-4*P('-')*lexer.digit^-2*P('-')*lexer.digit^-2))  -- too aggressive

-- get this to work. https://github.com/orbitalquark/scintillua/discussions/135#discussioncomment-11876564
--lex:add_rule('date', #lexer.space*lex:tag(lexer.KEYWORD, lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))

-- does NOT work
--lex:add_rule('date', lex:tag(lexer.KEYWORD, #lexer.space*lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))
--lex:add_rule('date', lex:tag(lexer.KEYWORD, lexer.space*lexer.digit*lexer.digit*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit*P('-')*lexer.digit*lexer.digit))


-- Project and Context last, as same characters can show up in key:value

-- Project +
lex:add_rule('project', lex:tag(lexer.REFERENCE, lexer.range('+', lexer.space, true)))  -- REFERENCE and lexer.LINK seem the same
--lex:add_rule('project', lex:tag(lexer.LABEL, lexer.range('+', lexer.space, true)))
--lex:add_rule('project', lex:tag(lexer.TYPE, lexer.range('+', lexer.space, true)))
-- Context @
--lex:add_rule('context', lex:tag(lexer.NUMBER, P('@')))
--lex:add_rule('context', lex:tag(lexer.STRING, lexer.range('@', lexer.space, true)))
lex:add_rule('context', lex:tag(lexer.ITALIC, lexer.range('@', lexer.space, true)))


lex:add_rule('todo_txt', lex:tag(lexer.STRING, lexer.any))

-- style notes
-- map to operator? - sort of bold
-- map to keyword? - different color

return lex
