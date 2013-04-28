require('source-map-support').install()

util = require 'util'
{parse} = require './parse-regex'
{exec, buildFA, showFA, dotFA} = require './regex'

console.log dotFA buildFA parse process.argv[2]
