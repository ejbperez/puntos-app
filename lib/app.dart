import 'package:flutter/material.dart';
import 'data/match_repository.dart';
import 'screens/main_navigation_shell.dart';
import 'state/match_controller.dart';
import 'theme/app_theme.dart';

class PuntosApp extends StatefulWidget {
  const PuntosApp({this.repository, super.key});

  final MatchRepository? repository;

  @override
  State<PuntosApp> createState() => _PuntosAppState();
}

class _PuntosAppState extends State<PuntosApp> {
  late final MatchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MatchController(repository: widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puntos App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: MainNavigationShell(controller: _controller),
    );
  }
}
