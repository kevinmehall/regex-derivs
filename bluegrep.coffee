require('source-map-support').install()

util = require 'util'
{parse} = require './parse-regex'
Bitset = require './bitset'
{exec, buildFA, showFA, dotFA} = require './regex'

p = parse("[a-zA-Z123]")

console.log 'exec', exec(parse("abc"), "abc")

console.log 'exec', exec(parse("abc|abf|axx"), "abc")

console.log 'exec', exec(parse("a*babc"), "aaaaababc")
console.log 'exec', exec(parse("a*aaaa"), "aaaaaaaaa")
console.log 'exec', exec(parse("a*aaa"), "aa")

console.log 'exec', exec(parse("(ab|bc)*c"), "ababbcabc")

console.log 'exec', exec(parse("(aaa|aaa)*c"), "aaaaaaaaac")

showFA buildFA(parse("(((aa)a)|aaa)b"))


