import 'package:flutter/foundation.dart' hide Category;
import 'package:latlong2/latlong.dart';
import '../../../shared/events/event_repository.dart';
import '../../../shared/services/l10n_service.dart';
import '../../explore/models.dart';
import 'create_event_state.dart';

class CreateEventController extends ChangeNotifier {
  CreateEventController({required EventRepository eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository _eventRepository;
  CreateEventState _state = const CreateEventState();
  CreateEventState get state => _state;

  LatLng? _selectedLocation;

  void updateTitle(String title) {
    final l10n = L10nService.l10n;
    String? error;
    if (title.isEmpty) {
      error = l10n.hubCreateEventValidationRequired;
    } else if (title.length < 3) {
      error = l10n.hubCreateEventValidationMinChars3;
    }

    _state = _state.copyWith(title: title, titleError: () => error);
    notifyListeners();
  }

  void updateDescription(String description) {
    final l10n = L10nService.l10n;
    String? error;
    if (description.isEmpty) {
      error = l10n.hubCreateEventValidationRequired;
    } else if (description.length < 10) {
      error = l10n.hubCreateEventValidationDescriptionMin10;
    }

    _state = _state.copyWith(
      description: description,
      descriptionError: () => error,
    );
    notifyListeners();
  }

  void updateLocation(String label, LatLng? location) {
    final l10n = L10nService.l10n;
    _selectedLocation = location;
    _state = _state.copyWith(
      locationLabel: label,
      locationError: () => location == null
          ? l10n.hubCreateEventValidationLocationRequired
          : null,
    );
    notifyListeners();
  }

  void clearLocation() {
    final l10n = L10nService.l10n;
    _selectedLocation = null;
    _state = _state.copyWith(
      locationLabel: '',
      locationError: () => l10n.hubCreateEventValidationLocationRequired,
    );
    notifyListeners();
  }

  void updateDate(DateTime? date) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      selectedDate: () => date,
      dateError: () =>
          date == null ? l10n.hubCreateEventValidationDateTimeRequired : null,
    );
    notifyListeners();
  }

  void updateTime(DateTime? time) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      selectedTime: () => time,
      timeError: () =>
          time == null ? l10n.hubCreateEventValidationDateTimeRequired : null,
    );
    notifyListeners();
  }

  void toggleCategory(Category category) {
    final l10n = L10nService.l10n;
    final next = [..._state.selectedCategories];
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }

    _state = _state.copyWith(
      selectedCategories: next,
      categoriesError: () =>
          next.isEmpty ? l10n.hubCreateEventValidationRequired : null,
    );
    notifyListeners();
  }

  void updateStatus(EventStatus status) {
    _state = _state.copyWith(eventStatus: status);
    notifyListeners();
  }

  void updateTicketUrl(String? url) {
    _state = _state.copyWith(ticketUrl: () => url);
    notifyListeners();
  }

  void updateSlotLimit(int? limit) {
    final l10n = L10nService.l10n;
    _state = _state.copyWith(
      slotLimit: () => limit,
      slotLimitError: () => (limit != null && limit <= 0)
          ? l10n.hubCreateEventValidationPositiveNumber
          : null,
    );
    notifyListeners();
  }

  void addSelectedImages(List<CreateEventSelectedImage> images) {
    if (images.isEmpty) return;
    _state = _state.copyWith(
      selectedImages: [..._state.selectedImages, ...images],
    );
    notifyListeners();
  }

  void removeSelectedImageAt(int index) {
    if (index < 0 || index >= _state.selectedImages.length) return;
    final next = [..._state.selectedImages]..removeAt(index);
    _state = _state.copyWith(selectedImages: next);
    notifyListeners();
  }

  void reorderSelectedImages(int oldIndex, int newIndex) {
    final images = [..._state.selectedImages];
    if (oldIndex < 0 || oldIndex >= images.length) return;
    if (newIndex < 0 || newIndex > images.length) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final moved = images.removeAt(oldIndex);
    images.insert(newIndex, moved);
    _state = _state.copyWith(selectedImages: images);
    notifyListeners();
  }

  Future<void> submit() async {
    if (_state.status == CreateEventFormStatus.submitting) return;

    final l10n = L10nService.l10n;
    String? titleError;
    if (_state.title.isEmpty) {
      titleError = l10n.hubCreateEventValidationRequired;
    } else if (_state.title.length < 3) {
      titleError = l10n.hubCreateEventValidationMinChars3;
    }

    String? descError;
    if (_state.description.isEmpty) {
      descError = l10n.hubCreateEventValidationRequired;
    } else if (_state.description.length < 10) {
      descError = l10n.hubCreateEventValidationDescriptionMin10;
    }

    _state = _state.copyWith(
      titleError: () => titleError,
      descriptionError: () => descError,
      categoriesError: () => _state.selectedCategories.isEmpty
          ? l10n.hubCreateEventValidationCategoryRequired
          : null,
      locationError: () => _selectedLocation == null
          ? l10n.hubCreateEventValidationLocationRequired
          : null,
      dateError: () => _state.selectedDate == null
          ? l10n.hubCreateEventValidationDateTimeRequired
          : null,
      timeError: () => _state.selectedTime == null
          ? l10n.hubCreateEventValidationDateTimeRequired
          : null,
    );
    notifyListeners();

    if (!state.canSubmit) return;

    _state = _state.copyWith(status: CreateEventFormStatus.submitting);
    notifyListeners();

    try {
      final request = EventRequest(
        name: _state.title,
        description: _state.description,
        startAt: _combineDateAndTime(
          _state.selectedDate!,
          _state.selectedTime!,
        ),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _state.locationLabel,
        categoryIds: _state.selectedCategories.map((c) => c.id).toList(),
        status: _state.eventStatus,
        ticketUrl: _state.ticketUrl,
        slotLimit: _state.slotLimit,
      );

      final createdEvent = await _eventRepository.createEvent(request);
      final selectedImages = _state.selectedImages;
      if (selectedImages.isNotEmpty) {
        try {
          final uploadedMedia = <EventMedia>[];
          for (final image in selectedImages) {
            final media = await _eventRepository.uploadEventMedia(
              createdEvent.id,
              image.bytes,
              image.fileName,
            );
            uploadedMedia.add(media);
          }
          final firstMediaId = uploadedMedia.firstOrNull?.id;
          if (firstMediaId != null && firstMediaId.isNotEmpty) {
            await _eventRepository.setEventThumbnail(
              createdEvent.id,
              firstMediaId,
            );
          }
        } catch (error, stackTrace) {
          debugPrint('CreateEventController image upload failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      _state = _state.copyWith(status: CreateEventFormStatus.success);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(status: CreateEventFormStatus.error);
      notifyListeners();
    }
  }

  DateTime _combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
