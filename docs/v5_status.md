# V5 — fremskridt, gentagelse og motivation

Implementeret 2026-11-02.

## Leveret

- Seneste modul, forløb, opgave og svarstatus gemmes. Forsiden viser Fortsæt forløbet; genoptagelse registrerer ikke et nyt forsøg.
- Fremskridt viser gennemførte opgaver og hele forløb. Et forløb er gennemført, når alle dets opgave-ID'er er gennemført.
- Gentagelsesforslag prioriterer opgaver med fejl eller flere forsøg. Markeringen bevares efter et korrekt genforsøg og fjernes, når opgaven senere gentages korrekt uden en ny fejl. Uden sådanne opgaver foreslås en ugennemført eller ældst gennemført opgave.
- Med hjælp giver adgang til tydeligt mærkede hints. Uden hjælp skjuler hints. Det er samme faglige indhold; valget er støtte, ikke en automatisk vurdering af elevens niveau. Historik slettes ikke ved skift.
- Nulstilling med bekræftelse rydder aktiv profils historik, placering og hjælpestatus. Andre profilers data bevares.

Ingen login, backend, personoplysninger, rangliste eller tidspres. Ingen nye
Flutter-pakker, tilladelser eller ændringer af eksisterende fagligt indhold,
tema, ikon, app-ID eller signering.

## Data og migration

ProgressRepository beholder nøglen `progress_v1`, så gamle installationer kan
læse deres eksisterende data. Schema 1 indlæses fortsat. Ved næste skrivning
oprettes schema 2 med `activeProfileId` og en `profiles`-beholder.
Aktiv profil indeholder opgavestatistik, review-markering, niveau og bogmærke.
Personnavne og elevens rå fritekstsvar gemmes ikke. UI til flere profiler er
ikke tilføjet; modellen er kun klargjort til en senere udvidelse.

Opgave-ID'er bevares. Bogmærker, som ikke matcher det aktuelle indhold, tilbydes
ikke i UI. Svarstatus kontrolleres mod gemte forsøg, så et ugyldigt bogmærke
ikke i sig selv giver en korrekt besvarelse. Fejl i læsning/skrivning giver en
besked og tillader fortsat øvelse uden lovet permanent lagring.

AppState samler et katalog over V1–V4-opgaver. ExerciseController gemmer
placering ved åbning, svar, genforsøg og næste opgave. Sidste opgave rydder
bogmærket ved afslutning. Historiske gennemførsler slettes ikke ved gentagelse.
Appen gemmer ét senest aktivt forløb pr. profil, ikke alle åbne navigationsstakke.

## Verifikation

- `fvm flutter analyze`: bestået.
- `fvm flutter test`: 79 unit-/widgettests bestået.
- Android-debugbuild: bestået.
- Samlet V1–V4-integrationstest med V5-lagring: bestået på Samsung SM S931B / Android 17.
- Separate V5-prøver før/efter eksplicit `adb shell am force-stop`: bestået.

Genstartstesten bekræfter genindlæst historik, review-markering, bestemt opgave
og Med hjælp/Uden hjælp fra native lagring i en ny Android-proces. Den
kontrollerer også, at Fortsæt forløbet åbner den rette opgave uden hints i
Uden hjælp. Testændringer gendannes fra en midlertidig snapshot efter testen.

Tests omfatter schema 1-migration, isolering af profiler ved reset,
fejlhåndtering, genoptagelse af feedback, næste/afslutning, anbefalinger,
bevarelse af historik og layout på 320 × 640 med dobbelt tekststørrelse.

## Sikker Android-testarbejdsgang

Brug altid `--no-uninstall` på telefonen. Flutter afinstallerer som standard
appen efter integrationstest; afinstallation fjerner appdata. Kommandoer:

```sh
fvm flutter test integration_test/progress_prepare_test.dart --no-uninstall -d DEVICE_ID
adb -s DEVICE_ID shell am force-stop com.incipier.sprogappen.debug
fvm flutter test integration_test/progress_restart_test.dart --no-uninstall -d DEVICE_ID
fvm flutter test integration_test/vowel_ladder_flow_test.dart --no-uninstall -d DEVICE_ID
```

Erstat DEVICE_ID med telefonens ID. Prepare/restart er et sammenhængende par;
prepare tager snapshot og sætter kendte testværdier. Restart verificerer dem og
gendanner snapshot i finally. Den samlede øvelsestest tager også snapshot og
gendanner det i teardown. Kør ikke nulstilling af rigtige brugerdata som en test.

**Hændelse under implementeringen:** Den første native test blev kørt uden
--no-uninstall. Flutters automatiske oprydning afinstallerede debugappen og
fjernede dens lokale fremskridt samt den midlertidige backup. De tidligere
fremskridt kunne derfor ikke gendannes. Testkommandoer og AGENTS.md er rettet;
de efterfølgende V5-procesgenstartstests bekræfter lagring med databevaring.

## Resterende arbejde

Fagligt differentierede datasæt, automatisk niveaustigning og UI til flere
profiler er ikke implementeret. Ejer bør afprøve, om hintniveauer og
anbefalinger er nyttige. TalkBack og generel release-/lydkvalitet ligger stadig
i V6 og de åbne kvalitetskontroller fra V1–V4. V5's lokale funktioner kræver
ikke internet; enhedens TTS kan fortsat kræve netværk.

Intet commit eller push er udført.
