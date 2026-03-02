import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plena_veste/di.dart';
import 'package:plena_veste/pages/login/login_page.dart';

void main() {
    setupDependencies();
    runApp(const MainApp());
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

    @override
    void initState() {
        super.initState();
        _instance = this;
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Plena Veste',
            theme: ThemeData(
                useMaterial3: true,
                textTheme: GoogleFonts.lexendTextTheme(ThemeData(brightness: MainAppState.brightness).textTheme),
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.amber,
                    brightness: MainAppState.brightness
                ),
            ),
            home: LoginPage(),
        );
    }
}