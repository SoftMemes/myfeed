// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/feed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'feed.pb.dart' as $0;

export 'feed.pb.dart';

/// FeedService is the read-only surface for the authenticated user's feed.
/// All RPCs require a valid Firebase Auth token in gRPC metadata.
@$pb.GrpcServiceName('com.softmemes.myfeed.v1.FeedService')
class FeedServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FeedServiceClient(super.channel, {super.options, super.interceptors});

  /// GetFeed returns the user's feed in reverse-chronological order.
  /// All filter fields are optional; omitting them returns the full feed.
  $grpc.ResponseFuture<$0.GetFeedResponse> getFeed(
    $0.GetFeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFeed, request, options: options);
  }

  // method descriptors

  static final _$getFeed =
      $grpc.ClientMethod<$0.GetFeedRequest, $0.GetFeedResponse>(
          '/com.softmemes.myfeed.v1.FeedService/GetFeed',
          ($0.GetFeedRequest value) => value.writeToBuffer(),
          $0.GetFeedResponse.fromBuffer);
}

@$pb.GrpcServiceName('com.softmemes.myfeed.v1.FeedService')
abstract class FeedServiceBase extends $grpc.Service {
  $core.String get $name => 'com.softmemes.myfeed.v1.FeedService';

  FeedServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetFeedRequest, $0.GetFeedResponse>(
        'GetFeed',
        getFeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetFeedRequest.fromBuffer(value),
        ($0.GetFeedResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetFeedResponse> getFeed_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetFeedRequest> $request) async {
    return getFeed($call, await $request);
  }

  $async.Future<$0.GetFeedResponse> getFeed(
      $grpc.ServiceCall call, $0.GetFeedRequest request);
}
