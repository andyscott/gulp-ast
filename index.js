var escodegen, esprima, through2, transform, traverse;

escodegen = require('escodegen');

esprima = require('esprima');

through2 = require('through2');

exports.parse = function() {
  return through2.obj(function(file, encoding, cb) {
    var err;
    try {
      file.ast = esprima.parse(String(file.contents));
      this.push(file);
    } catch (_error) {
      err = _error;
      this.emit('error', new Error(err));
    }
    return cb();
  });
};

exports.render = function() {
  return through2.obj(function(file, encoding, cb) {
    var err;
    if (file.ast == null) {
      this.push(file);
    } else {
      try {
        file.contents = new Buffer(escodegen.generate(file.ast));
        delete file.ast;
        this.push(file);
      } catch (_error) {
        err = _error;
        this.emit(err);
      }
    }
    return cb();
  });
};

exports.transform = transform = function(f) {
  return through2.obj(function(file, encoding, cb) {
    if (file.ast != null) {
      f(file.ast);
    }
    this.push(file);
    return cb();
  });
};

exports.traverse = traverse = function(node, cb) {
  var key, _results;
  if (Array.isArray(node)) {
    return node.forEach(function(x) {
      if (x != null) {
        return traverse(x, cb);
      }
    });
  } else if ((node != null) && typeof node === 'object') {
    cb(node);
    _results = [];
    for (key in node) {
      if (node.hasOwnProperty(key)) {
        _results.push(traverse(node[key], cb));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }
};

exports.rewriteRequire = function(f) {
  return transform(function(ast) {
    return traverse(ast, function(node) {
      var c, mappedName;
      c = node.callee;
      if (!((c != null) && node.type === 'CallExpression' && c.type === 'Identifier' && c.name === 'require')) {
        return;
      }
      if (node["arguments"].length && node["arguments"][0].type === 'Literal') {
        mappedName = f(node["arguments"][0].value);
        if (mappedName != null) {
          return node["arguments"][0].value = mappedName;
        }
      }
    });
  });
};
