// Generated on 2013-10-21 using generator-webapp 0.4.3
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to recursively match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // Show elapsed time at the end
  require('time-grunt')(grunt);
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);

  // Project configuration.
  grunt.initConfig({
    // Metadata
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
      '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
      ' Licensed MIT */\n',

    // Configurable paths
    yeoman: {
      src: 'src',
      test: 'spec',
      dist: 'dist',
      site_src: 'site_src',
      site_dist: 'site_dist'
    },

    watch: {
      options: {
        interrupt: false
      },
      serve: {
        files: [
          '<%= yeoman.src %>/**/*.{coffee,scss}',
          '<%= yeoman.test %>/**/*.coffee'
        ],
        tasks: [
          'coffee:dist',
          'browserify:serve',
          'sass:serve'
        ]
      }
    },

    connect: {
      options: {
        port: 9500,
        // change this to '0.0.0.0' to access the server from outside
        hostname: '0.0.0.0'
      },
      serve: {
        options: {
          open: true,
          base: [
            '.tmp',
            '<%= yeoman.src %>',
            '<%= yeoman.site_src %>',
            'bower_components'
          ]
        }
      },
      dist: {
        options: {
          open: true,
          base: [
            '<%= yeoman.dist %>',
            '<%= yeoman.site_src %>',
            'bower_components'
          ]
        }
      }
    },

    coffee: {
      dist: {
        expand: true,
        cwd: '<%= yeoman.src %>/javascripts/',
        src: ['**/*.coffee'],
        dest: '.tmp/javascripts/',
        ext: '.js'
      },
      test: {
        expand: true,
        cwd: 'spec',
        src: ['**/*.coffee'],
        dest: '.tmp/spec/',
        ext: '.js'
      }
    },

    browserify: {
      dist: {
        src: ['.tmp/javascripts/**/*.js'],
        dest: '<%= yeoman.dist %>/<%= pkg.name %>.js'
      },
      serve: {
        src: ['.tmp/javascripts/**/*.js'],
        dest: '.tmp/<%= pkg.name %>.js'
      }
    },

    sass: {
      options: {
        style: 'expanded'
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.src %>/stylesheets/',
          src: ['**/*.scss', '!**/_*.scss'],
          dest: '<%= yeoman.dist %>/',
          ext: '.css'
        }]
      },
      serve: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.src %>/stylesheets/',
          src: ['**/*.scss', '!**/_*.scss'],
          dest: '.tmp/',
          ext: '.css'
        }]
      }
    },

    // Put files not handled in other tasks here
    copy: {
      test: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.test %>',
          dest: '.tmp/spec/',
          src: ['**/*.js']
        }]
      },
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.src %>',
          dest: '<%= yeoman.dist %>',
          src: ['fonts/**/*']
        }]
      },
      site: {
        files: [
          {
            expand: true,
            dot: true,
            cwd: '<%= yeoman.site_src %>',
            dest: '<%= yeoman.site_dist %>',
            src: ['**/*']
          },
          {
            expand: true,
            dot: true,
            cwd: 'bower_components',
            dest: '<%= yeoman.site_dist %>',
            src: ['**/*']
          },
          {
            expand: true,
            dot: true,
            cwd: '<%= yeoman.dist %>',
            dest: '<%= yeoman.site_dist %>',
            src: ['**/*']
          }
        ]
      }
    },

    uglify: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['**/*.js'],
          dest: '<%= yeoman.dist %>',
          ext: '.min.js'
        }]
      }
    },

    cssmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.dist %>',
          src: ['**/*.css'],
          dest: '<%= yeoman.dist %>',
          ext: '.min.css'
        }]
      }
    },

    jasmine: {
      options:{
        specs: [
          'bower_components/jquery/jquery.js',
          'bower_components/underscore/underscore.js',
          'bower_components/ttm-coffeescript-utilities/dist/ttm-coffeescript-utilities.js',
          'bower_components/ttm-coffeescript-math/dist/ttm-coffeescript-math.js',
          '<%= yeoman.dist %>/<%= pkg.name %>.js',
          'bower_components/jasmine-jquery/lib/jasmine-jquery.js',
          '.tmp/spec/support/spec_helpers.js',
          '.tmp/spec/**/*.js'
        ]
      },
      ci:{
        options: {
          junit:{
            path: 'tests',
            consolidate: true
          }
        }
      }
    },

    'gh-pages': {
      options: {
        base: '<%= yeoman.site_dist %>'
      },
      src: ['**']
    },

    clean: {
      serve: {
        src: '.tmp'
      },
      dist: {
        src: [
          '.tmp',
          '<%= yeoman.dist %>',
          '<%= yeoman.site_dist %>'
        ]
      }
    }
  });

  // Custom tasks
  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:serve',
      'coffee:dist',
      'sass:serve',
      'browserify:serve',
      'connect:serve',
      'watch'
    ]);
  });

  grunt.registerTask('build', [
    'clean:dist',
    'coffee:dist',
    'browserify:dist',
    'uglify',
    'sass:dist',
    'cssmin',
    'copy:dist'
  ]);

  grunt.registerTask('test', [
    'build',
    'coffee:test',
    'copy:test',
    'jasmine'
  ]);

  grunt.registerTask('pages', [
    'build',
    'copy:site',
    'gh-pages'
  ]);

  grunt.registerTask('default', ['build']);
};
