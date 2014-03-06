// Generated by CoffeeScript 1.6.3
var coffee, gulp, gutil;

gulp = require('gulp');

coffee = require('gulp-coffee');

gutil = require('gulp-util');

var src = ['index.coffee'];

gulp.task('watch', ['default'], function() {
  gulp.watch(src, ['default']);
});

gulp.task('default', function() {
  return gulp.src(src).pipe(coffee({
    bare: true
  }).on('error', gutil.log)).pipe(gulp.dest('.'));
});