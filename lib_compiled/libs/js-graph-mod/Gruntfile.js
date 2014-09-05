"use strict";

module.exports = function (grunt) {

	//// loading grunt plugins

	[ 'grunt-contrib-uglify',
	  'grunt-contrib-compress',
	  'grunt-contrib-watch',
	  'grunt-contrib-copy',
	  'grunt-karma',
	  'grunt-coveralls'
	].map(grunt.loadNpmTasks);


	grunt.initConfig({


		////////////////////////////
		//// Define Directories ////
		////////////////////////////


		dirs: {
			js:    "src",
			build: "dist"
		},


		//////////////////
		//// Metadata ////
		//////////////////


		pkg:         grunt.file.readJSON("package.json"),
		banner: "\n" +
		        "/*\n" +
		        " * -------------------------------------------------------\n" +
		        " * Project: <%= pkg.title %>\n" +
		        " * Version: <%= pkg.version %>\n" +
		        " *\n" +
		        " * Author:  <%= pkg.author.name %>\n" +
		        " * Site:    <%= pkg.author.url %>\n" +
		        " * Contact: <%= pkg.author.email %>\n" +
		        " *\n" +
		        " *\n" +
		        " * Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>\n" +
		        " * -------------------------------------------------------\n" +
		        " */\n" +
		        "\n",
		smallBanner: "/* <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\"yyyy-mm-dd\") %> */",


		////////////////////////////////////////
		//// Copying file to dist directory ////
		////////////////////////////////////////


		copy: {
			source: {
				files: [
					{
						expand:  true,
						flatten: true,
						src:     "<%= dirs.js %>/<%= pkg.name %>.js",
						dest:    "<%= dirs.build %>"
					}
				]
			},
			lcov: {
				files: [
					{
						expand:  true,
						flatten: true,
						src:     ["coverage/*/lcov.info"],
						dest:    "coverage"
					}
				]
			}
		},


		//////////////////////
		//// Minification ////
		//////////////////////


		uglify: {
			dist: {
				options: {
					banner:    "<%= smallBanner %>",
					sourceMap: true,
					report:    'gzip'
				},
				files:   {
					"<%= dirs.build %>/<%= pkg.name %>.min.js": "<%= dirs.js %>/<%= pkg.name %>.js"
				}
			}
		},


		/////////////////////
		//// Compression ////
		/////////////////////


		compress: {
			dist: {
				options: { mode: 'gzip' },
				src:     "<%= dirs.build %>/<%= pkg.name %>.min.js",
				dest:    "<%= dirs.build %>/<%= pkg.name %>.min.js.gz"
			}
		},


		/////////////////
		//// Testing ////
		/////////////////


		karma: {
			options: {
				basePath:   '',
				frameworks: [ 'jasmine', 'requirejs' ],
				exclude:    [],
				runnerPort: 9876,
				colors:     true,
				logLevel:   'INFO',
				autoWatch:  false,
				browsers:   ['PhantomJS'],
				singleRun:  true
			},
			dev:     {
				options: {
					files:            [ 'spec/main-dev.js', {pattern: '**/*.js', included: false} ],
					reporters:        ['progress', 'coverage'],
					preprocessors:    { 'src/**/*.js': ['coverage'] },
					coverageReporter: {
						reporters: [
							{ type: 'text-summary' },
							{ type: 'lcovonly'}
						]
					}
				}
			},
			dist:    {
				options: {
					files:     [ 'spec/main-dist.js', {pattern: '**/*.js', included: false} ],
					reporters: ['progress']
				}
			}
		},


		//////////////////
		//// Coverage ////
		//////////////////

		coveralls: {
			dev:  {
				src:     'coverage/lcov.info',
				options: {
					force: true
				}
			}
		}


	});


	////////////////////////
	//// Register Tasks ////
	////////////////////////


	grunt.registerTask("test:dev", [ "karma:dev"  ]);
	grunt.registerTask("test:dist", [ "karma:dist" ]);

	grunt.registerTask("coverage:dev", [ "copy:lcov", "coveralls:dev"  ]);

	grunt.registerTask("dist", [ "copy:source", "uglify:dist", "compress:dist" ]);

};
