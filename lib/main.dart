import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'controllers/receipt_controller.dart';
import 'services/draft_service.dart';
import 'services/pdf_service.dart';
import 'services/settings_service.dart';
import 'ui/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final controller = ReceiptController(SettingsService(), PdfService(), DraftService());
  await controller.init();

  runApp(NotaAlyaApp(controller: controller));
}

class NotaAlyaApp extends StatelessWidget {
  const NotaAlyaApp({super.key, required this.controller});

  final ReceiptController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nota Alya Florist',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(controller.settings.themeSeed), brightness: Brightness.light),
            visualDensity: VisualDensity.compact,
            textTheme: const TextTheme(
              headlineSmall: TextStyle(fontWeight: FontWeight.w700),
              titleMedium: TextStyle(fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(height: 1.35),
              labelLarge: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(controller.settings.themeSeed), brightness: Brightness.dark),
            visualDensity: VisualDensity.compact,
            textTheme: const TextTheme(
              headlineSmall: TextStyle(fontWeight: FontWeight.w700),
              titleMedium: TextStyle(fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(height: 1.35),
              labelLarge: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          themeMode: controller.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(controller: controller),
        );
      },
    );
  }
}
