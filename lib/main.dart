import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BatteryMonitorApp();
  }
}

class BatteryMonitorApp extends StatelessWidget {
  const BatteryMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const BatteryHomePage(),
    );
  }
}

class BatteryHomePage extends StatefulWidget {
  const BatteryHomePage({super.key});

  @override
  State<BatteryHomePage> createState() => _BatteryHomePageState();
}

class _BatteryHomePageState extends State<BatteryHomePage> {
  final Battery _battery = Battery();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _requestPermissions();
    
    // Listen for state changes (charging/discharging)
    _battery.onBatteryStateChanged.listen((state) {
      setState(() => _batteryState = state);
    });

    // Check battery level every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _checkBattery());
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  Future<void> _requestPermissions() async {
    await [Permission.notification, Permission.sms].request();
  }

  Future<void> _checkBattery() async {
    final level = await _battery.batteryLevel;
    setState(() => _batteryLevel = level);

    // LOGIC: If battery is high (e.g., > 90%) and charging
    if (level >= 75 && _batteryState == BatteryState.charging) {
      _notifyContacts();
    }
  }

  Future<void> _notifyContacts() async {
    const androidDetails = AndroidNotificationDetails(
      'battery_channel', 'Battery Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await _notifications.show(
      0,
      'High Battery Alert!',
      'Battery is at $_batteryLevel%. Notifying contacts...',
      const NotificationDetails(android: androidDetails),
    );

    // In a real app, you would call your SMS/API function here
    print("ACTION: Sending SMS to personal contacts...");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Guard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _batteryState == BatteryState.charging ? Icons.battery_charging_full : Icons.battery_full,
              size: 100,
              color: _batteryLevel > 75 ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 20),
            Text('Current Level: $_batteryLevel%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Status: ${_batteryState.name.toUpperCase()}', style: const TextStyle(fontSize: 16)),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Note: This app will notify your contacts when battery hits 90% while charging.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:battery_plus/battery_plus.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BatteryMonitorApp();
//   }
// }

// class BatteryMonitorApp extends StatelessWidget {
//   const BatteryMonitorApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
//       home: const BatteryHomePage(),
//     );
//   }
// }

// class BatteryHomePage extends StatefulWidget {
//   const BatteryHomePage({super.key});

//   @override
//   State<BatteryHomePage> createState() => _BatteryHomePageState();
// }

// class _BatteryHomePageState extends State<BatteryHomePage> {
//   final Battery _battery = Battery();
//   final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
//   int _batteryLevel = 0;
//   BatteryState _batteryState = BatteryState.unknown;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _initNotifications();
//     _requestPermissions();
    
//     // Listen for state changes (charging/discharging)
//     _battery.onBatteryStateChanged.listen((state) {
//       setState(() => _batteryState = state);
//     });

//     // Check battery level every 10 seconds
//     _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _checkBattery());
//   }

//   Future<void> _initNotifications() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidSettings);
//     await _notifications.initialize(initSettings);
//   }

//   Future<void> _requestPermissions() async {
//     await [Permission.notification, Permission.sms].request();
//   }

//   Future<void> _checkBattery() async {
//     final level = await _battery.batteryLevel;
//     setState(() => _batteryLevel = level);

//     // LOGIC: If battery is high (e.g., > 90%) and charging
//     if (level >= 90 && _batteryState == BatteryState.charging) {
//       _notifyContacts();
//     }
//   }

//   Future<void> _notifyContacts() async {
//     const androidDetails = AndroidNotificationDetails(
//       'battery_channel', 'Battery Alerts',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
    
//     await _notifications.show(
//       0,
//       'High Battery Alert!',
//       'Battery is at $_batteryLevel%. Notifying contacts...',
//       const NotificationDetails(android: androidDetails),
//     );

//     // In a real app, you would call your SMS/API function here
//     print("ACTION: Sending SMS to personal contacts...");
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Battery Guard')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _batteryState == BatteryState.charging ? Icons.battery_charging_full : Icons.battery_full,
//               size: 100,
//               color: _batteryLevel > 90 ? Colors.green : Colors.blue,
//             ),
//             const SizedBox(height: 20),
//             Text('Current Level: $_batteryLevel%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             Text('Status: ${_batteryState.name.toUpperCase()}', style: const TextStyle(fontSize: 16)),
//             const Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Text(
//                 'Note: This app will notify your contacts when battery hits 90% while charging.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }