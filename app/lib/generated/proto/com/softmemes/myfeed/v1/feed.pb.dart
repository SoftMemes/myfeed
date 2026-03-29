// This is a generated file - do not edit.
//
// Generated from com/softmemes/myfeed/v1/feed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

import 'common.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// FeedItem is a single piece of content surfaced in the user's feed.
/// It is produced by a Subscription and links back to both the Source and the
/// Subscription that generated it. Consumption happens on the original platform;
/// myfeed surfaces a preview and link only.
/// platform_type mirrors Source.platform_type (e.g. "youtube", "rss").
class FeedItem extends $pb.GeneratedMessage {
  factory FeedItem({
    $core.String? id,
    $core.String? sourceId,
    $core.String? subscriptionId,
    $core.String? platformType,
    $core.String? title,
    $core.String? description,
    $core.String? url,
    $core.String? imageUrl,
    $1.Timestamp? publishedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sourceId != null) result.sourceId = sourceId;
    if (subscriptionId != null) result.subscriptionId = subscriptionId;
    if (platformType != null) result.platformType = platformType;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (url != null) result.url = url;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (publishedAt != null) result.publishedAt = publishedAt;
    return result;
  }

  FeedItem._();

  factory FeedItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeedItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeedItem',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'com.softmemes.myfeed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sourceId')
    ..aOS(3, _omitFieldNames ? '' : 'subscriptionId')
    ..aOS(4, _omitFieldNames ? '' : 'platformType')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'url')
    ..aOS(8, _omitFieldNames ? '' : 'imageUrl')
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'publishedAt',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeedItem copyWith(void Function(FeedItem) updates) =>
      super.copyWith((message) => updates(message as FeedItem)) as FeedItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeedItem create() => FeedItem._();
  @$core.override
  FeedItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeedItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedItem>(create);
  static FeedItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sourceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get subscriptionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set subscriptionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubscriptionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubscriptionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get platformType => $_getSZ(3);
  @$pb.TagNumber(4)
  set platformType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPlatformType() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlatformType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  /// URL to the content on the original platform.
  @$pb.TagNumber(7)
  $core.String get url => $_getSZ(6);
  @$pb.TagNumber(7)
  set url($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get imageUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set imageUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasImageUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearImageUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.Timestamp get publishedAt => $_getN(8);
  @$pb.TagNumber(9)
  set publishedAt($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPublishedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearPublishedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensurePublishedAt() => $_ensure(8);
}

class GetFeedRequest extends $pb.GeneratedMessage {
  factory GetFeedRequest({
    $2.PageRequest? page,
    $core.String? sourceId,
    $core.String? subscriptionId,
    $1.Timestamp? after,
    $1.Timestamp? before,
  }) {
    final result = create();
    if (page != null) result.page = page;
    if (sourceId != null) result.sourceId = sourceId;
    if (subscriptionId != null) result.subscriptionId = subscriptionId;
    if (after != null) result.after = after;
    if (before != null) result.before = before;
    return result;
  }

  GetFeedRequest._();

  factory GetFeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFeedRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'com.softmemes.myfeed.v1'),
      createEmptyInstance: create)
    ..aOM<$2.PageRequest>(1, _omitFieldNames ? '' : 'page',
        subBuilder: $2.PageRequest.create)
    ..aOS(2, _omitFieldNames ? '' : 'sourceId')
    ..aOS(3, _omitFieldNames ? '' : 'subscriptionId')
    ..aOM<$1.Timestamp>(4, _omitFieldNames ? '' : 'after',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'before',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedRequest copyWith(void Function(GetFeedRequest) updates) =>
      super.copyWith((message) => updates(message as GetFeedRequest))
          as GetFeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFeedRequest create() => GetFeedRequest._();
  @$core.override
  GetFeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFeedRequest>(create);
  static GetFeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.PageRequest get page => $_getN(0);
  @$pb.TagNumber(1)
  set page($2.PageRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPage() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.PageRequest ensurePage() => $_ensure(0);

  /// Filter to a specific source connection.
  @$pb.TagNumber(2)
  $core.String get sourceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceId() => $_clearField(2);

  /// Filter to a specific subscription (e.g. one channel).
  @$pb.TagNumber(3)
  $core.String get subscriptionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set subscriptionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubscriptionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubscriptionId() => $_clearField(3);

  /// Return only items published after this timestamp.
  @$pb.TagNumber(4)
  $1.Timestamp get after => $_getN(3);
  @$pb.TagNumber(4)
  set after($1.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAfter() => $_has(3);
  @$pb.TagNumber(4)
  void clearAfter() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Timestamp ensureAfter() => $_ensure(3);

  /// Return only items published before this timestamp.
  @$pb.TagNumber(5)
  $1.Timestamp get before => $_getN(4);
  @$pb.TagNumber(5)
  set before($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBefore() => $_has(4);
  @$pb.TagNumber(5)
  void clearBefore() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureBefore() => $_ensure(4);
}

class GetFeedResponse extends $pb.GeneratedMessage {
  factory GetFeedResponse({
    $core.Iterable<FeedItem>? items,
    $2.PageResponse? page,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (page != null) result.page = page;
    return result;
  }

  GetFeedResponse._();

  factory GetFeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFeedResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'com.softmemes.myfeed.v1'),
      createEmptyInstance: create)
    ..pPM<FeedItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: FeedItem.create)
    ..aOM<$2.PageResponse>(2, _omitFieldNames ? '' : 'page',
        subBuilder: $2.PageResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFeedResponse copyWith(void Function(GetFeedResponse) updates) =>
      super.copyWith((message) => updates(message as GetFeedResponse))
          as GetFeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFeedResponse create() => GetFeedResponse._();
  @$core.override
  GetFeedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFeedResponse>(create);
  static GetFeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FeedItem> get items => $_getList(0);

  @$pb.TagNumber(2)
  $2.PageResponse get page => $_getN(1);
  @$pb.TagNumber(2)
  set page($2.PageResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.PageResponse ensurePage() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
