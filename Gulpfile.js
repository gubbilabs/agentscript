var gulp    = require('gulp');
var concat  = require('gulp-concat');
var coffee  = require('gulp-coffee');
var docco   = require('gulp-docco');
var uglify  = require('gulp-uglify');
var rename  = require('gulp-rename');
var lazypipe= require('lazypipe');
var taskList= require('gulp-task-listing');


var ASNames = 'util evented color shapes agentset patch patches agent agents link links model animator canvasview canvastileview'.split(' ');
var ASPaths = ASNames.map(function(n){return 'src/'+n+'.coffee';});

// Create "macro" pipes.  Note 'pipe(name,args)' not 'pipe(name(args))'
// https://github.com/OverZealous/lazypipe
var jsTasks = lazypipe() // write .js and .min.js into lib/
  .pipe(gulp.dest, 'lib/')
  .pipe(rename, {suffix: '.min'})
  .pipe(uglify)
  .pipe(gulp.dest, 'lib/');
var coffeeTasks = lazypipe()
  .pipe(coffee)
  .pipe(jsTasks);

gulp.task('all', ['build', 'docs', 'models']);

// Build tasks:
gulp.task('build-agentscript', function () {
  return gulp.src(ASPaths)
  .pipe(concat('agentscript.coffee'))
  .pipe(coffeeTasks());
});
gulp.task('build-extras-cs', function () {
  return gulp.src('extras/*.coffee')
  .pipe(coffeeTasks());
});
gulp.task('build-extras-js', function () {
  return gulp.src('extras/*.js')
  .pipe(jsTasks());
});
gulp.task('build-extras', ['build-extras-cs','build-extras-js']);
gulp.task('build', ['build-agentscript', 'build-extras']);

// Watch tasks
gulp.task('watch', function() {
  gulp.watch(ASPaths, ['build-agentscript']);
  gulp.watch('extras/*.js', function(event) {
    console.log(event);
    gulp.src(event.path)
    .pipe(jsTasks());
  });
  gulp.watch('extras/*.coffee', function(event) {
    console.log(event);
    gulp.src(event.path)
    .pipe(coffeeTasks());
  });
});

// Build any models not embedded in html file:
gulp.task('models', function() {
  return gulp.src('./models/*.coffee')
  .pipe(coffee())
  .pipe(gulp.dest('./models/'));
});


// Documentation tasks
gulp.task('docs', function() {
  return gulp.src(["src/*coffee", "extras/*.{coffee,js}", "models/template.coffee"])
  .pipe(docco())
  .pipe(gulp.dest('docs/'));
});

// Git tasks: we mainly have these to avoid gh-pages conflicts
// gulp.task('git:prep', )

// Default: list out tasks
gulp.task('default', taskList);

/*
Notes:
  - coffee: add sourcemaps?
    Doesn't have the Generated by CoffeeScript 1.7.1 comment
  - add jsHint?
  - node_modules/.bin/gulp
  - why-do-we-need-to-install-gulp-globally-and-locally http://goo.gl/OhdWvO
  - http://substack.net/task_automation_with_npm_run
  - agentscript watch can report event like so:
  var watcher = gulp.watch(ASPaths, ['build-agentscript']);
  watcher.on('change', function(event) {
    console.log(event);
  });
  -or-


*/
