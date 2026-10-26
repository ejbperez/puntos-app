import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'data/match_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MatchRepository? repository;
  try {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>('matches');
    repository = MatchRepository(box);
  } catch (e) {
    debugPrint('Hive init error (falling back to memory): $e');
  }

  runApp(PuntosApp(repository: repository));
}
