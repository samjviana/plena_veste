import 'package:flutter/material.dart';
import 'package:plena_veste/main.dart';
import 'package:plena_veste/pages/menu/menu_logic.dart';
import 'package:plena_veste/pages/menu/menu_state.dart';

class MenuPage extends StatefulWidget {
    const MenuPage({super.key});

    @override
    State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> { 
    late final MenuState _state;
    late final MenuLogic _logic;

    @override
    void initState() {
        super.initState();

        _state = MenuState();
        _logic = MenuLogic(_state, setState);
    }

    @override
    Widget build(BuildContext context) {
        return Row(
            children: [
                NavigationRail(
                    selectedIndex: _state.selectedIndex,
                    extended: true,
                    onDestinationSelected: _logic.selectDestination,
                    destinations: _state.destinations.map((d) => d.navDestination).toList(),
                    // TODO: This layout with trailing buttons is a bit hacky, refactor this into a custom widget (there are a custom widget in my other projects)
                    trailing: Expanded(
                        child: Column(
                            children: [
                                const Spacer(),
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                        children: [
                                            ElevatedButton(
                                                onPressed: _logic.toggleTheme,
                                                style: ElevatedButton.styleFrom(
                                                    shape: const CircleBorder(),
                                                    padding: const EdgeInsets.all(12),
                                                ),
                                                child: Icon(MainAppState.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode)
                                            ),
                                            ElevatedButton.icon(
                                                onPressed: () => _logic.logout(context),
                                                icon: const Icon(Icons.logout),
                                                label: const Text('Sair')
                                            ),
                                        ],
                                    )
                                )
                            ],
                        )
                    )
                ),
                VerticalDivider(thickness: 1, width: 1),
                Expanded(
                    child: Scaffold(
                        appBar: AppBar(
                            title: Text(_state.destinations[_state.selectedIndex].label),
                        ),
                        body: _state.destinations[_state.selectedIndex].page
                    ),
                )
            ],
        );
    }
}