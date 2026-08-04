import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHandler {
  ConnectivityHandler._();

  static final ConnectivityHandler _singleton = ConnectivityHandler._();

  factory ConnectivityHandler() => _singleton;

  late bool hasConnection;

  Stream<List<ConnectivityResult>> start() {
    return Connectivity().onConnectivityChanged;
  }

  Future<void> checkConnection() async {
    List<ConnectivityResult> connections =
        await Connectivity().checkConnectivity();
    hasConnection =
        connections.any((connection) => connection != ConnectivityResult.none);
  }
}
