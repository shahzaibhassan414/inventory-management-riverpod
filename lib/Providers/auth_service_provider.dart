import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/auth_services.dart';

final authServiceProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});
