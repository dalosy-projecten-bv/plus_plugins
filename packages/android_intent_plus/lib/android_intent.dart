// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:android_intent_plus/src/bundles/bundles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

export 'src/bundles/bundles.dart';
export 'src/parcelable_classes/base/parcelable_base.dart';
export 'src/parcelable_classes/bundle.dart';
export 'src/put_classes/put_bool.dart';
export 'src/put_classes/put_bool_array.dart';
export 'src/put_classes/put_bundle.dart';
export 'src/put_classes/put_byte.dart';
export 'src/put_classes/put_byte_array.dart';
export 'src/put_classes/put_char.dart';
export 'src/put_classes/put_char_array.dart';
export 'src/put_classes/put_char_sequence.dart';
export 'src/put_classes/put_char_sequence_array.dart';
export 'src/put_classes/put_char_sequence_array_list.dart';
export 'src/put_classes/put_double.dart';
export 'src/put_classes/put_double_array.dart';
export 'src/put_classes/put_float.dart';
export 'src/put_classes/put_float_array.dart';
export 'src/put_classes/put_int.dart';
export 'src/put_classes/put_int_array.dart';
export 'src/put_classes/put_integer_array_list.dart';
export 'src/put_classes/put_long.dart';
export 'src/put_classes/put_long_array.dart';
export 'src/put_classes/put_parcelable.dart';
export 'src/put_classes/put_parcelable_array.dart';
export 'src/put_classes/put_parcelable_array_list.dart';
export 'src/put_classes/put_short.dart';
export 'src/put_classes/put_short_array.dart';
export 'src/put_classes/put_string.dart';
export 'src/put_classes/put_string_array.dart';
export 'src/put_classes/put_string_array_list.dart';
export 'src/test_values.dart';

const String _kChannelName = 'dev.fluttercommunity.plus/android_intent';

/// Flutter plugin for launching arbitrary Android Intents.
///
/// See [the official Android
/// documentation](https://developer.android.com/reference/android/content/Intent.html)
/// for more information on how to use Intents.
class AndroidIntent {
  /// Builds an Android intent with the following parameters
  /// [action] refers to the action parameter of the intent.
  /// [flags] is the list of int that will be converted to native flags.
  /// [category] refers to the category of the intent, can be null.
  /// [data] refers to the string format of the URI that will be passed to
  /// intent.
  /// [arguments] is the map that will be converted into an extras bundle and
  /// passed to the intent.
  /// [arrayArguments] is a map that will be converted into an extra bundle
  /// as in an array and passed to the intent.
  /// [package] refers to the package parameter of the intent, can be null.
  /// [componentName] refers to the component name of the intent, can be null.
  /// If not null, then [package] but also be provided.
  /// [type] refers to the type of the intent, can be null.
  const AndroidIntent({
    this.action,
    this.flags,
    this.category,
    this.data,
    this.arguments,
    this.extras,
    this.arrayArguments,
    this.package,
    this.componentName,
    Platform? platform,
    this.type,
  })  : assert(action != null || componentName != null,
            'action or component (or both) must be specified'),
        _channel = const MethodChannel(_kChannelName),
        _platform = platform ?? const LocalPlatform();

  /// This constructor is only exposed for unit testing. Do not rely on this in
  /// app code, it may break without warning.
  @visibleForTesting
  AndroidIntent.private({
    required Platform platform,
    required MethodChannel channel,
    this.action,
    this.flags,
    this.category,
    this.data,
    this.arguments,
    this.extras,
    this.arrayArguments,
    this.package,
    this.componentName,
    this.type,
  })  : assert(action != null || componentName != null,
            'action or component (or both) must be specified'),
        _channel = channel,
        _platform = platform;

  /// This is the general verb that the intent should attempt to do. This
  /// includes constants like `ACTION_VIEW`.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#intent-structure.
  final String? action;

  /// Constants that can be set on an intent to tweak how it is finally handled.
  /// Some of the constants are mirrored to Dart via [Flag].
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#setFlags(int).
  final List<int>? flags;

  /// An optional additional constant qualifying the given [action].
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#intent-structure.
  final String? category;

  /// The Uri that the [action] is pointed towards.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#intent-structure.
  final String? data;

  /// The equivalent of `extras`, a generic `Bundle` of data that the Intent can
  /// carry. This is a slot for extraneous data that the listener may use.
  ///
  /// If the argument contains a list value, then the value will be put in as an
  /// array list.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#intent-structure.
  final Map<String, dynamic>? arguments;

  /// Similar to [arguments] and [arrayArguments], but in this case the list
  /// can contain nested values, bundles and arrays. The tree is constructed
  /// with classes like PutString, PutStringArray and PutStringArrayList.
  /// Not all types are implemented; PutChar, PutCharArray, PutByte etc are
  /// still missing. Please add them when needed.
  /// Sample:
  /// AndroidIntent datawedgeProfile() => AndroidIntent(
  //         action: constants.datawedgeAction,
  //         extras: [
  //           Bundle(
  //             values: [
  //               PutBundle(
  //                 key: constants.extraSetConfig,
  //                 values: [
  //                   PutString(
  //                     key: 'PROFILE_NAME',
  //                     value: constants.extraProfileName,
  //                   ),
  //                   PutString(
  //                     key: 'PROFILE_ENABLED',
  //                     value: 'true',
  //                   ),
  //                   PutString(
  //                     key: 'CONFIG_MODE',
  //                     value: 'CREATE_IF_NOT_EXIST',
  //                   ),
  //                   PutParcelableArray(
  //                     key: 'APP_LIST',
  //                     values: [
  //                       appList(),
  //                     ],
  //                   ),
  //                   PutParcelableArrayList(
  //                     key: 'PLUGIN_CONFIG',
  //                     values: [
  //                       barcodePluginConfig(),
  //                       intentPluginConfig(),
  //                       keystrokePluginConfig(),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  final Bundles? extras;

  /// Similar to [arguments], but in this case the arguments are an array and
  /// will be added to the intent as in an array extra instead of of an array
  /// list.
  final Map<String, List<dynamic>>? arrayArguments;

  /// Sets the [data] to only resolve within this given package.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#setPackage(java.lang.String).
  final String? package;

  /// Set the exact `ComponentName` that should handle the intent. If this is
  /// set [package] should also be non-null.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#setComponent(android.content.ComponentName).
  final String? componentName;
  final MethodChannel _channel;
  final Platform _platform;

  /// Set an explicit MIME data type.
  ///
  /// See https://developer.android.com/reference/android/content/Intent.html#intent-structure.
  final String? type;

  bool _isPowerOfTwo(int x) {
    /* First x in the below expression is for the case when x is 0 */
    return x != 0 && ((x & (x - 1)) == 0);
  }

  /// This method is just visible for unit testing and should not be relied on.
  /// Its method signature may change at any time.
  @visibleForTesting
  int convertFlags(List<int> flags) {
    var finalValue = 0;
    for (var i = 0; i < flags.length; i++) {
      if (!_isPowerOfTwo(flags[i])) {
        throw ArgumentError.value(flags[i], 'flag\'s value must be power of 2');
      }
      finalValue |= flags[i];
    }
    return finalValue;
  }

  /// Launch the intent.
  ///
  /// This works only on Android platforms.
  Future<void> launch() async {
    if (!_platform.isAndroid) {
      return;
    }

    await _channel.invokeMethod<void>('launch', _buildArguments());
  }

  /// Launch the intent with 'createChooser(intent, title)'.
  ///
  /// This works only on Android platforms.
  Future<void> launchChooser(String title) async {
    if (!_platform.isAndroid) {
      return;
    }

    final buildArguments = _buildArguments();
    buildArguments['chooserTitle'] = title;
    await _channel.invokeMethod<void>(
      'launchChooser',
      buildArguments,
    );
  }

  /// Sends intent as broadcast.
  ///
  /// This works only on Android platforms.
  Future<void> sendBroadcast() async {
    if (!_platform.isAndroid) {
      return;
    }

    await _channel.invokeMethod<void>(
      'sendBroadcast',
      _buildArguments(),
    );
  }

  /// Check whether the intent can be resolved to an activity.
  ///
  /// This works only on Android platforms.
  Future<bool?> canResolveActivity() async {
    if (!_platform.isAndroid) {
      return false;
    }

    return await _channel.invokeMethod<bool>(
      'canResolveActivity',
      _buildArguments(),
    );
  }

  /// Constructs the map of arguments which is passed to the plugin.
  Map<String, dynamic> _buildArguments() {
    String? extras;
    if (this.extras != null) {
      late JsonEncoder jsonEncoder;
      kDebugMode
          ? jsonEncoder = const JsonEncoder.withIndent('  ')
          : jsonEncoder = const JsonEncoder();
      extras = jsonEncoder.convert(this.extras);
    }
    return {
      if (action != null) 'action': action,
      if (flags != null) 'flags': convertFlags(flags!),
      if (category != null) 'category': category,
      if (data != null) 'data': data,
      if (arguments != null) 'arguments': arguments,
      if (extras != null) 'extras': extras,
      if (arrayArguments != null) 'arrayArguments': arrayArguments,
      if (package != null) ...{
        'package': package,
        if (componentName != null) 'componentName': componentName,
      },
      if (type != null) 'type': type,
    };
  }
}
