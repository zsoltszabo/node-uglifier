'use strict';

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define([".", "matchers"], function (Graph) {////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	var graph;

	beforeEach(function () {
		graph = new Graph();
	});



	describe("method", function () {////////////////////////////////////////////////////////////////////////////////


		var methodUnderTest = "";

		function describeMethod(method, fn) {
			describe("'" + method + "'", function () {
				beforeEach(function () {
					methodUnderTest = method;
				});
				it("is present", function () {
					expect(typeof graph[methodUnderTest]).toBe('function');
				});
				fn();
			});
		}

		function callItWith() {
			return graph[methodUnderTest].apply(undefined, arguments);
		}

		function expectItWhenBoundWith() {
			var args = arguments;
			return expect(function () {
				graph[methodUnderTest].apply(undefined, args);
			});
		}

		function expectItWhenCalledWith() {
			var args = Array.prototype.slice.call(arguments, 0);
			return expect(graph[methodUnderTest].apply(undefined, args));
		}


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		var originalVertices, originalEdges, originalVertexCount, originalEdgeCount;


		function expectTheGraphNotToHaveChanged() {
			var vertices = {};
			graph.eachVertex(function (key, value) {
				vertices[key] = value;
			});
			expect(vertices).toEqual(originalVertices);

			var edges = {};
			graph.eachEdge(function (from, to, value) {
				edges[from + ", " + to] = value;
			});
			expect(edges).toEqual(originalEdges);
		}


		beforeEach(function () {
			//// the original graph:
			//
			graph.addNewVertex('k1', 'oldValue1');
			graph.addNewVertex('k2');
			graph.addNewVertex('k3');
			graph.addNewVertex('k4');
			graph.addNewVertex('k5', 'oldValue5');
			graph.addNewEdge('k2', 'k3', 'oldValue23');
			graph.addNewEdge('k3', 'k4');
			graph.addNewEdge('k2', 'k5');
			graph.addNewEdge('k5', 'k3');

			// k1     k2 --> k3 --> k4
			//        |      ^
			//        |      ;
			//        V     /
			//        k5 __/

			//// some preliminary work to more easily 'expect' things about the original graph:
			//
			originalVertices = {
				'k1': 'oldValue1',
				'k2': undefined,
				'k3': undefined,
				'k4': undefined,
				'k5': 'oldValue5'
			};
			originalEdges = {
				'k2, k3': 'oldValue23',
				'k3, k4': undefined,
				'k2, k5': undefined,
				'k5, k3': undefined
			};
			originalVertexCount = Object.keys(originalVertices).length;
			originalEdgeCount = Object.keys(originalEdges).length;

			//// and we now 'expect' that those variables are set correctly
			//
			expectTheGraphNotToHaveChanged();
		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('vertexCount', function () {

			it("throws nothing", function () {
				expectItWhenBoundWith().not.toThrow();
			});

			it("returns the number of vertices in the graph", function () {
				expectItWhenCalledWith().toBe(originalVertexCount);
			});

		});


		describeMethod('edgeCount', function () {

			it("throws nothing", function () {
				expectItWhenBoundWith().not.toThrow();
			});

			it("returns the number of edges in the graph", function () {
				expectItWhenCalledWith().toBe(originalEdgeCount);
			});

		});


		describeMethod('hasVertex', function () {

			it("throws nothing when passed a key argument", function () {
				expectItWhenBoundWith('k1').not.toThrow();
				expectItWhenBoundWith('newKey').not.toThrow();
			});

			it("returns a truthy value for an existing vertex", function () {
				expectItWhenCalledWith('k1').toBeTruthy();
				expectItWhenCalledWith('k2').toBeTruthy();
			});

			it("returns a falsy value for an absent vertex", function () {
				expectItWhenCalledWith('newKey').toBeFalsy();
			});

		});


		describeMethod('hasEdge', function () {

			it("throws nothing when passed two key arguments", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('newKey', 'k2').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').not.toThrow();
			});

			it("returns a truthy value for an existing edge", function () {
				expectItWhenCalledWith('k2', 'k3').toBeTruthy();
				expectItWhenCalledWith('k3', 'k4').toBeTruthy();
			});

			it("returns a falsy value for an absent edge", function () {
				expectItWhenCalledWith('k1', 'k2').toBeFalsy();
				expectItWhenCalledWith('k3', 'k2').toBeFalsy();
				expectItWhenCalledWith('newKey', 'k2').toBeFalsy();
				expectItWhenCalledWith('newKey1', 'newKey2').toBeFalsy();
			});

		});


		describeMethod('vertexValue', function () {

			it("throws nothing when passed a key argument", function () {
				expectItWhenBoundWith('k1').not.toThrow();
				expectItWhenBoundWith('k2').not.toThrow();
				expectItWhenBoundWith('newKey').not.toThrow();
			});

			it("returns the proper value belonging to a vertex", function () {
				expectItWhenCalledWith('k1').toBe('oldValue1');
			});

			it("returns the 'undefined' value for vertices with no value", function () {
				expectItWhenCalledWith('k2').toBeUndefined();
			});

			it("returns the 'undefined' value for absent vertices", function () {
				expectItWhenCalledWith('newKey').toBeUndefined();
			});

		});


		describeMethod('edgeValue', function () {

			it("throws nothing when passed two key arguments", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('newKey', 'k2').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').not.toThrow();
			});

			it("returns the proper value belonging to an edge", function () {
				expectItWhenCalledWith('k2', 'k3').toBe('oldValue23');
			});

			it("returns the 'undefined' value for edges with no value", function () {
				expectItWhenCalledWith('k3', 'k4').toBeUndefined();
			});

			it("returns the 'undefined' value for absent edges", function () {
				expectItWhenCalledWith('k1', 'k2').toBeUndefined();
				expectItWhenCalledWith('k3', 'k2').toBeUndefined();
				expectItWhenCalledWith('newKey', 'k2').toBeUndefined();
				expectItWhenCalledWith('newKey1', 'newKey2').toBeUndefined();
			});

		});


		describeMethod('eachVertex', function () {

			it("throws nothing when passed a non-throwing function", function () {
				expectItWhenBoundWith(function () {/*not throwing things*/}).not.toThrow();
			});

			it("does not change the graph if the specified handler doesn't", function () {
				callItWith(function () {
					// not changing the graph from here
				});
				expectTheGraphNotToHaveChanged();
			});

			it("calls the specified handler exactly once for each vertex in the graph", function () {
				var verticesFound = {};
				callItWith(function (key, value) {
					expect(verticesFound[key]).toBeUndefined();
					verticesFound[key] = value;
				});
				expect(verticesFound).toEqual(originalVertices);
			});

		});


		describeMethod('eachVertexFrom', function () {

			it("throws an error if the given vertex does not exist", function () {
				expectItWhenBoundWith('newKey', function () {}).toThrow();
				expectItWhenBoundWith('newKey', function () {}).toThrowSpecific(Graph.VertexNotExistsError, {'newKey': undefined});
			});

			it("throws nothing if the given vertex exists", function () {
				expectItWhenBoundWith('k1', function () {}).not.toThrow();
			});

			it("does not change the graph if the specified handler doesn't", function () {
				callItWith('k2', function () {
					// not changing the graph from here
				});
				expectTheGraphNotToHaveChanged();
			});

			it("calls the specified handler exactly once for each outgoing edge, providing the connected vertex key/value and edge value", function () {
				var valuesFound = {};
				callItWith('k2', function (key, value, edgeValue) {
					expect(valuesFound[key]).toBeUndefined();
					valuesFound[key] = [value, edgeValue];
				});
				expect(valuesFound).toEqual({
					'k3': [undefined, 'oldValue23'],
					'k5': ['oldValue5', undefined]
				});
			});

		});


		describeMethod('eachVertexTo', function () {

			it("throws an error if the given vertex does not exist", function () {
				expectItWhenBoundWith('newKey', function () {}).toThrow();
				expectItWhenBoundWith('newKey', function () {}).toThrowSpecific(Graph.VertexNotExistsError, {'newKey': undefined});
			});

			it("throws nothing if the given vertex exists", function () {
				expectItWhenBoundWith('k1', function () {}).not.toThrow();
			});

			it("does not change the graph if the specified handler doesn't", function () {
				callItWith('k3', function () {
					// not changing the graph from here
				});
				expectTheGraphNotToHaveChanged();
			});

			it("calls the specified handler exactly once for each incoming edge, providing the connected vertex key/value and edge value", function () {
				var valuesFound = {};
				callItWith('k3', function (key, value, edgeValue) {
					expect(valuesFound[key]).toBeUndefined();
					valuesFound[key] = [value, edgeValue];
				});
				expect(valuesFound).toEqual({
					'k2': [undefined, 'oldValue23'],
					'k5': ['oldValue5', undefined]
				});
			});

		});


		describeMethod('eachEdge', function () {

			it("throws nothing when passed a non-throwing function", function () {
				expectItWhenBoundWith(function () {/*not throwing things*/}).not.toThrow();
			});

			it("does not change the graph if the specified handler doesn't", function () {
				callItWith(function () {
					// not changing the graph from here
				});
				expectTheGraphNotToHaveChanged();
			});

			it("calls the specified handler exactly once for each edge in the graph", function () {
				var edgesFound = {};
				callItWith(function (from, to, value) {
					var key = from + ", " + to;
					expect(edgesFound[key]).toBeUndefined();
					edgesFound[key] = value;
				});
				expect(edgesFound).toEqual(originalEdges);
			});

		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		function it_throwsErrorIfVertexExists() {
			it("throws an error if a vertex with the given key already exists", function () {
				expectItWhenBoundWith('k1').toThrow();
				expectItWhenBoundWith('k2').toThrow();
				expectItWhenBoundWith('k1').toThrowSpecific(Graph.VertexExistsError, { vertices: {'k1': 'oldValue1'} });
				expectItWhenBoundWith('k2').toThrowSpecific(Graph.VertexExistsError, { vertices: {'k2': undefined} });
			});
		}

		function it_throwsErrorIfVertexDoesNotExist() {
			it("throws an error if a vertex with the given key does not exist", function () {
				expectItWhenBoundWith('newKey').toThrow();
				expectItWhenBoundWith('newKey').toThrowSpecific(Graph.VertexNotExistsError, { vertices: {'newKey': undefined} });
			});
		}

		function it_throwsErrorIfEdgesAreConnected() {
			it("throws an error if there are edges connected to that vertex", function () {
				expectItWhenBoundWith('k2').toThrow();
				expectItWhenBoundWith('k3').toThrow();
				expectItWhenBoundWith('k4').toThrow();
				expectItWhenBoundWith('k2').toThrowSpecific(Graph.HasConnectedEdgesError, { key: 'k2' });
				expectItWhenBoundWith('k3').toThrowSpecific(Graph.HasConnectedEdgesError, { key: 'k3' });
				expectItWhenBoundWith('k4').toThrowSpecific(Graph.HasConnectedEdgesError, { key: 'k4' });
			});
		}

		function it_throwsNothingIfVertexDoesNotExist() {
			it("throws no exceptions if a vertex with that key does not exist", function () {
				expectItWhenBoundWith('newKey').not.toThrow();
			});
		}

		function it_throwsNothingIfVertexExists() {
			it("throws no exceptions if a vertex with that key exists", function () {
				expectItWhenBoundWith('k3').not.toThrow();
			});
		}

		function it_throwsNothingIfUnconnectedVertexExists() {
			it("throws no exceptions if a vertex with that key exists, not connected to any edges", function () {
				expectItWhenBoundWith('k1').not.toThrow();
			});
		}

		function it_throwsNothingWhenPassedAKey() {
			it("throws no exceptions when it is passed a single key argument", function () {
				expectItWhenBoundWith('k1').not.toThrow();
				expectItWhenBoundWith('newKey').not.toThrow();
			});
		}

		function it_throwsNothingWhenPassedAKeyAndValue() {
			it("throws no exceptions when it is passed a key and a value argument", function () {
				expectItWhenBoundWith('k1', 'newValue').not.toThrow();
				expectItWhenBoundWith('newKey', 'newValue').not.toThrow();
			});
		}


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		function it_leavesNewVertexWithNewValue() {
			it("leaves a new vertex in the graph with a new value", function () {
				callItWith('newKey', 'newValue');
				expect(graph.hasVertex('newKey')).toBeTruthy();
				expect(graph.vertexValue('newKey')).toBe('newValue');
				expect(graph.vertexCount()).toBe(originalVertexCount + 1);
			});
		}

		function it_leavesNewVertexWithNewUndefinedValue() {
			it("leaves a new vertex in the graph with a new 'undefined' value", function () {
				callItWith('newKey');
				expect(graph.hasVertex('newKey')).toBeTruthy();
				expect(graph.vertexValue('newKey')).toBeUndefined();
				expect(graph.vertexCount()).toBe(originalVertexCount + 1);
			});
		}

		function it_leavesExistingVertexWithNewValue() {
			it("leaves an existing vertex in the graph with a new value", function () {
				callItWith('k1', 'newValue');
				expect(graph.hasVertex('k1')).toBeTruthy();
				expect(graph.vertexValue('k1')).toBe('newValue');
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});
		}

		function it_leavesExistingVertexWithNewUndefinedValue() {
			it("leaves an existing vertex in the graph with a new 'undefined' value", function () {
				callItWith('k1');
				expect(graph.hasVertex('k1')).toBeTruthy();
				expect(graph.vertexValue('k1')).toBeUndefined();
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});
		}

		function it_leavesExistingVertexWithOldValue() {
			it("leaves an existing vertex in the graph with its old value", function () {
				callItWith('k1', 'newValue');
				expect(graph.hasVertex('k1')).toBeTruthy();
				expect(graph.vertexValue('k1')).toBe('oldValue1');
				expect(graph.vertexCount()).toBe(originalVertexCount);
				callItWith('k1', undefined);
				expect(graph.hasVertex('k1')).toBeTruthy();
				expect(graph.vertexValue('k1')).toBe('oldValue1');
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});
		}

		function it_leavesExistingVertexWithOldUndefinedValue() {
			it("leaves an existing vertex in the graph with its old 'undefined' value", function () {
				callItWith('k2', 'newValue');
				expect(graph.hasVertex('k2')).toBeTruthy();
				expect(graph.vertexValue('k2')).toBeUndefined();
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});
		}

		function it_leavesExistingVertexAbsent() {
			it("leaves an existing vertex absent from the graph", function () {
				callItWith('k1');
				expect(graph.hasVertex('k1')).toBeFalsy();
				expect(graph.vertexCount()).toBe(originalVertexCount - 1);
			});
		}

		function it_leavesConnectedEdgesAbsent() {
			it("leaves existing connected edges absent from the graph", function () {
				callItWith('k3');
				expect(graph.hasEdge('k2', 'k3')).toBeFalsy();
				expect(graph.hasEdge('k3', 'k4')).toBeFalsy();
				expect(graph.hasEdge('k4', 'k3')).toBeFalsy();
				expect(graph.edgeCount()).toBe(originalEdgeCount - 3);
			});
		}

		function it_leavesAbsentVertexAbsent() {
			it("leaves an absent vertex absent from the graph", function () {
				callItWith('newKey');
				expect(graph.hasVertex('newKey')).toBeFalsy();
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});
		}


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('addNewVertex', function () {
			it_throwsErrorIfVertexExists();
			it_throwsNothingIfVertexDoesNotExist();
			it_leavesNewVertexWithNewValue();
			it_leavesNewVertexWithNewUndefinedValue();
		});

		describeMethod('setVertex', function () {
			it_throwsErrorIfVertexDoesNotExist();
			it_throwsNothingIfVertexExists();
			it_leavesExistingVertexWithNewValue();
			it_leavesExistingVertexWithNewUndefinedValue();
		});

		describeMethod('ensureVertex', function () {
			it_throwsNothingWhenPassedAKey();
			it_throwsNothingWhenPassedAKeyAndValue();
			it_leavesNewVertexWithNewValue();
			it_leavesNewVertexWithNewUndefinedValue();
			it_leavesExistingVertexWithOldValue();
			it_leavesExistingVertexWithOldUndefinedValue();
		});

		describeMethod('addVertex', function () {
			it_throwsNothingWhenPassedAKey();
			it_throwsNothingWhenPassedAKeyAndValue();
			it_leavesNewVertexWithNewValue();
			it_leavesNewVertexWithNewUndefinedValue();
			it_leavesExistingVertexWithNewValue();
			it_leavesExistingVertexWithNewUndefinedValue();
		});

		describeMethod('removeExistingVertex', function () {
			it_throwsErrorIfVertexDoesNotExist();
			it_throwsErrorIfEdgesAreConnected();
			it_throwsNothingIfUnconnectedVertexExists();
			it_leavesExistingVertexAbsent();
		});

		describeMethod('destroyExistingVertex', function () {
			it_throwsErrorIfVertexDoesNotExist();
			it_throwsNothingIfVertexExists();
			it_leavesExistingVertexAbsent();
			it_leavesConnectedEdgesAbsent();
		});

		describeMethod('removeVertex', function () {
			it_throwsErrorIfEdgesAreConnected();
			it_throwsNothingIfUnconnectedVertexExists();
			it_leavesExistingVertexAbsent();
			it_leavesAbsentVertexAbsent();
		});

		describeMethod('destroyVertex', function () {
			it_throwsNothingWhenPassedAKey();
			it_leavesExistingVertexAbsent();
			it_leavesAbsentVertexAbsent();
			it_leavesConnectedEdgesAbsent();
		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		function it_throwsErrorIfEdgeExists() {
			it("throws an error if an edge with the given keys already exists", function () {
				expectItWhenBoundWith('k2', 'k3').toThrow();
				expectItWhenBoundWith('k3', 'k4').toThrow();
				expectItWhenBoundWith('k2', 'k3').toThrowSpecific(Graph.EdgeExistsError, { edges: {'k2': {'k3': 'oldValue23'}} });
				expectItWhenBoundWith('k3', 'k4').toThrowSpecific(Graph.EdgeExistsError, { edges: {'k3': {'k4': undefined}} });
			});
		}

		function it_throwsErrorIfEdgeDoesNotExist() {
			it("throws an error if an edge with the given keys does not exist", function () {
				expectItWhenBoundWith('k1', 'k2').toThrow();
				expectItWhenBoundWith('k1', 'k2').toThrowSpecific(Graph.EdgeNotExistsError, { edges: {'k1': {'k2': undefined}} });
			});
		}

		function it_throwsErrorIfVerticesDoNotExist() {
			it("throws an error if the required vertices do not exist", function () {
				expectItWhenBoundWith('newKey1', 'newKey2').toThrow();
				expectItWhenBoundWith('k1', 'newKey3').toThrow();
				expectItWhenBoundWith('newKey4', 'k2').toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').toThrowSpecific(Graph.VertexNotExistsError, { vertices: {'newKey1': undefined, 'newKey2': undefined} });
				expectItWhenBoundWith('k1', 'newKey3').toThrowSpecific(Graph.VertexNotExistsError, { vertices: {'newKey3': undefined} });
				expectItWhenBoundWith('newKey4', 'k2').toThrowSpecific(Graph.VertexNotExistsError, { vertices: {'newKey4': undefined} });
			});
		}

		function it_throwsNothingIfEdgeDoesNotExist() {
			it("throws nothing if the edge does not exist", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').not.toThrow();
			});
		}

		function it_throwsNothingIfEdgeExists() {
			it("throws nothing if the edge exists", function () {
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('k3', 'k4').not.toThrow();
			});
		}

		function it_throwsNothingIfVerticesExistAndEdgeDoesNot() {
			it("throws nothing if the required vertices exist but the edge does not", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
			});
		}

		function it_throwsNothingIfVerticesExist() {
			it("throws nothing if the required vertices exist", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('k3', 'k4').not.toThrow();
			});
		}

		function it_throwsNothingWhenPassedTwoKeys() {
			it("throws no exceptions when it is passed two key arguments", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('k3', 'k4').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').not.toThrow();
			});
		}

		function it_throwsNothingWhenPassedTwoKeysAndValue() {
			it("throws no exceptions when it is passed two keys and a value argument", function () {
				expectItWhenBoundWith('k1', 'k2', 'newValue').not.toThrow();
				expectItWhenBoundWith('k2', 'k3', 'newValue').not.toThrow();
				expectItWhenBoundWith('k3', 'k4', 'newValue').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2', 'newValue').not.toThrow();
			});
		}


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		function it_leavesNewEdgeWithNewValue() {
			it("leaves a new edge in the graph with a new value", function () {
				callItWith('k1', 'k2', 'newValue');
				expect(graph.hasEdge('k1', 'k2')).toBeTruthy();
				expect(graph.edgeValue('k1', 'k2')).toBe('newValue');
				expect(graph.edgeCount()).toBe(originalEdgeCount + 1);
			});
		}

		function it_leavesNewEdgeWithNewUndefinedValue() {
			it("leaves a new edge in the graph with a new 'undefined' value", function () {
				callItWith('k1', 'k2');
				expect(graph.hasEdge('k1', 'k2')).toBeTruthy();
				expect(graph.edgeValue('k1', 'k2')).toBeUndefined();
				expect(graph.edgeCount()).toBe(originalEdgeCount + 1);
			});
		}

		function it_leavesExistingEdgeWithNewValue() {
			it("leaves an existing edge in the graph with a new value", function () {
				callItWith('k2', 'k3', 'newValue');
				expect(graph.hasEdge('k2', 'k3')).toBeTruthy();
				expect(graph.edgeValue('k2', 'k3')).toBe('newValue');
				expect(graph.edgeCount()).toBe(originalEdgeCount);
			});
		}

		function it_leavesExistingEdgeWithNewUndefinedValue() {
			it("leaves an existing edge in the graph with a new 'undefined' value", function () {
				callItWith('k2', 'k3');
				expect(graph.hasEdge('k2', 'k3')).toBeTruthy();
				expect(graph.edgeValue('k2', 'k3')).toBeUndefined();
				expect(graph.edgeCount()).toBe(originalEdgeCount);
			});
		}

		function it_leavesExistingEdgeWithOldValue() {
			it("leaves an existing edge in the graph with its old value", function () {
				callItWith('k2', 'k3', 'newValue');
				expect(graph.hasEdge('k2', 'k3')).toBeTruthy();
				expect(graph.edgeValue('k2', 'k3')).toBe('oldValue23');
				expect(graph.edgeCount()).toBe(originalEdgeCount);
				callItWith('k2', 'k3', undefined);
				expect(graph.hasEdge('k2', 'k3')).toBeTruthy();
				expect(graph.edgeValue('k2', 'k3')).toBe('oldValue23');
				expect(graph.edgeCount()).toBe(originalEdgeCount);
			});
		}

		function it_leavesExistingEdgeWithOldUndefinedValue() {
			it("leaves an existing edge in the graph with its old 'undefined' value", function () {
				callItWith('k3', 'k4', 'newValue');
				expect(graph.hasEdge('k3', 'k4')).toBeTruthy();
				expect(graph.edgeValue('k3', 'k4')).toBeUndefined();
				expect(graph.edgeCount()).toBe(originalEdgeCount);
			});
		}

		function it_leavesExistingEdgeAbsent() {
			it("leaves an existing edge absent from the graph", function () {
				callItWith('k2', 'k3');
				expect(graph.hasEdge('k2', 'k3')).toBeFalsy();
				expect(graph.edgeCount()).toBe(originalEdgeCount - 1);
				callItWith('k3', 'k4');
				expect(graph.hasEdge('k3', 'k4')).toBeFalsy();
				expect(graph.edgeCount()).toBe(originalEdgeCount - 2);
			});
		}

		function it_leavesAbsentEdgeAbsent() {
			it("leaves an absent edge absent from the graph", function () {
				callItWith('k1', 'k2');
				expect(graph.hasEdge('k1', 'k2')).toBeFalsy();
				expect(graph.edgeCount()).toBe(originalEdgeCount);
			});
		}

		function it_leavesAbsentVerticesPresent() {
			it("leaves absent vertices present in the graph", function () {
				callItWith('newKey1', 'k1');
				expect(graph.hasVertex('newKey1')).toBeTruthy();
				expect(graph.vertexCount()).toBe(originalVertexCount + 1);
				callItWith('k1', 'newKey2');
				expect(graph.hasVertex('newKey2')).toBeTruthy();
				expect(graph.vertexCount()).toBe(originalVertexCount + 2);
				callItWith('newKey3', 'newKey4');
				expect(graph.hasVertex('newKey3')).toBeTruthy();
				expect(graph.hasVertex('newKey4')).toBeTruthy();
				expect(graph.vertexCount()).toBe(originalVertexCount + 4);
			});
		}


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('addNewEdge', function () {
			it_throwsErrorIfEdgeExists();
			it_throwsErrorIfVerticesDoNotExist();
			it_throwsNothingIfVerticesExistAndEdgeDoesNot();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
		});

		describeMethod('createNewEdge', function () {
			it_throwsErrorIfEdgeExists();
			it_throwsNothingIfEdgeDoesNotExist();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
			it_leavesAbsentVerticesPresent();
		});

		describeMethod('setEdge', function () {
			it_throwsErrorIfEdgeDoesNotExist();
			it_throwsNothingIfEdgeExists();
			it_leavesExistingEdgeWithNewValue();
			it_leavesExistingEdgeWithNewUndefinedValue();
		});

		describeMethod('spanEdge', function () {
			it_throwsErrorIfVerticesDoNotExist();
			it_throwsNothingIfVerticesExist();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
			it_leavesExistingEdgeWithOldValue();
			it_leavesExistingEdgeWithOldUndefinedValue();
		});

		describeMethod('addEdge', function () {
			it_throwsErrorIfVerticesDoNotExist();
			it_throwsNothingIfVerticesExist();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
			it_leavesExistingEdgeWithNewValue();
			it_leavesExistingEdgeWithNewUndefinedValue();
		});

		describeMethod('ensureEdge', function () {
			it_throwsNothingWhenPassedTwoKeys();
			it_throwsNothingWhenPassedTwoKeysAndValue();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
			it_leavesExistingEdgeWithOldValue();
			it_leavesExistingEdgeWithOldUndefinedValue();
			it_leavesAbsentVerticesPresent();
		});

		describeMethod('createEdge', function () {
			it_throwsNothingWhenPassedTwoKeys();
			it_throwsNothingWhenPassedTwoKeysAndValue();
			it_leavesNewEdgeWithNewValue();
			it_leavesNewEdgeWithNewUndefinedValue();
			it_leavesExistingEdgeWithNewValue();
			it_leavesExistingEdgeWithNewUndefinedValue();
			it_leavesAbsentVerticesPresent();
		});

		describeMethod('removeExistingEdge', function () {
			it_throwsErrorIfEdgeDoesNotExist();
			it_leavesExistingEdgeAbsent();
		});

		describeMethod('removeEdge', function () {
			it_throwsNothingWhenPassedTwoKeys();
			it_leavesExistingEdgeAbsent();
			it_leavesAbsentEdgeAbsent();
		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('clearEdges', function () {

			it("throws nothing", function () {
				expectItWhenBoundWith().not.toThrow();
			});

			it("leaves the graph without edges", function () {
				callItWith();
				expect(graph.edgeCount()).toBe(0);
			});

			it("leaves existing vertices in the graph", function () {
				callItWith();
				expect(graph.vertexCount()).toBe(originalVertexCount);
			});

		});


		describeMethod('clear', function () {

			it("throws nothing", function () {
				expectItWhenBoundWith().not.toThrow();
			});

			it("leaves the graph without edges", function () {
				callItWith();
				expect(graph.edgeCount()).toBe(0);
			});

			it("leaves the graph without vertices", function () {
				callItWith();
				expect(graph.vertexCount()).toBe(0);
			});

		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('onAddVertex', function () {

			it("throws no exceptions when passed a function", function () {
				expectItWhenBoundWith(function () { throw new Error("should not be thrown"); }).not.toThrow();
			});

			it("does not modify the graph", function () {
				callItWith(function () {
					graph = null;
				});
				expectTheGraphNotToHaveChanged();
			});

			it("causes the handler to be called after a new vertex is added", function () {
				var addedVertices = {};
				callItWith(function (key, value) {
					expect(graph.hasVertex(key)).toBeTruthy();
					addedVertices[key] = value;
				});
				graph.addNewVertex('newKey', 'newValue');
				expect(addedVertices).toEqual({ 'newKey': 'newValue' });
			});

			it("does not cause the handler to be called when an existing vertex is modified", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.setVertex('k1', 'newValue');
				graph.setVertex('k2', 'newValue');
			});

			it("does not cause the handler to be called when an existing vertex is removed", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.removeExistingVertex('k1');
			});

			it("causes the handler to be called after a previously removed vertex is added again", function () {
				var vertices = {};
				callItWith(function (key, value) {
					expect(graph.hasVertex(key)).toBeTruthy();
					vertices[key] = value;
				});
				graph.removeExistingVertex('k1');
				expect(vertices).toEqual({});
				graph.addNewVertex('k1', 'oldValue1');
				expect(vertices).toEqual({ 'k1': 'oldValue1' });
			});

			it("does not cause the handler to be called after the handler is removed", function () {
				var registeredAddedVertices = {};
				var removeCallback = callItWith(function (key, value) {
					registeredAddedVertices[key] = value;
				});
				graph.addNewVertex('newKey', 'newValue');
				expect(registeredAddedVertices).toEqual({ 'newKey': 'newValue' });
				removeCallback();
				graph.addNewVertex('newKey2', 'newValue2');
				expect(registeredAddedVertices).toEqual({ 'newKey': 'newValue' });
			});

		});


		describeMethod('onAddEdge', function () {

			it("throws no exceptions when passed a function", function () {
				expectItWhenBoundWith(function () { throw new Error("should not be thrown"); }).not.toThrow();
			});

			it("does not modify the graph", function () {
				callItWith(function () {
					graph = null;
				});
				expectTheGraphNotToHaveChanged();
			});

			it("causes the handler to be called after a new edge is added", function () {
				var addedEdges = {};
				callItWith(function (from, to, value) {
					expect(graph.hasEdge(from, to)).toBeTruthy();
					addedEdges[from + ", " + to] = value;
				});
				graph.addNewEdge('k1', 'k2', 'newValue');
				expect(addedEdges).toEqual({ 'k1, k2': 'newValue' });
			});

			it("does not cause the handler to be called when an existing edge is modified", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.setEdge('k2', 'k3', 'newValue');
				graph.setEdge('k3', 'k4', 'newValue');
			});

			it("does not cause the handler to be called when an existing edge is removed", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.removeExistingEdge('k2', 'k3');
			});

			it("causes the handler to be called after a previously removed edge is added again", function () {
				var edges = {};
				callItWith(function (from, to, value) {
					expect(graph.hasEdge(from, to)).toBeTruthy();
					edges[from + ", " + to] = value;
				});
				graph.removeExistingEdge('k2', 'k3');
				expect(edges).toEqual({});
				graph.addNewEdge('k2', 'k3', 'oldValue23');
				expect(edges).toEqual({ 'k2, k3': 'oldValue23' });
			});

			it("does not cause the handler to be called after the handler is removed", function () {
				var registeredAddedEdges = {};
				var removeCallback = callItWith(function (from, to, value) {
					registeredAddedEdges[from + ", " + to] = value;
				});
				graph.addNewEdge('k1', 'k2', 'newValue');
				expect(registeredAddedEdges).toEqual({ 'k1, k2': 'newValue' });
				removeCallback();
				graph.addNewEdge('k2', 'k1', 'newValue2');
				expect(registeredAddedEdges).toEqual({ 'k1, k2': 'newValue' });
			});

		});


		describeMethod('onRemoveVertex', function () {

			it("throws no exceptions when passed a function", function () {
				expectItWhenBoundWith(function () { throw new Error("should not be thrown"); }).not.toThrow();
			});

			it("does not modify the graph", function () {
				callItWith(function () {
					graph = null;
				});
				expectTheGraphNotToHaveChanged();
			});

			it("causes the handler to be called after an existing vertex is removed", function () {
				var removedVertices = {};
				callItWith(function (key, value) {
					expect(graph.hasVertex(key)).toBeFalsy();
					removedVertices[key] = value;
				});
				graph.removeExistingVertex('k1');
				expect(removedVertices).toEqual({ 'k1': 'oldValue1' });
			});

			it("does not cause the handler to be called when an existing vertex is modified", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.setVertex('k1', 'newValue');
				graph.setVertex('k2', 'newValue');
			});

			it("does not cause the handler to be called when an absent vertex is left absent", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.removeVertex('newKey');
			});

			it("does not cause the handler to be called when an absent vertex is added", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.addNewVertex('newKey');
			});

			it("does not cause the handler to be called after the handler is removed", function () {
				var registeredRemovedVertices = {};
				var removeCallback = callItWith(function (key, value) {
					registeredRemovedVertices[key] = value;
				});
				graph.addNewVertex('k99', 'newValue');
				graph.removeExistingVertex('k99');
				expect(registeredRemovedVertices).toEqual({ 'k99': 'newValue' });
				removeCallback();
				graph.removeExistingVertex('k1');
				expect(registeredRemovedVertices).toEqual({ 'k99': 'newValue' });
			});

		});


		describeMethod('onRemoveEdge', function () {

			it("throws no exceptions when passed a function", function () {
				expectItWhenBoundWith(function () { throw new Error("should not be thrown"); }).not.toThrow();
			});

			it("does not modify the graph", function () {
				callItWith(function () {
					graph = null;
				});
				expectTheGraphNotToHaveChanged();
			});

			it("causes the handler to be called after an existing edge is removed", function () {
				var removedEdges = {};
				callItWith(function (from, to, value) {
					expect(graph.hasEdge(from, to)).toBeFalsy();
					removedEdges[from + ", " + to] = value;
				});
				graph.removeExistingEdge('k2', 'k3');
				expect(removedEdges).toEqual({ 'k2, k3': 'oldValue23' });
			});

			it("does not cause the handler to be called when an existing edge is modified", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.setEdge('k2', 'k3', 'newValue');
				graph.setEdge('k3', 'k4', 'newValue');
			});

			it("does not cause the handler to be called when an absent edge is left absent", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.removeEdge('k1', 'k2');
			});

			it("does not cause the handler to be called when an absent edge is added", function () {
				callItWith(function () {
					expect().not.toBeReachable();
				});
				graph.addNewEdge('k1', 'k2');
			});

			it("does not cause the handler to be called after the handler is removed", function () {
				var registeredRemovedEdges = {};
				var removeCallback = callItWith(function (from, to, value) {
					registeredRemovedEdges[from + ", " + to] = value;
				});
				graph.removeExistingEdge('k2', 'k3');
				expect(registeredRemovedEdges).toEqual({ 'k2, k3': 'oldValue23' });
				removeCallback();
				graph.removeExistingEdge('k3', 'k4');
				expect(registeredRemovedEdges).toEqual({ 'k2, k3': 'oldValue23' });
			});

		});


		describe("event subscription methods", function () {

			it("register each handler only once", function () {
				var counter = 0;
				var handler = function () {
					++counter;
				};
				graph.onAddVertex(handler);
				graph.onAddVertex(handler);
				graph.addNewVertex('newKey', 'newValue');
				expect(counter).toBe(1);
			});

			it("quietly ignore multiple removals of the same handler", function () {
				var counter = 0;
				graph.onAddVertex(function () { // adding a handler before the main handler
					++counter;
				});
				var removeCallback = graph.onAddVertex(function () {
					counter += 10;
				});
				graph.onAddVertex(function () { // adding a handler after the main handler
					++counter;
				});
				graph.addNewVertex('newKey', 'newValue');
				expect(counter).toBe(12);
				removeCallback();
				removeCallback();
				graph.addNewVertex('newKey2', 'newValue2');
				expect(counter).toBe(14); // meaning: the other two handlers are not accidentally removed
			});

		});


		// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //


		describeMethod('hasPath', function () {

			it("throws nothing when passed two key arguments", function () {
				expectItWhenBoundWith('k1', 'k2').not.toThrow();
				expectItWhenBoundWith('k2', 'k3').not.toThrow();
				expectItWhenBoundWith('newKey', 'k2').not.toThrow();
				expectItWhenBoundWith('newKey1', 'newKey2').not.toThrow();
			});

			// k1     k2 --> k3 --> k4
			//        |      ^
			//        |      ;
			//        V     /
			//        k5 __/

			it("returns a falsy value if the path doesn't exist (1)", function () {
				expectItWhenCalledWith('k1', 'k2').toBeFalsy();
				expectItWhenCalledWith('k1', 'k3').toBeFalsy();
				expectItWhenCalledWith('k2', 'k1').toBeFalsy();
			});

			it("returns a falsy value if the path doesn't exist (2: self-loop)", function () {
				expectItWhenCalledWith('k2', 'k2').toBeFalsy();
			});

			it("returns a falsy value if the path doesn't exist (3: edge backwards)", function () {
				expectItWhenCalledWith('k3', 'k2').toBeFalsy();
				expectItWhenCalledWith('k4', 'k2').toBeFalsy();
			});

			it("returns a truthy value if the path exists (1: single edge)", function () {
				expectItWhenCalledWith('k2', 'k3').toBeTruthy();
				expectItWhenCalledWith('k3', 'k4').toBeTruthy();
				expectItWhenCalledWith('k2', 'k5').toBeTruthy();
				expectItWhenCalledWith('k5', 'k3').toBeTruthy();
			});

			it("returns a truthy value if the path exists (2: transitive)", function () {
				expectItWhenCalledWith('k2', 'k4').toBeTruthy();
				expectItWhenCalledWith('k5', 'k4').toBeTruthy();
				graph.addEdge('k4', 'k1');
				expectItWhenCalledWith('k2', 'k1').toBeTruthy();
			});

			it("returns a truthy value if the path exists (3: reflexive cycle)", function () {
				graph.addEdge('k1', 'k1');
				expectItWhenCalledWith('k1', 'k1').toBeTruthy();
			});

			it("returns a truthy value if the path exists (4: symmetric cycle)", function () {
				graph.addEdge('k4', 'k3');
				expectItWhenCalledWith('k3', 'k3').toBeTruthy();
			});

			it("returns a truthy value if the path exists (5: larger cycle)", function () {
				graph.addEdge('k4', 'k1');
				graph.addEdge('k1', 'k2');
				expectItWhenCalledWith('k3', 'k3').toBeTruthy();
			});

			it("returns a truthy value if the path exists (6: including part of a cycle, part 1)", function () {
				graph.clear();

				graph.createEdge('n1', 'n2');
				graph.createEdge('n2', 'n3');
				graph.createEdge('n3', 'n4');
				graph.createEdge('n4', 'n5');
				graph.createEdge('n3', 'n23');
				graph.createEdge('n23', 'n2');

				// n1 --> n2 --> n3 --> n4 --> n5
				//        ^      |
				//        |      ;
				//        |     /
				//       n23 <-"

				expectItWhenCalledWith('n1', 'n5').toBeTruthy();
			});

			it("returns a truthy value if the path exists (7: including part of a cycle, part 2)", function () {
				graph.clear();

				graph.createEdge('n3', 'n23'); // same graph as above, but creating the loopy bit
				graph.createEdge('n23', 'n2'); // first; insertion order matters for some engines
				graph.createEdge('n1', 'n2');
				graph.createEdge('n2', 'n3');
				graph.createEdge('n3', 'n4');
				graph.createEdge('n4', 'n5');

				// n1 --> n2 --> n3 --> n4 --> n5
				//        ^      |
				//        |      ;
				//        |     /
				//       n23 <-"

				expectItWhenCalledWith('n1', 'n5').toBeTruthy();
			});

		});


		describeMethod('topologically', function () {

			it("throws an error if the graph contains a cycle (1)", function () {
				graph.clear();

				graph.createEdge('n1', 'n2');
				graph.createEdge('n2', 'n3');
				graph.createEdge('n3', 'n4');
				graph.createEdge('n4', 'n5');
				graph.createEdge('n3', 'n23');
				graph.createEdge('n23', 'n2');

				// n1 --> n2 --> n3 --> n4 --> n5
				//        ^      |
				//        |      ;
				//        |     /
				//       n23 <-"

				expectItWhenBoundWith(function () {}).toThrow();
				expectItWhenBoundWith(function () {}).toThrowSpecific(Graph.CycleError, {});

				try {
					callItWith(function () {});
				} catch (err) {
					expect(err.cycle).toEqualOneOf(
							['n23', 'n2', 'n3'],
							['n3', 'n23', 'n2'],
							['n2', 'n3', 'n23']
					);
				}
			});

			it("throws an error if the graph contains a cycle (2)", function () {
				graph.clear();

				graph.createEdge('n1', 'n1');

				expectItWhenBoundWith(function () {}).toThrow();
				expectItWhenBoundWith(function () {}).toThrowSpecific(Graph.CycleError, {});

				try {
					callItWith(function () {});
				} catch (err) {
					expect(err.cycle).toEqual(['n1']);
				}
			});

			it("throws nothing if the graph has no cycle and the passed function throws nothing", function () {
				expectItWhenBoundWith(function () {/*not throwing stuff*/}).not.toThrow();
			});

			it("calls the specified handler exactly once for each vertex in the graph", function () {
				var verticesFound = {};
				callItWith(function (key, value) {
					expect(verticesFound[key]).toBeUndefined();
					verticesFound[key] = value;
				});
				expect(verticesFound).toEqual(originalVertices);
			});

			it("visits vertices only when their predecessors have already been visited", function () {
				graph.clear();

				graph.createEdge('n3', 'n23');
				graph.createEdge('n2', 'n23');
				graph.createEdge('n1', 'n2');
				graph.createEdge('n2', 'n3');
				graph.createEdge('n3', 'n4');
				graph.createEdge('n4', 'n5');

				// n1 --> n2 --> n3 --> n4 --> n5
				//        |      |
				//        |      ;
				//        V     /
				//       n23 <-"

				var visited = {};

				callItWith(function (key) {
					if (key === 'n2') { expect(visited['n1']).toBeDefined(); }
					if (key === 'n3') { expect(visited['n2']).toBeDefined(); }
					if (key === 'n4') { expect(visited['n3']).toBeDefined(); }
					if (key === 'n5') { expect(visited['n4']).toBeDefined(); }
					if (key === 'n23') {
						expect(visited['n2']).toBeDefined();
						expect(visited['n3']).toBeDefined();
					}
					visited[key] = true;
				});

			});


		});


	});/////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
});/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
