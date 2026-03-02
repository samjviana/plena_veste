import 'package:flutter/material.dart';
import 'package:plena_veste/auth/oauth_service.dart';
import 'package:plena_veste/di.dart';

class LoginState extends ChangeNotifier {
    final GoogleOAuthService oauth = getIt<GoogleOAuthService>();
}