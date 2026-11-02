# Sprog Appen — Getting Started (Flutter / Android / FVM / GitHub)

**Dokumentversion:** 0.1  
**Dato:** 2026-11-02  
**Repository:** https://github.com/EsbenSoeltoft/sprog_appen  
**Udviklingsmiljø:** macOS på Apple Silicon, VS Code, Android Studio til Android SDK  
**Status:** Opsætningsguide — kommandoerne er vejledende og er ikke kørt på din Mac

Denne guide sætter et **Android-only Flutter-projekt** op med **FVM** til lokal Flutter-versionsstyring og Git/GitHub som versionskontrol. En global Flutter-installation er ikke nødvendig, når projektets kommandoer køres gennem `fvm`.

> Repositoryet blev tjekket 2026-11-02: Der lå `README.md` og `LICENSE`, men endnu ingen Flutter-projektfiler. Vi opretter derfor projektet i den eksisterende repositorymappe; vi opretter ikke et nyt Git-repository.

## 1. Forudsætninger

Installér eller kontrollér følgende:

- macOS (Apple Silicon), Terminal (zsh) og internet til første opsætning.
- **Homebrew** (`brew --version`). Installér fra https://brew.sh hvis det mangler.
- **Git** (`git --version`). macOS Command Line Tools kan installeres med `xcode-select --install` ved behov.
- **VS Code**, gerne med Flutter- og Dart-udvidelser.
- **Android Studio**, som bruges til Android SDK, emulator og eventuelt SDK/Gradle-fejlfinding. Hele Xcode er **ikke** påkrævet til en Android-only app.
- Enten en Android-telefon med USB-debugging eller en Android-emulator.

Tjek værktøjer:

```bash
brew --version
git --version
xcode-select -p
```

Hvis Command Line Tools mangler:

```bash
xcode-select --install
```

Installér Android Studio og VS Code, hvis nødvendigt, gennem de officielle installationsprogrammer eller Homebrew. Eksempel:

```bash
brew install --cask android-studio
brew install --cask visual-studio-code
```

Android Studio kan allerede være installeret; geninstallér ikke uden grund.

## 2. Installér FVM

FVM styrer en Flutter-version pr. projekt. På macOS anbefaler vi Homebrew:

```bash
brew install fvm
fvm --version
```

Der findes også andre installationsmetoder på https://fvm.app/documentation/getting-started/installation. Brug **ikke** den separat navngivne `fvm-sh/fvm` (en anden version-manager til shell); vi mener Flutter Version Management fra `fvm.app`.

## 3. Klon det eksisterende GitHub-repository

Vælg, hvor du vil have udviklingsprojektet liggende. For eksempel:

```bash
mkdir -p ~/Documents/Code
cd ~/Documents/Code
git clone https://github.com/EsbenSoeltoft/sprog_appen.git
cd sprog_appen
```

Kontrollér remoten og indholdet:

```bash
git remote -v
git branch --show-current
ls -la
```

Forvent `origin` på `https://github.com/EsbenSoeltoft/sprog_appen.git` og `main` som standardbranch. HTTPS push kræver GitHub-autentifikation (f.eks. Git Credential Manager eller `gh auth login`); kontoens **password** alene kan ikke bruges til Git over HTTPS.

**Kopiér de to dokumenter til repositoryets rod:**

```text
sprog_appen/
  README.md
  LICENSE
  roadmap_sprog_appen.md
  getting_started.md
```

## 4. Fastlås Flutter-version med FVM

Installér den aktuelle stabile Flutter og lås den version, som anvendes af projektet:

```bash
fvm install stable
fvm use stable --pin
fvm flutter --version
cat .fvmrc
```

`--pin` gør det muligt at tage udgangspunkt i seneste stable, men registrere **en konkret release** i `.fvmrc`. Hvis din installerede FVM-udgave ikke genkender flaget, brug `fvm use <konkret-version>` med det præcise versionsnummer, du har valgt. Det centrale er, at `.fvmrc` indeholder en bestemt version (fx `3.x.y`) frem for blot at flyde med `stable`.

Når `.fvmrc` er committed, skal andre maskiner bruge:

```bash
fvm install
fvm flutter --version
```

**Regler:**

- Commit `.fvmrc`, så alle bruger samme Flutter SDK.
- Ignorér `.fvm/`, som indeholder lokale links/cache og ikke skal versionsstyres.
- Brug `fvm flutter ...` og `fvm dart ...` inde i projektet; undgå at blande forskellige globale Flutter-installationer.
- Opgradér Flutter **bevidst** på en særskilt branch, og kør tests før merge.

## 5. Opret Flutter-projektet i eksisterende repo

Fra roden af `sprog_appen`:

```bash
fvm flutter create --platforms=android --project-name sprog_appen .
```

Punktummet `.` betyder "opret Flutter-projektet i den mappe, vi står i". Den eksisterende `.git`-mappe bevares. Kommandoen er beregnet til en ny kodebase; brug **ikke** `--overwrite`, hvis du har ændret eksisterende filer.

Det Android application ID, Flutter genererer som standard, er kun til udvikling. **Vælg og konfigurer et permanent, unikt ID før en offentlig release** (V6).

Kør nu:

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

Projektet har på dette tidspunkt kun Flutters standarddemo, **ikke** de fem læringsmoduler. Modulerne implementeres i V1–V4 i `roadmap_sprog_appen.md`.

## 6. Konfigurér `.gitignore`

Flutter opretter normalt en `.gitignore`. Kontrollér, at den også indeholder (tilføj kun manglende linjer):

```gitignore
# Flutter Version Management: local SDK symlink/cache
.fvm/

# Local configuration and build secrets
.env
.env.*
*.jks
*.keystore
android/key.properties
```

**Commit:** `.fvmrc`, `pubspec.yaml`, **`pubspec.lock`** (det er en app), `lib/`, `test/`, Android-projektfiler og dokumentation.  
**Commit aldrig:** `.fvm/`, `build/`, `.dart_tool/`, private nøgler, signeringsfiler eller adgangstokens.

Bemærk: `.gitignore` hindrer ikke filer, som allerede er tracked. Kontroller altid `git status` og `git diff --staged` før commit.

## 7. VS Code og FVM

Installér udvidelserne **Flutter** (Dart Code) og **Dart** i VS Code. Åbn projektet:

```bash
code .
```

Hvis `code` ikke virker, kan du i VS Code bruge Command Palette → **Shell Command: Install 'code' command in PATH**.

For at sikre projektets FVM-SDK kan du oprette `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

Hvis VS Code ikke kan finde SDK'et, kontrollér, at `fvm use` har oprettet `.fvm/flutter_sdk`, genstart VS Code, og kontrollér at terminalens `fvm flutter --version` stemmer med editorens Flutter-version.

Android Studio kan konfigureres under **Settings → Languages & Frameworks → Flutter** til projektets absolutte sti, der slutter med `.fvm/flutter_sdk` (ikke `/bin`).

## 8. Android SDK og licenser

Åbn Android Studio → **SDK Manager**. Installer en kompatibel Android SDK Platform samt relevante SDK-værktøjer; følg Flutter doctors konkrete anbefalinger frem for at hardcode et API-niveau.

Som minimum er disse normalt relevante:

- Android SDK Platform og Build-Tools
- Android SDK Command-line Tools
- Android SDK Platform-Tools (ADB)
- Android Emulator og en ARM64-systemimage, **hvis** du vil bruge emulator på Apple Silicon

Kør:

```bash
fvm flutter doctor -v
fvm flutter doctor --android-licenses
fvm flutter doctor -v
```

Accepter licenser, hvis du er enig i dem. Korrigér fejl under **Android toolchain**. Manglende Xcode til iOS/macOS kan ignoreres, når målet kun er Android.

Hvis Flutter ikke finder Android SDK, kontroller SDK Manager-installationsstien og brug efter behov:

```bash
fvm flutter config --android-sdk "$HOME/Library/Android/sdk"
```

Kun hvis denne sti faktisk er den rigtige på din Mac.

## 9. Kør appen på en Android-telefon (anbefalet)

1. På telefonen: Åbn **Indstillinger → Om telefonen → Softwareoplysninger** og tryk på **Buildnummer** flere gange, indtil udviklerindstillinger er aktiveret. Sti/navne kan variere efter Android-model.
2. Aktivér **USB-fejlfinding** under Udviklerindstillinger.
3. Forbind med USB til Mac, og godkend computeren på telefonen.
4. Kontrollér, at Flutter kan se enheden:

```bash
fvm flutter devices
```

5. Start appen:

```bash
fvm flutter run
```

Hvis der er flere mulige enheder, angiv ID'et, som `fvm flutter devices` viser:

```bash
fvm flutter run -d <device-id>
```

`<device-id>` er en pladsholder og skal erstattes. Brug `r` i Flutter-terminalen til hot reload og `q` for at afslutte.

### Alternativ: Android-emulator

I Android Studio → **Device Manager** → opret og start en Android Virtual Device (gerne ARM64 på Apple Silicon). Herefter:

```bash
fvm flutter emulators
fvm flutter devices
fvm flutter run
```

## 10. Git-workflow mod GitHub

Start med at kontrollere ændringerne:

```bash
git status
git diff --stat
```

### Første commit (dokumentation + Flutter-grundprojekt)

Når du har kopieret dokumenterne til repoet og har oprettet Flutter-projektet:

```bash
git add .
git diff --staged --stat
git status
git commit -m "chore: bootstrap Android Flutter app with FVM and docs"
git push origin main
```

`git add .` er kun passende, når du **først** har kontrolleret `.gitignore` og de staged filer for hemmeligheder. Hvis du vil committe dokumenterne før Flutter-scaffoldet:

```bash
git add getting_started.md roadmap_sprog_appen.md
git commit -m "docs: add roadmap and getting started guide"
git push origin main
```

### Anbefalet workflow for hver version

Eksempel for V1:

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/v1-lydtrappen

# Lav ændringerne ...
fvm flutter analyze
fvm flutter test

git add .
git diff --staged
git commit -m "feat: add first sound ladder learning flow"
git push -u origin feature/v1-lydtrappen
```

Opret derefter en **Pull Request** på GitHub mod `main`. Efter godkendelse/merge opdateres lokal `main` med `git pull --ff-only`.

### God Git-praksis

- Commit små, sammenhængende ændringer med klare beskrivelser.
- Beskyt `main` mod ufærdige eksperimenter; brug `feature/`-branches.
- Push aldrig adgangstokens, signeringsnøgler eller private lydfiler med uklare rettigheder.
- Opdatér roadmapets status og versionshistorik ved hver milepæl.

## 11. Første pakker — først når V1 påbegyndes

Når vi implementerer lyd i V1, er følgende mulige startpunkt:

```bash
fvm flutter pub add flutter_tts just_audio
fvm flutter pub get
```

Disse pakker installeres **ikke** af denne guide. Til kortvarige enkeltlyde og fonemer foretrækkes indspillede lydfiler; `flutter_tts` anvendes til sammenhængende dansk tale, når `da-DK` er tilgængeligt. Kernelydene skal fungere offline.

Undersøg altid aktuelle pakkeversioner, platformkrav, licenser og vedligeholdelse før adoption.

## 12. Hurtig daglig arbejdsgang

```bash
cd ~/Documents/Code/sprog_appen
git pull --ff-only
fvm install
fvm flutter pub get
fvm flutter devices
fvm flutter run
```

**Kvalitetskontrol før commit:**

```bash
fvm dart format .
fvm flutter analyze
fvm flutter test
git status
```

**Forventet V0-resultat:** En standard Flutter-app starter på telefonen, `.fvmrc` fastlåser Flutter SDK, og GitHub indeholder kode og dokumentation. Først derefter starter udviklingen af lydtrappen i V1.

## 13. Fejlfinding

| Problem | Kontrol/løsning |
| --- | --- |
| `fvm: command not found` | Kontrollér Homebrew-installation og shell `PATH`; prøv `brew --prefix fvm`. |
| FVM bruger forkert Flutter | Kør `cat .fvmrc`, `fvm install`, `fvm flutter --version`; se efter andre SDK'er i editoren. |
| `.fvm/flutter_sdk` mangler | Kør `fvm use <pinned-version>` fra projektets rod. |
| Android SDK mangler | Installér i Android Studio SDK Manager, derefter `fvm flutter doctor -v`. |
| Licenser mangler | Kør `fvm flutter doctor --android-licenses`. |
| Telefonen vises ikke | Kontrollér USB-fejlfinding, USB-kabel, enhedsgodkendelse og `fvm flutter devices`. |
| Gradle-/Java-fejl | Brug den kompatible JDK/Gradle-konfiguration, som den genererede Flutter-version forventer; se `fvm flutter doctor -v`. |
| GitHub `push` afvises | Kontrollér `git remote -v`, branch, rettigheder og HTTPS/SSH-autentifikation. Brug aldrig konto-password direkte i Git. |
| TTS kan ikke tale dansk | Kontrollér dansk stemme på enheden; brug indspillede lydfiler i appens centrale lydøvelser. |

## 14. Officielle ressourcer

- Flutter installation: https://docs.flutter.dev/install
- Android tooling og enheder: https://docs.flutter.dev/platform-integration/android/setup
- FVM: https://fvm.app/
- FVM installation: https://fvm.app/documentation/getting-started/installation
- FVM + Android Studio: https://fvm.app/documentation/guides/android-studio
- Homebrew FVM: https://formulae.brew.sh/formula/fvm
- GitHub Git-autentifikation: https://docs.github.com/en/authentication

## 15. Opdateringshistorik

| Dokumentversion | Dato | Ændring |
| --- | --- | --- |
| 0.1 | 2026-11-02 | Første macOS/Android-guide med FVM, lokal udvikling og GitHub-workflow |
