'use strict';

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define([], function () {////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	beforeEach(function () {
		(jasmine.addMatchers ? jasmine : this).addMatchers({
			toBeReachable: function () {
				return {
					compare: function () {
						var result = {};
						result.message = "Expected this test not to be reachable.";
						result.pass = true;
						return result;
					}
				};
			},
			toThrowSpecific: function () {
				var util = arguments[0]; // using 'arguments' to avoid argument count warning
				var customEqualityTesters = arguments[1];
				return {
					compare: function (actual, expectedType, expectedContent) {
						var result = {};
						result.message = "";

						if (typeof expectedContent === 'undefined') {
							expectedContent = {};
						}

						try {
							actual();
							result.pass = false;
						} catch (exception) {
							result.pass = exception instanceof expectedType;
							if (result.pass) {
								Object.keys(expectedContent).map(function (prop) {
									result.pass = result.pass && util.equals(expectedContent[prop], exception[prop], customEqualityTesters);
								});
								result.message = "However, the thrown " + expectedType.prototype.name + " had the following properties: " + JSON.stringify(exception, undefined, ' ');
							} else {
								result.message = "However, the thrown exception was not a subclass of " + expectedType.prototype.name + ".";
							}
						}

						result.message = "Expected the function to throw a new " + expectedType.prototype.name + " with the following properties: " +
						                 JSON.stringify(expectedContent, undefined, ' ') + ". " + result.message;

						return result;
					}
				};
			},
			toEqualOneOf: function () {
				var util = arguments[0]; // using 'arguments' to avoid argument count warning
				var customEqualityTesters = arguments[1];
				return {
					compare: function () {
						var actual = arguments[0];
						var candidates = Array.prototype.slice.call(arguments, 1);
						var result = {};

						result.pass = candidates.some(function (candidate) {
							return util.equals(actual, candidate, customEqualityTesters);
						});

						if (!result.pass) {
							result.message = "Expected " + JSON.stringify(actual) + " to equal one of: " +
							                 candidates.map(function (c) {return JSON.stringify(c);}).join(', ');
						}

						return result;
					}
				};
			}
		});
	});

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
});/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
