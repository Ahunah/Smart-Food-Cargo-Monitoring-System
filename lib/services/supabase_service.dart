import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cargo_reading.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Latest single reading
  Future<CargoReading?> getLatestReading() async {
    final data = await _client
        .from('cargo_readings')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return CargoReading.fromMap(data);
  }

  // Last 20 readings for history chart
  Future<List<CargoReading>> getRecentReadings() async {
    final data = await _client
        .from('cargo_readings')
        .select()
        .order('created_at', ascending: false)
        .limit(20);
    return (data as List)
        .map((e) => CargoReading.fromMap(e))
        .toList();
  }

  // Real-time stream
  Stream<List<CargoReading>> streamReadings() {
    return _client
        .from('cargo_readings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows.map(CargoReading.fromMap).toList());
  }
}