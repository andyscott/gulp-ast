## Information

<table>
<tr>
<td>Package</td><td>gulp-ast</td>
</tr>
<tr>
<td>Description</td>
<td>Modify the JS AST</td>
</tr>
</table>

## Usage

Add a prefix to all require statements

```javascript
var AST = require('gulp-ast');

gulp.task('default', function() {
  gulp.src('./src/*.js')
    .pipe(AST.parse())
    .pipe(AST.rewriteRequire(function(name) {
      return 'prefix/' + name;
    }))
    .pipe(AST.render())
    .pipe(gulp.dest('./lib/'))
});
```

Custom transform, redirect a method

```javascript
var AST = require('gulp-ast');
var through2 = require('through2');

// replace `console.log` with `myLog.log`
var customTransform = function() {
  return AST.transform(function(ast) {
    return AST.traverse(ast, function(node) {
      var callee = node.callee;
      if (callee == null) return;
      if (node.type !== 'CallExpression') return;
      if (callee.type !== 'MemberExpression') return;
      var nested = callee.object;
      if (nested.type !== 'MemberExpression') return;
      if (nested.object.type !== 'Identifier') return;
      if (nested.object.name !== 'console') return;
      if (nested.property.type !== 'Identifier') return;
      if (nested.property.name !== 'API') return;
      var proxy = function() {
        return callee.object = {
          type: 'Identifier',
          name: 'myLog'
        };
      };
      switch (callee.property.name) {
        case 'log'  : return proxy();
      }
    });
  });
};

gulp.task('default', function() {
  gulp.src('./src/*.js')
    .pipe(AST.parse())
    .pipe(customTransform())
    .pipe(AST.render())
    .pipe(gulp.dest('./lib/'))
});
```

## LICENSE

(MIT License)

Copyright (c) 2014 Andy Scott

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.