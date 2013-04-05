size = 1024

module.exports = class HashTable
	constructor: ->
		@table = new Array(size)

	get: (key) ->
		l = @table[key.hash % size]
		return false unless l
		for {k,v} in l
			return v if key.equal(k)
		return false

	insert: (k,v) ->
		l = @table[k.hash % size] or= []
		l.push {k, v}
		return v
