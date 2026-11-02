import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/lydtrappen/data/lesson_repository.dart';

import 'support/fakes.dart';

class FixtureBundle extends CachingAssetBundle {
  FixtureBundle(this.data);
  final Map<String, dynamic> data;
  @override
  Future<ByteData> load(String key) async {
    final String value;
    if (key == 'assets/data/vowel_ladders_v1.json') {
      value = jsonEncode(data);
    } else if (key == 'assets/audio/audio_manifest.json') {
      value = '{"schemaVersion":1,"clips":[]}';
    } else {
      throw StateError('missing asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test("registered Flutter asset bundle loads", () async {
    final data = await LessonRepository().load();
    expect(data.exercises.length, 6);
    expect(data.approvedAssets, isEmpty);
  });
  test(
    'loads six draft exercises, three separate ladders and Danish words',
    () async {
      final data = await LessonRepository().load(
        bundle: FixtureBundle(fixture()),
      );
      expect(data.ladders.length, 3);
      expect(data.exercises.length, 6);
      expect(data.words.every((w) => w.contentStatus == 'draft'), isTrue);
      for (final e in data.exercises) {
        expect(
          e.maskedText.replaceFirst('_', e.answer),
          data.word(e.wordId).text,
        );
        for (final wrong in e.options.where((v) => v != e.answer)) {
          expect(e.accepts(wrong), isFalse);
        }
      }
    },
  );
  void invalid(
    String name,
    void Function(Map<String, dynamic>) change,
    String code,
  ) {
    test(name, () {
      final data = fixture();
      change(data);
      expect(
        () => ContentValidator.parse(data),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'code',
            contains(code),
          ),
        ),
      );
    });
  }

  invalid(
    'unknown word reference',
    (d) => d['exercises'][0]['wordId'] = 'missing',
    'unknown_word',
  );
  invalid(
    'unknown ladder reference',
    (d) => d['words'][0]['ladderId'] = 'missing',
    'unknown_ladder',
  );
  invalid(
    'duplicate ID',
    (d) => d['words'][1]['id'] = d['words'][0]['id'],
    'duplicate_id',
  );
  invalid(
    'invalid answer reconstruction',
    (d) => d['exercises'][0]['maskedText'] = 'h__st',
    'masked_word',
  );
  invalid(
    'duplicate answer choice',
    (d) => d['exercises'][0]['options'] = ['e', 'e'],
    'options',
  );
  invalid(
    'TTS must be the whole word',
    (d) => d['words'][0]['audio']['ttsText'] = 'æ',
    'tts_must_be_whole_word',
  );
  invalid(
    'no remote audio paths',
    (d) => d['words'][0]['audio']['assetPath'] = 'https://example.com/a.mp3',
    'invalid_asset_path',
  );
  invalid('unknown schema', (d) => d['schemaVersion'] = 2, 'schema_version');
  test('missing referenced asset fails controlled repository load', () async {
    final data = fixture();
    data['words'][0]['audio']['assetPath'] = 'assets/audio/missing.mp3';
    await expectLater(
      LessonRepository().load(bundle: FixtureBundle(data)),
      throwsStateError,
    );
  });
  test('answer position is not treated as the correct answer', () {
    final data = fixture();
    for (final e in data['exercises']) {
      e['options'] = (e['options'] as List).reversed.toList();
    }
    final content = ContentValidator.parse(data);
    for (final e in content.exercises) {
      expect(e.accepts(e.options.first), isFalse);
      expect(e.accepts(e.answer), isTrue);
    }
  });
  invalid(
    'u to o is not a training rule',
    (d) => d['words'][3]['pronunciationHint'] = 'o',
    'unsupported_vowel_pattern',
  );
}
