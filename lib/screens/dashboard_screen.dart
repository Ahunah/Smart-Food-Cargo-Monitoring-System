import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/screens/alert_screen.dart';
import '../models/cargo_reading.dart';
import '../services/supabase_service.dart';
import 'history_screen.dart';
import 'forensic_log_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();
  CargoReading? _latest;
  int _selectedIndex = 0;

  Color _statusColor(String status) {
    switch (status) {
      case 'GREEN':  return const Color(0xFF00E5B4);
      case 'YELLOW': return const Color(0xFFFFD600);
      default:       return const Color(0xFFFF4444);
    }
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF00E5B4);
    if (score >= 50) return const Color(0xFFFFD600);
    return const Color(0xFFFF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: StreamBuilder<List<CargoReading>>(
        stream: _service.streamReadings(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            _latest = snapshot.data!.first;
          }
          return _latest == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00E5B4)),
                      SizedBox(height: 16),
                      Text('Waiting for ESP32 data...',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : _buildDashboard(_latest!);
        },
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF16213E),
        indicatorColor:  const Color(0xFF00E5B4).withOpacity(0.2),
        selectedIndex:   _selectedIndex,
        onDestinationSelected: (i) {
          // ── FIXED: all navigation cases in one clean block ──
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()));
          } else if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ForensicLogScreen()));
          } else if (i == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()));
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        destinations: const [
          // ── FIXED: clean destinations list, nothing extra inside ──
          NavigationDestination(
            icon:         Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label:        'Dashboard'),
          NavigationDestination(
            icon:         Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label:        'History'),
          NavigationDestination(
            icon:         Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label:        'Forensic Log'),
          NavigationDestination(
            icon:         Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label:        'Alerts'),
        ],
      ),
    );
  }

  Widget _buildDashboard(CargoReading r) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cargo Guardian',
                        style: TextStyle(
                            fontSize:   22,
                            fontWeight: FontWeight.bold,
                            color:      Colors.white)),
                    Text('Pharmaceutical Monitor',
                        style: TextStyle(
                            fontSize: 13, color: Colors.white54)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(r.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor(r.status).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(r.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(r.status,
                          style: TextStyle(
                              color:      _statusColor(r.status),
                              fontWeight: FontWeight.bold,
                              fontSize:   13)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:        const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _scoreColor(r.score).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Integrity Score',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${r.score}',
                      style: TextStyle(
                          fontSize:   80,
                          fontWeight: FontWeight.bold,
                          color:      _scoreColor(r.score))),
                  Text('out of 100',
                      style: TextStyle(
                          color:    _scoreColor(r.score).withOpacity(0.7),
                          fontSize: 14)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:           r.score / 100,
                      minHeight:       8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _scoreColor(r.score)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _sensorCard(
                  icon:   Icons.thermostat,
                  label:  'Temperature',
                  value:  '${r.temperature.toStringAsFixed(1)}°C',
                  safe:   r.temperature >= 2 && r.temperature <= 8,
                  warn:   r.temperature > 8  && r.temperature <= 15,
                  detail: 'Safe: 2–8°C',
                )),
                const SizedBox(width: 12),
                Expanded(child: _sensorCard(
                  icon:   Icons.water_drop_outlined,
                  label:  'Humidity',
                  value:  '${r.humidity.toStringAsFixed(1)}%',
                  safe:   r.humidity >= 45 && r.humidity <= 65,
                  warn:   (r.humidity > 65 && r.humidity <= 80) ||
                          (r.humidity >= 30 && r.humidity < 45),
                  detail: 'Safe: 45–65%',
                )),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _boolSensorCard(
                  icon:      Icons.light_mode_outlined,
                  label:     'Lid / Light',
                  triggered: r.light,
                  okText:    'Sealed',
                  alertText: 'LID OPEN',
                )),
                const SizedBox(width: 12),
                Expanded(child: _boolSensorCard(
                  icon:      Icons.directions_run,
                  label:     'Motion',
                  triggered: r.motion,
                  okText:    'No motion',
                  alertText: 'MOTION!',
                )),
                const SizedBox(width: 12),
                Expanded(child: _boolSensorCard(
                  icon:      Icons.screen_rotation_outlined,
                  label:     'Tilt',
                  triggered: r.tilt,
                  okText:    'Upright',
                  alertText: 'TILTED!',
                )),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Events',
                      style: TextStyle(
                          color:      Colors.white54,
                          fontSize:   13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text(
                    r.events.replaceAll(';', '\n').trim(),
                    style: const TextStyle(
                        color:      Color(0xFF00E5B4),
                        fontFamily: 'monospace',
                        fontSize:   13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Last updated: ${DateFormat('HH:mm:ss dd MMM').format(r.createdAt.toLocal())}',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard({
    required IconData icon,
    required String   label,
    required String   value,
    required bool     safe,
    required bool     warn,
    required String   detail,
  }) {
    final color = safe
        ? const Color(0xFF00E5B4)
        : warn
            ? const Color(0xFFFFD600)
            : const Color(0xFFFF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color:      color,
                  fontSize:   26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
          Text(detail,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _boolSensorCard({
    required IconData icon,
    required String   label,
    required bool     triggered,
    required String   okText,
    required String   alertText,
  }) {
    final color = triggered
        ? const Color(0xFFFF4444)
        : const Color(0xFF00E5B4);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color:        const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(triggered ? alertText : okText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:      color,
                  fontSize:   11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}