module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      reset:
        src: ['bin']
      temp:
        src: ['temp']

    coffeeLint: 
      scripts:
        files: [
          {
            expand: true
            src: ['client/**/*.coffee', '!client/js/components/**']
          }
          {
            expand: true
            src: ['server/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'
      tests:
        files: [
          {
            expand: true
            src: ['test/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'
    coffee:
      scripts:
        expand: true
        cwd: 'client'
        src: ['**/*.coffee']
        dest: 'temp/client/js/'
        ext: '.js'
        options:
          bare: true

    ngTemplateCache:
      views:
        files:
          './temp/client/js/views.js': './client/views/*.html'
        options:
          trim: './client'
    copy:
      views:
        src: 'temp/client/js/views.js'
        dest: 'bin/views.js'

    requirejs:
      scripts:
        options:
          baseUrl: 'temp/client/js/'
          findNestedDependencies: true
          logLevel: 0
          mainConfigFile: 'temp/client/js/main.js'
          name: 'main'
          onBuildWrite: (moduleName, path, contents) ->
            modulesToExclude = ['main']
            shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0

            if (shouldExcludeModule)
              return ''

            return contents
          optimize: 'none'
          out: 'bin/gint-security.js'
          preserveLicenseComments: false
          skipModuleInsertion: true
          uglify:
            no_mangle: false
    watch:
      dev:
        files: ['client/**', 'server/**']
        tasks: ['default']
      html:
        files: ['client/views/*.html']
        tasks: ['ngTemplateCache', 'copy:views', 'karma:unit:run']
      mochaTests:
        files: ['test/server/**/*.coffee']
        tasks: ['coffeeLint:tests', 'mocha:unit']
      unitTests:
        files: ['test/client/**/*.coffee']
        tasks: ['coffeeLint:tests', 'karma:unit:run']

    mocha:
      unit:
        expand: true
        src: ['test/server/**/*_test.coffee']
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          reporter: 'spec'
          growl: true
      travis:
        expand: true
        src: ['test/server/**/*_test.coffee']
        options:
          globals: ['should']
          timeout: 3000
          ignoreLeaks: false
          reporter: 'dot'   

    karma:
      unit:
        configFile: 'test/karma.conf.js'
        reporters: ['dots', 'growl']
      travis:
        configFile: 'test/karma.conf.js'
        singleRun: true
        browsers: [ 'PhantomJS' ]

  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-karma'

  grunt.registerTask 'build'
  , ['clean', 'coffeeLint', 'coffee', 'ngTemplateCache','requirejs', 'copy', 'clean:temp']

  grunt.registerTask 'default'
  , ['build', 'mocha:unit', 'karma:unit:run']

  grunt.registerTask 'travis'
  , ['build', 'mocha:travis', 'karma:travis' ]

  grunt.registerTask 'run'
  , [ 'default', 'watch']