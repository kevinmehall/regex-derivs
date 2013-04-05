require('source-map-support').install()

util = require 'util'
{parse} = require './parse-regex'
Bitset = require './bitset'
{exec, buildFA, showFA, dotFA} = require './regex'

p = parse("[a-zA-Z123]")


#console.log util.inspect p, true, 10, true

#console.log (String.fromCharCode(i) for i in [0..255] when p.charset.test(i)).join('') 

#console.log util.inspect regex.parse(".|a")

console.log 'exec', exec(parse("abc"), "abc")

console.log 'exec', exec(parse("abc|abf|axx"), "abc")

console.log 'exec', exec(parse("a*babc"), "aaaaababc")
console.log 'exec', exec(parse("a*aaaa"), "aaaaaaaaa")
console.log 'exec', exec(parse("a*aaa"), "aa")

console.log 'exec', exec(parse("(ab|bc)*c"), "ababbcabc")

console.log 'exec', exec(parse("(aaa|aaa)*c"), "aaaaaaaaac")

console.log dotFA buildFA(parse("a*aa[ab]aaa[ab]aaaa"))


