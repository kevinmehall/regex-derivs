assert = require 'assert'
{parse} = require '../parse-regex'
{execExpr, buildFA} = require '../regex'

describe 'execExpr', ->
	it 'matches a literal string', ->
		assert execExpr(parse("abc"), "abc")
		assert not execExpr(parse("abc"), "abx")

	it 'matches a disjunction', ->
		assert execExpr(parse("abc|abf|axx"), "abc")

	it 'matches a kleene star', ->
		assert execExpr(parse("a*babc"), "aaaaababc")
		assert execExpr(parse("a*aaaa"), "aaaaaaaaa")
		assert not execExpr(parse("a*aaa"), "aa")

	it 'matches a more complex expression', ->
		assert execExpr(parse("(ab|bc)*c"), "ababbcabc")
		assert not execExpr(parse("(axa|aay)*c"), "aaaaaaaaac")

describe 'buildFA', ->
	it 'handles a trivial case', ->
		assert buildFA(parse('a')).length == 2

	it 'handles an expression that requires normalization to terminate', ->
		assert buildFA(parse("(a*b*c*)*")).length <= 4

	l = [
		'(a+b+c+)+'
		'((abc)*)|ax'
		'((a*)*)*'
	]

	for i in l
		it "succeeds on `#{i}`", ->
			buildFA(parse(i))

	null
