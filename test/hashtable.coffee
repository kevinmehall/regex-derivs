assert = require 'assert'
HashTable = require '../hashtable'

class TestItem
	constructor: (@n, @hash = @n) ->
	equal: (other) -> other.n == @n

describe 'HashTable', ->
	it 'handles basic inserts and gets', ->
		h = new HashTable()
		h.insert(new TestItem(11111), 'foo1')
		h.insert(new TestItem(22222), 'bar2')
		assert.equal h.get(new TestItem(11111)), 'foo1'
		assert.equal h.get(new TestItem(22222)), 'bar2'

	it 'handles hash collisions', ->
		h = new HashTable()
		h.insert(new TestItem(44444, 99), 'foo3')
		h.insert(new TestItem(55555, 99), 'bar4')
		assert.equal h.get(new TestItem(44444, 99)), 'foo3'
		assert.equal h.get(new TestItem(55555, 99)), 'bar4'
