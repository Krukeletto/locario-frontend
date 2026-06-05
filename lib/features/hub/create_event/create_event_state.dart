import '../../explore/models.dart';
import '../../../shared/groups/group_models.dart';

enum CreateEventFormStatus { idle, submitting, success, error }

class CreateEventSelectedImage {
  const CreateEventSelectedImage({required this.bytes, required this.fileName});

  final List<int> bytes;
  final String fileName;
}

class CreateEventState {
  const CreateEventState({
    this.title = '',
    this.titleError,
    this.description = '',
    this.descriptionError,
    this.locationLabel = '',
    this.locationError,
    this.selectedDate,
    this.dateError,
    this.selectedTime,
    this.timeError,
    this.selectedCategories = const [],
    this.categoriesError,
    this.selectedGroups = const [],
    this.groupsError,
    this.eventStatus = EventStatus.draft,
    this.ticketUrl,
    this.ticketUrlError,
    this.slotLimit,
    this.slotLimitError,
    this.selectedImages = const [],
    this.status = CreateEventFormStatus.idle,
  });

  final String title;
  final String? titleError;
  final String description;
  final String? descriptionError;
  final String locationLabel;
  final String? locationError;
  final DateTime? selectedDate;
  final String? dateError;
  final DateTime? selectedTime;
  final String? timeError;
  final List<Category> selectedCategories;
  final String? categoriesError;
  final List<Group> selectedGroups;
  final String? groupsError;
  final EventStatus eventStatus;
  final String? ticketUrl;
  final String? ticketUrlError;
  final int? slotLimit;
  final String? slotLimitError;
  final List<CreateEventSelectedImage> selectedImages;
  final CreateEventFormStatus status;

  bool get canSubmit =>
      status != CreateEventFormStatus.submitting &&
      title.isNotEmpty &&
      titleError == null &&
      description.isNotEmpty &&
      descriptionError == null &&
      selectedCategories.isNotEmpty &&
      categoriesError == null &&
      groupsError == null &&
      locationLabel.isNotEmpty &&
      locationError == null &&
      selectedDate != null &&
      dateError == null &&
      selectedTime != null &&
      timeError == null;

  CreateEventState copyWith({
    String? title,
    String? Function()? titleError,
    String? description,
    String? Function()? descriptionError,
    String? locationLabel,
    String? Function()? locationError,
    DateTime? Function()? selectedDate,
    String? Function()? dateError,
    DateTime? Function()? selectedTime,
    String? Function()? timeError,
    List<Category>? selectedCategories,
    String? Function()? categoriesError,
    List<Group>? selectedGroups,
    String? Function()? groupsError,
    EventStatus? eventStatus,
    String? Function()? ticketUrl,
    String? Function()? ticketUrlError,
    int? Function()? slotLimit,
    String? Function()? slotLimitError,
    List<CreateEventSelectedImage>? selectedImages,
    CreateEventFormStatus? status,
  }) {
    return CreateEventState(
      title: title ?? this.title,
      titleError: titleError != null ? titleError() : this.titleError,
      description: description ?? this.description,
      descriptionError: descriptionError != null
          ? descriptionError()
          : this.descriptionError,
      locationLabel: locationLabel ?? this.locationLabel,
      locationError: locationError != null
          ? locationError()
          : this.locationError,
      selectedDate: selectedDate != null ? selectedDate() : this.selectedDate,
      dateError: dateError != null ? dateError() : this.dateError,
      selectedTime: selectedTime != null ? selectedTime() : this.selectedTime,
      timeError: timeError != null ? timeError() : this.timeError,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      categoriesError: categoriesError != null
          ? categoriesError()
          : this.categoriesError,
      selectedGroups: selectedGroups ?? this.selectedGroups,
      groupsError: groupsError != null ? groupsError() : this.groupsError,
      eventStatus: eventStatus ?? this.eventStatus,
      ticketUrl: ticketUrl != null ? ticketUrl() : this.ticketUrl,
      ticketUrlError: ticketUrlError != null
          ? ticketUrlError()
          : this.ticketUrlError,
      slotLimit: slotLimit != null ? slotLimit() : this.slotLimit,
      slotLimitError: slotLimitError != null
          ? slotLimitError()
          : this.slotLimitError,
      selectedImages: selectedImages ?? this.selectedImages,
      status: status ?? this.status,
    );
  }
}
