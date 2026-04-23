import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cargo_reading.dart';
import '../services/supabase_service.dart';

class ForensicLogScreen extends StatelessWidget {
  const ForensicLogScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'GREEN':  return const Color(0xFF00E5B4);
      case 'YELLOW': return const Color(0xFFFFD600);
      default:       return const Color(0xFFFF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Forensic Event Log'),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: FutureBuilder<List<CargoReading>>(
        future: service.getRecentReadings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF00E5B4)));
          }

          final readings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: readings.length,
            itemBuilder: (context, i) {
              final r = readings[i];
              final color = _statusColor(r.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:        const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color:        color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(r.status,
                              style: TextStyle(
                                  color:      color,
                                  fontSize:   12,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          'Score: ${r.score}/100',
                          style: TextStyle(
                              color:      color,
                              fontWeight: FontWeight.bold,
                              fontSize:   13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.thermostat,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${r.temperature.toStringAsFixed(1)}°C  ',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const Icon(Icons.water_drop_outlined,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${r.humidity.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.events.replaceAll(';', '  |  '),
                      style: const TextStyle(
                          color:      Color(0xFF00E5B4),
                          fontSize:   12,
                          fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM yyyy  HH:mm:ss')
                          .format(r.createdAt.toLocal()),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}