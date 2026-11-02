# V3 — sammensatte ord og orddeling

Implementeret 2026-11-02 efter hovedroadmappets V3-milepæl.

## Leveret

Fire separate forløb med to opgaver hver:

- Byg sammensatte ord: sol + briller og regn + jakke med trykbare brikker.
- Find betydningsdele: solbriller samt bibliotek + s + bog. Bindebogstav er et særskilt felt.
- Find stavelser: solbriller og kage. Der skelnes mellem sol + briller og sol · bril · ler.
- Del ved linjeskift: skole og biblioteksbog. Svarmulighederne viser faktisk to linjer med bindestreg på første linje.

Alle opgaver kan løses med tekst alene. Hele ord bruger eksisterende dansk TTS;
ingen enkeltstavelser eller bogstavnavne sendes som lydfallback. Alle fem nye
ord er draft og afventer ejerens godkendelse. Der er ikke oprettet lydklip.

## Implementering

`assets/data/word_structure_v3.json` indeholder ord, fire forløb og otte opgaver.
Det eksisterende practice-repository og de fælles skærme under
`lib/features/stavelser_endelser/` er udvidet med modulet `ordstruktur`.
V2's ruter og ID'er er bevaret. V3 har egne `/ordstruktur`-ruter og `v3-`-ID'er.

Datamodellen adskiller betydningsdele (`parts`), stavelser (`syllables`),
bindebogstav (`linkingElement`) og udvalgte delinger (`lineBreaks`). Validatoren
kontrollerer rekonstruktion af ord, referencer, entydige opgaver, svar og
bindebogstavets placering i det konkrete eksempel. Den er ikke en automatisk
algoritme, som kan afgøre alle danske stavelses- og orddelingsregler.

AppState, fremdriftsoversigt og bekræftet nulstilling omfatter alle tre moduler.
Opstart indlæser alle kendte ID'er, før gemt historik filtreres. Ingen nye
packages eller ændringer af tema, ikon, app-ID eller Android-signering.
Fremskridt og Lydtest er fortsat placeret over Lydtrappen på forsiden.

## Verifikation

- Statisk analyse: bestået.
- Samlet testpakke: 53 tests bestået, inklusive alle tidligere V1/V2-tests.
- Android-debugbuild: bestået.
- Udvidet integrationstest på Samsung SM S931B / Android 17 (API 37): bestået.

Integrationstesten gennemfører V1 y/ø, V2's seks opgaver og alle otte V3-opgaver,
genopretter app-state og genindlæser fremdrift fra native lagring. Lydtest-
diagnostik åbnes også. Det er ikke en fuld Android-procesgenstart eller en
manuel vurdering af faktisk hørt lyd. Widgettests dækker alle V3-svar med fejl,
genforsøg og resultater samt linjeskift, ukendte ID'er og dobbelt tekststørrelse
på 320 × 640. Unit-tests dækker blandt andet forskellen på betydningsdele og
stavelser, bindebogstavets placering og historik fra alle tre moduler.

## Åbent før milepælen er fagligt godkendt

Ejer skal gennemgå ordvalg, forklaringer, opgavernes sværhedsgrad og faktisk
TTS-udtale. Afprøv manuelt TalkBack, fuld lukning/genåbning og flytilstand.
TTS har fortsat ingen offlinegaranti. Godkendte lokale optagelser og V1's
G1–G3 er stadig åbne; V3-kodearbejdet lukker ikke disse punkter.

Åbn Sammensatte ord og orddeling → Åbn ordstruktur fra forsiden. Kontrollér,
at de fire læringsmål er lette at skelne. Vær især opmærksom på, om forskellen
mellem to betydningsdele og tre stavelser i solbriller er tydelig.

## Kilder

De konkrete opgavetekster er skrevet til prototypen. Baggrund for sammensatte
ord, linjeskift og bindebogstav er [Sproget.dk: Orddeling](https://sproget.dk/typiske-problemer/orddeling/).
Kilden er fagligt grundlag, ikke dokumentation for ejerens godkendelse af vores
undervisningsmateriale. Ingen tredjepartslyd eller illustrationer er hentet.

Intet commit eller push er udført.

Seneste samlede verifikation efter V4: 67 automatiske tests og udvidet fysisk
Android-integrationstest består. Se [V4-status](v4_status.md). Tidligere tal
beskriver den tidligere leverance; faglige og lydmæssige godkendelser er fortsat åbne.

Seneste samlede status efter V5: 79 automatiske tests og native genoptagelse
efter et fuldt Android-processtop består. Se [V5-status](v5_status.md), inklusive
rettet testarbejdsgang med --no-uninstall. Tidligere testtal er historiske.
