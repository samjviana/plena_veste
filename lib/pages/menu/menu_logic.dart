import 'package:flutter/material.dart';
import 'package:plena_veste/main.dart';
import 'package:plena_veste/pages/login/login_page.dart';
import 'package:plena_veste/pages/menu/menu_state.dart';

class MenuLogic {
    late final MenuState _state;
    late final void Function(void Function()) _setState;

    MenuLogic(MenuState state, void Function(void Function()) setState) {
        _state = state;
        _setState = setState;
    }

    void selectDestination(int index) {
        _setState(() {
            _state.selectedIndex = index;
        });
    }

    // TODO: Another point that could be improved with a addition of a Authentication Gate widget.
    Future<void> logout(BuildContext context) async {
        if (!context.mounted) return;

        await _state.oauth.signOut();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false    
        );
    }

    // TODO: The whole logic behind theme management should be refactored into a separate class (there is a theme management class in my other projects)
    void toggleTheme() {
        _setState(() {
            if (MainAppState.brightness == Brightness.dark) {
                MainAppState.brightness = Brightness.light;
            } else {
                MainAppState.brightness = Brightness.dark;
            }
        });
    }
}