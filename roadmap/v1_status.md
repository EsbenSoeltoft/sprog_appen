# V1 — implementering og teststatus

Dato: 2026-11-02. Grundlag: `roadmap/v1_implementation_plan.md`.

## Resultat og arkitektur

Eksisterende Flutter 3.47.9 / Dart 3.13.7, FVM, Material 3 og Navigator er
bevaret. Baseline-analyse og de to eksisterende widgettests bestod før ændringer.
Android-ID `com.incipier.sprog_appen` og debug/profile/release-signering er uændret.
Kun TTS-service-query er tilføjet til Android-manifestet; ingen mikrofon,
cleartext eller ny netværkstilladelse er tilføjet.

Nye dependencies: `just_audio` 0.10.6, `flutter_tts` 4.2.5,
`shared_preferences` 2.5.6 og SDK-pakken `integration_test`. Navigator er
allerede i brug, så go_router er ikke tilføjet. ChangeNotifier håndterer state.

- `assets/data/vowel_ladders_v1.json`: tre separate vokalrækker og seks draft-ord med stabile ASCII-ID'er. Planens `træffe`-ID er normaliseret til `traeffe` før første lagrede fremdrift; visning bevarer æ.
- `lib/features/lydtrappen/data/lesson_repository.dart`: modeller, asynkron assetindlæsning, validering af schema, ID'er, referencer, svar, vokalmønstre og lydstier. Ugyldigt indhold giver en pæn fejltilstand med genforsøg.
- `lib/features/lydtrappen/logic/exercise_controller.dart`: svar, genforsøg, rækkefølge og bevaret session ved tilbage-navigation.
- `lib/features/lydtrappen/lydtrappen_screen.dart`: trappeoversigter, ord, øvelse, resultat, fremskridt og lydtest. Fælles LearningPage og AudioWordButton er efter V2 flyttet til egne filer. Læsehjælp er valgfri og afslører hele ordet, så øvelsen kan gennemføres uden lyd.
- `lib/features/audio/learning_audio_service.dart`: én lokal afspiller og TTS-wrapper; godkendt asset før da-DK-helords-TTS. Dansk sprog og stemme kontrolleres; intet engelsk fallback. Serialisering og request-ID'er håndterer hurtige tryk. Stop ved navigation/app-pause; ingen automatisk afspilning.
- `lib/features/progress/progress_repository.dart`: `SharedPreferencesAsync`, versioneret `progress_v1`, forsøg og første-svar-statistik, serialiserede writes, robust fejltilstand og bekræftet nulstilling. Genstart af en øvelse sletter ikke historik.
- `lib/app/`: opstart, fejlhåndtering, eksisterende navngivne Navigator-ruter og service-livscyklus. Ukendte ruter/ID'er giver en fejlskærm med vej til forsiden.
- `assets/audio/AUDIO_SOURCES.md` og tomt `audio_manifest.json`: rettigheder og godkendelsesprocedure. Der er ingen lokale lydklip eller falske placeholders.

Alle data og lyd er prototypeindhold. Ejeren er den aftalte godkender;
implementering eller TTS er ikke i sig selv faglig godkendelse.

## Verifikation

| Kontrol | Resultat |
| --- | --- |
| `fvm flutter analyze` | Bestået |
| `fvm flutter test` | 40 tests bestået i den samlede V1/V2-pakke (26 ved den første V1-leverance) |
| `fvm flutter build apk --debug` | Bestået |
| `fvm flutter build apk --profile` | Bestået ved V1-leverancen; ikke gentaget efter V2 |
| `fvm flutter build appbundle --release` | Stoppet som forventet ved `validateReleaseSigning`: privat `android/key.properties` mangler. Et signeret/optimeret release-build er derfor ikke verificeret. |
| Android-enhed | Efterfølgende integrationstest bestået på Samsung SM S931B / Android 17 (API 37): V1 y/ø, alle V2-forløb, native lagring genindlæst ved genoprettelse af app-state samt TTS-diagnostik. V5 har siden verificeret lagring efter fuldt processtop; lyttebedømmelse afventer. |

Tests dækker den faktiske Flutter-assetregistrering, alle seks spørgsmål,
forkerte svarmuligheder og ændret svarrækkefølge, ugyldigt indhold, manglende
assets, TTS/assetprioritet, manglende dansk stemme, hurtige lydkald og
lydfejl med fake backend. Widgettests dækker alle tre forløb, tilbage-navigation,
direkte øvelsesrute, ukendt ID, fejl/genforsøg ved opstart, semantik, nulstilling
og 320 × 640 ved dobbelt tekststørrelse. Lagring genindlæses i en ny repository-
instans i tests; native diskpersistens efter fuldt processtop er efterfølgende verificeret i V5.

Builds viser en advarsel om `flutter_tts`' brug af Kotlin Gradle Plugin. Den
fastlåste Flutter-version bygger korrekt. Vurdér pluginets understøttelse af
Built-in Kotlin ved en senere Flutter-opgradering; ændr ikke nuværende signering
eller Gradle-opsætning alene for at fjerne advarslen.

## Kvalitets-gates

| Gate | Status |
| --- | --- |
| G0 — kodeprototype | Kode og automatiske tests består. Fysisk Android-integrationstest har gennemført V1 y/ø, V2, native genindlæsning og TTS-diagnostik. Fuld procesgenstart for lagringen er siden verificeret i V5. Faktisk afspilning af alle ord mangler fortsat; G0 er derfor ikke fuldt accepteret. |
| G1 — lokal lydprototype | Afventer én reel, lovlig, godkendt ordoptagelse og afspilning på Android. |
| G2 — fagligt gennemset pilot | Afventer ejerens godkendelse af alle seks ord, forklaringer og den faktiske udtale. Alle ord forbliver draft. |
| G3 — offentlig udgivelse | Afventer G1/G2, privatliv, tilgængelighed på enhed, rettigheder og release-signering. Ikke udgivelsesklar. |

## Afprøv på Android

Tilslut en fysisk Android-telefon og kør:

```sh
fvm flutter devices
fvm flutter run -d DEVICE_ID
fvm flutter test integration_test/vowel_ladder_flow_test.dart --no-uninstall -d DEVICE_ID
```

Erstat `DEVICE_ID` med telefonens ID. Integrationstesten er efterfølgende kørt
og bestået på Android. Den åbner appen, løser y/ø-forløbet og alle V2-forløb,
genopretter app-state og kontrollerer fremdrift samt åbner native TTS-diagnostik.
Den erstatter ikke lytning eller fuld lukning/genåbning af Android-processen.

Gennemfør også V1-planens manuelle matrix: alle seks ord, 10 hurtige afspilninger,
appskift, fuld lukning/genåbning, manglende dansk stemme, flytilstand, lydstyrke,
TalkBack, stor tekst og landskab. TTS kan kræve netværk. Der kan endnu ikke
gives en offline-lydgaranti, da der ikke findes bundtede ordoptagelser.

Intet commit eller push er udført som led i implementeringen.

Efterfølgende status: Den samlede pakke har nu 40 tests samt én bestået fysisk
Android-integrationstest. Se [V2-status](v2_status.md). G1–G3 er fortsat åbne.

Seneste samlede verifikation efter V3: 53 tests samt den udvidede fysiske
Android-integrationstest består. Se [V3-status](v3_status.md). Tidligere testtal
i dette dokument beskriver leverancen på det pågældende tidspunkt.

Seneste samlede verifikation efter V4: 67 automatiske tests og udvidet fysisk
Android-integrationstest består. Se [V4-status](v4_status.md). Tidligere tal
beskriver den tidligere leverance; faglige og lydmæssige godkendelser er fortsat åbne.

Seneste samlede status efter V5: 79 automatiske tests og native genoptagelse
efter et fuldt Android-processtop består. Se [V5-status](v5_status.md), inklusive
rettet testarbejdsgang med --no-uninstall. Tidligere testtal er historiske.
