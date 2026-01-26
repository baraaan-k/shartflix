import 'package:flutter/material.dart';

import '../../../../shared/widgets/simple_placeholder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholder(
      title: 'Home Feed',
      description: 'Movie list will appear here in the next milestone.',
    );
  }
}
