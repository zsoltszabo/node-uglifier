var allTestFiles = [];
var TEST_REGEXP = /\w+\-spec\.js$/i;

var pathToModule = function (path) {
	return path.replace(/^\/base\//, '').replace(/\.js$/, '');
};

Object.keys(window.__karma__.files).forEach(function (file) {
	if (TEST_REGEXP.test(file)) {
		allTestFiles.push(pathToModule(file));
	}
});

require.config({
	baseUrl: '/base',
	deps:     allTestFiles,
	callback: window.__karma__.start,
	paths:    {
		'matchers': 'spec/matchers',
		'js-graph': 'src/js-graph'
	}
});

console.info('running development unit-tests');
