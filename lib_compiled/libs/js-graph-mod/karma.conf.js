'use strict';

module.exports = function (config) {
	config.set({
		basePath:      '',
		frameworks:    [ 'jasmine', 'requirejs' ],
		files:         [ 'spec/main-dev.js', {pattern: '**/*.js', included: false} ],
		exclude:       [],
		preprocessors: { 'src/**/*.js': ['coverage'] },
		reporters:     ['progress'],
		port:          9876,
		colors:        true,
		logLevel:      config.LOG_INFO,
		autoWatch:     false,
		browsers:      ['Chrome'],
		singleRun:     true
	});
};
