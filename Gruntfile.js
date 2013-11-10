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
      bower: 'bower_components',
      src: 'src',
      test: 'spec',
      dist: 'dist',
      site: 'site'
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

    connect: {
      options: {
        port: 9000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      },
      serve: {
        options: {
          open: true,
          base: [
            '<%= yeoman.site %>',
            '<%= yeoman.dist %>'
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

    sass: {
      dist: {
        options: {
          style: 'expanded'
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.src %>/stylesheets/',
          src: [
            '**/*.scss',
            // contrib-sass doesn't currently ignore partials so we have to
            // manually. https://github.com/gruntjs/grunt-contrib-sass/issues/72
            '!**/_*.scss'
            ],
          dest: '.tmp/stylesheets/',
          ext: '.css'
        }]
      }
    },

    concat: {
      options: {
        banner: '<%= banner %>',
        stripBanners: true,
      },
      dist: {
        files: {
          '<%= yeoman.dist %>/<%= pkg.name %>.js': ['.tmp/**/*.js'],
          '<%= yeoman.dist %>/<%= pkg.name %>.css': ['.tmp/**/*.css']
        }
      },
      serve: {
        files: {
          '.tmp/<%= pkg.name %>.js': ['.tmp/**/*.js'],
          '.tmp/<%= pkg.name %>.css': ['.tmp/**/*.css']
        }
      }
    },

    copy: {
      test: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= yeoman.test %>',
          dest: '.tmp/spec/',
          src: [
            '**/*.js',
          ]
        }]
      },
      site: {
        files: [
          {
            expand: true,
            dot: true,
            cwd: '<%= yeoman.site %>',
            dest: '<%= yeoman.dist %>',
            src: [
              '**/*',
            ]
          },
          {
            expand: true,
            dot: true,
            cwd: '<%= yeoman.bower %>',
            dest: '<%= yeoman.dist %>',
            src: [
              '**/*',
            ]
          },
        ]
      }
    },

    browserify: {
      dist: {
        src: '.tmp/javascripts/browser.js',
        dest: '<%= yeoman.dist %>/<%= pkg.name %>.js'
      }
    },

    clean: {
      options: {
        // "no-write": true
      },
      server: {
        src: '.tmp'
      },
      dist: {
        src: '<%= yeoman.dist %>'
      }
    },

    jasmine: {
      specs: [
        '<%= yeoman.bower %>/jquery/jquery.js',
        '<%= yeoman.bower %>/underscore/underscore.js',
        '<%= yeoman.bower %>/ttm-coffeescript-utilities/dist/ttm-coffeescript-utilities.js',
        '<%= yeoman.bower %>/ttm-coffeescript-math/dist/ttm-coffeescript-math.js',
        '.tmp/spec/support/jasmine-jquery.js',
        '<%= yeoman.dist %>/<%= pkg.name %>.js',
        '.tmp/spec/support/spec_helpers.js',
        '.tmp/spec/**/*.js'
      ]
    },

    uglify: {
      dist: {
        files: {
          '<%= yeoman.dist %>/<%= pkg.name %>.min.js': '<%= yeoman.dist %>/<%= pkg.name %>.js'
        }
      }
    },

    cssmin: {
      dist: {
        files: {
          '<%= yeoman.dist %>/<%= pkg.name %>.min.css': '<%= yeoman.dist %>/<%= pkg.name %>.css'
        }
      }
    },

    'gh-pages': {
      options: {
        base: '<%= yeoman.dist %>'
      },
      src: ['**']
    }
  });

  // Tasks
  grunt.registerTask('serve', ['build', 'connect:serve:keepalive']);

  grunt.registerTask('watch-serve', [
    'connect:serve', 'watch'
  ]);

  grunt.registerTask('build', [
    'clean',
    'coffee',
    'sass',
    'concat',
    'copy:spec',
    'browserify',
    'uglify',
    'cssmin',
    'copy:site'
  ]);

  grunt.registerTask('test', [
    'build',
    'jasmine'
  ]);

  grunt.registerTask('default', ['build']);
};
