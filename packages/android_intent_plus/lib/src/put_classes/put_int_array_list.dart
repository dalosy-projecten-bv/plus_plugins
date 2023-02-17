import 'package:android_intent_plus/src/put_classes/base/put_base.dart';

class PutIntArrayList extends PutBase<List<int>> {
  PutIntArrayList({required String key, required List<int> value})
      : super(key: key, value: value);

  @override
  String get javaClass => 'PutIntArrayList';
}
