import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';

// TODO: It would be better to have this class into its own file, but the current structure/working is not very safe as it exposes the Client Secret
class GoogleOAuthConfig {
    final String clientId;
    final String clientSecret;

    GoogleOAuthConfig({
        required this.clientId,
        required this.clientSecret,
    });

    factory GoogleOAuthConfig.fromJson(Map<String, dynamic> json) {
        final section = (json['installed'] as Map<String, dynamic>?) ?? (json['web'] as Map<String, dynamic>?);

        if (section == null) {
            throw FormatException('Invalid OAuth client JSON: missing "installed" or "web" section.');
        }

        final clientId = section['client_id'] as String?;
        if (clientId == null || clientId.trim().isEmpty) {
            throw FormatException('Invalid OAuth client JSON: missing "client_id".');
        }

        final clientSecret = section['client_secret'] as String?;
        if (clientSecret == null || clientSecret.trim().isEmpty) {
            throw FormatException('Invalid OAuth client JSON: missing "client_secret".');
        }

        return GoogleOAuthConfig(
            clientId: clientId,
            clientSecret: clientSecret,
        );
    }

    static Future<Map<String, dynamic>> fromAsset(String assetPath) async {
        final raw = await rootBundle.loadString(assetPath);
        final map = jsonDecode(raw) as Map<String, dynamic>;
        
        return map;
    }
}

// TODO: Some things can be made into constructor parameters, like the port and the storage but it would be necessary to figure out a good structure to hold them without calling it "util"
class GoogleOAuthService {
    static const String _bigQueryScope = 'https://www.googleapis.com/auth/bigquery';
    static const String _desktopTokenKey = 'google_sign_in_all_platforms_token_v1';
    
    static int? _port;
    static Future<int> get port async {
        if (_port != null) return _port!;

        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        _port = server.port;
        await server.close();
        return _port!;
    }

    final Lock _storageLock = Lock();
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    GoogleOAuthConfig? _config;
    Future<GoogleOAuthConfig> get config async {
        if (_config != null) return _config!;

        final map = await GoogleOAuthConfig.fromAsset('assets/oauth_client.json');
        _config = GoogleOAuthConfig.fromJson(map);
        return _config!;
    }

    GoogleSignIn? _googleSignIn;
    Future<GoogleSignIn> get googleSignIn async {
        if (_googleSignIn != null) return _googleSignIn!;

        final config = await this.config;

        _googleSignIn = GoogleSignIn(
            params: GoogleSignInParams(
                clientId: config.clientId,
                clientSecret: config.clientSecret,
                scopes: [ _bigQueryScope ],
                redirectPort: await port,
                saveAccessToken: _saveToken,
                retrieveAccessToken: retrieveToken,
                deleteAccessToken: deleteToken,
            ),
        );

        return _googleSignIn!;
    }

    // TODO: These "Feature" related methods are lacking logging and proper error handling, moving them into a "system-wide" storage management class would be better
    Future<void> _saveToken(String token) async {
        await _storageLock.synchronized(() async {
            try {
                await _storage.write(key: _desktopTokenKey, value: token);
            } catch (_) {
                await _storage.delete(key: _desktopTokenKey);
                await _storage.write(key: _desktopTokenKey, value: token);
            }
        });
    }

    Future<String?> retrieveToken() async {
        return await _storageLock.synchronized(() async {
            try {
                return await _storage.read(key: _desktopTokenKey);
            } catch (_) {
                await _storage.delete(key: _desktopTokenKey);
                return null;
            }
        });
    }

    Future<void> deleteToken() async {
        await _storageLock.synchronized(() async {
            await _storage.delete(key: _desktopTokenKey);
        });
    }

    // TODO: The login/logout flow seems very basic, maybe they can be removed or at least refactored to have better error handling and logging
    Future<bool> tryRestoreSession() async {
        final session = await googleSignIn;
        final creds = await session.silentSignIn();
        return creds != null;
    }

    Future<bool> signIn() async {
        final session = await googleSignIn;
        final creds = await session.signIn();
        return creds != null;
    }

    Future<void> signOut() async {
        final session = await googleSignIn;
        await session.signOut();
    }

    Future<http.Client> authenticatedClient() async {
        final session = await googleSignIn;
        final client = await session.authenticatedClient;
        if (client == null) {
            throw StateError('Not authenticated.');
        }
        return client;
    }
}