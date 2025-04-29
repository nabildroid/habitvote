import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCElFmAjZzswfeXvUrX-I0dQ2OiMJjjN3A",
    appId: '1:429661583504:android:058e79ee17f8a0e2d70015',
    messagingSenderId: '759463905380',
    projectId: 'habitvote25',
    storageBucket: 'habitvote25.firebasestorage.app',
  );

  late FirebaseApp app;

  Future<void> init() async {
    app = await Firebase.initializeApp(
      options: android,
      name: "HabitVoteApp",
    );
  }
}
