library nv.storage;

import 'dart:async';
import 'dart:json' as JSON;
import 'package:meta/meta.dart';
import 'package:bot/bot.dart';

part 'storage/nested_storage.dart';
part 'storage/string_storage.dart';

/**
 * By convention, the only supported value types should be JSON-serializable
 */
abstract class Storage {

  bool get isDisposed;

  Future set(String key, value);

  Future<dynamic> get(String key);

  Future<bool> exists(String key);

  Future remove(String key);

  Future clear();

  Future<List<String>> getKeys();

  Future addAll(Map<String, dynamic> values);

  void dispose();
}
