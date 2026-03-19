import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plena_veste/pages/login/login_logic.dart';
import 'package:plena_veste/pages/login/login_state.dart';
import 'package:plena_veste/pages/menu/menu_page.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    late final LoginState _state;
    late final LoginLogic _logic;

    @override
    void initState() {
        super.initState();

        _state = LoginState();
        _logic = LoginLogic(_state, setState);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                // TODO: Possibly write a Authentication Gate widget to handle which page to show, this should avoid the manual re-routing when login/logout are done.
                child: Stack(
                    children: [
                        FutureBuilder<bool>(
                            future: _state.oauth.tryRestoreSession(),
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                // TODO: Add a proper loading indicator as the current way don't change state when logging in.
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                }

                                if (snapshot.hasError) {
                                    return ErrorWidget(snapshot.error!);
                                }

                                if (snapshot.hasData && snapshot.data == true) {
                                    _state.isLoggedIn = true;
                                    return MenuPage();
                                }

                                // TODO: Write a custom "Login with Google" button per https://developers.google.com/identity/branding-guidelines.
                                return InkWell(
                                    onTap: _logic.login,
                                    borderRadius: BorderRadius.circular(20),
                                    child: SvgPicture.asset(
                                        'assets/login_google.svg',
                                    ),
                                );
                            }
                        ),
                        _state.isLoggedIn ? Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.all(64),
                            child: FloatingActionButton(
                                shape: CircleBorder(),
                                onPressed: _logic.logout,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Icon(Icons.logout, color: Theme.of(context).colorScheme.onPrimary),
                            )
                        ) : Container()
                    ]
                )
            )
        );
    }
}
