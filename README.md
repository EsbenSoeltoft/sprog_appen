# Sprog Appen

Android-app til dansk sprogtræning, udviklet med Flutter under Incipier.

## Offentligt repository

Dette GitHub-repository er **public**. Både AI-agenter og øvrige bidragydere
skal følge [projektinstruktionerne i AGENTS.md](AGENTS.md), herunder reglerne
om miljøfiler, secrets, signeringsnøgler og kontrol før commit/push.
Rigtige hemmeligheder må aldrig lægges i kode, dokumentation eller eksempelfiler.

## Kom i gang

- [Opsætning og Git-workflow](docs/getting_started.md)
- [Android-builds og release-signering](docs/android_release.md)
- [Roadmap](roadmap/roadmap_sprog_appen.md)

## Aktuel implementering

V1-prototypen har tre vokalrækker, seks ordøvelser, dansk helords-TTS,
Lydtest og lokal fremdrift. V2 tilføjer seks øvelser i stavelser, ordbygning og
flertalsendelser. V3 tilføjer otte opgaver i sammensatte ord, betydningsdele, stavelser og
linjeskift. V4 tilføjer fire bøjningsskemaer og ti udsagnsordsopgaver, inklusive fritekst.
Alle fire modulers fremdrift gemmes samlet. V5 tilføjer genoptagelse af seneste
opgave, gentagelsesforslag og valget Med hjælp/Uden hjælp.
Alle ord er udkast; ejeren godkender indhold og lyd før udgivelse.
Ingen lokale lydoptagelser er endnu tilføjet; TTS har ingen offline-garanti.

- [V1-implementeringsplan](roadmap/v1_implementation_plan.md)
- [V1-teststatus og kvalitets-gates](docs/v1_status.md)
- [V2-teststatus og Android-afprøvning](docs/v2_status.md)
- [V3-teststatus og Android-afprøvning](docs/v3_status.md)
- [V4-teststatus og Android-afprøvning](docs/v4_status.md)
- [V5-fremdrift, migration og genstartstest](docs/v5_status.md)

```sh
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
```

## Launcherikon

V4-kilderne er placeret i `assets/icon/`. Generér Androids standardikon,
adaptive lag og monokrome temaikon med:

```sh
fvm dart run flutter_launcher_icons
```

Konfiguration: `flutter_launcher_icons.yaml`. Genererede native ressourcer ligger
under `android/app/src/main/res/` og skal versionsstyres. Play Store-materiale
og øvrige kildefiler ligger i `assets/sprog_appen_icon_v4/` og indgår ikke i
appens Flutter-assetbundle.
