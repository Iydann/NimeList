import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nime_list/main.dart';
import 'package:nime_list/screens/detail_screen.dart';
import 'package:nime_list/screens/login_screen.dart';
import 'package:nime_list/screens/main_screen.dart';

void main() {
  testWidgets('Login is replaced and detail returns to the selected tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Login dengan Google'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen, skipOffstage: false), findsNothing);
    expect(Navigator.canPop(tester.element(find.byType(MainScreen))), isFalse);

    const tabIcons = [Icons.home_outlined, Icons.search, Icons.bookmark_border];

    for (var index = 0; index < tabIcons.length; index++) {
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(tabIcons[index]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);

      // Pada layar kecil, judul kartu mungkin perlu digulir terlebih dahulu.
      await tester.ensureVisible(find.text('Frieren'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frieren'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(DetailScreen), findsNothing);
      expect(find.byType(BackButton), findsNothing);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        index,
      );
      expect(
        Navigator.canPop(tester.element(find.byType(MainScreen))),
        isFalse,
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('Leaving Home during loading does not update disposed state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Login dengan Google'));
    await tester.pump();
    // Selesaikan animasi route sebelum loading dua detik selesai.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.search),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
