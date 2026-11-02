# Sprog Appen — Udviklingsroadmap

**Dokumentversion:** 0.10

**Dato:** 2026-11-02  
**Repository:** https://github.com/EsbenSoeltoft/sprog_appen  
**Platform:** Android (Flutter/Dart)  
**Status:** V1–V4-kodeprototyper og V5-fremdrift implementeret. Android-integrationstest og fuld procesgenstart for V5 består; lydoptagelser og faglig godkendelse afventer.

## 1. Vision og formål

Sprog Appen er en dansk læringsapp, hvor begyndere i læsning og stavning kan **se, høre og øve** sprogets opbygning. Fokus er korte, overskuelige øvelser med korrekt dansk udtale, tydelig feedback og en rolig brugerflade. Appen skal på sigt kunne bruges af børn og andre, der har gavn af systematisk træning i dansk.

### De fem faglige områder

1. **Lydtrappen:** Lær bogstavlyde og lydforskelle med tryk-for-at-høre og eksempler. V1-prototypen bruger Vokaltrappen med tre separate vokalrækker efter `v1_implementation_plan.md`. Den endelige undervisningsmodel og indholdsgodkendelse ligger hos ejeren.
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

- [x] Klon `EsbenSoeltoft/sprog_appen` og opret Flutter-projektet i repositoryets rod.
- [x] Installer Flutter med **FVM**, og fastlås en konkret stable-release i `.fvmrc` (`fvm use stable --pin`).
- [x] Konfigurer Android SDK, fysisk enhed og VS Code (FVM-sti i `.vscode/settings.json`; appen kørt på Samsung SM S931B).
- [x] Beslut foreløbig mappestruktur, navigation og en enkel Material 3-stil.
- [x] Opsæt `.gitignore`, `analysis_options.yaml`, `pubspec.lock` og grundlæggende tests.
- [x] Tilføj en kort `README.md` med links til dette roadmap og `getting_started.md`.
- [x] Fastlæg målgruppe og model for første prototype: ca. 3.–6. klasse, Vokaltrappen med tre separate vokalrækker efter `v1_implementation_plan.md`. Endelig faglig indholdsgodkendelse håndteres i V1/G2 af ejeren.
- [x] Aftal, hvem der validerer danske lyde, eksempler og sproglige regler: appens ejer står selv for godkendelsen.

### Acceptkriterier

- [x] `fvm flutter doctor` viser en fungerende Android-toolchain.
- [x] `fvm flutter run` starter appen på en fysisk Android-enhed (Samsung SM S931B, Android 17 / API 37).
- [x] `fvm flutter analyze` og `fvm flutter test` gennemføres.
- [x] `.fvmrc` er committed; `.fvm/` er ikke committed.
- [ ] Et nyt checkout kan genskabe den fastlåste Flutter-version via FVM.

### Aktuel V0-status — 2026-11-02

Projektopsætning, SDK/FVM, VS Code-konfiguration, navigation, testgrundlag og
opstart på fysisk Android er gennemført. Den aktuelle app har nu V1-, V2-,
V3- og V4-forløb. Senest består statisk analyse, 79 automatiske tests, debugbuild og
en fysisk Android-integrationstest. Den almindelige app er også startet med
`fvm flutter run` på telefonen efter integrationstesten.

**Eneste åbne V0-kontrol:** Reproducerbarhed fra et helt nyt checkout er ikke
afprøvet. `.fvmrc` er versionsstyret og fastlåser Flutter 3.47.9, men det er ikke
alene bevis for, at et rent checkout kan genskabes uden lokal opsætning.
V0 er derfor teknisk etableret med denne ene verifikation udestående.

TalkBack, faktisk udtale, lydrettigheder og faglig godkendelse er fortsat åbne
kvalitetskontroller under V1–V4 og releasearbejdet; de er ikke manglende
projektopsætning i V0.

**Afhængighed:** Ingen. Se `getting_started.md`.

## V1 — Lydtrappen og første komplette læringsflow (MVP)

**Mål:** Første brugbare app, hvor man kan vælge en lyd, høre den og løse en lille opgave.

**Status:** Kodeprototype implementeret og testet; milepælen er ikke fuldt accepteret, da lydoptagelser, manuel lydtest og ejerens faglige godkendelse mangler.

### Kodeprototype — 2026-11-02

Implementeret efter [V1-planen](v1_implementation_plan.md): tre adskilte
vokalrækker, seks JSON-baserede ordøvelser med draft-status, lydservice med
prioritet godkendt asset → dansk helords-TTS → fejlbesked, Lydtest, feedback,
resultater og lokal fremdrift med bekræftet nulstilling. Ordets korrekte stavning
vises efter svar; valgfri læsehjælp gør øvelsen mulig uden lyd.

V1-planens manglende-vokal-øvelse er den konkrete prototypeopgave; den erstatter
foreløbigt det tidligere forslag om at vælge et eksempel ud fra en enkeltlyd.
Fremdrift er fremrykket fra V5 i det omfang, V1-planen kræver; V5's anbefalinger,
profiler og niveaustyring er stadig senere arbejde.

Se [implementerings- og teststatus](../docs/v1_status.md) for G0–G3 og afprøvning.
Afkrydsede kodepunkter er implementeret og automatisk testet. På fysisk Android
er y/ø-forløbet, navigation, genindlæsning af native fremdrift og TTS-diagnostik
afprøvet. Alle seks V1-øvelser er dækket af widgettests; faktisk afspilning og
udtale af samtlige ord er ikke dokumenteret gennemgået. Ingen lokale
lydoptagelser er tilføjet, og indholdet er ikke fagligt godkendt.


### Arbejde

- [x] Startskærm, moduloversigt, lydtrappeskærm og én øvelsestype.
- [x] Datamodel med stabile ID’er, tekst, eksempler, forklaring, lydreferencer, svarmuligheder og målklassetrin i modulmetadata. Individuel niveaustyring er senere arbejde.
- [x] Lydafspilning med afspil/stop, gentagelse og tydelige fejlbeskeder.
- [ ] **Indspillede lydfiler** for præcise bogstav-/enkeltlyde og udvalgte referenceord.
- [x] `flutter_tts` til hele ord med dansk stemmekontrol (`da-DK`), som krævet af den konkrete V1-plan. Oplæsning af instruktioner/sætninger er ikke implementeret i prototypen.
- [x] Kontrol af tilgængelig dansk TTS-stemme; hvis den mangler, tilbydes lydfil eller tydelig besked.
- [x] Mulighed for at lytte igen og stoppe afspilning.
- [ ] Valgfri langsommere afspilning i UI. TTS har en fast talehastighed, som stadig skal vurderes på telefonen.
- [x] Første opgavetype efter V1-planen: hør hele ordet og vælg den manglende vokal, med korrekt/ukorrekt feedback og genforsøg. Det tidligere forslag om at vælge et eksempel til en enkeltlyd er erstattet.
- [x] Lille, manuelt sammensat prototypedatasæt med seks ord. Alle er `draft`; faglig godkendelse er fortsat åben nedenfor.
- [x] Widgettests for navigation og svarfeedback; enhedstest for indholdsvalidering.

### Acceptkriterier

- [x] Brugeren kan starte en øvelse fra forsiden og afslutte den: y/ø-forløbet er gennemført i fysisk Android-integrationstest, alle tre V1-forløb i widgettests.
- [ ] Alle lydknapper giver forventet lyd på en fysisk Android-telefon.
- [ ] De essentielle lydøvelser virker i flytilstand.
- [x] Manglende dansk TTS, assetfejl og afspilningsfejl håndteres uden crash i automatiske tests med fake backend. Manuel test med manglende dansk stemme på telefon afventer.
- [ ] Lyd og læringsindhold er fagligt gennemgået.

**Vigtigt:** Et isoleret bogstav må ikke automatisk afspilles med TTS som erstatning for den ønskede *fonemlyd*; en TTS-motor kan sige bogstavnavnet eller vælge en anden udtale.

## V2 — Stavelser og endelser

**Status:** Tre øvelsesformer implementeret og gennemført på Android; milepælen afventer orddeleoptagelser, offline-lydtest, niveaustyring og ejerens faglige godkendelse.

**Mål:** Brugeren kan høre ord og relevante orddele og genkende stavelser og endelser.

### Implementeringsstatus — 2026-11-02

Tre forløb med seks øvelser er implementeret fra lokale JSON-data:
Find stavelserne (`ka-ge`, `sko-le`), Byg med stavelser (tryk orddele i rækkefølge)
og Find endelsen (konkret flertal: bil → biler, hest → heste).

Fælles svarfeedback, genforsøg, resultater, navigation og fremdrift genbruges.
V1- og V2-ID'er indlæses samlet, så tidligere fremdrift ikke bortfiltreres.
Hele ord kan høres med eksisterende dansk TTS. Der er ikke tilføjet eller
syntetiseret isolerede stavelser/endelser. Alle nye ord er draft.

Ved V2-leverancen bestod 40 automatiske tests og Android-debugbuild. Integrationstesten på
Samsung SM S931B / Android 17 (API 37) gennemførte alle tre V2-forløb,
kontrollerede genindlæst native fremdrift efter genoprettelse af app-state og
åbnede TTS-diagnostik. Testen er ikke en manuel vurdering af faktisk udtale
eller en fuld Android-procesgenstart. Ejer har meldt den første prototype
fungerende; denne tilbagemelding er ikke registreret som generel faglig godkendelse.

Se [V2-status og afprøvning](../docs/v2_status.md).

### Arbejde

- [x] Vis ord med visuel opdeling i stavelser, fx `ka-ge` og `sko-le`.
- [x] Afspil hele ord med den fælles danske TTS-service; faktisk udtale skal vurderes manuelt.
- [ ] Tilføj og afprøv **kuraterede indspilninger** af stavelser og endelser.
- [x] Øvelser: vælg korrekt stavelsesopdeling, sæt stavelser sammen, genkend en endelse.
- [x] Forklar konkrete flertalsendelser i korte sætninger uden en universel regel.
- [ ] Udvid til flere grammatiske sammenhænge og godkendte udtaleeksempler, herunder forskellige anvendelser af `-er`.
- [x] Indfør stabil datarepræsentation af orddelinger og relation til hele ord.
- [x] Gentagelse af gennemførte forløb uden at slette historik.
- [ ] Mulighed for at vælge et lettere niveau.

### Acceptkriterier

- [x] Alle tre øvelsesformer kan gennemføres: samtlige seks V2-opgaver er gennemført i både widgettests og fysisk Android-integrationstest.
- [ ] Hele ord og udvalgte orddele kan afspilles hver for sig.
- [ ] Korrekte svar og forklaringer er kvalitetssikret mod dansk sprogbrug.
- [ ] Offline-funktion er verificeret for alt kerneindhold.

## V3 — Sammensatte ord og orddeling

**Mål:** Brugeren lærer både at sammensætte ord og at dele dem på sprogligt korrekt vis.

**Status:** Kodeprototype med fire forløb og otte opgaver. Faglig godkendelse og manuel lyd-/offlinekontrol afventer.

### Implementeringsstatus — 2026-11-02

Byg sammensatte ord, Find betydningsdele, Find stavelser og Del ved linjeskift
er separate forløb. Data skelner mellem `parts`, `syllables`, `linkingElement`
og konkrete `lineBreaks`. Solbriller illustrerer to betydningsdele over for tre
stavelser; biblioteksbog viser et eksplicit bindebogstav.

Svarfeedback, genforsøg, resultater, helords-TTS og lokal fremdrift genbruges.
V1–V3-ID'er indlæses samlet, så tidligere historik bevares. Alle nye ord er draft.
De 53 automatiske tests består. Den udvidede integrationstest gennemførte alle
otte V3-opgaver på Samsung SM S931B / Android 17 og genindlæste V3-fremdrift
fra native lagring efter genoprettelse af app-state. Det er ikke en fuld
procesgenstart eller en faglig godkendelse af udtale og indhold.

Se [V3-status og afprøvning](../docs/v3_status.md).

### Arbejde

- [x] Øvelse: byg et sammensat ord af to led (`sol + briller`).
- [x] Øvelse: find de betydningsbærende dele i et sammensat ord.
- [x] Øvelse: find stavelser i almindelige ord.
- [x] Separat øvelse: korrekt orddeling ved linjeskift, med tydelige regler og eksempler.
- [x] Understøt bindebogstav som særskilt datafelt og konkret prototypeopgave.
- [ ] Ejer validerer eksemplet med bindebogstav og øvrigt fagligt indhold.
- [x] Brug tap-to-select i første omgang; træk-og-slip kan tilføjes senere.

### Acceptkriterier

- [x] Appen skelner tydeligt mellem sammensætning, stavelsesdeling og orddeling ved linjeskift.
- [x] Øvelserne kan løses uden lyd; relevante hele ord er tilsluttet den fælles danske TTS-service.
- [ ] Faktisk udtale og offlineadfærd er gennemgået på telefonen.
- [x] Testcases dækker enkle sammensætninger samt bindebogstav og forkert placering af delingen før s.

## V4 — Bøjning af udsagnsord

**Mål:** Brugeren kan genkende og træne navneform, nutid, datid og førnutid.

**Status:** Kodeprototype implementeret og gennemført i Android-integrationstest. Faglig godkendelse og manuel lytte-/offlinekontrol afventer.

### Implementeringsstatus — 2026-11-02

Fire bøjningsskemaer (lege, spise, gå, være) og tre forløb med ti opgaver er
implementeret: vælg korrekt form, skriv manglende form og genkend navneform/tid.
Navneform, nutid, datid og førnutid vises særskilt. Hjælpeverber indgår i
kontekst; gå bruger fx er gået hjem, uden at dette præsenteres som den eneste
mulige førnutid af gå. Udtale kan høres i korte danske sætninger via TTS.

Fritekstsvar normaliseres for mellemrum og store/små bogstaver. Kun forsøg og
gennemførsel gemmes, ikke elevens indtastning. Alle eksempler er draft.
Fremdrift fra alle fire moduler bevares. Ingen nye pakker er nødvendige.

67 automatiske tests og Android-debugbuild består. Den udvidede integrationstest
på Samsung SM S931B / Android 17 gennemførte alle ti V4-opgaver, inklusive
fritekst med tastatur, og genindlæste V4-fremdrift fra native lagring efter
genoprettelse af app-state. Fuld Android-procesgenstart og faktisk udtale er
fortsat særskilte manuelle kontroller.

Se [V4-status og afprøvning](../docs/v4_status.md).

### Arbejde

- [x] Introducer bøjningsskemaer med få, velkendte udsagnsord.
- [x] Øvelser: vælg korrekt form, udfyld manglende form, match form med tidsbetegnelse.
- [x] Medtag både regelmæssige og uregelmæssige verber (`at spise`, `at gå`, `at være`).
- [x] Kobl formerne til korte danske sætninger med TTS-afspilning.
- [ ] Ejer godkender sætninger, grammatiske forklaringer og faktisk hørt udtale.
- [x] Forklar forskellen mellem grundform, tid og hjælpeverber uden unødvendigt fagsprog.

### Acceptkriterier

- [x] Verber og bøjninger er gemt som strukturerede, validerede data.
- [x] Korrekthed kan testes automatisk for hver opgave.
- [x] Et lille forløb kan gennemføres fra forklaring til afsluttende øvelse.

## V5 — Fremskridt, gentagelse og motivation

**Mål:** Brugeren kan fortsætte, hvor vedkommende slap, og gentage det svære.

**Status:** V5-funktioner implementeret og testet. Indholdets faglige/lydmæssige godkendelse under V1–V4 er fortsat åben.

### Implementeringsstatus — 2026-11-02

Seneste forløb, opgave og svarstatus gemmes lokalt. Forsiden viser Fortsæt forløbet,
når der er en gyldig placering. Fremskridt viser gennemførte opgaver/forløb og
foreslår gentagelse af opgaver, som har krævet flere forsøg; derefter en ny eller
ældst gennemført opgave. Ingen automatisk faglig niveauvurdering eller rangliste.

Med hjælp/Uden hjælp ændrer adgangen til hints i samme datasæt. Valget gemmes
pr. lokal profil, og historikken bevares ved skift. Schema 1 migreres til schema 2
på den eksisterende lagringsnøgle. Schema 2 har profilbeholder og aktivt profil-ID,
men ingen UI til at oprette/skifte profiler og ingen personoplysninger.

79 automatiske tests, debugbuild og det samlede Android-scenarie består.
Separate native prøver før/efter et eksplicit Android force-stop bekræfter, at
historik, gentagelsesmarkering, bogmærke og hjælpestatus overlever procesgenstart.
Den nye testarbejdsgang bruger --no-uninstall og gendanner testændringer.

Se [V5-status, migration og testforløb](../docs/v5_status.md).

### Arbejde

- [x] Gem opgavehistorik, afledt gennemførsel af forløb, seneste placering og valgt hjælpestatus lokalt på telefonen.
- [x] Enkel oversigt over fremgang og anbefalede gentagelser.
- [x] Indfør to støtteniveauer: Med hjælp og Uden hjælp i samme indhold.
- [ ] Valgfri senere udvidelse: fagligt differentierede opgaver og automatisk gradvis progression. Dette indgår ikke i den leverede støttebaserede V5.
- [x] Positiv, konkret feedback uden tidspres eller konkurrence som standard.
- [x] Klargør lagringsmodellen til flere lokale profiler. Profiladministration i UI er udskudt, indtil behovet opstår.

### Acceptkriterier

- [x] Historik, bogmærke og hjælpestatus overlever fuldt stop af Android-processen og ny appstart (native test).
- [x] Brugeren kan med bekræftelse nulstille aktiv profils historik, bogmærke og hjælpestatus; andre profilers data bevares (unit-/widgettests).
- [x] V5-funktionerne kræver ingen konto, backend eller netforbindelse. Eksisterende TTS kan stadig kræve netværk; der er ikke lovet offline-lyd for hele appen.

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

## Ansvar for godkendelse og kvalitet

**Beslutning — 2026-11-02:** Appens ejer står selv for godkendelse af danske
lyde, lydoptagelser, eksempler, sproglige regler, læringsindhold og øvrig
kvalitet i appen. Der kræves ikke en særskilt ekstern godkender.

Implementering og automatiske tests kan understøtte kvalitetssikringen, men
erstatter ikke ejerens godkendelse. Et punkt om faglig gennemgang eller kvalitet
markeres først som afsluttet, når ejeren har godkendt det konkrete indhold eller
den konkrete funktion. Valget af godkender betyder ikke, at eksisterende indhold
allerede er godkendt.

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
| Hvilken "lydtrappe" mener vi? | Vokaltrappen som konkret prototype efter V1-planen; endelig model godkendes af ejer | Før fagligt godkendt pilot |
| Hvem er primær bruger? | V1-pilot ca. 3.–6. klasse; langsigtet 1.–9. klasse efter færdighed | Ejer evaluerer i pilot |
| Dansk udtale kan ikke altid udledes af stavemåden | Brug kuraterede lydoptagelser til kritiske lyde | V1–V2 |
| TTS findes ikke nødvendigvis offline på alle telefoner | Bundl nøglelyde; test fallback | V1 |
| Orddeling kan betyde forskellige ting | Separate læringsmål og datasæt | V3 |
| Copyright/licenser for lyd og materialer | Brug egne eller licenserede optagelser og dokumentér rettigheder | Før distribution |
| Mikrofon og børns persondata | Ikke i MVP; lokal behandling og særskilt designvurdering | V7+ |

## 7. Næste konkrete skridt

1. Verificér V0 fra et rent checkout. Gennemgå derefter TalkBack og den manuelle Android-testmatrix; almindelig opstart og integrationstest på telefonen er allerede gennemført.
2. Ejer gennemgår V1-planens seks draft-ord, forklaringer og faktisk dansk TTS på telefonen; skaf derefter en reel, rettighedsafklaret ordoptagelse til asset-test.
3. Integrationstesten for V1–V4 og V5-lagring efter fuldt Android-processtop er bestået. Gennemfør de resterende manuelle kontroller: faktisk lyd/udtale, manglende dansk stemme, flytilstand og TalkBack.
4. Opdatér dette dokument efter hver version: **Hvad er færdigt, hvad er ændret, hvad kommer nu?**

**Versionshistorik**

| Dokumentversion | Dato | Ændring |
| --- | --- | --- |
| 0.1 | 2026-11-02 | Første roadmap: V0–V7+, mål, acceptkriterier og tekniske principper |
| 0.2 | 2026-11-02 | V0-startskærm, dansk Material 3, navigation og tilgængelighedstests; V1-indhold udskudt efter ejers beslutning |
| 0.3 | 2026-11-02 | Ejer står selv for godkendelse af lyde, læringsindhold og øvrig kvalitet; valg af godkender er afklaret |
| 0.4 | 2026-11-02 | V1-kodeprototype efter konkret plan: data, vokaltrapper, øvelser, lydfallback og lokal fremdrift; fysiske kvalitets-gates afventer |
| 0.5 | 2026-11-02 | V2-prototype: stavelser, ordbygning og flertalsendelser; 40 automatiske tests og fysisk Android-integrationstest består |
| 0.6 | 2026-11-02 | V0-status ajourført: SDK/enhed, prototypegrundlag og fysisk opstart er afsluttet; kun rent-checkout-verifikation står åben |
| 0.7 | 2026-11-02 | V1/V2-status revideret mod kode og testdækning; implementerede dele adskilt fra udestående lyd, manuel afprøvning og faglig godkendelse |
| 0.8 | 2026-11-02 | V3-prototype med fire separate forløb og otte opgaver; 53 automatiske tests og udvidet Android-integrationstest består |
| 0.9 | 2026-11-02 | V4-prototype: fire bøjningsskemaer, ti opgaver og fritekst; 67 automatiske tests og udvidet Android-integrationstest består |
| 0.10 | 2026-11-02 | V5: lokal genoptagelse, gentagelsesforslag, støtteniveauer og profilklart schema; 79 tests og faktisk Android-procesgenstart verificeret |
