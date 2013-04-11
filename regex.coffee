# DFAs with regular expression derivatives.

# The derivative `a\r` of an expression `r` with respect to a character `a` is
# the continuation of the expression after it has matched `a`.

# I implement a modified form of the traditional algorithm. Instead of taking
# the derivative with respect to a particular character and separately
# grouping equivalent characters into partitions, the `Expr` class has an
# `allDerivatives` method. It finds the character partitions and produces a
# derivative for each partition.

# This also has the effect of removing the need for the "null set" expression.
# Its equivalent is simply an empty list of possible derivatives.


Bitset = require './bitset'

# Helpers for pretty-printing Exprs
chr = String.fromCharCode
wrap  = (s, delim) -> if s.length == 1 then s else "#{delim[0]}#{s}#{delim[1]}"
showBitset = (s) -> wrap (chr i for i in [0..255] when s.test(i)).join(''), '[]'

# Base class for regular expressions. Expr subclass instances are created with
# functions that perform normalization, not with the regular constructors.
@Expr = class Expr

	# Returns a list of `{match, expr}` pairs for the partitions of possible
	# characters (the characters in the Bitset `match`), and the corresponding
	# derivative expressions. The `match` bitsets must not overlap. Characters
	# not covered by any of the partitions are assumed to transition to the
	# error state.
	allDerivatives: -> []
	
	# This property is overridden by subclasses. True if the expression
	# accepts the empty string.
	isNullable: false

	toString: -> "<#{@constructor.name}>"

	# Comparison function when used as a hash table key. This definition is
	# necessary but not sufficient for subclasses, which must compare data
	# fields as well. Subclasses also define the @hash property.
	equal: (other) ->
		@constructor.name is other.constructor.name and @hash is other.hash

# The singleton Expr that matches the empty string
epsilon = new Expr()
epsilon.isNullable = true
epsilon.hash = 1
epsilon.toString = -> "ε"

# Literals are expressions that match a single character from a Bitset
class Literal extends Expr
	constructor: (@charset) ->
		@hash = @charset.data.reduce((x,y)->((x+y)*99990001)|0)
	equal: (other) -> super(other) and @charset.equal(other.charset)
	toString: -> showBitset @charset

	# x \ x = ε
	# x \ y = ∅
	allDerivatives: -> [{match:@charset, next:epsilon}]

@literal = (charset) -> new Literal(charset)

# Merge two sets of {match, next} objects (as returned by allDerivatives),
# creating disjunctions on the derivatives when the match bitsets overlap.
disjunctionMerge = (as, bs) ->
	out = []
	used = Bitset.empty

	for {match:a, next:aNext} in as
		for {match:b, next:bNext} in bs
			if (intersect = a.intersect(b)).notEmpty()
				# The intersecting parts have their derivative replaced with
				# the disjunction of the `next` expressions.
				out.push {match:intersect, next:disjunction([aNext, bNext])}
				used = used.union(intersect)

	for l in [as, bs]
		for {match, next} in l
			if (match = match.without(used)).notEmpty()
				# The non-overlapping parts are retained.
				out.push {match, next}
	out

class Concatenation extends Expr
	constructor: (@first, @second) ->
		@isNullable = @first.isNullable and @second.isNullable
		@hash = (@first.hash*263167) | (@second.hash*16785407)

	equal: (other) -> super(other) and
		@first.equal(other.first) and @second.equal(other.second)
	
	toString: -> "#{wrap @first.toString(), '()'}#{@second.toString()}"

	# a \ (r·s) = a\r · s | nullable(r) · a\s
	allDerivatives: ->
		f = for {match, next} in @first.allDerivatives()
			{match, next:concatenation(next, @second)}

		if not @first.isNullable then f
		else disjunctionMerge(f, @second.allDerivatives())

@concatenation = concatenation = (first, second) ->
	# Simplifies a·ε and ε·a into a and normalizes nested concatenations.
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
	
	toString: -> @choices.join('|')

	# a \ x|y  = a\x | a\y
	allDerivatives: ->
		out = []
		for i in @choices
			out = disjunctionMerge(out, i.allDerivatives())
		out

inSet = (item, set) ->
	set.some (i) -> item.equal(i)

@disjunction = disjunction = (choices) ->
	cleaned = []
	add = (e) ->
		if e instanceof Disjunction
			# Flatten nested disjunctions
			add(i) for i in e.choices
		else unless inSet e, cleaned
			# Removes duplicate choices
			cleaned.push e

	add(i) for i in choices

	if cleaned.length == 1
		# Disjunction of one choice isn't a disjunction
		cleaned[0]
	else
		new Disjunction(cleaned)

class Repeat extends Expr
	constructor: (@a) ->
		@hash = (2097593 * @a.hash)|0
	equal: (other) -> super(other) and @a.equal(other.a)
	toString: -> "#{wrap @a.toString(), '()'}*"
	isNullable: true

	# a \ r* = a\r · r*
	allDerivatives: ->
		for {match, next} in @a.allDerivatives()
			{match, next:concatenation(next, this)}

@repeat = (a) -> new Repeat(a)

# Test an expression against a string directly. It repeatedly takes the
# derivative of the current expression and takes the branch whose bitset
# matches the next character of the string.
@execExpr = (expr, str) ->
	while str
		#console.log expr.hash, expr.toString(), str
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

# Build a DFA from an expression by mapping Exprs to states and their
# derivatives to edges.
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
				# Haven't seen this expression before. Create a state for it
				# and put it in the queue to explore.
				state = lookup.insert next, {expr:next, id:states.length}
				states.push state
				queue.push state

			{match, state}

	return states

# Pretty-print a DFA.
@showFA = (fa) ->
	for {id, expr, derivs} in fa
		console.log "#{['-','+'][+expr.isNullable]}State #{id}: #{expr}"
		for d in derivs
			console.log("\t #{showBitset d.match} -> #{d.state.id}")
	null

# Output a DFA as a graphviz dot file.
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
