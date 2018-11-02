import 'package:quiver/core.dart';

import 'lookup_key.dart';

/// A type that the user is trying to inject with associated metadata about how
/// the user is trying to inject it.
class InjectedType {
  /// The type the user is trying to inject.
  final LookupKey lookupKey;

  /// True if the user is trying to inject [LookupKey] using a function type. If
  /// false, the user is trying to inject the type directly.
  final bool isProvider;

  InjectedType(this.lookupKey, {this.isProvider = false});

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [InjectedType.toJson].
  factory InjectedType.fromJson(Map<String, dynamic> json) {
    return new InjectedType(
      new LookupKey.fromJson(
          (json['lookupKey'] as Map).cast<String, dynamic>()),
      isProvider: json['isProvider'],
    );
  }

  /// Returns the JSON encoding of this instance.
  ///
  /// See also [InjectedType.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'lookupKey': lookupKey.toJson(),
      'isProvider': isProvider,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectedType &&
          runtimeType == other.runtimeType &&
          lookupKey == other.lookupKey &&
          isProvider == other.isProvider;

  @override
  int get hashCode {
    // Not all fields are here. See the equals method doc for more info.
    return hash2(lookupKey, isProvider);
  }

  @override
  String toString() {
    return '$InjectedType{'
        'lookupKey: $lookupKey, '
        'isProvider: $isProvider}';
  }
}
