import 'package:flutter/material.dart';
import 'package:plena_veste/auth/oauth_service.dart';
import 'package:plena_veste/di.dart';
import 'package:plena_veste/pages/home/home_page.dart';

class MenuState extends ChangeNotifier {
    int _selectedIndex = 0;
    int get selectedIndex => _selectedIndex;
    set selectedIndex(int value) {
        if (_selectedIndex == value) return;

        _selectedIndex = value;
        notifyListeners();
    }

    // TODO: The use of a custom widget for the navigation rail should allow a more structured way to manage the destinations avoiding multiple classes in the same file.
    List<Destination> get destinations => [
        Destination(
            icon: const Icon(Icons.home),
            label: 'Home',
            page: HomePage()
        )
    ];

    final GoogleOAuthService oauth = getIt<GoogleOAuthService>();
}

class Destination {
    final Widget page;
    final String label;
    final NavigationRailDestination navDestination;

    Destination({required Widget icon, required this.label, required this.page})
        : navDestination = NavigationRailDestination(icon: icon, label: Text(label));
}