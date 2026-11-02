# V4 — bøjning af udsagnsord

Implementeret 2026-11-02 efter hovedroadmappets V4-milepæl.

## Leveret

Fire foldbare bøjningsskemaer: lege, spise, gå og være. Hvert skema viser
navneform, nutid, datid og førnutid, med en kort sætning for hver form.
Lege illustrerer regelmæssig bøjning, gå/være giver uregelmæssige eksempler.
Navneform beskrives som grundform, ikke som en tid. Hjælpeverber behandles i
konkret sammenhæng; er gået hjem er et eksempel, ikke en universel har/er-regel.

Tre forløb med ti opgaver:

- Vælg den rigtige form: tre opgaver med svarmuligheder.
- Skriv den manglende form: tre fritekstopgaver, inklusive hele førnutidsformen med hjælpeverbum.
- Genkend formen: fire opgaver med betegnelserne navneform, nutid, datid og førnutid.

Fritekst sammenlignes efter normalisering af store/små bogstaver og mellemrum.
Tomme svar tæller ikke som forsøg. Forkerte svar giver forklaring og genforsøg.
Rå indtastninger gemmes ikke; kun den eksisterende forsøg-/gennemførselsstatistik.

## Implementering

`assets/data/verbs_v4.json`: paradigmer, sætninger, tre forløb og ti opgaver.
`lib/features/udsagnsord/verb_repository.dart`: model, assetindlæsning,
normalisering og validering af fire formfelter, sætninger, hjælpeverber,
stabile ID'er, svar, valgmuligheder og referencer. Validering af relationer er
ikke en erstatning for ejerens sproglige godkendelse.
`lib/features/udsagnsord/verb_reference.dart`: foldbare bøjningsskemaer.

De fælles practice-skærme håndterer nu et fritekstfelt. ExerciseController
bevarer kontrollen over svar, feedback og statistik. V4 bruger egne
`/udsagnsord`-ruter og `v4-`-ID'er. Opstart, fremdriftsoversigt og bekræftet
nulstilling omfatter alle fire moduler; tidligere fremdrift bortfiltreres ikke.

Den fælles lydservice bruges til komplette sætninger. TTS-input er altid den
korrekte sætning fra data, aldrig elevens svar eller teksten med hul. Knappen
hedder Hør sætningen i V4. Ingen nye lydfiler, pakker, tilladelser, ændringer
af tema, ikon eller Android-signering er tilføjet.

## Verifikation

- `fvm flutter analyze`: bestået.
- `fvm flutter test`: 67 tests bestået, inklusive alle V1–V3-tests.
- Android-debugbuild: bestået.
- Samlet Android-integrationstest: bestået på Samsung SM S931B / Android 17 (API 37).

Widgettests gennemfører alle ti V4-opgaver med fejl/genforsøg, også fritekst,
og kontrollerer foldbare skemaer og tekstfelter på 320 × 640 ved dobbelt tekst.
Unit-tests dækker blandt andet forkerte paradigmereferencer, manglende former,
hjælpeverbum, normalisering og bevaret historik fra alle fire moduler.

En målrettet native V4-test og den samlede V1–V4-test gennemfører alle ti
V4-opgaver med tastatur. Et tekstfelt-ID pr. opgave og afslutning af den gamle
tastaturforbindelse før skift forhindrer, at et nyt svar nulstilles ved næste opgave.
Testene kontrollerer
fremdrift ved genoprettelse af app-state og genindlæsning af native lagring.
Den erstatter ikke en fuld procesgenstart eller manuel lytning.

## Afprøvning og åbne punkter

Åbn Udsagnsord fra forsiden. Prøv de tre forløb og fold bøjningsskemaerne ud
nedenunder. Kontrollér især sætninger med hjælpeverbum, tastaturets opførsel,
feedback ved forkerte svar og faktisk hørt udtale.

Alle paradigmer og eksempler er draft. Ejerens faglige godkendelse, lyttebedømmelse,
TalkBack, fuld lukning/genåbning og flytilstand er fortsat åbne. TTS kan kræve
internet; V1's G1–G3 er ikke lukket af denne kodeleverance.

Fagligt baggrundsmateriale: [Sproget.dk: Verber](https://sproget.dk/typiske-problemer/verber-udsagnord/).
Opgaver og sætninger er skrevet til prototypen; ingen tredjepartslyd er hentet.

Intet commit eller push er udført.

Seneste samlede status efter V5: 79 automatiske tests og native genoptagelse
efter et fuldt Android-processtop består. Se [V5-status](v5_status.md), inklusive
rettet testarbejdsgang med --no-uninstall. Tidligere testtal er historiske.
