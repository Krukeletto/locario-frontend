import 'package:flutter/foundation.dart' hide Category;
import '../../features/explore/models.dart';
import 'event_repository.dart';

class CategoryController extends ChangeNotifier {
  CategoryController({required EventRepository eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository _eventRepository;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _eventRepository.fetchCategories();
      if (fetched.isEmpty) {
        _categories = [const Category(id: 'any', name: 'Dowolna', slug: 'any')];
      } else {
        _categories = fetched;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _categories = [const Category(id: 'any', name: 'Dowolna', slug: 'any')];
      notifyListeners();
    }
  }
}
