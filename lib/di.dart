import 'package:get_it/get_it.dart';
import 'package:plena_veste/auth/oauth_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
    getIt.registerLazySingleton<GoogleOAuthService>(() => GoogleOAuthService());
}