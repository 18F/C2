module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    jasmine: {
      test: {
        src: 'scripts/*.js',
        options: {
          specs: 'test/*.spec.js'
        }
      }
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-contrib-jasmine');

  // Default task(s)
  grunt.registerTask('default', ['jasmine']);

};