// ── Event Model ───────────────────────────────────────────────────────────────
class CampusEvent {
  final String id, title, description, location, category, organizer;
  final DateTime eventDate;
  final double? latitude, longitude;

  const CampusEvent({
    required this.id, required this.title, required this.description,
    required this.location, required this.category, required this.organizer,
    required this.eventDate, this.latitude, this.longitude,
  });

  factory CampusEvent.fromJson(Map<String, dynamic> j) => CampusEvent(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        location: j['location'] ?? '',
        category: j['category'] ?? 'general',
        organizer: j['organizer'] ?? '',
        eventDate: DateTime.tryParse(j['event_date'] ?? '') ?? DateTime.now(),
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'title': title, 'description': description,
        'location': location, 'category': category, 'organizer': organizer,
        'event_date': eventDate.toIso8601String(),
        'latitude': latitude, 'longitude': longitude,
      };

  factory CampusEvent.fromMap(Map<String, dynamic> m) => CampusEvent.fromJson(m);
}
