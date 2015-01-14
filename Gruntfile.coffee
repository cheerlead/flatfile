
module.exports = (grunt) ->

	grunt.loadNpmTasks('grunt-simple-mocha')

	@initConfig
		pkg: grunt.file.readJSON('package.json'),
		simplemocha:
			options:
				globals: ['expect', 'confidence']
				timeout: 3000
				ignoreLeaks: false
				ui: 'bdd'
				reporter: 'spec'
				#grep: 'Combine'

			all: { src: ['test/*.coffee'] }

	@registerTask "default", ["simplemocha"]

