class EventSlotsResponse {
  const EventSlotsResponse({
    required this.slotLimit,
    required this.registeredCount,
    required this.availableSlots,
    required this.waitlistCount,
    required this.soldOut,
  });

  final int slotLimit;
  final int registeredCount;
  final int availableSlots;
  final int waitlistCount;
  final bool soldOut;

  factory EventSlotsResponse.fromJson(Map<String, dynamic> json) {
    return EventSlotsResponse(
      slotLimit: (json['slotLimit'] as num?)?.toInt() ?? 0,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
      waitlistCount: (json['waitlistCount'] as num?)?.toInt() ?? 0,
      soldOut: json['soldOut'] as bool? ?? false,
    );
  }
}
