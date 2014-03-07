# helpers to convert javascript to and from ASTs in
# gulp.  - Andy

escodegen = require 'escodegen'
esprima   = require 'esprima'
through2  = require 'through2'

exports.parse = -> through2.obj (file, encoding, cb) ->
  try
    file.ast = esprima.parse String(file.contents)
    @push file
  catch err
    @emit 'error', new Error(err)
  cb()

exports.render = -> through2.obj (file, encoding, cb) ->
  if not file.ast? then @push file
  else
    try
      file.contents = new Buffer(escodegen.generate file.ast)
      delete file.ast
      @push file
    catch err
      @emit err
  cb()

exports.transform = transform = (f) ->
  through2.obj (file, encoding, cb) ->
    if file.ast? then f file.ast
    @push file
    cb()

exports.traverse = traverse = (node, cb) ->
  if Array.isArray node
    node.forEach (x) ->
      if x? then traverse x, cb
  else if node? and typeof node == 'object'
    cb node    
    for key of node
      if node.hasOwnProperty key
        traverse node[key], cb

exports.rewriteRequire = (f) -> transform (ast) -> traverse ast, (node) ->
  c = node.callee
  return unless c? and node.type == 'CallExpression' and c.type == 'Identifier' and c.name == 'require'
  if node.arguments.length and node.arguments[0].type == 'Literal'
    mappedName = f node.arguments[0].value
    if mappedName? then node.arguments[0].value = mappedName