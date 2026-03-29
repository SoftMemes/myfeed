// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/subscriptions.proto.

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

import 'subscriptions.pb.dart' as $0;

export 'subscriptions.pb.dart';

/// SubscriptionService manages the authenticated user's sources and subscriptions.
/// All RPCs require a valid Firebase Auth token in gRPC metadata.
@$pb.GrpcServiceName('com.softmemes.myfeed.v1.SubscriptionService')
class SubscriptionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SubscriptionServiceClient(super.channel, {super.options, super.interceptors});

  /// CreateSource adds a new platform connection for the user.
  $grpc.ResponseFuture<$0.CreateSourceResponse> createSource(
    $0.CreateSourceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSource, request, options: options);
  }

  /// DeleteSource removes a source and cascades to delete all its subscriptions.
  $grpc.ResponseFuture<$0.DeleteSourceResponse> deleteSource(
    $0.DeleteSourceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteSource, request, options: options);
  }

  /// ListSources returns all platform connections for the authenticated user.
  $grpc.ResponseFuture<$0.ListSourcesResponse> listSources(
    $0.ListSourcesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSources, request, options: options);
  }

  /// SearchSubscribables searches for things to subscribe to within a source.
  /// Results are streamed individually as they arrive from the platform API.
  $grpc.ResponseStream<$0.SearchSubscribablesResponse> searchSubscribables(
    $0.SearchSubscribablesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$searchSubscribables, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// AddSubscription subscribes the user to a specific item within a source.
  $grpc.ResponseFuture<$0.AddSubscriptionResponse> addSubscription(
    $0.AddSubscriptionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addSubscription, request, options: options);
  }

  /// RemoveSubscription removes a specific subscription.
  $grpc.ResponseFuture<$0.RemoveSubscriptionResponse> removeSubscription(
    $0.RemoveSubscriptionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeSubscription, request, options: options);
  }

  /// ListSubscriptions returns the user's subscriptions, optionally filtered by source.
  $grpc.ResponseFuture<$0.ListSubscriptionsResponse> listSubscriptions(
    $0.ListSubscriptionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSubscriptions, request, options: options);
  }

  // method descriptors

  static final _$createSource =
      $grpc.ClientMethod<$0.CreateSourceRequest, $0.CreateSourceResponse>(
          '/com.softmemes.myfeed.v1.SubscriptionService/CreateSource',
          ($0.CreateSourceRequest value) => value.writeToBuffer(),
          $0.CreateSourceResponse.fromBuffer);
  static final _$deleteSource =
      $grpc.ClientMethod<$0.DeleteSourceRequest, $0.DeleteSourceResponse>(
          '/com.softmemes.myfeed.v1.SubscriptionService/DeleteSource',
          ($0.DeleteSourceRequest value) => value.writeToBuffer(),
          $0.DeleteSourceResponse.fromBuffer);
  static final _$listSources =
      $grpc.ClientMethod<$0.ListSourcesRequest, $0.ListSourcesResponse>(
          '/com.softmemes.myfeed.v1.SubscriptionService/ListSources',
          ($0.ListSourcesRequest value) => value.writeToBuffer(),
          $0.ListSourcesResponse.fromBuffer);
  static final _$searchSubscribables = $grpc.ClientMethod<
          $0.SearchSubscribablesRequest, $0.SearchSubscribablesResponse>(
      '/com.softmemes.myfeed.v1.SubscriptionService/SearchSubscribables',
      ($0.SearchSubscribablesRequest value) => value.writeToBuffer(),
      $0.SearchSubscribablesResponse.fromBuffer);
  static final _$addSubscription =
      $grpc.ClientMethod<$0.AddSubscriptionRequest, $0.AddSubscriptionResponse>(
          '/com.softmemes.myfeed.v1.SubscriptionService/AddSubscription',
          ($0.AddSubscriptionRequest value) => value.writeToBuffer(),
          $0.AddSubscriptionResponse.fromBuffer);
  static final _$removeSubscription = $grpc.ClientMethod<
          $0.RemoveSubscriptionRequest, $0.RemoveSubscriptionResponse>(
      '/com.softmemes.myfeed.v1.SubscriptionService/RemoveSubscription',
      ($0.RemoveSubscriptionRequest value) => value.writeToBuffer(),
      $0.RemoveSubscriptionResponse.fromBuffer);
  static final _$listSubscriptions = $grpc.ClientMethod<
          $0.ListSubscriptionsRequest, $0.ListSubscriptionsResponse>(
      '/com.softmemes.myfeed.v1.SubscriptionService/ListSubscriptions',
      ($0.ListSubscriptionsRequest value) => value.writeToBuffer(),
      $0.ListSubscriptionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('com.softmemes.myfeed.v1.SubscriptionService')
abstract class SubscriptionServiceBase extends $grpc.Service {
  $core.String get $name => 'com.softmemes.myfeed.v1.SubscriptionService';

  SubscriptionServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.CreateSourceRequest, $0.CreateSourceResponse>(
            'CreateSource',
            createSource_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateSourceRequest.fromBuffer(value),
            ($0.CreateSourceResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteSourceRequest, $0.DeleteSourceResponse>(
            'DeleteSource',
            deleteSource_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteSourceRequest.fromBuffer(value),
            ($0.DeleteSourceResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListSourcesRequest, $0.ListSourcesResponse>(
            'ListSources',
            listSources_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListSourcesRequest.fromBuffer(value),
            ($0.ListSourcesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchSubscribablesRequest,
            $0.SearchSubscribablesResponse>(
        'SearchSubscribables',
        searchSubscribables_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.SearchSubscribablesRequest.fromBuffer(value),
        ($0.SearchSubscribablesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddSubscriptionRequest,
            $0.AddSubscriptionResponse>(
        'AddSubscription',
        addSubscription_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddSubscriptionRequest.fromBuffer(value),
        ($0.AddSubscriptionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveSubscriptionRequest,
            $0.RemoveSubscriptionResponse>(
        'RemoveSubscription',
        removeSubscription_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RemoveSubscriptionRequest.fromBuffer(value),
        ($0.RemoveSubscriptionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListSubscriptionsRequest,
            $0.ListSubscriptionsResponse>(
        'ListSubscriptions',
        listSubscriptions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListSubscriptionsRequest.fromBuffer(value),
        ($0.ListSubscriptionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateSourceResponse> createSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateSourceRequest> $request) async {
    return createSource($call, await $request);
  }

  $async.Future<$0.CreateSourceResponse> createSource(
      $grpc.ServiceCall call, $0.CreateSourceRequest request);

  $async.Future<$0.DeleteSourceResponse> deleteSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteSourceRequest> $request) async {
    return deleteSource($call, await $request);
  }

  $async.Future<$0.DeleteSourceResponse> deleteSource(
      $grpc.ServiceCall call, $0.DeleteSourceRequest request);

  $async.Future<$0.ListSourcesResponse> listSources_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListSourcesRequest> $request) async {
    return listSources($call, await $request);
  }

  $async.Future<$0.ListSourcesResponse> listSources(
      $grpc.ServiceCall call, $0.ListSourcesRequest request);

  $async.Stream<$0.SearchSubscribablesResponse> searchSubscribables_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SearchSubscribablesRequest> $request) async* {
    yield* searchSubscribables($call, await $request);
  }

  $async.Stream<$0.SearchSubscribablesResponse> searchSubscribables(
      $grpc.ServiceCall call, $0.SearchSubscribablesRequest request);

  $async.Future<$0.AddSubscriptionResponse> addSubscription_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AddSubscriptionRequest> $request) async {
    return addSubscription($call, await $request);
  }

  $async.Future<$0.AddSubscriptionResponse> addSubscription(
      $grpc.ServiceCall call, $0.AddSubscriptionRequest request);

  $async.Future<$0.RemoveSubscriptionResponse> removeSubscription_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveSubscriptionRequest> $request) async {
    return removeSubscription($call, await $request);
  }

  $async.Future<$0.RemoveSubscriptionResponse> removeSubscription(
      $grpc.ServiceCall call, $0.RemoveSubscriptionRequest request);

  $async.Future<$0.ListSubscriptionsResponse> listSubscriptions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListSubscriptionsRequest> $request) async {
    return listSubscriptions($call, await $request);
  }

  $async.Future<$0.ListSubscriptionsResponse> listSubscriptions(
      $grpc.ServiceCall call, $0.ListSubscriptionsRequest request);
}
