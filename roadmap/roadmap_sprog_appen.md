# Sprog Appen — Udviklingsroadmap

**Dokumentversion:** 0.1  
**Dato:** 2026-11-02  
**Repository:** https://github.com/EsbenSoeltoft/sprog_appen  
**Platform:** Android (Flutter/Dart)  
**Status:** Plan / endnu ikke implementeret

## 1. Vision og formål

Sprog Appen er en dansk læringsapp, hvor begyndere i læsning og stavning kan **se, høre og øve** sprogets opbygning. Fokus er korte, overskuelige øvelser med korrekt dansk udtale, tydelig feedback og en rolig brugerflade. Appen skal på sigt kunne bruges af børn og andre, der har gavn af systematisk træning i dansk.

### De fem faglige områder

1. **Lydtrappen:** Lær bogstavlyde og lydforskelle med tryk-for-at-høre og eksempler. Det præcise undervisningssystem skal afklares, inden indholdet fastlåses. Vokaltrappen er en *mulig* fortolkning, ikke en vedtaget definition.
2. **Stavelser og endelser:** Lyt til og arbejd med ord, stavelser og almindelige endelser. Skeln mellem bogstavnavn, lyd og udtale i sammenhæng.
3. **Sammensatte ord:** Find bestanddele og byg nye ord, fx `sol + briller = solbriller`.
4. **Orddeling:** Træn opdeling i stavelser og korrekt orddeling ved linjeskift. Hold dette adskilt fra at opdele sammensatte ord.
5. **Bøjning af udsagnsord:** Arbejd med navneform, nutid, datid og førnutid, fx `at spise → spiser → spiste → har spist`.

## 2. Produktprincipper

- **Lyd først:** Brugeren kan lytte flere gange uden straf eller tidspres.
- **Små læringstrin:** Én faglig pointe og én tydelig handling pr. skærm.
- **Dansk som standardsprog:** Danske tekster og korrekt dansk tale (da-DK).
- **Fagligt korrekte eksempler:** Ord, stavelsesdeling og udtaler kvalitetssikres; regler formuleres uden at oversimplificere dansk ortografi.
- **Offline-first:** Basisøvelser og essentielle indspillede lydfiler skal fungere offline. Enhedens TTS er en supplerende funktion, ikke garanti for offline-dækning.
- **Privatliv som standard:** Ingen konto, tracking, reklamer eller cloud-backend i de tidlige versioner.
- **Tilgængelighed:** Store trykflader, god kontrast, mulighed for gentagelse og ikke kun farvebaseret feedback.
- **Udvidelighed:** Øvelsesindhold gemmes adskilt fra præsentations- og afspilningslogik.

## 3. Versioneringsmodel

Versionerne nedenfor er **produktmilepæle**, ikke nødvendigvis semantiske appversioner i `pubspec.yaml`. Hver milepæl skal være demonstrerbar og have opfyldt sine acceptkriterier, før næste fase betragtes som afsluttet.

| Version | Leverance | Formål |
| --- | --- | --- |
| **V0** | Projektgrundlag og miljø | Reproducerbar Flutter-/Android-opsætning |
| **V1** | Første app med lydtrappe | Afprøve navigation, data og korrekt lydafspilning |
| **V2** | Stavelser og endelser | Høre, opdele og genkende orddele |
| **V3** | Sammensatte ord og orddeling | Ordstruktur gennem interaktive opgaver |
| **V4** | Bøjning af udsagnsord | Arbejde med verbalformer og feedback |
| **V5** | Fremskridt og læringsforløb | Gentagelse, niveauer og lokal historik |
| **V6** | Kvalitet, offline og Android-release | Gøre appen robust til testdistribution |
| **V7+** | Mulige udvidelser | Adaptiv læring, optagelse af egen tale m.m. |

---

## V0 — Projektfundament

**Mål:** En ren Flutter-app kan bygges og køres på en Android-telefon. Teamet har én reproducerbar udviklingsopsætning.

### Arbejde

- [ ] Klon `EsbenSoeltoft/sprog_appen` og opret Flutter-projektet i repositoryets rod.
- [ ] Installer Flutter med **FVM**, og fastlås en konkret stable-release i `.fvmrc` (`fvm use stable --pin`).
- [ ] Konfigurer Android SDK, fysisk enhed/emulator og VS Code.
- [ ] Beslut foreløbig mappestruktur, navigation og en enkel Material 3-stil.
- [ ] Opsæt `.gitignore`, `analysis_options.yaml`, `pubspec.lock` og grundlæggende tests.
- [ ] Tilføj en kort `README.md` med links til dette roadmap og `getting_started.md`.
- [ ] Afklar målgruppe, mål for første læringsforløb og den **konkrete betydning af "lydtrappen"** (gerne med et eksempel/billede fra undervisningsmaterialet).
- [ ] Aftal, hvem der validerer danske lyde, eksempler og sproglige regler.

### Acceptkriterier

- [ ] `fvm flutter doctor` viser en fungerende Android-toolchain.
- [ ] `fvm flutter run` starter standardappen på en Android-enhed.
- [ ] `fvm flutter analyze` og `fvm flutter test` gennemføres.
- [ ] `.fvmrc` er committed; `.fvm/` er ikke committed.
- [ ] Et nyt checkout kan genskabe den fastlåste Flutter-version via FVM.

**Afhængighed:** Ingen. Se `getting_started.md`.

## V1 — Lydtrappen og første komplette læringsflow (MVP)

**Mål:** Første brugbare app, hvor man kan vælge en lyd, høre den og løse en lille opgave.

### Arbejde

- [ ] Startskærm, moduloversigt, lydtrappeskærm og én øvelsestype.
- [ ] Datamodel for læringsindhold: `id`, tekst, niveau, eksempler, forklaring, lydreferencer og svarmuligheder.
- [ ] Lydafspilning med afspil/stop, gentagelse og tydelige fejlbeskeder.
- [ ] **Indspillede lydfiler** for præcise bogstav-/enkeltlyde og udvalgte referenceord.
- [ ] `flutter_tts` som *valgfri* afspilning af hele ord, korte sætninger og instruktioner; sprog `da-DK`.
- [ ] Kontrol af tilgængelig dansk TTS-stemme; hvis den mangler, tilbydes lydfil eller tydelig besked.
- [ ] Mulighed for at lytte igen og evt. afspille langsommere (uden at ændre udtalens karakter uhensigtsmæssigt).
- [ ] Første opgavetype: "Hør lyden og vælg det rigtige eksempel" med korrekt/ukorrekt feedback.
- [ ] Et lille, håndkurateret indholdssæt — kvalitet frem for antal.
- [ ] Widgettests for navigation og svarfeedback; enhedstest for indholdsvalidering.

### Acceptkriterier

- [ ] Brugeren kan starte en øvelse fra forsiden og afslutte den.
- [ ] Alle lydknapper giver forventet lyd på en fysisk Android-telefon.
- [ ] De essentielle lydøvelser virker i flytilstand.
- [ ] Manglende TTS eller lydfil håndteres uden crash.
- [ ] Lyd og læringsindhold er fagligt gennemgået.

**Vigtigt:** Et isoleret bogstav må ikke automatisk afspilles med TTS som erstatning for den ønskede *fonemlyd*; en TTS-motor kan sige bogstavnavnet eller vælge en anden udtale.

## V2 — Stavelser og endelser

**Mål:** Brugeren kan høre ord og relevante orddele og genkende stavelser og endelser.

### Arbejde

- [ ] Vis ord med visuel opdeling i stavelser, fx `ka-ge` og `sko-le`.
- [ ] Afspil hele ord samt **kuraterede indspilninger** af stavelser og endelser.
- [ ] Øvelser: vælg korrekt stavelsesopdeling, sæt stavelser sammen, genkend en endelse.
- [ ] Forklar almindelige endelser i deres grammatiske sammenhæng; fx udtales `-er` ikke nødvendigvis ens i alle ord og situationer.
- [ ] Indfør stabil datarepræsentation af orddelinger og relation til hele ord.
- [ ] Gentagelse og mulighed for at vælge et lettere niveau.

### Acceptkriterier

- [ ] Mindst tre øvelsesformer kan gennemføres.
- [ ] Hele ord og udvalgte orddele kan afspilles hver for sig.
- [ ] Korrekte svar og forklaringer er kvalitetssikret mod dansk sprogbrug.
- [ ] Offline-funktion er verificeret for alt kerneindhold.

## V3 — Sammensatte ord og orddeling

**Mål:** Brugeren lærer både at sammensætte ord og at dele dem på sprogligt korrekt vis.

### Arbejde

- [ ] Øvelse: byg et sammensat ord af to led (`sol + briller`).
- [ ] Øvelse: find de betydningsbærende dele i et sammensat ord.
- [ ] Øvelse: find stavelser i almindelige ord.
- [ ] Separat øvelse: korrekt orddeling ved linjeskift, med tydelige regler og eksempler.
- [ ] Understøt eventuelle bindebogstaver/fugeelementer med håndvaliderede eksempler.
- [ ] Brug tap-to-select i første omgang; træk-og-slip kan tilføjes senere.

### Acceptkriterier

- [ ] Appen skelner tydeligt mellem sammensætning, stavelsesdeling og orddeling ved linjeskift.
- [ ] Øvelserne kan løses uden lyd, men relevante hele ord kan afspilles.
- [ ] Testcases dækker både lette eksempler og udvalgte undtagelser.

## V4 — Bøjning af udsagnsord

**Mål:** Brugeren kan genkende og træne navneform, nutid, datid og førnutid.

### Arbejde

- [ ] Introducer bøjningsskemaer med få, velkendte udsagnsord.
- [ ] Øvelser: vælg korrekt form, udfyld manglende form, match form med tidsbetegnelse.
- [ ] Medtag både regelmæssige og uregelmæssige verber (`at spise`, `at gå`, `at være`).
- [ ] Afspil formerne i korte, naturlige sætninger.
- [ ] Forklar forskellen mellem grundform, tid og hjælpeverber uden unødvendigt fagsprog.

### Acceptkriterier

- [ ] Verber og bøjninger er gemt som strukturerede, validerede data.
- [ ] Korrekthed kan testes automatisk for hver opgave.
- [ ] Et lille forløb kan gennemføres fra forklaring til afsluttende øvelse.

## V5 — Fremskridt, gentagelse og motivation

**Mål:** Brugeren kan fortsætte, hvor vedkommende slap, og gentage det svære.

### Arbejde

- [ ] Gem gennemførte lektioner og seneste niveau **lokalt på telefonen**.
- [ ] Enkel oversigt over fremgang og anbefalede gentagelser.
- [ ] Indfør let/svær og evt. gradvis sværhedsprogression.
- [ ] Positiv, konkret feedback uden tidspres eller konkurrence som standard.
- [ ] Klargør modellen til flere lokale brugerprofiler, hvis behovet opstår.

### Acceptkriterier

- [ ] Data overlever genstart af appen.
- [ ] Brugeren kan nulstille egne fremskridt.
- [ ] Appen kræver stadig ingen konto eller netforbindelse.

## V6 — Stabilitet og Android-release

**Mål:** En testbar Android-pakke til familie-/pilotafprøvning.

### Arbejde

- [ ] Gennemfør test på flere skærmstørrelser, Android-versioner og TTS-konfigurationer.
- [ ] Test tilgængelighed, tekstskalering, skærmlæser og touch-områder.
- [ ] Optimer lydstørrelse og indlæsning; test flytilstand og lave ressourcer.
- [ ] Revider stave- og grammatikindhold med en dansksproglig fagperson.
- [ ] Gennemgå licenser og rettigheder til lydoptagelser, illustrationer og ordlister.
- [ ] Beslut permanent Android application ID, ikon, versionsnumre og distributionsform.
- [ ] Konfigurer signering sikkert (keystore må aldrig committes).
- [ ] Opret CI for analyze/test/build og en versionsstyret releaseproces.
- [ ] Udgiv eventuelt først som privat APK/internal testing; Play Store er en særskilt beslutning.

### Acceptkriterier

- [ ] Ingen kritiske fejl under et aftalt pilotforløb.
- [ ] Offline-kernefunktioner virker på testtelefoner.
- [ ] Release kan genskabes fra Git-tag + `.fvmrc`.
- [ ] Eventuelle persondata og krav ved distribution til børn er vurderet.

## V7+ — Mulige udvidelser (ikke besluttet)

- Adaptiv træning baseret på fejl og gentagelsesbehov.
- Flere faglige temaer, ordforråd og niveauer.
- Flere profiler på samme telefon uden server.
- **Optagelse af egen udtale:** Kun hvis brugerværdi, samtykke, mikrofontilladelser og privatliv er gennemtænkt; automatisk vurdering af dansk udtale er en særskilt teknisk udfordring.
- Lærerstyrede forløb eller mulighed for at indlæse nye undervisningspakker.
- iOS-understøttelse senere, hvis Android-versionen fungerer godt.

---

## 4. Foreløbig teknisk arkitektur

### Princip

Hold læringsdata, lyd og UI adskilt, så nye moduler ikke kræver at omskrive hele appen.

```text
lib/
  main.dart
  app/
    app.dart                 # App, tema og navigation
  core/
    audio/                  # Lydafspilning og TTS-interface
    content/                # Læsning og validering af øvelsesdata
    models/                 # Fælles datatyper
  features/
    home/
    lydtrappen/
    stavelser_endelser/
    sammensatte_ord/
    orddeling/
    udsagnsord/
  shared/
    widgets/                # Genbrugelige kort, knapper og feedback
assets/
  content/                  # Versionsstyret JSON med læringsindhold
  audio/                    # Kvalitetssikrede danske lydoptagelser
  images/
test/
```

Dette er en **foreslået** struktur, ikke en oprettet kodebase. Undgå unødvendige abstraktioner i V0; opret mapperne, efterhånden som de bruges.

### Mulige pakker (evalueres i relevant version)

| Formål | Mulig løsning | Tidspunkt |
| --- | --- | --- |
| Dansk TTS | `flutter_tts` | V1 |
| Afspilning af indspillede filer | `just_audio` | V1 |
| Lokal fremskridtslagring | `shared_preferences` til små indstillinger, evt. lokal database senere | V5 |
| Navigation og state management | Start med Flutters egne værktøjer; vælg ekstra pakker kun ved behov | V0–V2 |

Ingen cloud- eller AI-tjeneste er nødvendig til MVP'en. Gem ikke logik i JSON; datafiler skal indeholde deklarativt og validerbart indhold.

### Forslag til én lyd-/øvelsespost

```json
{
  "id": "v1_lyd_001",
  "module": "lydtrappen",
  "title": "Lyt og vælg",
  "prompt": "Hvilket eksempel passer til lyden?",
  "audio_asset": "assets/audio/lydtrappen/eksempel_001.mp3",
  "tts_text": null,
  "choices": [
    {"id": "a", "text": "Eksempel A"},
    {"id": "b", "text": "Eksempel B"}
  ],
  "correct_choice_id": "a"
}
```

**Bemærk:** Dataene her er blot et teknisk skema, ikke en fagligt færdig opgave. Over tid bør skemaet udvides med lydtype, fonetisk mål, kilde/licens, målgruppe, sværhedsgrad og valideringsstatus.

## 5. Definition of Done for hver version

- [ ] Funktionerne i versionen er demonstreret på en fysisk Android-enhed.
- [ ] Udvalgte enheds- og widgettests er tilføjet; `analyze` og `test` er grønne.
- [ ] Alt nyt læringsindhold er kvalitetssikret og har konsistente forklaringer.
- [ ] Lydknapper, gentagelse og offlineadfærd er testet, når de indgår.
- [ ] Tilgængelighed og privatliv er vurderet i forhold til ændringen.
- [ ] Roadmap, changelog/README og relevante dokumenter er opdateret.
- [ ] Koden er committed på en feature branch, gennemgået og integreret.

## 6. Åbne beslutninger og risici

| Spørgsmål/risiko | Foreløbig håndtering | Skal afklares |
| --- | --- | --- |
| Hvilken "lydtrappe" mener vi? | Ingen fastlåst lyd- eller undervisningsmodel endnu | **Før V1** |
| Hvem er primær bruger? | Begyndere i dansk læsning, sandsynligvis børn | Før indholdsdesign |
| Dansk udtale kan ikke altid udledes af stavemåden | Brug kuraterede lydoptagelser til kritiske lyde | V1–V2 |
| TTS findes ikke nødvendigvis offline på alle telefoner | Bundl nøglelyde; test fallback | V1 |
| Orddeling kan betyde forskellige ting | Separate læringsmål og datasæt | V3 |
| Copyright/licenser for lyd og materialer | Brug egne eller licenserede optagelser og dokumentér rettigheder | Før distribution |
| Mikrofon og børns persondata | Ikke i MVP; lokal behandling og særskilt designvurdering | V7+ |

## 7. Næste konkrete skridt

1. Følg `getting_started.md` og bekræft, at en standard Flutter-app starter på Android.
2. Afklar den konkrete undervisningsmodel bag lydtrappen og målgruppen.
3. Implementér V1 som én komplet, lille læringsoplevelse, før der bygges fem parallelle moduler.
4. Opdatér dette dokument efter hver version: **Hvad er færdigt, hvad er ændret, hvad kommer nu?**

**Versionshistorik**

| Dokumentversion | Dato | Ændring |
| --- | --- | --- |
| 0.1 | 2026-11-02 | Første roadmap: V0–V7+, mål, acceptkriterier og tekniske principper |
