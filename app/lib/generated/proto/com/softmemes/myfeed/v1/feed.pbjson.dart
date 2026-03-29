// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/feed.proto.

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

@$core.Deprecated('Use feedItemDescriptor instead')
const FeedItem$json = {
  '1': 'FeedItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'source_id', '3': 2, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'subscription_id', '3': 3, '4': 1, '5': 9, '10': 'subscriptionId'},
    {'1': 'platform_type', '3': 4, '4': 1, '5': 9, '10': 'platformType'},
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'url', '3': 7, '4': 1, '5': 9, '10': 'url'},
    {'1': 'image_url', '3': 8, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'published_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'publishedAt'
    },
  ],
};

/// Descriptor for `FeedItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feedItemDescriptor = $convert.base64Decode(
    'CghGZWVkSXRlbRIOCgJpZBgBIAEoCVICaWQSGwoJc291cmNlX2lkGAIgASgJUghzb3VyY2VJZB'
    'InCg9zdWJzY3JpcHRpb25faWQYAyABKAlSDnN1YnNjcmlwdGlvbklkEiMKDXBsYXRmb3JtX3R5'
    'cGUYBCABKAlSDHBsYXRmb3JtVHlwZRIUCgV0aXRsZRgFIAEoCVIFdGl0bGUSIAoLZGVzY3JpcH'
    'Rpb24YBiABKAlSC2Rlc2NyaXB0aW9uEhAKA3VybBgHIAEoCVIDdXJsEhsKCWltYWdlX3VybBgI'
    'IAEoCVIIaW1hZ2VVcmwSPQoMcHVibGlzaGVkX2F0GAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFILcHVibGlzaGVkQXQ=');

@$core.Deprecated('Use getFeedRequestDescriptor instead')
const GetFeedRequest$json = {
  '1': 'GetFeedRequest',
  '2': [
    {
      '1': 'page',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.PageRequest',
      '10': 'page'
    },
    {'1': 'source_id', '3': 2, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'subscription_id', '3': 3, '4': 1, '5': 9, '10': 'subscriptionId'},
    {
      '1': 'after',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'after'
    },
    {
      '1': 'before',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'before'
    },
  ],
};

/// Descriptor for `GetFeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFeedRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRGZWVkUmVxdWVzdBI4CgRwYWdlGAEgASgLMiQuY29tLnNvZnRtZW1lcy5teWZlZWQudj'
    'EuUGFnZVJlcXVlc3RSBHBhZ2USGwoJc291cmNlX2lkGAIgASgJUghzb3VyY2VJZBInCg9zdWJz'
    'Y3JpcHRpb25faWQYAyABKAlSDnN1YnNjcmlwdGlvbklkEjAKBWFmdGVyGAQgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIFYWZ0ZXISMgoGYmVmb3JlGAUgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIGYmVmb3Jl');

@$core.Deprecated('Use getFeedResponseDescriptor instead')
const GetFeedResponse$json = {
  '1': 'GetFeedResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.com.softmemes.myfeed.v1.FeedItem',
      '10': 'items'
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

/// Descriptor for `GetFeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFeedResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRGZWVkUmVzcG9uc2USNwoFaXRlbXMYASADKAsyIS5jb20uc29mdG1lbWVzLm15ZmVlZC'
    '52MS5GZWVkSXRlbVIFaXRlbXMSOQoEcGFnZRgCIAEoCzIlLmNvbS5zb2Z0bWVtZXMubXlmZWVk'
    'LnYxLlBhZ2VSZXNwb25zZVIEcGFnZQ==');
