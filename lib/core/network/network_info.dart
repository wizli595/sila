import 'package:connectivity_plus/connectivity_plus.dart';

final connectivity = Connectivity();

Future<bool> isConnected() async {
  final result = await connectivity.checkConnectivity();
  return !result.contains(ConnectivityResult.none);
}
