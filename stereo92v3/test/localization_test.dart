import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/l10n/generated/app_localizations.dart';

void main() {
  test('loads all supported radio localizations', () async {
    const expectedTaglines = <String, String>{
      'es': 'MÁS RADIO',
      'en': 'More radio',
      'pt': 'Mais rádio',
      'fr': 'Plus de radio',
    };

    for (final entry in expectedTaglines.entries) {
      final l10n = await AppLocalizations.delegate.load(Locale(entry.key));
      expect(l10n.stationTagline, entry.value);
      expect(l10n.play, isNotEmpty);
      expect(l10n.timerConfigure, isNotEmpty);
    }
  });
}
