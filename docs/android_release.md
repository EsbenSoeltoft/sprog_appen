# Android-builds og Incipier-domæne

Appens domæne er `incipier.com`; Android bruger omvendt domænenotation.

| Build | Application ID | Signering |
| --- | --- | --- |
| Release | `com.incipier.sprogappen` | Privat upload-/release-nøgle |
| Debug | `com.incipier.sprogappen.debug` | Lokal debugnøgle |
| Profile | `com.incipier.sprogappen.profile` | Lokal debugnøgle |

Namespace og Kotlin-package er `com.incipier.sprogappen`. Alle tre builds kan installeres parallelt, også sammen med hovedappen `com.incipier.incipier`.
Profile oprettes af Flutter-pluginet og beholder dets profilopsætning.

Et application ID er ikke en webadresse. Denne opsætning ændrer ikke DNS,
webhosting eller hovedappens domæne `incipier.incipier.com`. App Links kræver
senere en aftalt URL, routing i appen og en offentlig `assetlinks.json` med
release-certifikatets fingeraftryk. Der er derfor ingen URL-intent-filter endnu.

## Dependencies før første Flutter-commit

`flutter`, `cupertino_icons`, `flutter_test` og `flutter_lints` dækker det
nuværende grundprojekt. `pubspec.lock` og `.fvmrc` skal versionsstyres.
Ingen backend-, navigation- eller state management-pakke er nødvendig i V0.
Roadmappets `flutter_tts` og `just_audio` evalueres og tilføjes ved V1;
lokal lagring tilføjes ved V5. Undgå at fastlåse ubrugte plugins før deres
platformkrav og funktioner kan afprøves. Flutter leverer selv Material-ikoner.

## Byg og verificér

```sh
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug
fvm flutter build apk --profile
fvm flutter build appbundle --release
```

Release kræver en privat nøgle. Kopiér `android/key.properties.example` til
`android/key.properties`, og udfyld alle fire felter. Relative keystore-stier
regnes fra `android/`. Opbevar nøgle og passwords sikkert uden for Git;
release falder aldrig tilbage til debugsignering. Debug/profile kræver ikke
release-nøglen. Play App Signing bruger typisk denne nøgle som uploadnøgle.

Den eksisterende Gradle-rootopsætning deler build-mappen og repositories;
buildtyper hører til i `android/app/build.gradle.kts`. SDK-versioner følger
projektets fastlåste Flutter-version. Ingen pluginopgradering er nødvendig
for at tilføje de tre buildkonfigurationer.

Før commit: kontrollér `git status --short` og de staged filer. `.gitignore`
dækker Dart-/Flutter-cache, FVM, IDE-filer, Android-builds og signeringsfiler.
Der oprettes eller pushes ikke et commit som del af denne klargøring.

Kilder: https://docs.flutter.dev/deployment/android og
https://developer.android.com/build/build-variants
