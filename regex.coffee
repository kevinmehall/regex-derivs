@Expr = class Expr
	allDerivatives: -> []
	isNullable: false
	toString: -> "<#{@constructor.name}>"
	equal: (other) ->
		@constructor.name is other.constructor.name and @hash is other.hash

epsilon = new Expr()
epsilon.isNullable = true
epsilon.hash = 1
epsilon.toString = -> "ε"

chr = String.fromCharCode
wrap  = (s, delim) -> if s.length == 1 then s else "#{delim[0]}#{s}#{delim[1]}"

showBitset = (s) -> wrap (chr i for i in [0..255] when s.test(i)).join(''), '[]'

class Literal extends Expr
	constructor: (@charset) ->
		@hash = @charset.data.reduce((x,y)->((x+y)*99990001)|0)
	equal: (other) -> super(other) and @charset.equal(other.charset)
	allDerivatives: -> [{match:@charset, next:epsilon}]
	toString: -> showBitset @charset

@literal = (charset) -> new Literal(charset)

disjunctionMerge = (as, bs) ->
	out = []
	used = Bitset.empty

	for {match:a, next:aNext} in as
		for {match:b, next:bNext} in bs
			if (intersect = a.intersect(b)).notEmpty()
				out.push {match:intersect, next:disjunction([aNext, bNext])}
				used = used.union(intersect)

	for l in [as, bs]
		for {match, next} in l
			if (match = match.without(used)).notEmpty()
				out.push {match, next}
	out

class Concatenation extends Expr
	constructor: (@first, @second) ->
		@isNullable = @first.isNullable and @second.isNullable
		@hash = (@first.hash*263167) | (@second.hash*16785407)

	equal: (other) -> super(other) and
		@first.equal(other.first) and @second.equal(other.second)

	allDerivatives: ->
		f = for {match, next} in @first.allDerivatives()
			{match, next:concatenation(next, @second)}

		if not @first.isNullable then f
		else disjunctionMerge(f, @second.allDerivatives())

	toString: -> "#{wrap @first.toString(), '()'}#{@second.toString()}"

@concatenation = concatenation = (first, second) ->
	console.assert first instanceof Expr
	console.assert second instanceof Expr
	if first is epsilon then second
	else if second is epsilon then first
	else if first instanceof Concatenation
		concatenation(first.first, concatenation(first.second, second))
	else new Concatenation(first, second)

class Disjunction extends Expr
	constructor: (@choices) ->
		@isNullable = @choices.some((x)->x.isNullable)
		@hash = @choices.reduce ((x,y)->((x+y.hash)|0)), 28657

	equal: (other) ->
		return false unless super(other)
		return false unless @choices.length == other.choices.length
		count = 0
		for i in @choices
			for j in other.choices
				count++ if i.equal(j)
		@choices.length == count

	allDerivatives: ->
		out = []
		for i in @choices
			out = disjunctionMerge(out, i.allDerivatives())
		out

	toString: -> @choices.join('|')


inSet = (item, set) ->
	for i in set
		return true if item.equal(i)
	false

@disjunction = disjunction = (choices) ->
	console.assert choices instanceof Array

	cleaned = []
	add = (e) ->
		if e instanceof Disjunction
			add(i) for i in e.choices
		else
			cleaned.push e unless inSet e, cleaned

	add(i) for i in choices

	if cleaned.length == 1
		cleaned[0]
	else
		new Disjunction(cleaned)

class Repeat extends Expr
	constructor: (@a) ->
		@hash = (2097593 * @a.hash)|0
	equal: (other) -> super(other) and @a.equal(other.a)
	isNullable: true
	allDerivatives: ->
		for {match, next} in @a.allDerivatives()
			{match, next:concatenation(next, this)}
	toString: -> "#{wrap @a.toString(), '()'}*"

@repeat = (a) -> new Repeat(a)

@exec = (expr, str) ->
	while str
		console.log expr.hash, expr.toString(), str
		char = str.charCodeAt(0)
		str = str.slice(1)

		nextExpr = null
		for {match, next} in expr.allDerivatives()
			if match.test char
				nextExpr = next
				break

		if nextExpr
			expr = nextExpr
		else
			return false

	return expr.isNullable

HashTable = require './hashtable'

@buildFA = (expr) ->
	startState = {expr, id:0}
	states = [startState]
	queue = [startState]
	lookup = new HashTable()
	lookup.insert(expr, startState)

	while queue.length
		s = queue.pop()

		s.derivs = for {match, next} in s.expr.allDerivatives()
			state = lookup.get(next)

			if not state
				state = lookup.insert next, {expr:next, id:states.length}
				states.push state
				queue.push state

			{match, state}

	return states

@showFA = (fa) ->
	for {id, expr, derivs} in fa
		console.log "#{['-','+'][+expr.isNullable]}State #{id}: #{expr}"
		for d in derivs
			console.log("\t #{showBitset d.match} -> #{d.state.id}")
	null

@dotFA = (fa) ->
	lines = []

	lines.push "digraph g { "

	for {id, expr, derivs} in fa
		if expr.isNullable
			lines.push "\ts#{id} [peripheries=2]"
		for d in derivs
			lines.push "\ts#{id} -> s#{d.state.id} [label=\"#{showBitset d.match}\"]"

	lines.push "}"

	return lines.join('\n')
