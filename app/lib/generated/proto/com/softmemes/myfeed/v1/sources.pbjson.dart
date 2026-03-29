// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/sources.proto.

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

@$core.Deprecated('Use sourceDescriptor instead')
const Source$json = {
  '1': 'Source',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'platform_type', '3': 2, '4': 1, '5': 9, '10': 'platformType'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Source`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sourceDescriptor = $convert.base64Decode(
    'CgZTb3VyY2USDgoCaWQYASABKAlSAmlkEiMKDXBsYXRmb3JtX3R5cGUYAiABKAlSDHBsYXRmb3'
    'JtVHlwZRIhCgxkaXNwbGF5X25hbWUYAyABKAlSC2Rpc3BsYXlOYW1lEjkKCmNyZWF0ZWRfYXQY'
    'BCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use subscribableDescriptor instead')
const Subscribable$json = {
  '1': 'Subscribable',
  '2': [
    {'1': 'external_id', '3': 1, '4': 1, '5': 9, '10': 'externalId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 4, '4': 1, '5': 9, '10': 'imageUrl'},
  ],
};

/// Descriptor for `Subscribable`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribableDescriptor = $convert.base64Decode(
    'CgxTdWJzY3JpYmFibGUSHwoLZXh0ZXJuYWxfaWQYASABKAlSCmV4dGVybmFsSWQSIQoMZGlzcG'
    'xheV9uYW1lGAIgASgJUgtkaXNwbGF5TmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3Jp'
    'cHRpb24SGwoJaW1hZ2VfdXJsGAQgASgJUghpbWFnZVVybA==');
