import 'dart:math';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plena_veste/di.dart';
import 'package:plena_veste/pages/login/login_page.dart';

void main() {
    setupDependencies();
    runApp(const MainApp());
    
    doWhenWindowReady(() {
        final display = PlatformDispatcher.instance.displays.first;
        final screenSize = display.size;

        // get min size between width and height
        final minSize = min(screenSize.width, screenSize.height);

        appWindow.size = Size(minSize * 0.85, minSize * 0.7);
        appWindow.minSize = const Size(960, 640);
        appWindow.show();
    });
}

class MainApp extends StatefulWidget {
    const MainApp({super.key});

    @override
    State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
    // TODO: This is a very hacky and unsafe way to manage the app's theme, refactor this into a proper theme management class (there is a theme management class in my other projects)
    static MainAppState? _instance;
    static MainAppState get instance {
        if (_instance == null) {
            throw Exception('MainApp instance is not initialized yet');
        }
        return _instance!;
    }
    static Brightness _brightness = Brightness.dark;
    static Brightness get brightness => _brightness;
    static set brightness(Brightness value) {
        if (_brightness == value) return;

        _brightness = value;
        instance.setState(() {});
    }

    ThemeData _themeData() {
        final ColorScheme colorScheme = ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: MainAppState.brightness
        );

        return ThemeData(
            useMaterial3: true,
            textTheme: GoogleFonts.lexendTextTheme(ThemeData(brightness: MainAppState.brightness).textTheme),
            colorScheme: colorScheme,
            inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                ),
            ),
            cardTheme: CardThemeData(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.outline),
                ),
                surfaceTintColor: Colors.transparent,
                color: Colors.transparent,
                elevation: 0,
            )
        );
    }

    @override
    void initState() {
        super.initState();
        _instance = this;
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Plena Veste',
            theme: _themeData(),
            home: const LoginPage(),
        );
    }
}