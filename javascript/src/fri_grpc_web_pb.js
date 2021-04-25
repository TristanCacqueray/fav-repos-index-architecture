/**
 * @fileoverview gRPC-Web generated client stub for fri.v1
 * @enhanceable
 * @public
 */

// GENERATED CODE -- DO NOT EDIT!


/* eslint-disable */
// @ts-nocheck



const grpc = {};
grpc.web = require('grpc-web');

const proto = {};
proto.fri = {};
proto.fri.v1 = require('./fri_pb.js');

/**
 * @param {string} hostname
 * @param {?Object} credentials
 * @param {?Object} options
 * @constructor
 * @struct
 * @final
 */
proto.fri.v1.ServiceClient =
    function(hostname, credentials, options) {
  if (!options) options = {};
  options['format'] = 'text';

  /**
   * @private @const {!grpc.web.GrpcWebClientBase} The client
   */
  this.client_ = new grpc.web.GrpcWebClientBase(options);

  /**
   * @private @const {string} The hostname
   */
  this.hostname_ = hostname;

};


/**
 * @param {string} hostname
 * @param {?Object} credentials
 * @param {?Object} options
 * @constructor
 * @struct
 * @final
 */
proto.fri.v1.ServicePromiseClient =
    function(hostname, credentials, options) {
  if (!options) options = {};
  options['format'] = 'text';

  /**
   * @private @const {!grpc.web.GrpcWebClientBase} The client
   */
  this.client_ = new grpc.web.GrpcWebClientBase(options);

  /**
   * @private @const {string} The hostname
   */
  this.hostname_ = hostname;

};


/**
 * @const
 * @type {!grpc.web.MethodDescriptor<
 *   !proto.fri.v1.RegisterRequest,
 *   !proto.fri.v1.RegisterResponse>}
 */
const methodDescriptor_Service_Register = new grpc.web.MethodDescriptor(
  '/fri.v1.Service/Register',
  grpc.web.MethodType.SERVER_STREAMING,
  proto.fri.v1.RegisterRequest,
  proto.fri.v1.RegisterResponse,
  /**
   * @param {!proto.fri.v1.RegisterRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.fri.v1.RegisterResponse.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.fri.v1.RegisterRequest,
 *   !proto.fri.v1.RegisterResponse>}
 */
const methodInfo_Service_Register = new grpc.web.AbstractClientBase.MethodInfo(
  proto.fri.v1.RegisterResponse,
  /**
   * @param {!proto.fri.v1.RegisterRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.fri.v1.RegisterResponse.deserializeBinary
);


/**
 * @param {!proto.fri.v1.RegisterRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fri.v1.RegisterResponse>}
 *     The XHR Node Readable Stream
 */
proto.fri.v1.ServiceClient.prototype.register =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/fri.v1.Service/Register',
      request,
      metadata || {},
      methodDescriptor_Service_Register);
};


/**
 * @param {!proto.fri.v1.RegisterRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fri.v1.RegisterResponse>}
 *     The XHR Node Readable Stream
 */
proto.fri.v1.ServicePromiseClient.prototype.register =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/fri.v1.Service/Register',
      request,
      metadata || {},
      methodDescriptor_Service_Register);
};


/**
 * @const
 * @type {!grpc.web.MethodDescriptor<
 *   !proto.fri.v1.SearchRequest,
 *   !proto.fri.v1.SearchResponse>}
 */
const methodDescriptor_Service_Search = new grpc.web.MethodDescriptor(
  '/fri.v1.Service/Search',
  grpc.web.MethodType.SERVER_STREAMING,
  proto.fri.v1.SearchRequest,
  proto.fri.v1.SearchResponse,
  /**
   * @param {!proto.fri.v1.SearchRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.fri.v1.SearchResponse.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.fri.v1.SearchRequest,
 *   !proto.fri.v1.SearchResponse>}
 */
const methodInfo_Service_Search = new grpc.web.AbstractClientBase.MethodInfo(
  proto.fri.v1.SearchResponse,
  /**
   * @param {!proto.fri.v1.SearchRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.fri.v1.SearchResponse.deserializeBinary
);


/**
 * @param {!proto.fri.v1.SearchRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fri.v1.SearchResponse>}
 *     The XHR Node Readable Stream
 */
proto.fri.v1.ServiceClient.prototype.search =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/fri.v1.Service/Search',
      request,
      metadata || {},
      methodDescriptor_Service_Search);
};


/**
 * @param {!proto.fri.v1.SearchRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fri.v1.SearchResponse>}
 *     The XHR Node Readable Stream
 */
proto.fri.v1.ServicePromiseClient.prototype.search =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/fri.v1.Service/Search',
      request,
      metadata || {},
      methodDescriptor_Service_Search);
};


module.exports = proto.fri.v1;

