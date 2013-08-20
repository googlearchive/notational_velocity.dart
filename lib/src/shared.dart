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


Future<PropertyChangeRecord> firstPropChangeRecord(Observable source,
    Symbol matchingSymbol) =>
  source.changes
      .map((List<ChangeRecord> changes) {
        return changes
            .where((c) => c is PropertyChangeRecord)
            .where((PropertyChangeRecord pcr) => pcr.field == matchingSymbol)
            .toList();
      })
      .where((List<ChangeRecord> records) => records.isNotEmpty)
      .first.then((List<ChangeRecord> records) {
        return records.single;
      });
