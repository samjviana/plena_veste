import 'package:plena_veste/pages/login/login_state.dart';

class LoginLogic {
    late final LoginState _state;
    late final void Function(void Function()) _setState;

    LoginLogic(LoginState state, void Function(void Function()) setState) {
        _state = state;
        _setState = setState;
    }

    // TODO: The use of a Authentication Gate could also avoid the need of this function, as the page would automatically re-route when the session change.
    void login() async {
        await _state.oauth.signIn();
        _setState(() {});
    }
}