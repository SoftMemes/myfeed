// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/sources.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Source is a user's connection to a content platform (e.g. a YouTube account,
/// a podcast aggregator). A user may have multiple Sources for the same platform.
/// platform_type is a free-form string identifier (e.g. "youtube", "rss") — not
/// an enum, so new platforms require no proto change.
class Source extends $pb.GeneratedMessage {
  factory Source({
    $core.String? id,
    $core.String? platformType,
    $core.String? displayName,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (platformType != null) result.platformType = platformType;
    if (displayName != null) result.displayName = displayName;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Source._();

  factory Source.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Source.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Source',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'com.softmemes.myfeed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'platformType')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Source clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Source copyWith(void Function(Source) updates) =>
      super.copyWith((message) => updates(message as Source)) as Source;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Source create() => Source._();
  @$core.override
  Source createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Source getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Source>(create);
  static Source? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Free-form platform identifier, e.g. "youtube", "netflix", "rss".
  @$pb.TagNumber(2)
  $core.String get platformType => $_getSZ(1);
  @$pb.TagNumber(2)
  set platformType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlatformType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatformType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreatedAt() => $_ensure(3);
}

/// Subscribable is a candidate returned by SearchSubscribables — something the
/// user could subscribe to but has not yet. external_id is the platform's own
/// identifier for this item (e.g. a YouTube channel ID).
class Subscribable extends $pb.GeneratedMessage {
  factory Subscribable({
    $core.String? externalId,
    $core.String? displayName,
    $core.String? description,
    $core.String? imageUrl,
  }) {
    final result = create();
    if (externalId != null) result.externalId = externalId;
    if (displayName != null) result.displayName = displayName;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    return result;
  }

  Subscribable._();

  factory Subscribable.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Subscribable.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Subscribable',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'com.softmemes.myfeed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'externalId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'imageUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscribable clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Subscribable copyWith(void Function(Subscribable) updates) =>
      super.copyWith((message) => updates(message as Subscribable))
          as Subscribable;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Subscribable create() => Subscribable._();
  @$core.override
  Subscribable createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Subscribable getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Subscribable>(create);
  static Subscribable? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get externalId => $_getSZ(0);
  @$pb.TagNumber(1)
  set externalId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExternalId() => $_has(0);
  @$pb.TagNumber(1)
  void clearExternalId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get imageUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImageUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageUrl() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
