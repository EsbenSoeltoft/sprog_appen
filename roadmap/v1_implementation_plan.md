# Sprog Appen — v1 Implementation Plan

**Dokument:** `v1_implementation_plan.md`  
**Version:** 1.0  
**Dato:** 2026-11-02  
**Status:** Kodeprototype implementeret; Android-integrationstest bestået. Manuel lydtest, optagelser og ejerens faglige godkendelse afventer.
**Primær platform:** Flutter / Android, eksisterende FVM-konfiguration.  
**Projekt:** `sprog_appen` — forventet lokal placering: `~/Documents/Code/sprog_appen`.

> **Formål:** Lever en lille, fungerende vertikal prototype med navigation, dataindlæsning, en interaktiv **vokaltrappe** (i appens bredere *lydtrappe*-område), dansk lydafspilning, øvelser, fremdrift og automatiserede tests. Planen må ikke bruges som anledning til at omskrive allerede fungerende kode eller Android-buildopsætning.

---

## Implementeringsstatus — 2026-11-02

Kodeprototypen er implementeret; se [teststatus og G0–G3](../docs/v1_status.md).
Kodearbejdet i Step 0–5 er implementeret og automatisk testet. Lokal asset-test
afventer en optagelse. Fysisk Android-integrationstest og almindelig appstart
er gennemført; faktisk afspilning af alle ord, fuld procesgenstart og resten af
den manuelle testmatrix afventer. Step 3, 5 og 6 er derfor ikke fuldt accepteret.
Den allerede fungerende Flutter Navigator er genbrugt uden go_router.
Appens ejer er godkender af lyde, undervisningsindhold og øvrig kvalitet, som
besluttet i hovedroadmappet. Referencer til lærer/fagperson i planen ændrer
ikke denne ansvarsfordeling. Der er ikke indhentet faglig godkendelse endnu.

## 1. Beslutninger og afgrænsning

### 1.1 Målgruppe og læringsmodel

- Langsigtet målgruppe: elever på **1.–9. klassetrin**; fagligt niveau vælges efter færdighed, ikke automatisk efter alder eller klasse.
- V1-pilot: relevant for elever omkring **3.–6. klasse**, inklusive elever i 5. klasse, som træner vokalernes forbindelse mellem lyd og skrift.
- V1 har én reel læringssti: **Lydtrappen → Vokaltrappen**. Andre planlagte emner (stavelser, endelser, sammensatte ord og udsagnsord) må vises som *kommer senere* eller helt udelades.
- Brug **“Lydtrappen”** som bredt navigationsnavn, men **“Vokaltrappen”** om den specifikke model med vokalsænkning. Dette er en foreløbig produktbeslutning indtil læreren har bekræftet den nøjagtige betydning af “lydtrappen”.
- Ingen login, backend, cloudsynkronisering, mikrofon, reklamer, elevprofiler eller vurdering af elevens egen udtale i v1.

### 1.2 Faglig forståelse af vokaltrappen

Implementér tre **visuelle vokalrækker**, ikke én fælles serie:

1. `i → e → æ → a`
2. `u → o → å`
3. `y → ø`

Der er tale om pædagogiske oversigter over mulige **vokalsænkninger** i bestemte danske ord, **ikke** om en universel algoritme til at stave efter. En bestemt skrevet vokal kan have forskellige udtaler; der er samtidig mange ord, hvor ingen sænkning forekommer.

**Faglige guardrails:**

- Vis ikke `u → o` som en almindelig rigsdansk træningsregel. Vælg i v1 de dokumenterede mønstre `u → å` og `o → å`.
- For `i → e/æ`, `e → æ/a`, `æ → a`, `u → å`, `o → å` og `y → ø`: øvelserne bygger på *konkrete ord* med fagligt kontrolleret udtale, ikke på automatisk transformation af bogstaver.
- Et ords skrevne vokal (`spellingVowel`) og den **lyd, som eleven skal høre** (`pronunciationHint` / eventuelt fagligt valideret IPA), er forskellige datafelter.
- Vokallyden skal helst høres **inde i et helt ord**. Isolerede vokallyde er en særskilt, kvalitetssikret lydtype, ikke det samme som Android-TTS' udtale af bogstavnavnet.
- Oplys at lydhenvisninger som “e lyder lidt som æ” er pædagogiske tilnærmelser, og at udtalen kan variere.
- Brug ikke lyd- eller opgavefiler fra læremidler direkte uden rettighedsafklaring.

**Centrale faglige kilder:**

- GDF, *Vokaltrappen og vokalforveksling*: https://gdf.dk/stavning/vokaler/vokaltrappen
- Sproget.dk, *Lydskriftoversigt* (Dania/IPA og ordeksempler): https://sproget.dk/sprogviden/sprogtemaer/udtale/lydskriftoversigt/
- Fælles Mål, dansk: https://www.retsinformation.dk/eli/lta/2024/1715

### 1.3 Hvad betyder “v1 færdig”?

**Prototypen er implementeret**, når brugeren på en fysisk Android-telefon kan:

1. Åbne appen og finde **Lydtrappen** fra forsiden.
2. Se og skifte mellem de tre vokaltrapper.
3. Vælge en af trappens relevante ordøvelser.
4. Afspille **dansk udtale af hele ordet** via en lokal lydfil eller via eksplicit mærket dansk TTS-fallback.
5. Svare på mindst seks ordøvelser fordelt på de tre vokaltrapper.
6. Få fagligt forsvarlig feedback og prøve igen.
7. Gå frem, tilbage og vende tilbage til oversigten uden tab af navigationstilstand.
8. Lukke/genåbne appen og se gemt lokal fremdrift.
9. Åbne **Lydtest** og se, om lokal lyd, TTS og dansk stemme virker.
10. Gennemføre analysetest og debug-build uden fejl.

**Ikke ensbetydende med udgivelsesklar:** Alle lydklip og øvelser skal derefter gennemgås af en dansksproget fagperson. En TTS-only prototype må ikke markedsføres som en valideret udtaleunderviser.

---

## 2. Eksisterende projekt: kontrol før ændringer

Codex skal **først læse** disse filer, hvis de findes:

- `roadmap_sprog_appen.md`, `getting_started.md` og dette dokument.
- `pubspec.yaml`, `pubspec.lock`, `.fvmrc`, `.gitignore`.
- Eksisterende `lib/`-struktur, navigation, state management og tests.
- Android Gradle Kotlin DSL (`*.gradle.kts`), manifest og signing-konfiguration.

**Bevar:**

- Den valgte Flutter-version styret af FVM.
- Eksisterende package/application-id og planlagt domænetilknytning til `incipier.com`. Hvis et package-id skal etableres, foreslås `com.incipier.sprog appen`, men **ændr ikke en allerede besluttet identitet** uden grund.
- Eksisterende debug/profile/release-buildopsætning og signing.
- Eksisterende state management eller router, hvis allerede valgt og velfungerende.

**Rapportér kort før kodeændringer:** faktisk SDK-version, eksisterende dependencies, projektstruktur, konflikter og hvad der genbruges. Opret ikke en ny Flutter-app oven på den eksisterende.

---

## 3. Pakker og tekniske valg

| Behov | Anbefaling | Status i v1 | Bemærkning |
|---|---|---|---|
| Lokale lydfiler | [`just_audio`](https://pub.dev/packages/just_audio) | **Obligatorisk** | Understøtter `setAsset(...)` og afspilning uden internet. |
| Dansk TTS-fallback | [`flutter_tts`](https://pub.dev/packages/flutter_tts) | **Obligatorisk til prototypen** | Benytter installeret Android-TTS og `da-DK`, når tilgængelig. |
| Navigation | [`go_router`](https://pub.dev/packages/go_router) | Brug hvis ikke eksisterende router | Navigation 2 med navngivne ruter; undgå dobbelt router. |
| Lille lokal fremdrift | [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Brug hvis ingen eksisterende lokal lagring | Anvend `SharedPreferencesAsync` eller tilsvarende nyere API. |
| App-state | Eksisterende løsning eller almindelige `ChangeNotifier`/services | **Ingen ny pakke nødvendig** | Riverpod kan anvendes, hvis projektet allerede bruger det. |
| Test | `flutter_test`, `integration_test` (Flutter SDK) | **Obligatorisk** | Ingen tredjeparts testpakke er påkrævet. |

**Versionsafklaring pr. 2026-11-02:** `just_audio` 0.10.6, `flutter_tts` 4.2.5, `go_router` 18.1.2 og `shared_preferences` 2.5.6 er tilgængelige. Disse er **referenceversioner, ikke et krav om opgradering**: `go_router` 18.1.2 kræver Dart 3.12, mens `shared_preferences` 2.5.6 kræver Dart 3.11. Codex skal vælge nyeste kompatible, stabile version, respektere `pubspec.lock` og undgå unødvendig SDK-opgradering.

```bash
fvm flutter --version
fvm flutter pub outdated
# Tilføj kun nødvendige pakker og lås kompatible versioner:
fvm flutter pub add just_audio flutter_tts
# Kun hvis projektet ikke allerede har tilsvarende løsninger:
fvm flutter pub add go_router shared_preferences
fvm flutter pub get
```

**Fravalg i v1:** `record`, `permission_handler`, talegenkendelse, lydoptagelse fra børn, `audio_service`, `just_audio_background`, database/ORM, Firebase, netværksstreaming, cloud-TTS ved runtime og yderligere state-management-rammeværk. De er ikke nødvendige til den ønskede afprøvning.

---

## 4. Foreslået kode- og assetstruktur

Tilpas efter eksisterende projektkonventioner, men bevar ansvarsskellene:

```text
lib/
  app/
    app.dart
    app_router.dart
  features/
    home/
      home_screen.dart
    lydtrappe/
      data/
        lesson_repository.dart
        content_validator.dart
      domain/
        vowel_ladder.dart
        word_entry.dart
        exercise.dart
      presentation/
        lydtrappe_overview_screen.dart
        vowel_ladder_screen.dart
        word_exercise_screen.dart
        exercise_result_screen.dart
      logic/
        exercise_controller.dart
    progress/
      progress_repository.dart
      progress_screen.dart
    audio/
      learning_audio_service.dart
      asset_audio_player.dart
      tts_audio_player.dart
      audio_test_screen.dart
assets/
  data/
    vowel_ladders_v1.json
  audio/
    words/
      # Kun eksisterende lydfiler med verificerede rettigheder
    phonemes/
      # Kan være tom i prototypen; knapper deaktiveres uden godkendt lyd
    AUDIO_SOURCES.md
    audio_manifest.json

test/
  content_validation_test.dart
  exercise_controller_test.dart
  learning_audio_service_test.dart
  navigation_test.dart
integration_test/
  vowel_ladder_flow_test.dart
```

`assets/audio/AUDIO_SOURCES.md` skal forklare rettigheder, stemmekilder og kvalitetssikringsstatus. Tomme kataloger kan markeres med `.gitkeep`, men **aldrig** med tomme eller falske `.mp3`-filer.

I `pubspec.yaml` registreres mindst:

```yaml
flutter:
  assets:
    - assets/data/
    # Tilføj kun audio-mapper med reelle aktiver:
    # - assets/audio/words/
    # - assets/audio/phonemes/
```

---

## 5. Navigation og skærme

### 5.1 Ruteoversigt

| Rute | Skærm | Indhold |
|---|---|---|
| `/` | Forside | Kort introduktion, tydeligt kort: **Lydtrappen** |
| `/lydtrappe` | Lydtrappe-oversigt | Kort: **Vokaltrappen**, senere emner passive |
| `/lydtrappe/vokaler` | Vokaltrappe-oversigt | Tre visuelt tydelige trappegrupper |
| `/lydtrappe/vokaler/:ladderId` | Trappedetalje | Rækkens bogstaver, forklaring og ordøvelser |
| `/lydtrappe/oevelse/:exerciseId` | Ordøvelse | Afspil, vælg vokal, få feedback, fortsæt |
| `/fremskridt` | Fremskridt | Gennemførte øvelser, antal rigtige og gentag |
| `/indstillinger/lydtest` | Lydtest | Kontroller lydfil, dansk TTS og fejlstatus |

Brug konsekvente, ASCII-baserede ruteparametre og ID'er. Direkte deep links skal have en pæn fejltilstand ved ukendte ID'er. Androids tilbageknap skal virke naturligt, og quiz-state må ikke utilsigtet nulstilles af en almindelig tilbage-navigation.

### 5.2 Skærmenes minimumsindhold

**Forside**
- Titel, én kort sætning om appens formål og stor, tilgængelig knap til Lydtrappen.
- Diskret adgang til Fremskridt og Lydtest.

**Vokaltrappe-oversigt**
- En trappe tegnet med Flutter-widgets (`Column`, `Container`, `Semantics`), **ikke** med tredjeparts kopierede illustrationer.
- Tre grupper med egne farver, men **aldrig farve som eneste betydningsbærer**.
- Læsbar trinrækkefølge (`i`, `e`, `æ`, `a` osv.) med trykbare rækker.
- Kort note om, at lyde og stavning ikke altid er ens.

**Trappedetalje**
- Trappens titel og trin; vis eksempelord med markeret *skrevet* vokal.
- Knap “Hør ordet” ved hvert eksempel; vis kilde/status via udviklerens lydtest, ikke i børne-UI.
- “Start øvelser” og tilbage-knap.

**Øvelse**
- Præcis ét tydeligt spørgsmål ad gangen, eksempelvis `h_st` med valgene `e` / `æ`.
- Stort ikon/knap “Hør ordet”; mulighed for at høre gentagne gange.
- Lytteaktivitet og stavning adskilles: ordets komplette korrekte skriftform afsløres først efter svar.
- Ved svar: korrekt/ikke korrekt og en kort, positiv forklaring. Fejl må gerne kunne rettes uden at skamme eleven ud.
- Knapper: Prøv igen / Næste / Tilbage til trappen.
- Tilgængelighed: minimum 48 × 48 dp trykflader; skærmlæserlabels, understøt tekstskalering; ingen opgave, som **kun** kan forstås via lyd.

**Lydtest**
- Test lokal assetafspilning (hvis en ægte lydfil findes), afspilning med `da-DK` TTS og tydelig status på om stemmen er installeret.
- Vis fejlkoder/meddelelser til udvikleren og en enkel brugerbesked: “Dansk tale er ikke tilgængelig på denne enhed”.
- Tilbyd “Prøv igen”. **Ingen** automatisk mikrofontilladelse.

---

## 6. Læringsdata — aftalte kontrakter

### 6.1 Principper

- Indholdet leveres som lokale, versionsstyrede JSON-assets.
- UI må ikke have hårdkodede ordlister, korrekt-svar-indekser eller lydfilstier.
- Stabile ID'er må ikke ændres ved tekstrettelser. Progression gemmes via ID, ikke array-indeks.
- Indhold skal kunne udvides til stavelser, endelser og grammatik uden at ombygge router eller lydservice.
- Der skelnes eksplicit mellem **godkendt** og **udkast**.
- Appen håndterer ugyldigt dataindhold kontrolleret, uden crash i produktion.

### 6.2 Foreslået JSON-eksempel

Fil: `assets/data/vowel_ladders_v1.json`

```json
{
  "schemaVersion": 1,
  "moduleId": "lydtrappe.vokaler",
  "title": "Vokaltrappen",
  "targetGrades": [3, 4, 5, 6],
  "ladders": [
    {"id": "i-e-ae-a", "label": "i – e – æ – a", "letters": ["i", "e", "æ", "a"]},
    {"id": "u-o-aa", "label": "u – o – å", "letters": ["u", "o", "å"]},
    {"id": "y-oe", "label": "y – ø", "letters": ["y", "ø"]}
  ],
  "words": [
    {
      "id": "word-hest",
      "text": "hest",
      "ladderId": "i-e-ae-a",
      "spellingVowel": "e",
      "pronunciationHint": "æ",
      "patternId": "e-sounds-like-ae",
      "explanation": "I 'hest' skriver vi e, selv om vokalen lyder omtrent som æ.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "hest", "locale": "da-DK"}
    },
    {
      "id": "word-kvinde",
      "text": "kvinde",
      "ladderId": "i-e-ae-a",
      "spellingVowel": "i",
      "pronunciationHint": "e",
      "patternId": "i-sounds-like-e",
      "explanation": "I 'kvinde' skriver vi i. Vokalen kan lyde som e.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "kvinde", "locale": "da-DK"}
    },
    {
      "id": "word-ost",
      "text": "ost",
      "ladderId": "u-o-aa",
      "spellingVowel": "o",
      "pronunciationHint": "å",
      "patternId": "o-sounds-like-aa",
      "explanation": "I 'ost' skriver vi o, selv om lyden er å-lignende.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "ost", "locale": "da-DK"}
    },
    {
      "id": "word-bunde",
      "text": "bunde",
      "ladderId": "u-o-aa",
      "spellingVowel": "u",
      "pronunciationHint": "å",
      "patternId": "u-sounds-like-aa",
      "explanation": "I 'bunde' skriver vi u. Her lyder vokalen omtrent som å.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "bunde", "locale": "da-DK"}
    },
    {
      "id": "word-kysse",
      "text": "kysse",
      "ladderId": "y-oe",
      "spellingVowel": "y",
      "pronunciationHint": "ø",
      "patternId": "y-sounds-like-oe",
      "explanation": "I 'kysse' skriver vi y. Vokalen lyder omtrent som ø.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "kysse", "locale": "da-DK"}
    },
    {
      "id": "word-træffe",
      "text": "træffe",
      "ladderId": "i-e-ae-a",
      "spellingVowel": "æ",
      "pronunciationHint": "a",
      "patternId": "ae-sounds-like-a",
      "explanation": "I 'træffe' skriver vi æ. Her er udtalen mere a-lignende.",
      "contentStatus": "draft",
      "audio": {"assetPath": null, "ttsText": "træffe", "locale": "da-DK"}
    }
  ],
  "exercises": [
    {"id": "ex-hest", "type": "choose_missing_vowel", "wordId": "word-hest", "maskedText": "h_st", "options": ["e", "æ"], "answer": "e"},
    {"id": "ex-kvinde", "type": "choose_missing_vowel", "wordId": "word-kvinde", "maskedText": "kv_nde", "options": ["i", "e"], "answer": "i"},
    {"id": "ex-ost", "type": "choose_missing_vowel", "wordId": "word-ost", "maskedText": "_st", "options": ["o", "å"], "answer": "o"},
    {"id": "ex-bunde", "type": "choose_missing_vowel", "wordId": "word-bunde", "maskedText": "b_nde", "options": ["u", "å"], "answer": "u"},
    {"id": "ex-kysse", "type": "choose_missing_vowel", "wordId": "word-kysse", "maskedText": "k_sse", "options": ["y", "ø"], "answer": "y"},
    {"id": "ex-træffe", "type": "choose_missing_vowel", "wordId": "word-træffe", "maskedText": "tr_ffe", "options": ["æ", "a"], "answer": "æ"}
  ]
}
```

**Vigtigt:** JSON'en er et **startdatasæt til prototype**, ikke en fagligt godkendt ordliste. Kildeeksemplerne er valgt, fordi sproget.dk/GDF dokumenterer de relevante mønstre, men **ordvalg, lyd, dialekt, forklaring og sværhedsgrad skal gennemgås før publicering**. `contentStatus: "draft"` skal derfor bevares indtil eksplicit godkendelse.

### 6.3 Validering ved opstart og i tests

Implementér `ContentValidator` med disse checks:

- `schemaVersion == 1` og obligatoriske felter er udfyldt.
- Unikke `id` for ladders, words og exercises.
- Alle `ladderId`/`wordId` findes.
- `spellingVowel` forekommer på rette position i ordet; for v1 må der kun mangle **én** valgt vokal i `maskedText`.
- Sammenkædning af `maskedText` og `answer` giver præcis `word.text` (inkl. danske Unicode-tegn).
- `answer` findes i `options`, og hvert valgmuligheds-ID er entydigt inden for en øvelse.
- `pronunciationHint` må ikke betragtes som IPA eller bruges som TTS-input for enkeltlyd.
- Alle ikke-null `assetPath` skal ligge under `assets/audio/` og findes i bundlen.
- Manglende/ugyldige eller ikke-godkendte optagelser må aldrig falde tilbage til *bogstavnavne-TTS* uden tydelig UI-markering.
- Log detaljer i debug; vis pæn fejlskærm i release.

**Udvidelsespunkt efter v1:** tilføj `phoneticNotation` (`ipa`/`dania`), `pronunciationVariantId`, `audioReviewStatus` og `pedagogicalReview` uden at ændre eksisterende ID'er.

---

## 7. Lyd — arkitektur, kilder og kvalitetskrav

### 7.1 Lydprioritering

Audio-service skal have ét fælles interface, for eksempel:

```dart
abstract interface class LearningAudioService {
  Future<AudioPlaybackResult> playWord(WordEntry word);
  Future<AudioPlaybackResult> playAsset(String assetPath);
  Future<AudioDiagnostics> diagnostics();
  Future<void> stop();
  Future<void> dispose();
}
```

Konkret afspilningsstrategi:

1. **Førstevalg: lokal, licensgodkendt og sprogfagligt godkendt ordlydfil** (`audio.assetPath`). Afspil med `just_audio`.
2. **Prototype-fallback: Android-TTS af hele ordet**, hvis en dansk `da-DK`-stemme reelt er tilgængelig. Vis i Lydtest, at afspilningen er syntetisk.
3. Hvis ingen lokal lyd/brugbar dansk TTS: knappen markeres utilgængelig med kort forklaring; **ingen stiltiende engelsk stemme** eller lyd på et andet sprog.
4. Ved isolerede vokal-/fonemlyde: kræv **optaget og godkendt asset**. TTS, som får teksten `"e"`, kan læse bogstavets navn frem for den ønskede lyd og er derfor ikke en acceptabel automatisk fallback.

**Ingen browser-/cloudlyd ved runtime i v1.** TTS-motoren på enheden kan selv kræve netværk afhængigt af stemme og opsætning; **offline-garanti gælder derfor kun de bundtede lydfiler**. Test flytilstand eksplicit.

### 7.2 `just_audio`: krav til implementering

- Opret én afspiller pr. audio-service, genbrug den, og kald `dispose()` ved korrekt livscyklusafslutning.
- Ved hurtigt skift mellem ord: stop den gamle afspilning før nyt `setAsset()`; brug request-ID/cancellation guard mod race conditions.
- Under load: vis midlertidigt busy-state; tillad replay efter afslutning.
- Håndter `PlayerException`, ugyldige paths, lydafbrydelser og app pause/resume.
- Stop lyd ved navigation væk fra øvelsen. Afspil ikke automatisk, når skærmen åbnes.
- Lydfunktion må **ikke** bruge netværkstilladelse til lokale assets. Aktiver ikke bred `usesCleartextTraffic` for at håndtere et problem, vi ikke har.

Illustrativ API, som Codex skal indarbejde med egen fejl- og livscyklushåndtering:

```dart
final player = AudioPlayer();
await player.setAsset('assets/audio/words/hest.mp3');
await player.play();
// Stop ved navigation, dispose ved service-livscyklusens ophør.
```

### 7.3 `flutter_tts`: krav til implementering

- Initialisér én TTS-wrapper med `setLanguage('da-DK')` efter kontrol af tilgængelige sprog/stemmer.
- Undersøg `getLanguages`, `getVoices` og evt. Androids installerede stemme; fejlhåndtering skal være synlig på Lydtest-skærmen.
- Indstil talehastighed konservativt, men antag **ikke**, at en bestemt værdi lyder ens på alle Android-motorer. Den skal vurderes på den faktiske testenhed.
- TTS-ordet (`ttsText`) skal være det **hele danske ord**, aldrig maskeret tekst eller udtalehint.
- Ved hurtige tryk: kald `stop()` på forrige tale før ny `speak()`; serialisér/reducer samtidige kald.
- Android 11+-manifest: gennemgå dokumentationen om `<queries><intent><action android:name="android.intent.action.TTS_SERVICE" /></intent></queries>`; tilføj når nødvendigt i eksisterende manifest.
- Android-version/minSdk skal overholde både Flutter-projektet og valgt pluginversion; Codex skal **ikke** blindt ændre Gradle-/SDK-krav.

### 7.4 Egnede kilder til danske lydfiler

| Kilde | Hvad findes? | Vurdering til v1 |
|---|---|---|
| Egen indtaling | De seks ord og eventuelt særskilte vokaler | **Foretrukket.** Ensartet stemme, udtale og rettigheder; få lærer/fagperson til at validere. |
| [Wikimedia Commons: Danish pronunciation](https://commons.wikimedia.org/wiki/Category:Danish_pronunciation) | Enkeltord i OGG-format, begrænset udvalg | Mulig for konkrete ord; **kontrollér hver fils licens, ophav og udtale**. OGG-understøttelse skal testes på Android, eller filen konverteres lovligt til understøttet format med korrekt attribution. |
| [Mozilla Common Voice](https://commonvoice.mozilla.org/en/datasets) | Dansk CC0-1.0 taledatasæt med mange sætninger | God forsknings-/dataressource, **ikke et færdigt vokaltrappe-lydbibliotek**. Udklip af ord kræver manuel lyd- og kontekstkontrol. |
| [Den Danske Ordbog](https://ordnet.dk/ddo) / [sproget.dk](https://sproget.dk/) | Udtale-/lydskriftreference | Faglig kontrol; **ingen automatisk ret til at hente og genudgive lydfiler**. |
| Google Cloud TTS / anden cloud-TTS | Danske syntetiske stemmer | Mulig fremtidig produktionspipeline, men kræver pris-, API- og **licensvilkårsafklaring**. Ikke nødvendig for v1. |

**Ikke automatisk scraping:** Forvo, ordnet.dk, kommercielle læremidler og lignende må ikke bruges som frit lydbibliotek uden dokumenterede brugsrettigheder. Open-source-licens på et downloader-script giver **ikke** tilladelse til at genudgive de lydfiler, scriptet downloader.

### 7.5 Kontrakt for audio-manifest

Fil: `assets/audio/audio_manifest.json` — kan starte med `{"schemaVersion":1,"clips":[]}`.

Ved tilføjelse af en fil kræves mindst:

```json
{
  "schemaVersion": 1,
  "clips": [
    {
      "id": "audio-word-hest-v1",
      "wordId": "word-hest",
      "kind": "spoken_word",
      "assetPath": "assets/audio/words/hest.mp3",
      "locale": "da-DK",
      "speakerVariant": "standard-da-1",
      "sourceType": "own_recording",
      "sourceUrl": null,
      "creator": "Indsæt navn eller aftalt kreditering",
      "licenseId": "documented_permission",
      "licenseEvidence": "assets/audio/AUDIO_SOURCES.md",
      "audioReviewStatus": "pending",
      "pedagogicalReviewStatus": "pending"
    }
  ]
}
```

Eksemplet er en **kontrakt**, ikke et udsagn om, at `hest.mp3` allerede findes. Ingen fil refereres i runtime-JSON, før den faktisk er blevet tilføjet og indlæst/afprøvet. Ved Commons: angiv konkret URL, author, licens, licenslink, ændringer og påkrævet kreditering.

### 7.6 Optage- og lydkvalitet

Start med seks hele ord. Krav til optagelser:

- Én konsekvent dansk stemme; neutrale omgivelser og ens afstand til mikrofon.
- Hvert klip indeholder præcis det valgte ord i naturlig dansk udtale, ikke bogstavering.
- Ca. 0,1–0,2 sekund luft før/efter, uden lange tomme sekvenser.
- Gem gerne en tabsfri WAV-master; til app: ensartede, Android-kompatible MP3-filer i mono (fx 44,1 kHz, ~96–128 kbps). Test faktisk dekodning.
- Moderat ensartet lydstyrke uden clipping. Lyt på både højttaler og hovedtelefoner.
- Lad en dansksproget lærer eller anden fagperson tjekke **hvilken vokallyd** der kan høres i hvert eksempel.
- Markér audio- og indholdsgodkendelse uafhængigt.

**Mindste praktiske asset-test:** Tilføj **én reel lydfil**, som udvikleren selv har optaget eller lovligt fremskaffet. Brug den til en test af hele Flutter-assetkæden. Hvis den ikke foreligger, må Codex stadig færdiggøre TTS-prototypen og markere assettesten som *blocked/pending* — ikke fabrikere en lydfil.

---

## 8. Øvelseslogik og lokal fremdrift

### 8.1 MVP-regler

- Øvelsesrækkefølge hentes fra JSON; stabil ved genåbning i en læringssession.
- Ved første korrekt svar: `correct = true` og øvelsen markeres gennemført.
- Ved forkert svar: vis forklaring og tillad nyt forsøg. Gem `attempts`, men vis ingen negative point eller rangliste.
- Resultatvisning pr. trappe: `gennemført / i alt` og `korrekte første forsøg / gennemført`; undgå misvisende procentscore på få opgaver.
- “Start igen” gentager øvelserne uden at slette historisk gennemførsel, medmindre brugeren eksplicit vælger “Nulstil fremskridt”.
- Appen skal kunne fungere, selv om `shared_preferences` ikke kan læses: fortsæt uden lagret status og forklar problemet i debug.

### 8.2 Lokal model

Forslag til `progress_v1` under et versionsstyret `shared_preferences`-key:

```json
{
  "schemaVersion": 1,
  "completedExerciseIds": ["ex-hest"],
  "exerciseStats": {
    "ex-hest": {
      "totalAttempts": 2,
      "firstAttemptCorrect": false,
      "lastCompletedAt": "2026-11-02T19:00:00Z"
    }
  }
}
```

`lastCompletedAt` er kun et eksempel på ISO-8601-format. Brug det faktiske tidspunkt ved gennemførsel og håndter ugyldige/fremtidige værdier defensivt. Gem ikke navn, klasse, fødselsdato eller andre personoplysninger.

`shared_preferences` er til **enkel, ikke-kritisk lokal fremdrift**. Hvis produktet senere kræver flere elever, eksport, synkronisering eller stærkere dataintegritet, så migrér til en egentlig lokal database.

---

## 9. Implementeringssekvens til Codex

Gennemfør i nedenstående rækkefølge. Hvert trin afsluttes med tests og et lille, sammenhængende ændringssæt. Codex skal rapportere ændrede filer, væsentlige designvalg og eventuelle resterende blokeringer.

### Step 0 — Repository audit

- [x] Læs eksisterende roadmap, FVM, `pubspec.yaml`, `lib/`, test- og Android-opsætning.
- [x] Dokumentér kort faktisk SDK, arkitektur og hvad der kan genbruges.
- [x] Verificér at baseline `fvm flutter analyze` og eksisterende tests kører, eller dokumentér eksisterende fejl.

**Done når:** Der findes en kort status, og ingen eksisterende konfiguration er blevet overskrevet.

### Step 1 — Dependencies og datastruktur

- [x] Tilføj kompatible lydpakker og eventuelt router/storage-pakker.
- [x] Opret de foreslåede domæneklasser/repository og `vowel_ladders_v1.json`.
- [x] Indlæs JSON asynkront fra `rootBundle` (eller tilsvarende Flutter assets).
- [x] Opret `ContentValidator` og validerings-tests.
- [x] Indfør tydelig håndtering af manglende/ugyldige JSON-data.

**Done når:** Seks øvelser læses fra JSON; alle referencesammenhænge valideres i test.

### Step 2 — Navigation og visuel vokaltrappe

- [x] Implementér forsiden og de nødvendige routes.
- [x] Vis tre separate vokaltrapper samt ordlister per trappe.
- [x] UI viser skriftform, ikke en påstået regel for alle ord.
- [x] Implementér Back/Up og ukendte ID-fejltilstande.
- [x] Widget-test navigation og accessibility labels.

**Done når:** Alle skærme kan besøges med Android-back og uden navigation-crash.

### Step 3 — Audio engine og diagnostik

- [x] Implementér audio-interface med `just_audio` og `flutter_tts` wrappers.
- [x] Konfigurér `da-DK`; kontroller faktisk tilgængelighed.
- [x] Lokal asset har højere prioritet end TTS; ingen fejlformateret fallback.
- [x] Opret Lydtest-skærm med status, manuel replay og fejlbeskeder.
- [x] Test sekventielle/hurtige afspilninger, manglende asset og manglende dansk stemme.
- [ ] Integrér mindst én reel lovlig testlydfil, **hvis** den er til rådighed; ellers rapportér separat blokering.

**Done når:** Alle seks ord kan høres med dansk TTS på en testtelefon med dansk TTS tilgængelig, og eventuel assetafspilning er verificeret separat. Når dansk TTS mangler, skal appen oplyse dette uden at crashe eller bruge forkert sprog.

### Step 4 — Interaktiv øvelse

- [x] Render spørgsmål, maskeret ord, svarmuligheder og lytteknap fra data.
- [x] Kontrollér svar uden at hardcode facit i widgets.
- [x] Vis forklaring, Prøv igen, Næste og Tilbage.
- [x] Vis resultat efter gennemførsel af valgt trappe.
- [x] Mock lydservice i widget-tests, så tests er uafhængige af telefonens TTS.

**Done når:** Brugeren kan løse alle seks øvelser uden at sidde fast, også hvis lyd mangler.

### Step 5 — Fremdrift og robusthed

- [x] Gem statistik lokalt med versioneret struktur.
- [x] Genskab fremskridt ved genoprettelse af app-state og genindlæsning af native lagring (integrationstest).
- [ ] Verificér fremskridt efter fuld lukning og genstart af Android-processen.
- [x] Tilføj valgfri eksplicit nulstilling med bekræftelse.
- [x] Håndter tomme lister, ødelagte data og hurtigt skift mellem skærme.

**Done når:** Fremdrift består en app-genstartstest; fejl i progress-json crasher ikke appen.

### Step 6 — Test, dokumentation og v1-demo

- [x] `fvm dart format .`
- [x] `fvm flutter analyze`
- [x] `fvm flutter test`
- [x] `fvm flutter build apk --debug`
- [x] Kør appen og den automatiske integrationstest på fysisk Android: Samsung SM S931B / Android 17.
- [ ] Gennemfør hele det manuelle Android-scenarie nedenfor, inklusive faktisk lytning, procesgenstart, flytilstand og TalkBack.
- [x] Kontrollér eksisterende `profile`/`release` build-konfiguration uden at ændre signing unødigt; notér hvis release kræver ekstern signing.
- [x] Opdatér `roadmap_sprog_appen.md` med v1-status og åbne faglige/ligeledes lydmæssige punkter.

**Done når:** Dokumenterede tests passerer, og faktisk lyd- og navigationsadfærd er prøvet på en Android-telefon.

---

## 10. Testmatrix og acceptkriterier

### 10.1 Automatiske tests

| Test | Type | Accept |
|---|---|---|
| Seks unikke øvelser og tre trapper kan indlæses | Unit | Alle modeller oprettes korrekt |
| Ukendt ord-/trappe-ID i JSON | Unit | Fanget af validator med præcis fejlkode |
| Maskeret tekst + korrekt svar = ord | Unit | Gælder alle seks cases |
| Hver forkert svarmulighed giver forkert | Unit | Ingen “første svar er altid korrekt”-fejl |
| Lydservice med asset | Unit/mocks | Asset vælges før TTS |
| Asset mangler | Unit/mocks | Korrekt fallback eller tydelig fejl |
| `da-DK` mangler | Unit/mocks | Ingen engelsk fallback; UI fejltilstand |
| Hurtige gentagne afspilningstryk | Unit/mocks | Ingen overlappende lyd eller uncaught exception |
| Forside → trappe → øvelse → resultat → tilbage | Widget/integration | Navigationsstak fungerer |
| Gem/indlæs fremskridt | Unit/integration | Samme ID'er og status efter genstart |
| Ødelagt `progress_v1` | Unit | Failsafe uden app-crash |
| Widget-tests uden Android-TTS | Widget | Lydinterface kan fakes |

### 10.2 Manuel accepttest på Android

1. Installér debug-build på fysisk enhed, hvor dansk TTS enten er installeret eller kan installeres.
2. Åbn Lydtest. Bekræft om stemmen er `da-DK` — ikke kun at et `speak()`-kald returnerer succes.
3. Tryk på ordlyd 10 gange, inklusive hurtigt skift mellem to ord. Ingen overlappende tale, krakelering eller låst UI.
4. Gå gennem alle tre vokaltrapper og løs de seks spørgsmål. Kontroller stavning, lyd, forklaringer og tilbage-navigation.
5. Luk appen fuldstændigt og åbn igen. Bekræft bevaret fremdrift.
6. Test med lyd slukket, lav lydstyrke, skift til anden app og tilbage.
7. Aktivér flytilstand: lokale assets skal virke; TTS må fejle pænt, hvis enhedens motor kræver netværk.
8. Test med **dansk TTS ikke tilgængelig** (på test-device/emulator eller med mock). Bekræft fejlstatus, ikke engelsk udtale.
9. Test stor skrift, skærmlæserlabels og landskabs-/portrætvisning i relevante størrelser.
10. Lad mindst én dansksproget fagperson lytte til alle demoord og notere eventuelle problematiske udtaler. Denne test kan markeres *pending*, men ikke *passed*, uden reel gennemgang.

### 10.3 Eksplicitte kvalitets-gates

**G0 — Kodeprototype:** navigation, JSON, øvelser, TTS-fallback, lokal fremdrift og tests fungerer.  
**G1 — Lydprototype:** mindst ét godkendt lokalt ord-asset afspilles på rigtig Android-enhed.  
**G2 — Fagligt gennemset pilot:** hele demoordlisten, instruktioner og alle faktiske lydklip er gennemgået; eventuelle fejl er rettet.  
**G3 — Offentlig udgivelse:** rettigheder, privatliv, accessibility, release signing og versionsnummer er gennemgået.

Codex skal rapportere G0–G3 **hver for sig**. G0 må ikke fejlagtigt markeres G2 eller G3.

---

## 11. Kendte risici og løsninger

| Risiko | Håndtering |
|---|---|
| Android-TTS udtaler isolerede bogstaver frem for fonemer | TTS kun for **hele ord**. Isolerede lyde kræver godkendte lokale clips. |
| TTS-stemme afhænger af mobil/installation | Teststemmer i Lydtest; kontroller `da-DK`; fejltilstand uden forkert sprog. |
| Ord udtales forskelligt i forskellige dialekter | Fagligt vurderet referenceudtale og mulighed for senere flere varianter. |
| “Vokaltrappen” bliver fejlagtigt brugt som staveregel | Forklar den som mønstre i udvalgte ord og inkluder sidenhen lydrette kontrolord. |
| Lydlicens ukendt | Asset afvises fra release indtil kilde og rettigheder er dokumenteret. |
| Ny Flutter-pakke kræver nyere Dart SDK | Vælg kompatibel version; opgradér kun SDK efter konkret teknisk vurdering. |
| Kodemigration ødelægger tidligere Android release-setup | Bevar `gradle.kts`, signing og `applicationId`; minimér ændringer. |
| Børn misforstår fagord eller bliver frustrerede | Korte instruktioner, få valgmuligheder, ubegrænset replay, tydelig og positiv feedback. |
| Gemte ID'er brydes af fremtidig ordliste | Uforanderlige ID'er og versioneret migrationsstrategi. |

---

## 12. Udskudt til efter v1

- Flere ord og trinvis tilføjelse af lydrette kontrolord/undtagelser.
- Isolerede lydprøver med kvalitetssikrede vokaloptagelser og eventuel lydvisualisering.
- Stavelser, vokallængde, endelser, sammensatte ord, bøjning af udsagnsord.
- Klassetrins-/kompetenceniveaubaseret progression (1.–9. klasse) med differentieret sværhedsgrad.
- Elev-/lærerprofiler og eksport/synkronisering af fremdrift.
- Indtalings-/udtaletræning via mikrofon og talegenkendelse (kræver særskilt privatlivs- og børnedataspecifikation).
- Automatiseret generering af komplette lydbiblioteker, cloud-CDN og serverbaserede funktioner på `incipier.com`.

---

## 13. Handoff til Codex — konkret implementeringsopdrag

> Implementér v1 af Sprog Appen ifølge `v1_implementation_plan.md` i det **eksisterende Flutter-projekt**. Begynd med Step 0 og fortsæt dernæst Step 1–6. Anvend FVM. Genbrug eksisterende routing/state management, hvis det allerede fungerer. Opdatér kun `pubspec.yaml`, Android-manifest og buildfiler, hvor det er konkret nødvendigt; bevar domæne-/application-id- og release/debug/profile-opsætningen.
>
> Byg navigationsforløbet `Forside → Lydtrappen → Vokaltrappen → Trappe → Ordøvelse → Resultat`, lokalt JSON-indhold, seks eksempeløvelser, en audio-service med prioritet **lokal asset → da-DK TTS → informativ fejltilstand**, lokal fremdrift og en Lydtest-skærm.
>
> Brug kun TTS til **hele ord**, aldrig som erstatning for en isoleret dansk vokallyd. Download ikke automatisk tredjepartslyd fra ordbøger, undervisningsmaterialer eller Forvo. Brug ikke tomme lydfiler som placeholders. Er der ingen lovlig ordoptagelse, skal asset-testen markeres som afventer, mens TTS-prototypen færdiggøres.
>
> Implementér unit-, widget- og integrationstests, og kør `fvm flutter analyze`, `fvm flutter test` og et Android debug-build. Afslut med en rapport over ændrede filer, testresultater, eventuelle blokeringer samt særskilt status for kvalitets-gates G0–G3. Lav små, overskuelige ændringer, så de kan gennemgås og committes særskilt.

---

## 14. Kilder og teknisk dokumentation (kontrolleret 2026-11-02)

**Fagligt indhold**

- [GDF: Vokaltrappen og vokalforveksling](https://gdf.dk/stavning/vokaler/vokaltrappen)
- [Sproget.dk: Lydskriftoversigt](https://sproget.dk/sprogviden/sprogtemaer/udtale/lydskriftoversigt/)
- [Fælles Mål: Dansk, retsinformation](https://www.retsinformation.dk/eli/lta/2024/1715)

**Flutter**

- [just_audio](https://pub.dev/packages/just_audio)
- [flutter_tts](https://pub.dev/packages/flutter_tts)
- [go_router](https://pub.dev/packages/go_router)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [Flutter integration_test](https://docs.flutter.dev/testing/integration-tests)

**Lydkilder**

- [Wikimedia Commons: Danish pronunciation](https://commons.wikimedia.org/wiki/Category:Danish_pronunciation)
- [Mozilla Common Voice datasets](https://commonvoice.mozilla.org/en/datasets)
- [Sprogteknologi.dk: Common Voice (Dansk)](https://sprogteknologi.dk/dataset/common-voice-dansk)
- [Google Cloud: supported Danish TTS voices](https://docs.cloud.google.com/text-to-speech/docs/list-voices-and-types)

**Note om kildebrug:** Materialerne dokumenterer pædagogiske koncepter, lydsystemer og tekniske muligheder. Der overdrages **ikke** nogen rettigheder til at kopiere eller genudgive tredjepartslyde eller læremidler.
