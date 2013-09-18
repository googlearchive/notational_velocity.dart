part of nv.shared;

const _VALUE = const Symbol('value');
const _IS_UPDATED = const Symbol('isUpdated');

class BackgroundUpdate<E> extends ChangeNotifierMixin {
  final _UpdateMethod _updateMethod;

  BackgroundUpdate.withNew(this._updateMethod, E newValue) {
    this.value = newValue;
  }

  BackgroundUpdate(this._updateMethod, [E value]) {
    _storedValue = _pendingValue = _currentValue = value;
  }

  E _storedValue;
  E _pendingValue;
  E _currentValue;

  Completer<E> _completer;

  E get value => _currentValue;

  void set value(E val) {
    _assertInvariants();
    if(val != _currentValue) {
      _currentValue = val;
      _notifyPropChange(_VALUE);
      _doUpdate();
    }
  }

  bool get isUpdated => _completer == null;

  Future<E> get updatedValue {
    _assertInvariants();
    if(isUpdated) {
      return new Future<E>.sync(() {
        _assertInvariants();
        return _currentValue;
      });
    }
    return _completer.future;
  }

  //
  // Implementation
  //

  void _notifyPropChange(Symbol field) {
    notifyChange(new PropertyChangeRecord(field));
  }

  void _doUpdate() {
    if(_completer == null) {
      _completer = new Completer<E>();
      _notifyPropChange(_IS_UPDATED);
      _pendingValue = _currentValue;
      _updateMethod(_pendingValue).then((_) => _onUpdateMethodComplete());
    }
  }

  void _onUpdateMethodComplete() {
    _assertInvariants();
    _storedValue = _pendingValue;

    if(_currentValue == _pendingValue) {
      _completer.complete(_currentValue);
      _completer = null;
      _notifyPropChange(_IS_UPDATED);
    } else {
      _pendingValue = _currentValue;
      _updateMethod(_pendingValue).then((_) => _onUpdateMethodComplete());
    }
  }

  void _assertInvariants() {
    if(isUpdated) {
      assert(_completer == null);
      assert(_storedValue == _pendingValue);
      assert(_pendingValue == _currentValue);
    } else {
      assert(_completer != null);
      assert(_currentValue != _pendingValue || _pendingValue != _storedValue);
    }
  }

}

typedef Future _UpdateMethod<E>(E value);
