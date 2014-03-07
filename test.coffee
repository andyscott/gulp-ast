chai   = require 'chai'
assert = chai.assert
chai.should()

gutil  = require 'gulp-util'
AST    = require './index'

makeFile = (obj) ->
  if Object::toString.call(obj) is '[object String]'
    obj = contents: new Buffer(obj)
  else if Object::toString.call(obj.contents) is '[object String]'
    obj.contents = new Buffer(obj.contents)
  f = new gutil.File(obj)
  for k, v of obj when not f[k]
    f[k] = v
  f

describe 'AST.parse', ->
  it 'should add .ast to valid file buffers', (cb) ->

    
    stream = AST.parse()

    res = {}
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.file = file
    stream.on 'end', ->
      res.file.ast.should.deep.equal
        type: 'Program'
        body: [
          type: 'ExpressionStatement'
          expression:
            type: 'BinaryExpression'
            operator: '+'
            left:
              type: 'Literal'
              value: 1
            right:
              type: 'Literal'
              value: 2
        ]
      cb()

    stream.write makeFile '1 + 2'
    stream.end()

  it 'should emit an error for invalid js', (cb) ->

    stream = AST.parse()

    res = {}
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.file = file

    stream.on 'end', ->
        assert.isUndefined res.file
        assert.ok res.err
        cb()

    stream.write makeFile '\/ invalid??'
    stream.end()

describe 'AST.render', ->
  it 'should render valid .ast on vinyl files', (cb) ->

    stream = AST.render()

    res = {}
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.file = file

    stream.on 'end', ->
      res.file.contents.toString().should.equal '1 + 2;'
      cb()

    stream.write makeFile ast:
      type: 'Program'
      body: [
        type: 'ExpressionStatement'
        expression:
          type: 'BinaryExpression'
          operator: '+'
          left:
            type: 'Literal'
            value: 1
          right:
            type: 'Literal'
            value: 2
      ]
    stream.end()
