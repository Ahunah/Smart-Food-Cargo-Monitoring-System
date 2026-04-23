import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _supabase = Supabase.instance.client;

  Color _severityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return const Color(0xFFFF4444);
      case 'HIGH':
        return const Color(0xFFFF8800);
      default:
        return const Color(0xFFFFD600);
    }
  }

  IconData _alertIcon(String type) {
    switch (type) {
      case 'TEMP_CRITICAL':
      case 'TEMP_WARNING':
        return Icons.thermostat;
      case 'LID_OPEN':
        return Icons.lock_open;
      case 'MOTION_DETECTED':
        return Icons.directions_run;
      case 'TILT_ALERT':
        return Icons.screen_rotation;
      case 'HUMID_CRITICAL':
      case 'HUMID_WARNING':
        return Icons.water_drop;
      default:
        return Icons.warning_amber;
    }
  }

  String _driverMessage(String alertType, String message) {
    switch (alertType) {
      case 'TEMP_CRITICAL':
        return 'STOP NOW: Temperature is dangerously high. Pull over and check cooling immediately.';
      case 'TEMP_WARNING':
        return 'Check cooling system. Temperature is rising above safe limit for medicines.';
      case 'LID_OPEN':
        return 'Container lid has been opened. Please verify cargo security.';
      case 'MOTION_DETECTED':
        return 'Movement detected inside container. Check for tampering immediately.';
      case 'TILT_ALERT':
        return 'Container is tilted. Drive carefully — vials and IV bags may be damaged.';
      case 'HUMID_CRITICAL':
        return 'Humidity critical. Moisture may be damaging medicines. Check container seal.';
      case 'HUMID_WARNING':
        return 'Humidity outside safe range. Monitor carefully.';
      default:
        return message;
    }
  }

  Future<void> _markAsRead(int id) async {
    await _supabase.from('cargo_alerts').update({'is_read': true}).eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Driver Alerts'),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          TextButton(
            onPressed: () async {
              await _supabase
                  .from('cargo_alerts')
                  .update({'is_read': true})
                  .eq('is_read', false);
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFF00E5B4)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('cargo_alerts')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false)
            .limit(50),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5B4)),
            );
          }

          final alerts = snapshot.data!;

          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF00E5B4),
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'All clear — no alerts',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final unread = alerts.where((a) => !(a['is_read'] as bool)).length;

          return Column(
            children: [
              if (unread > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                  child: Text(
                    '$unread unread alert${unread > 1 ? 's' : ''} — take action!',
                    style: const TextStyle(
                      color: Color(0xFFFF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, i) {
                    final a = alerts[i];
                    final isRead = a['is_read'] as bool;
                    final color = _severityColor(a['severity']);
                    final time = DateTime.parse(a['created_at']).toLocal();

                    return GestureDetector(
                      onTap: () => _markAsRead(a['id']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead
                              ? const Color(0xFF16213E)
                              : color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? Colors.white12
                                : color.withValues(alpha: 0.5),
                            width: isRead ? 0.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _alertIcon(a['alert_type']),
                                  color: color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a['alert_type'].toString().replaceAll(
                                      '_',
                                      ' ',
                                    ),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    a['severity'],
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _driverMessage(a['alert_type'], a['message']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd MMM  HH:mm:ss').format(time),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                                if (!isRead)
                                  const Text(
                                    'Tap to mark read',
                                    style: TextStyle(
                                      color: Color(0xFF00E5B4),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
