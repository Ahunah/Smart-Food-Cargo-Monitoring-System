import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://shotcrnrdeqzqhtehdvo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNob3Rjcm5yZGVxenFodGVoZHZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NDY5OTEsImV4cCI6MjA5MDUyMjk5MX0.HZkbGINSICYEu9jvr8C0CN_8mBdkuoZGTrybBF6VYsg',
  );

  runApp(const CargoGuardianApp());
}

class CargoGuardianApp extends StatefulWidget {
  const CargoGuardianApp({super.key});
  @override
  State<CargoGuardianApp> createState() => _CargoGuardianAppState();
}

class _CargoGuardianAppState extends State<CargoGuardianApp> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _listenForAlerts();
  }

  void _listenForAlerts() {
    _supabase
        .from('cargo_alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(1)
        .listen((data) {
          if (data.isEmpty) return;
          final alert = data.first;
          if (alert['is_read'] == true) return;

          // Show popup anywhere in app
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_navigatorKey.currentContext == null) return;
            _showAlertDialog(
              _navigatorKey.currentContext!,
              alert['alert_type'] ?? '',
              alert['message'] ?? '',
              alert['severity'] ?? 'MEDIUM',
              alert['id'] as int,
            );
          });
        });
  }

  void _showAlertDialog(
    BuildContext context,
    String type,
    String message,
    String severity,
    int id,
  ) {
    final color = severity == 'CRITICAL'
        ? const Color(0xFFFF4444)
        : severity == 'HIGH'
        ? const Color(0xFFFF8800)
        : const Color(0xFFFFD600);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                type.replaceAll('_', ' '),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark as read
              _supabase
                  .from('cargo_alerts')
                  .update({'is_read': true})
                  .eq('id', id);
              Navigator.pop(context);
            },
            child: Text(
              'OK — Got it',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Cargo Guardian',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5B4),
          secondary: Color(0xFF1A1A2E),
          surface: Color(0xFF16213E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF16213E),
      ),
      home: const DashboardScreen(),
    );
  }
}
