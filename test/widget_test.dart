import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemacentral/main.dart';
import 'package:cinemacentral/services/favorites_service.dart';

void main() {
  testWidgets('CinemaCentral app builds and renders navigation tabs', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await FavoritesService().init();
    });

    await tester.pumpWidget(const CinemaCentralApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify main app title and navigation items exist
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Dispose widgets cleanly to cancel periodic timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
