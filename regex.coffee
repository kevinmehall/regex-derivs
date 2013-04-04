@Expr = class Expr
	allDerivatives: -> []
	isNullable: false
	toString: -> "<#{@constructor.name}>"

epsilon = new Expr()
epsilon.isNullable = true
epsilon.toString = -> "ε"

chr = String.fromCharCode
wrap  = (s, delim) -> if s.length == 1 then s else "#{delim[0]}#{s}#{delim[1]}"

class Literal extends Expr
	constructor: (@charset) ->
	allDerivatives: -> [{match:@charset, next:epsilon}]
	toString: -> wrap (chr i for i in [0..255] when @charset.test(i)).join(''), '[]'

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

	allDerivatives: ->
		f = for {match, next} in @first.allDerivatives()
			{match, next:concatenation(next, @second)}

		if not @first.isNullable then f
		else disjunctionMerge(f, @second.allDerivatives())

	toString: -> "#{@first.toString()}#{@second.toString()}"

@concatenation = concatenation = (first, second) ->
	console.assert first instanceof Expr
	console.assert second instanceof Expr
	if first is epsilon then second
	else if second is epsilon then first
	else new Concatenation(first, second)

class Disjunction extends Expr
	constructor: (@choices) ->
		@isNullable = @choices.some((x)->x.isNullable)

	allDerivatives: ->
		out = []
		for i in @choices
			out = disjunctionMerge(out, i.allDerivatives())
		out

	toString: -> @choices.join('|')

@disjunction = disjunction = (choices) ->
	console.assert choices instanceof Array
	new Disjunction(choices)

class Repeat extends Expr
	constructor: (@a) ->
	isNullable: true
	allDerivatives: ->
		for {match, next} in @a.allDerivatives()
			{match, next:concatenation(next, this)}
	toString: -> "#{wrap @a.toString(), '()'}*"

@repeat = (a) -> new Repeat(a)

@exec = (expr, str) ->
	while str
		console.log expr.toString(), str
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