// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/subscriptions.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use subscriptionDescriptor instead')
const Subscription$json = {
  '1': 'Subscription',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'source_id', '3': 2, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'external_id', '3': 3, '4': 1, '5': 9, '10': 'externalId'},
    {'1': 'display_name', '3': 4, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 6, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Subscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscriptionDescriptor = $convert.base64Decode(
    'CgxTdWJzY3JpcHRpb24SDgoCaWQYASABKAlSAmlkEhsKCXNvdXJjZV9pZBgCIAEoCVIIc291cm'
    'NlSWQSHwoLZXh0ZXJuYWxfaWQYAyABKAlSCmV4dGVybmFsSWQSIQoMZGlzcGxheV9uYW1lGAQg'
    'ASgJUgtkaXNwbGF5TmFtZRIgCgtkZXNjcmlwdGlvbhgFIAEoCVILZGVzY3JpcHRpb24SGwoJaW'
    '1hZ2VfdXJsGAYgASgJUghpbWFnZVVybBI5CgpjcmVhdGVkX2F0GAcgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use createSourceRequestDescriptor instead')
const CreateSourceRequest$json = {
  '1': 'CreateSourceRequest',
  '2': [
    {'1': 'platform_type', '3': 1, '4': 1, '5': 9, '10': 'platformType'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `CreateSourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSourceRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVTb3VyY2VSZXF1ZXN0EiMKDXBsYXRmb3JtX3R5cGUYASABKAlSDHBsYXRmb3JtVH'
    'lwZRIhCgxkaXNwbGF5X25hbWUYAiABKAlSC2Rpc3BsYXlOYW1l');

@$core.Deprecated('Use createSourceResponseDescriptor instead')
const CreateSourceResponse$json = {
  '1': 'CreateSourceResponse',
  '2': [
    {
      '1': 'source',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.Source',
      '10': 'source'
    },
  ],
};

/// Descriptor for `CreateSourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSourceResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVTb3VyY2VSZXNwb25zZRI3CgZzb3VyY2UYASABKAsyHy5jb20uc29mdG1lbWVzLm'
    '15ZmVlZC52MS5Tb3VyY2VSBnNvdXJjZQ==');

@$core.Deprecated('Use deleteSourceRequestDescriptor instead')
const DeleteSourceRequest$json = {
  '1': 'DeleteSourceRequest',
  '2': [
    {'1': 'source_id', '3': 1, '4': 1, '5': 9, '10': 'sourceId'},
  ],
};

/// Descriptor for `DeleteSourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSourceRequestDescriptor =
    $convert.base64Decode(
        'ChNEZWxldGVTb3VyY2VSZXF1ZXN0EhsKCXNvdXJjZV9pZBgBIAEoCVIIc291cmNlSWQ=');

@$core.Deprecated('Use deleteSourceResponseDescriptor instead')
const DeleteSourceResponse$json = {
  '1': 'DeleteSourceResponse',
};

/// Descriptor for `DeleteSourceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSourceResponseDescriptor =
    $convert.base64Decode('ChREZWxldGVTb3VyY2VSZXNwb25zZQ==');

@$core.Deprecated('Use listSourcesRequestDescriptor instead')
const ListSourcesRequest$json = {
  '1': 'ListSourcesRequest',
  '2': [
    {
      '1': 'page',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.PageRequest',
      '10': 'page'
    },
  ],
};

/// Descriptor for `ListSourcesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSourcesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0U291cmNlc1JlcXVlc3QSOAoEcGFnZRgBIAEoCzIkLmNvbS5zb2Z0bWVtZXMubXlmZW'
    'VkLnYxLlBhZ2VSZXF1ZXN0UgRwYWdl');

@$core.Deprecated('Use listSourcesResponseDescriptor instead')
const ListSourcesResponse$json = {
  '1': 'ListSourcesResponse',
  '2': [
    {
      '1': 'sources',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.Source',
      '10': 'sources'
    },
    {
      '1': 'page',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.PageResponse',
      '10': 'page'
    },
  ],
};

/// Descriptor for `ListSourcesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSourcesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0U291cmNlc1Jlc3BvbnNlEjkKB3NvdXJjZXMYASADKAsyHy5jb20uc29mdG1lbWVzLm'
    '15ZmVlZC52MS5Tb3VyY2VSB3NvdXJjZXMSOQoEcGFnZRgCIAEoCzIlLmNvbS5zb2Z0bWVtZXMu'
    'bXlmZWVkLnYxLlBhZ2VSZXNwb25zZVIEcGFnZQ==');

@$core.Deprecated('Use searchSubscribablesRequestDescriptor instead')
const SearchSubscribablesRequest$json = {
  '1': 'SearchSubscribablesRequest',
  '2': [
    {'1': 'source_id', '3': 1, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchSubscribablesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchSubscribablesRequestDescriptor =
    $convert.base64Decode(
        'ChpTZWFyY2hTdWJzY3JpYmFibGVzUmVxdWVzdBIbCglzb3VyY2VfaWQYASABKAlSCHNvdXJjZU'
        'lkEhQKBXF1ZXJ5GAIgASgJUgVxdWVyeQ==');

@$core.Deprecated('Use searchSubscribablesResponseDescriptor instead')
const SearchSubscribablesResponse$json = {
  '1': 'SearchSubscribablesResponse',
  '2': [
    {
      '1': 'subscribable',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.Subscribable',
      '10': 'subscribable'
    },
  ],
};

/// Descriptor for `SearchSubscribablesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchSubscribablesResponseDescriptor =
    $convert.base64Decode(
        'ChtTZWFyY2hTdWJzY3JpYmFibGVzUmVzcG9uc2USSQoMc3Vic2NyaWJhYmxlGAEgASgLMiUuY2'
        '9tLnNvZnRtZW1lcy5teWZlZWQudjEuU3Vic2NyaWJhYmxlUgxzdWJzY3JpYmFibGU=');

@$core.Deprecated('Use addSubscriptionRequestDescriptor instead')
const AddSubscriptionRequest$json = {
  '1': 'AddSubscriptionRequest',
  '2': [
    {'1': 'source_id', '3': 1, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'external_id', '3': 2, '4': 1, '5': 9, '10': 'externalId'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 5, '4': 1, '5': 9, '10': 'imageUrl'},
  ],
};

/// Descriptor for `AddSubscriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSubscriptionRequestDescriptor = $convert.base64Decode(
    'ChZBZGRTdWJzY3JpcHRpb25SZXF1ZXN0EhsKCXNvdXJjZV9pZBgBIAEoCVIIc291cmNlSWQSHw'
    'oLZXh0ZXJuYWxfaWQYAiABKAlSCmV4dGVybmFsSWQSIQoMZGlzcGxheV9uYW1lGAMgASgJUgtk'
    'aXNwbGF5TmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SGwoJaW1hZ2VfdX'
    'JsGAUgASgJUghpbWFnZVVybA==');

@$core.Deprecated('Use addSubscriptionResponseDescriptor instead')
const AddSubscriptionResponse$json = {
  '1': 'AddSubscriptionResponse',
  '2': [
    {
      '1': 'subscription',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.Subscription',
      '10': 'subscription'
    },
  ],
};

/// Descriptor for `AddSubscriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSubscriptionResponseDescriptor =
    $convert.base64Decode(
        'ChdBZGRTdWJzY3JpcHRpb25SZXNwb25zZRJJCgxzdWJzY3JpcHRpb24YASABKAsyJS5jb20uc2'
        '9mdG1lbWVzLm15ZmVlZC52MS5TdWJzY3JpcHRpb25SDHN1YnNjcmlwdGlvbg==');

@$core.Deprecated('Use removeSubscriptionRequestDescriptor instead')
const RemoveSubscriptionRequest$json = {
  '1': 'RemoveSubscriptionRequest',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
  ],
};

/// Descriptor for `RemoveSubscriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeSubscriptionRequestDescriptor =
    $convert.base64Decode(
        'ChlSZW1vdmVTdWJzY3JpcHRpb25SZXF1ZXN0EicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3'
        'Vic2NyaXB0aW9uSWQ=');

@$core.Deprecated('Use removeSubscriptionResponseDescriptor instead')
const RemoveSubscriptionResponse$json = {
  '1': 'RemoveSubscriptionResponse',
};

/// Descriptor for `RemoveSubscriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeSubscriptionResponseDescriptor =
    $convert.base64Decode('ChpSZW1vdmVTdWJzY3JpcHRpb25SZXNwb25zZQ==');

@$core.Deprecated('Use listSubscriptionsRequestDescriptor instead')
const ListSubscriptionsRequest$json = {
  '1': 'ListSubscriptionsRequest',
  '2': [
    {'1': 'source_id', '3': 1, '4': 1, '5': 9, '10': 'sourceId'},
    {
      '1': 'page',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.PageRequest',
      '10': 'page'
    },
  ],
};

/// Descriptor for `ListSubscriptionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSubscriptionsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0U3Vic2NyaXB0aW9uc1JlcXVlc3QSGwoJc291cmNlX2lkGAEgASgJUghzb3VyY2VJZB'
    'I4CgRwYWdlGAIgASgLMiQuY29tLnNvZnRtZW1lcy5teWZlZWQudjEuUGFnZVJlcXVlc3RSBHBh'
    'Z2U=');

@$core.Deprecated('Use listSubscriptionsResponseDescriptor instead')
const ListSubscriptionsResponse$json = {
  '1': 'ListSubscriptionsResponse',
  '2': [
    {
      '1': 'subscriptions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.Subscription',
      '10': 'subscriptions'
    },
    {
      '1': 'page',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.PageResponse',
      '10': 'page'
    },
  ],
};

/// Descriptor for `ListSubscriptionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSubscriptionsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0U3Vic2NyaXB0aW9uc1Jlc3BvbnNlEksKDXN1YnNjcmlwdGlvbnMYASADKAsyJS5jb2'
    '0uc29mdG1lbWVzLm15ZmVlZC52MS5TdWJzY3JpcHRpb25SDXN1YnNjcmlwdGlvbnMSOQoEcGFn'
    'ZRgCIAEoCzIlLmNvbS5zb2Z0bWVtZXMubXlmZWVkLnYxLlBhZ2VSZXNwb25zZVIEcGFnZQ==');
