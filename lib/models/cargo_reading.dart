class CargoReading {
  final int     id;
  final double  temperature;
  final double  humidity;
  final bool    light;
  final bool    motion;
  final bool    tilt;
  final int     score;
  final String  status;
  final String  events;
  final DateTime createdAt;

  CargoReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.motion,
    required this.tilt,
    required this.score,
    required this.status,
    required this.events,
    required this.createdAt,
  });

  factory CargoReading.fromMap(Map<String, dynamic> map) {
    return CargoReading(
      id:          map['id']          as int,
      temperature: (map['temperature'] as num).toDouble(),
      humidity:    (map['humidity']    as num).toDouble(),
      light:       map['light']        as bool,
      motion:      map['motion']       as bool,
      tilt:        map['tilt']         as bool,
      score:       map['score']        as int,
      status:      map['status']       as String,
      events:      map['events']       as String,
      createdAt:   DateTime.parse(map['created_at']),
    );
  }
}