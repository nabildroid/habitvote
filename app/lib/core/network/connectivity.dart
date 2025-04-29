import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final isOnline = BehaviorSubject<bool>.seeded(false);

void initConnectivity() {
  Connectivity().checkConnectivity().then((status) {
    isOnline.add(!status.contains(ConnectivityResult.none));
  });

  Connectivity().onConnectivityChanged.listen((status) => isOnline.add(
        !status.contains(ConnectivityResult.none),
      ));
}
