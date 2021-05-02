/**
 * @fileoverview gRPC-Web generated client stub for frirpc
 * @enhanceable
 * @public
 */

// GENERATED CODE -- DO NOT EDIT!


/* eslint-disable */
// @ts-nocheck



const grpc = {};
grpc.web = require('grpc-web');


var fri_messages_pb = require('../fri/messages_pb.js')
const proto = {};
proto.frirpc = require('./services_pb.js');

/**
 * @param {string} hostname
 * @param {?Object} credentials
 * @param {?Object} options
 * @constructor
 * @struct
 * @final
 */
proto.frirpc.ServiceClient =
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
proto.frirpc.ServicePromiseClient =
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
 *   !proto.fripb.RegisterRequest,
 *   !proto.fripb.RegisterResponse>}
 */
const methodDescriptor_Service_Register = new grpc.web.MethodDescriptor(
  '/frirpc.Service/Register',
  grpc.web.MethodType.SERVER_STREAMING,
  fri_messages_pb.RegisterRequest,
  fri_messages_pb.RegisterResponse,
  /**
   * @param {!proto.fripb.RegisterRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  fri_messages_pb.RegisterResponse.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.fripb.RegisterRequest,
 *   !proto.fripb.RegisterResponse>}
 */
const methodInfo_Service_Register = new grpc.web.AbstractClientBase.MethodInfo(
  fri_messages_pb.RegisterResponse,
  /**
   * @param {!proto.fripb.RegisterRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  fri_messages_pb.RegisterResponse.deserializeBinary
);


/**
 * @param {!proto.fripb.RegisterRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fripb.RegisterResponse>}
 *     The XHR Node Readable Stream
 */
proto.frirpc.ServiceClient.prototype.register =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/frirpc.Service/Register',
      request,
      metadata || {},
      methodDescriptor_Service_Register);
};


/**
 * @param {!proto.fripb.RegisterRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fripb.RegisterResponse>}
 *     The XHR Node Readable Stream
 */
proto.frirpc.ServicePromiseClient.prototype.register =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/frirpc.Service/Register',
      request,
      metadata || {},
      methodDescriptor_Service_Register);
};


/**
 * @const
 * @type {!grpc.web.MethodDescriptor<
 *   !proto.fripb.SearchRequest,
 *   !proto.fripb.SearchResponse>}
 */
const methodDescriptor_Service_Search = new grpc.web.MethodDescriptor(
  '/frirpc.Service/Search',
  grpc.web.MethodType.SERVER_STREAMING,
  fri_messages_pb.SearchRequest,
  fri_messages_pb.SearchResponse,
  /**
   * @param {!proto.fripb.SearchRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  fri_messages_pb.SearchResponse.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.fripb.SearchRequest,
 *   !proto.fripb.SearchResponse>}
 */
const methodInfo_Service_Search = new grpc.web.AbstractClientBase.MethodInfo(
  fri_messages_pb.SearchResponse,
  /**
   * @param {!proto.fripb.SearchRequest} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  fri_messages_pb.SearchResponse.deserializeBinary
);


/**
 * @param {!proto.fripb.SearchRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fripb.SearchResponse>}
 *     The XHR Node Readable Stream
 */
proto.frirpc.ServiceClient.prototype.search =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/frirpc.Service/Search',
      request,
      metadata || {},
      methodDescriptor_Service_Search);
};


/**
 * @param {!proto.fripb.SearchRequest} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.fripb.SearchResponse>}
 *     The XHR Node Readable Stream
 */
proto.frirpc.ServicePromiseClient.prototype.search =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/frirpc.Service/Search',
      request,
      metadata || {},
      methodDescriptor_Service_Search);
};


module.exports = proto.frirpc;

