require('source-map-support').install()

llvm = require 'llvm'

util = require 'util'
{parse} = require './parse-regex'
{exec, buildFA, showFA, llvmFA} = require './regex'

mod = new llvm.Module("regex", llvm.globalContext)
fa = buildFA parse process.argv[2]
fn = llvmFA(fa, mod, 'regex')
console.log fn.dump()
