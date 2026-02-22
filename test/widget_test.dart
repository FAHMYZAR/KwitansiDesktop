import 'package:flutter_test/flutter_test.dart';
import 'package:nota_alya_florist/controllers/receipt_controller.dart';
import 'package:nota_alya_florist/main.dart';
import 'package:nota_alya_florist/services/draft_service.dart';
import 'package:nota_alya_florist/services/history_service.dart';
import 'package:nota_alya_florist/services/pdf_service.dart';
import 'package:nota_alya_florist/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app boot', (tester) async {
    final controller = ReceiptController(SettingsService(), PdfService(), DraftService(), HistoryService());
    await controller.init();

    await tester.pumpWidget(NotaAlyaApp(controller: controller));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.textContaining('Alyaa Florist'), findsOneWidget);
    expect(find.text('Form Nota'), findsOneWidget);
  });
}
