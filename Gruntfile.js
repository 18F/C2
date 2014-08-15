module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    jasmine: {
      test: {
        src: [
        "./public/javascripts/jquery.min.js",
        "./public/javascripts/underscore-min.js",
        "./public/javascripts/backbone-min.js",
        "./public/javascripts/backbone-localstorage.js",
        "./public/javascripts/overlay.js"
        ],

        options: {
          specs: ['./spec/javascripts/**/*_spec.js']
        }
      }
    }
  });

  // Load the plugin that provides the tasks
  grunt.loadNpmTasks('grunt-contrib-jasmine');

  // Default task(s)
  grunt.registerTask('default', ['jasmine']);
  grunt.registerTask('travis', ['jasmine']);

};