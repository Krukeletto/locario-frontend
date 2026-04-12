import 'dart:collection';

import 'package:flutter/material.dart';

import '../../explore/models.dart';

class ShellHeaderController extends ChangeNotifier {
  static const int allFilterIndex = 0;

  ExploreContentView _selectedView = ExploreContentView.map;
  Set<int> _selectedFilterIndices = {allFilterIndex};

  ExploreContentView get selectedView => _selectedView;
  Set<int> get selectedFilterIndices =>
      UnmodifiableSetView(_selectedFilterIndices);

  void setSelectedView(ExploreContentView view) {
    if (_selectedView == view) {
      return;
    }

    _selectedView = view;
    notifyListeners();
  }

  void toggleFilter(int index) {
    if (index == allFilterIndex) {
      _setSelectedFilterIndices({allFilterIndex});
      return;
    }

    final next = {..._selectedFilterIndices}..remove(allFilterIndex);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }

    _setSelectedFilterIndices(next.isEmpty ? {allFilterIndex} : next);
  }

  void _setSelectedFilterIndices(Set<int> next) {
    if (_selectedFilterIndices.length == next.length &&
        _selectedFilterIndices.containsAll(next)) {
      return;
    }

    _selectedFilterIndices = next;
    notifyListeners();
  }
}
