# 256-bit bitmap
module.exports = class Bitset
	constructor: (@data) ->

	@empty = new Bitset([0, 0, 0, 0, 0, 0, 0, 0])

	@fromRange: (start, end=start) ->
		data = [0, 0, 0, 0, 0, 0, 0, 0]

		for i in [start..end]
			data[(i/32)|0] |= (1 << (i%32))

		return new Bitset(data)

	intersect: (b) -> new Bitset(@data[i] &  b.data[i] for i in [0...8])
	without:   (b) -> new Bitset(@data[i] & ~b.data[i] for i in [0...8])
	union:     (b) -> new Bitset(@data[i] |  b.data[i] for i in [0...8])

	invert: -> new Bitset(~i for i in @data)
	test: (i) -> !!(@data[(i/32)|0] & (1 << (i%32)))

	equal: (other) ->
		for i in [0...8]
			return false if @data[i] != other.data[i]
		return true
	
	notEmpty: -> 
		for i in @data
			return true if i
		return false
