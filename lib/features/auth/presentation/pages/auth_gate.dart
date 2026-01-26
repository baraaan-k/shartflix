import 'package:flutter/material.dart';

import '../../../../app/app_shell.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/get_token_usecase.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final getToken = ServiceLocator.instance.get<GetTokenUseCase>();

    return FutureBuilder<String?>(
      future: getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data != null) {
          return const AppShell();
        }

        return const LoginPage();
      },
    );
  }
}
