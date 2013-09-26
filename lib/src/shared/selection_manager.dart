part of nv.shared;

// TODO: need a callback in _MappedListViewBase to handle clean-up of disposed
// wrappers?

class SelectionManager<E> extends _MappedListViewBase<E, Selectable<E>> {
  List<E> get source => super._source;

  int _selectedIndex = -1;
  Selectable<E> _cachedSelectedItem;

  SelectionManager(List<E> source) :
    super(source);

  int get length {
    _ensureConsistent();
    return super.length;
  }

  Selectable<E> operator[](int index) {
    _ensureConsistent();
    return super[index];
  }

  E get selectedValue {
    _ensureConsistent();
    return hasSelection ? _cachedSelectedItem.value : null;
  }

  void set selectedValue(E value) {
    var index = _source.indexOf(value);
    selectedIndex = index;
  }

  int get selectedIndex {
    _ensureConsistent();
    return _selectedIndex;
  }

  void set selectedIndex(int value) {
    assert(value != null);
    assert(value >= -1);
    assert(value < source.length);
    _ensureConsistent();

    if(value == _selectedIndex) {
      if(value == -1) {
        assert(_cachedSelectedItem == null);
      } else {
        assert(super[_selectedIndex] == _cachedSelectedItem);
        assert(_cachedSelectedItem.isSelected);
      }
      return;
    }

    var oldSelection = hasSelection;
    if(oldSelection) {
      assert(_cachedSelectedItem != null);
      assert(_cachedSelectedItem.isSelected);

      // again, being very paranoid
      var cacheAtIndex = super._getCachedValueAtIndex(_selectedIndex);
      if(cacheAtIndex != _cachedSelectedItem) {
        // assume that the vaulue for _cachedSelectedItem has been removed
        assert(!source.contains(_cachedSelectedItem.value));
        _cachedSelectedItem._updateIsSelectedValue(null);
      } else {
        assert(_cachedSelectedItem == cacheAtIndex);
        cacheAtIndex._updateIsSelectedValue(false);
      }
      _cachedSelectedItem = null;
    }

    _selectedIndex = value;
    if(value > -1) {
      assert(_cachedSelectedItem == null);

      // using super call to avoid validation
      _cachedSelectedItem = super[_selectedIndex];

      // It's possible the item has never been accessed, which means the
      // previous call to this[_selectedIndex] created a new item...which is
      // created selected! No need to update value...fire events, etc
      if(!_cachedSelectedItem.isSelected) {
        _cachedSelectedItem._updateIsSelectedValue(true);
      }
    }

    _notifyPropChange(const Symbol('selectedIndex'));
    _notifyPropChange(const Symbol('selectedValue'));
    if(oldSelection != hasSelection) {
      _notifyPropChange(const Symbol('hasSelection'));
    }
  }

  bool get hasSelection {
    _ensureConsistent();
    return _cachedSelectedItem != null;
  }

  //
  // Impl
  //

  void _ensureConsistent() {
    assert((_selectedIndex == -1) == (_cachedSelectedItem == null));

    if(_cachedSelectedItem != null &&
        (_selectedIndex >= source.length ||
        _cachedSelectedItem.value != source[_selectedIndex])) {

      var sourceSelectedValueIndex = _source.indexOf(_cachedSelectedItem.value);
      if(sourceSelectedValueIndex >= 0) {
        assert(sourceSelectedValueIndex != _selectedIndex);

        // Fix up the selected index value
        _selectedIndex = sourceSelectedValueIndex;
        _notifyPropChange(const Symbol('selectedIndex'));
      } else {
        // the selected value has been removed! Need to clean up!
        _cachedSelectedItem._updateIsSelectedValue(null);
        _cachedSelectedItem = null;
        _selectedIndex = -1;

        _notifyPropChange(const Symbol('selectedIndex'));
        _notifyPropChange(const Symbol('selectedValue'));
        _notifyPropChange(const Symbol('hasSelection'));
      }
    }

    assert(_cachedSelectedItem == null || identical(_cachedSelectedItem, super[_selectedIndex]));
  }

  @override
  Selectable<E> _wrap(int index, E item) {
    // should never try to re-wrap the _cachedSelectedItem, if it exists
    assert(_cachedSelectedItem == null || _cachedSelectedItem.value != item);

    var entry = new Selectable<E>._(item, this._requestSelect);

    if(index == _selectedIndex) {
      // should be creating the _cachedSelectedItem here
      assert(_cachedSelectedItem == null);
      _cachedSelectedItem = entry;
      entry._isSelected = true;
    }

    return entry;
  }

  void _requestSelect(Selectable<E> item, bool value) {
    var itemIndex = this.indexOf(item);

    // TODO: should throw a real exception in this case
    assert(itemIndex >= 0);

    if(value && itemIndex != _selectedIndex) {
      // requesting to select the non-current item
      this.selectedIndex = itemIndex;
    } else if(!value && itemIndex == _selectedIndex) {
      // requesting to unselect the current item
      this.selectedIndex = -1;
    } else {
      // it appears that the user is requesting a no-op, right?
      assert(item.isSelected == value);
    }
  }

  @override
  void _list_changes(List<ChangeRecord> changes) {
    super._list_changes(changes);

    // fix up selection
    if(hasSelection) {
      assert(_cachedSelectedItem != null);
      assert(_cachedSelectedItem.isSelected);
      assert(_selectedIndex != null);
      if(_selectedIndex >= source.length) {
        _selectedIndex = null;
      }

      // NOTE: the core cache has likely been cleared
      if(_selectedIndex != null &&
          _cachedSelectedItem.value == source[_selectedIndex]) {
        // the selection hasn't changed locations...this is easy

        var currentWrapper = this[_selectedIndex];

        // this will likely fail in some cases
        // ponder pre-populating super._cache w/ the old instance
        assert(identical(_cachedSelectedItem, currentWrapper));

        return;
      }

      E cachedSelectedValue = _cachedSelectedItem.value;
      var newSelectedIndex = source.indexOf(cachedSelectedValue);

      // paranoid
      assert(newSelectedIndex != _selectedIndex);

      if(newSelectedIndex == -1) {
        // TODO: should we 'freeze' the now obsolete Selectable? Something?

        // Now 'manually' update the selectedIndex and fire the prop change
        _selectedIndex = -1;

        // freeze!
        _cachedSelectedItem._updateIsSelectedValue(null);

        _cachedSelectedItem = null;
        _notifyPropChange(const Symbol('selectedIndex'));
        _notifyPropChange(const Symbol('selectedValue'));
        _notifyPropChange(const Symbol('hasSelection'));
      } else {
        // The selection is still exists, perhaps moved

        // first, super._cache for the selected item should equal our existing
        // item or be null...

        var cachedSelectedItem = super._cache.putIfAbsent(cachedSelectedValue,
            () => _cachedSelectedItem);

        assert(cachedSelectedItem == _cachedSelectedItem);

        // Now 'manually' update the selectedIndex and fire the prop change
        _selectedIndex = newSelectedIndex;
        _notifyPropChange(const Symbol('selectedIndex'));
      }

    }
  }
}

typedef void RequestSelect<E>(Selectable<E> item, bool requestedValue);

class Selectable<E> extends ChangeNotifierBase {
  final E value;
  final RequestSelect<E> _requestSelect;

  bool _isSelected = false;

  Selectable._(this.value, this._requestSelect);

  bool get isSelected => _isSelected;

  void set isSelected(bool value) {
    if(_isSelected == null) {
      throw new InvalidOperationError('Item was removed from SelectionManager.');
    }
    _requestSelect(this, value);
  }

  String toString() => "$runtimeType :: $value";

  //
  // Implementation
  //

  /**
   * Called by the owning SelectionManager to actually change the selected value
   * and fire events
   */
  void _updateIsSelectedValue(bool selectionVal) {
    // generally, the caller should be smart enough to not do no-ops, right?
    assert(selectionVal != _isSelected);

    // value should only be 'frozen' once
    assert(_isSelected != null);

    var oldValue = _isSelected;
    _isSelected = selectionVal;
    notifyPropertyChange(const Symbol('isSelected'), oldValue, _isSelected);
  }

}
