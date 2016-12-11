var gulp = require('gulp'),
    sourcemaps = require('gulp-sourcemaps'),
    concat = require('gulp-concat'),
    rename = require('gulp-rename'),
    uglify = require('gulp-uglify'),
    imagemin = require('gulp-imagemin'),
    spritesmith = require('gulp.spritesmith'),
    cleanCSS = require('gulp-clean-css');

var jsFiles = [
    'bower_components/jquery/dist/jquery.min.js',
    'bower_components/angular/angular.min.js',
    'bower_components/angular-ui-router/release/angular-ui-router.min.js',
    'bower_components/bootstrap/dist/js/bootstrap.min.js',
    'bower_components/angular-input-masks/angular-input-masks-standalone.min.js',
    'bower_components/moment/min/moment-with-locales.min.js',
    'bower_components/moment/locale/pt-br.js',
    'bower_components/moment/min/moment-with-locales.js'
];

var cssFiles = [
    'bower_components/bootstrap/dist/css/bootstrap.min.css',
    'bower_components/fontawesome/css/font-awesome.min.css'
];

function logError(error) {
    console.error(error);
    this.emit('end');
}

gulp.task('styles', function() {
    gulp.src('./public/css/*.css')
        .pipe(sourcemaps.init())
        .pipe(cleanCSS())
        .on('error', logError)
        .pipe(rename('style.min.css'))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./public/css'));
});

gulp.task('scripts', function() {
    var appScripts = [
        './app/app.coffee',
        './app/routes.coffee',
        './app/services/*.coffee',
        './app/filters/*.coffee',
        './app/directives/*.coffee',
        './app/controllers/*.coffee'
    ];

    gulp.src(appScripts)
        .pipe(sourcemaps.init())
        .pipe(coffee({bare: true}))
        .on('error', logError)
        .pipe(concat('app.js'))
        .pipe(uglify())
        .on('error', logError)
        .pipe(rename('app.min.js'))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./public/js'));
});

gulp.task('dependencies', function() {

    gulp.src(cssFiles)
        .pipe(sourcemaps.init())
        .pipe(concat('dependencies.min.css'))
        .on('error', logError)
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./public/css'));

    gulp.src(jsFiles)
        .pipe(sourcemaps.init())
        .pipe(concat('dependencies.js'))
        .pipe(uglify())
        .on('error', logError)
        .pipe(rename('dependencies.min.js'))
        .pipe(sourcemaps.write('.'))
        .pipe(gulp.dest('./public/js'));
});

gulp.task('images', function() {
    gulp.src('./public/images/*')
        .pipe(imagemin({ progressive: true }))
        .on('error', logError)
        .pipe(gulp.dest('./public/images'));
});

gulp.task('fonts', function() {
    gulp.src('bower_components/fontawesome/fonts/*')
        .pipe(gulp.dest('./public/fonts'));
});

gulp.task('copy-files', function() {
    gulp.src('./public/images/*')
        .pipe(gulp.dest('dist/public/images'));
    gulp.src('./public/js/*')
        .pipe(gulp.dest('dist/public/js'));
    gulp.src('./public/css/*')
        .pipe(gulp.dest('dist/public/css'));
    gulp.src('./public/fonts/*')
        .pipe(gulp.dest('dist/public/fonts'));
    gulp.src(['./app/views/**/*'])
        .pipe(gulp.dest('dist/app/views'));
    gulp.src('./index.html')
        .pipe(gulp.dest('dist'));
});

gulp.task('watch', function() {
    gulp.watch(['./app/*.js', './app/**/*.js'], ['scripts']);
    gulp.watch(['./public/css/*.css'], ['styles']);
});

gulp.task('build', [
    'dependencies',
    'scripts',
    'styles',
    'images',
    'fonts',
    'copy-files'
]);