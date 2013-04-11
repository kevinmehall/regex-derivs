assert = require 'assert'
Bitset = require '../bitset'

describe 'Bitset', ->
	describe 'empty', ->
		it 'has all bits unset', ->
			e = Bitset.empty
			assert.equal e.test(i), false for i in [0..255]

		it 'should be empty', ->
			assert not Bitset.empty.notEmpty()

	a = 'a'.charCodeAt(0)
	z = 'z'.charCodeAt(0)
	f = 'f'.charCodeAt(0)
	m = 'm'.charCodeAt(0)

	describe 'fromRange', ->
		it 'accepts a range', ->
			b = Bitset.fromRange(a, z)
			assert.equal b.test(i), i >= a and i <= z for i in [0..255]
				
		it 'accepts a singleton', ->
			b = Bitset.fromRange(a)
			assert.equal b.test(i), i == a for i in [0..255]

	it 'can be compared', ->
		assert Bitset.fromRange(a, z).equal(Bitset.fromRange(a, z))
		assert not Bitset.fromRange(a, f).equal(Bitset.fromRange(a, z))
		
	describe 'bitwiseOps', ->
		az = Bitset.fromRange(a, z)
		fm = Bitset.fromRange(f, m)
		ae = Bitset.fromRange(a, f-1)
		nz = Bitset.fromRange(m+1, z)

		describe 'invert', ->
			it 'doubled, is identity', ->
				assert az.invert().invert().equal(az)

			it 'produces the right range', ->
				b = az.invert()
				assert.equal(b.test(i), i < a or i > z, i) for i in [0..255]

		it 'can intersect', ->
			assert az.intersect(fm).equal(fm)

		it 'can union', ->
			assert az.union(fm).equal(az)

		it 'can without', ->
			assert az.without(fm).equal(ae.union(nz))
