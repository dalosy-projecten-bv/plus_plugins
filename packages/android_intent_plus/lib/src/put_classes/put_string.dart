import 'package:android_intent_plus/src/put_classes/base/put_base.dart';

class PutString extends PutBase<String> {
  PutString({required String key, required String value})
      : super(key: key, value: value);

  @override
  String get javaClass => 'PutString';

  factory PutString.fromJson({required String key, required dynamic value}) {
    return PutString(key: key, value: value as String);
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'javaClass': javaClass,
      'value': value,
    };
  }
}
