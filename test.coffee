chai   = require 'chai'
assert = chai.assert
chai.should()

es     = require 'event-stream'

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

    res = files: []
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.files.push file
    stream.on 'end', ->
      res.files.length.should.equal 1
      res.files[0].ast.should.deep.equal
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

    res = files: []
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.files.push file

    stream.on 'end', ->
      res.files.length.should.equal 0
      assert.ok res.err
      cb()

    stream.write makeFile '\/ invalid??'
    stream.end()

describe 'AST.render', ->
  it 'should render valid .ast on vinyl files', (cb) ->

    stream = AST.render()

    res = files: []
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.files.push file

    stream.on 'end', ->
      res.files.length.should.equal 1
      res.files[0].contents.toString().should.equal '1 + 2;'
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

describe 'AST.parse -> AST.rewriteRequire -> AST.render', ->
  it 'should rewrite the require statement', (cb) ->

    stream = es.pipeline(
      AST.parse()
      AST.rewriteRequire (name) -> 'prefix.' + name
      AST.render()
    )

    res = files: []
    stream.on 'error', (err) -> res.err = err
    stream.on 'data', (file) -> res.files.push file

    stream.on 'end', ->
      res.files.length.should.equal 2
      res.files[0].contents.toString().should.equal 'require(\'prefix.file1\');'
      res.files[1].contents.toString().should.equal 'require(\'prefix.file2\');'
      cb()

    stream.write makeFile 'require(\'file1\');'
    stream.write makeFile 'require(\'file2\');'
    stream.end()

