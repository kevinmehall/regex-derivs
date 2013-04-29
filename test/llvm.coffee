{compileLLVM} = require '../regex'

describe 'LLVM compiled REs', ->
	it 'compiles a simple string match', ->
		fn = compileLLVM('foobar')
		assert fn('foobar')
		assert not fn('foobarbaz')
		assert not fn('asdfgh')

	it 'compiles a substring match', ->
		fn = compileLLVM('.*foo.*')
		assert fn('foo')
		assert fn('asadsaffoooasf')
		assert not fn('abcfghioxyzo')

	it 'compiles (a+b+c+)+', ->
		fn = compileLLVM('(a+b+c+)+')
		assert not fn('aaaaa')
		assert fn('aaaaabbbcccabc')
		assert fn('abcccabcaaaaaabbbbc')
		assert not fn('abca')
