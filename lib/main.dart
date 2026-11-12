import 'package:material_ui/material_ui.dart';
import 'package:lilypad/services/api.dart';
import 'package:lilypad/services/UI/dialog.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/log.dart';
import 'package:lilypad/services/session.dart';
import 'package:lilypad/util/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionService.init();
  await GeolocationService.init();
  LogService.log('Starting UI...');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    APIService.ping().then((result) {
      DialogService.showAlert('Ping Test', result.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LogService.log('Building Core App...', src: 'MainApp');
    return MaterialApp(
      navigatorKey: AppGlobal.navigatorKey,
      home: Scaffold(body: Center(child: Text('Welcome to Lilypad'))),
    );
  }
}
