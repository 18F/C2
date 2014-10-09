module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    jasmine: {
      test: {
        src: [
        "./vendor/assets/javascripts/jquery.min.js",
        "./vendor/assets/javascripts/underscore-min.js",
        "./vendor/assets/javascripts/backbone-min.js",
        "./vendor/assets/javascripts/backbone-localstorage.js",
        "./app/assets/javascripts/overlay/overlay.js.erb"
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