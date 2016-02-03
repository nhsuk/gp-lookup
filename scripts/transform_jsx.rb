#!/usr/bin/env ruby

require "babel-transpiler"

file_name = ARGV.fetch(0)
jsx_code = File.read(file_name)
js_code = Babel::Transpiler.transform(jsx_code).fetch("code")

puts js_code
