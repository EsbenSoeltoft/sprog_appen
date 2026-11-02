# V2 — stavelser og endelser

Implementeret 2026-11-02 efter hovedroadmappets V2-milepæl.

## Leveret

- Seks lokale JSON-øvelser fordelt på Find stavelserne, Byg med stavelser og Find endelsen.
- Stavelsesvisning af kage og skole; ordbygning ved at trykke på stavelser i rækkefølge. Valget kan ryddes før svar.
- Flertalsendelser i korte sætninger: bil + er og hest + e. Stamme/endelse holdes adskilt fra stavelsesdeling; ingen generel regel om alle danske ord eller om orddeling ved linjeskift.
- Feedback, genforsøg, gentagelse, resultat og bevaret svarstatus ved tilbage-navigation.
- Fælles fremdrift med V1, inklusive bekræftet nulstilling. Opstart tillader både V1- og V2-ID'er, så tidligere historik bevares.
- Hele ord afspilles gennem eksisterende dansk TTS. Læseteksten er tilstrækkelig til alle opgaver uden lyd. Isolerede stavelser/endelser afspilles ikke med TTS.

## Filer og valg

`assets/data/syllables_endings_v2.json` indeholder fire draft-ord og seks øvelser.
`lib/features/stavelser_endelser/data/syllable_repository.dart` indlæser og
validerer schema, stabile ID'er, referencer, stavelsessammensætning, endelser,
sætningskontekst og tildeling af øvelser til forløb.
`lib/features/stavelser_endelser/syllable_screen.dart` indeholder skærmforløbet.

Eksisterende ExerciseController, lydservice og ProgressRepository genbruges.
Et lille SpokenWord-interface gør det muligt at afspille hele ord fra begge
moduler uden at fylde V2-data med V1's vokaltrappefelter. Fælles LearningPage og
AudioWordButton er flyttet til egne filer, så modulerne ikke importerer hinandens
skærme i en cirkel. Ingen nye pakker eller Android-buildændringer er nødvendige.
Ikonmaterialet i `lib/sprog_appen_icon_v2/` er ikke ændret.

## Verifikation

- `fvm flutter analyze`: bestået.
- `fvm flutter test`: 40 tests bestået, inklusive alle tidligere V1-tests.
- `fvm flutter build apk --debug`: bestået.
- `fvm flutter test integration_test/vowel_ladder_flow_test.dart --no-uninstall -d DEVICE_ID`: én test bestået på Samsung SM S931B, Android 17 / API 37.

Den fysiske integrationstest gennemfører V1's y/ø-forløb og alle seks V2-opgaver,
genopretter app-state, genindlæser den native lagring og åbner TTS-diagnostikken.
Det er ikke en fuld genstart af Android-processen eller en manuel kontrol af
hørt udtale. Unit-tests bekræfter, at både V1- og V2-historik overlever en ny
repository-instans. Widgettests dækker forkerte svar, retry, resultater,
tilbage-navigation, ukendte ruter og 320 × 640 med dobbelt tekststørrelse.

Den kendte flutter_tts/Kotlin-advarsel er uændret; debugbuildet består.

## Afprøvning og åbne punkter

Åbn Stavelser og endelser fra forsiden og gennemfør de tre forløb. Kontrollér
på telefonen, at stavelsesbrikkerne er lette at trykke på, at feedback er tydelig,
og at helords-TTS lyder naturligt. Luk derefter appen helt og genåbn for at
kontrollere fremdrift uden for integrationstestens genoprettelse af app-state.

Alle nye eksempler er udkast til ejerens godkendelse. Indspillede, godkendte
stavelser og endelser mangler. Fuld offline-lyd, differentierede niveauer,
TalkBack-gennemgang og sproglig godkendelse er derfor fortsat åbne.
V2 er en kodeprototype, ikke en færdig fagligt godkendt milepæl. V1's G1–G3
forbliver åbne; den første prototypes positive tilbagemelding er ikke en
stiltiende godkendelse af nye ord eller lydklip.

## Fagligt grundlag

Eksempler og formuleringer er skrevet til denne prototype. Hovedroadmappet
angiver ka-ge og sko-le. Baggrund om stavelser og grammatiske endelser findes
hos [Sproget.dk om orddeling](https://sproget.dk/typiske-problemer/orddeling/) og
[Sproget.dk om navneord](https://sproget.dk/typiske-problemer/substantiver-navneord/).
Orddeling ved linjeskift er et særskilt læringsmål i V3; disse kilder betyder
ikke, at vores konkrete undervisningsindhold er godkendt.

Ingen indspilninger, tredjepartsillustrationer, hemmeligheder eller nye
netværkstjenester er tilføjet. Intet commit eller push er udført.

Seneste samlede verifikation efter V3: 53 tests samt den udvidede fysiske
Android-integrationstest består. Se [V3-status](v3_status.md). Tidligere testtal
i dette dokument beskriver leverancen på det pågældende tidspunkt.

Seneste samlede verifikation efter V4: 67 automatiske tests og udvidet fysisk
Android-integrationstest består. Se [V4-status](v4_status.md). Tidligere tal
beskriver den tidligere leverance; faglige og lydmæssige godkendelser er fortsat åbne.

Seneste samlede status efter V5: 79 automatiske tests og native genoptagelse
efter et fuldt Android-processtop består. Se [V5-status](v5_status.md), inklusive
rettet testarbejdsgang med --no-uninstall. Tidligere testtal er historiske.
