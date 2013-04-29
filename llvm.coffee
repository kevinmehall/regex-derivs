require('source-map-support').install()

{compileLLVM} = require './regex'

matchFn = compileLLVM(process.argv[2])

if process.argv[3]
	console.log matchFn(process.argv[3])
else
	console.log matchFn.llvmFn.dump()
