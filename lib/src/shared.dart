library nv.shared;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bot/bot.dart';
import 'package:observe/observe.dart';
import 'package:meta/meta.dart';

part 'shared/collection_view.dart';
part 'shared/mapped_list_view.dart';
part 'shared/observable_list_view.dart';
part 'shared/split.dart';

typedef bool Predicate<E>(E item);
typedef int Sorter<E>(E a, E b);

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

abstract class ChangeNotifierList<E> extends ListBase<E>
  with ChangeNotifierMixin implements ObservableList<E> {

  void operator []=(int index, E value) {
    throw new UnsupportedError(
        "Cannot modify an unmodifiable list");
  }

  void set length(int newLength) {
    throw new UnsupportedError(
        "Cannot change the length of an unmodifiable list");
  }

  void setAll(int at, Iterable<E> iterable) {
    throw new UnsupportedError(
        "Cannot modify an unmodifiable list");
  }

  void add(E value) {
    throw new UnsupportedError(
      "Cannot add to an unmodifiable list");
  }

  E insert(int index, E value) {
    throw new UnsupportedError(
        "Cannot add to an unmodifiable list");
  }

  void insertAll(int at, Iterable<E> iterable) {
    throw new UnsupportedError(
        "Cannot add to an unmodifiable list");
  }

  void addAll(Iterable<E> iterable) {
    throw new UnsupportedError(
        "Cannot add to an unmodifiable list");
  }

  bool remove(Object element) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void removeWhere(bool test(E element)) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void retainWhere(bool test(E element)) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void sort([Comparator<E> compare]) {
    throw new UnsupportedError(
        "Cannot modify an unmodifiable list");
  }

  void clear() {
    throw new UnsupportedError(
        "Cannot clear an unmodifiable list");
  }

  E removeAt(int index) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  E removeLast() {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    throw new UnsupportedError(
        "Cannot modify an unmodifiable list");
  }

  void removeRange(int start, int end) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void replaceRange(int start, int end, Iterable<E> iterable) {
    throw new UnsupportedError(
        "Cannot remove from an unmodifiable list");
  }

  void fillRange(int start, int end, [E fillValue]) {
    throw new UnsupportedError(
        "Cannot modify an unmodifiable list");
  }
}
