import 'models.dart';

sealed class ExploreState {
  const ExploreState();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreData extends ExploreState {
  const ExploreData({required this.events});
  final List<ExploreEvent> events;
}

class ExploreDataLoading extends ExploreState {
  const ExploreDataLoading({required this.previous});
  final List<ExploreEvent> previous;
}

class ExploreEmpty extends ExploreState {
  const ExploreEmpty();
}

enum ExploreErrorType { network, permission, unknown }

class ExploreError extends ExploreState {
  const ExploreError({required this.type, this.details});
  final ExploreErrorType type;
  final String? details;
}
