// models/booking_id.dart
class BookingID {
  final String id;
  final DateTime createdAt;
  final String prefix;

  const BookingID({
    required this.id,
    required this.createdAt,
    this.prefix = 'SDM',
  });

  factory BookingID.generate({String prefix = 'SDM'}) {
    return BookingID(
      id: '${prefix}${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      createdAt: DateTime.now(),
      prefix: prefix,
    );
  }

  factory BookingID.fromString(String bookingId) {
    final timestamp = int.tryParse(bookingId.substring(3)) ?? 0;
    return BookingID(
      id: bookingId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      prefix: bookingId.substring(0, 3),
    );
  }

  String get formattedID => id;

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingID &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}