require 'functional/curry' unless RUBY_VERSION >= '1.9.2'
require 'functional/lambda'
include Lambda::Primitive
include Lambda::Variable
include Lambda::Statement
