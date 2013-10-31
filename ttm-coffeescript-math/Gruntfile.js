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
    // configurable paths
    yeoman: {
      bower: 'bower_components',
      src: 'src',
      test: 'spec',
      out: '.tmp',
      dist: 'dist',
      site: 'site'
    },
    coffee: {
      lib: {
        expand: true,
        cwd: '<%= yeoman.src %>/',
        src: ['**/*.coffee'],
        dest: '<%= yeoman.out %>/src/',
        ext: '.js'
      },
      test: {
        expand: true,
        cwd: 'spec',
        src: ['**/*.coffee'],
        dest: '<%= yeoman.out %>/spec/',
        ext: '.js'
      }
    },

    // Put files not handled in other tasks here
    copy: {
      out: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.src %>',
          dest: '<%= yeoman.out %>',
          src: [
            '**/*.js',
          ]
        }]
      },
      spec: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.test %>',
          dest: '<%= yeoman.out %>/spec/',
          src: [
            '**/*.js',
          ]
        }]
      },
    },

    browserify: {
      dist: {
        src: '<%= yeoman.out %>/src/browser.js',
        dest: '<%= yeoman.dist %>/<%= pkg.name %>.js'
      }
    },
    clean: {
      options: {
      },
      all: {
        files: [{
          dot: true,
          src: [
            '<%= yeoman.out %>',
            '<%= yeoman.dist %>'
          ]
        }]
      }
    },
    jasmine: {
      specs: [
        '<%= yeoman.bower %>/underscore/underscore.js',
        '<%= yeoman.bower %>/ttm-coffeescript-utilities/dist/ttm-coffeescript-utilities.js',
        '<%= yeoman.dist %>/<%= pkg.name %>.js',
        '<%= yeoman.out %>/spec/spec_helpers.js',
        // '<%= yeoman.out %>/spec/**/*.js',
        '<%= yeoman.out %>/spec/build_expression_from_javascript_object_spec.js',
      ]
    },

    watch: {
      coffee: {
        files: [
          '<%= yeoman.src %>/**/*.{coffee,scss}',
          '<%= yeoman.test %>/**/*.coffee',
        ],
        tasks: ['build'],
        options: {
          interrupt: false
        }
      }
    },

    uglify: {
      dist: {
        files: {
          '<%= yeoman.dist %>/<%= pkg.name %>.min.js': '<%= yeoman.dist %>/<%= pkg.name %>.js'
        }
      }
    },

  });


  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('watch-serve', [
    'connect:serve', 'watch'
  ]);


  grunt.registerTask('build', [
    'clean',
    'coffee',
    'copy:out',
    'copy:spec',
    'browserify',
    'uglify',
  ]);



  grunt.registerTask('test', [
    'build',
    'jasmine'
  ]);


  grunt.registerTask('serve', ['build', 'connect:serve:keepalive']);

  grunt.registerTask('default', ['build']);


};
