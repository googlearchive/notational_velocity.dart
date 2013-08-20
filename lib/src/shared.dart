library nv.shared;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bot/bot.dart';
import 'package:observe/observe.dart';
import 'package:meta/meta.dart';

part 'shared/read_only_observable_list.dart';
part 'shared/split.dart';

class NVError extends Error {
  final String message;

  NVError(this.message) {
    assert(message != null);
    assert(message.isNotEmpty);
  }

  @override
  String toString() => 'NVError: $message';
}

class LoadState {
  final String _msg;

  static const LoadState UNLOADED = const LoadState._('unloaded');
  static const LoadState LOADING = const LoadState._('loading');
  static const LoadState LOADED = const LoadState._('loaded');

  const LoadState._(this._msg);

  @override
  String toString() => _msg;
}

abstract class Loadable implements Observable {
  Future load();
  LoadState get loadState;
  bool get isLoaded;
}

Stream<PropertyChangeRecord> filterPropertyChangeRecords(
    Observable source, Symbol matchingSymbol) =>
        source.changes.transform(new _PropChangeFilterTransform(matchingSymbol));

Future<PropertyChangeRecord> firstPropChangeRecord(Observable source,
    Symbol matchingSymbol) =>
        filterPropertyChangeRecords(source, matchingSymbol).first;

class _PropChangeFilterTransform extends StreamEventTransformer<List<ChangeRecord>, PropertyChangeRecord> {
  final Symbol targetProperty;

  _PropChangeFilterTransform(this.targetProperty);

  @override
  void handleData(List<ChangeRecord> records, EventSink<PropertyChangeRecord> sink) {
    var matches = records
        .where((r) => r is PropertyChangeRecord)
        .where((PropertyChangeRecord pcr) => pcr.field == targetProperty)
        .toList();

    if(matches.isNotEmpty) {
      sink.add(matches.first);
    }
  }
}
