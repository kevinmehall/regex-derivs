# Basic insert-only hash table. ES6 has Maps with key by object identity, but
# does not allow lookup by semantically-identical but separately- created
# elements.

# Objects used as keys must have a `.hash` property and an `.equal(other)`
# method.

size = 1024
module.exports = class HashTable
	constructor: ->
		@table = new Array(size)

	# Look up by key
	get: (key) ->
		l = @table[key.hash % size]
		return false unless l
		for {k,v} in l
			return v if key.equal(k)
		return false

	# Insert `value` at `key`. `key` must not already be present.
	insert: (k,v) ->
		l = @table[k.hash % size] or= []
		l.push {k, v}
		return v
