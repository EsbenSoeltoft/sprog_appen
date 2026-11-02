# Projektinstruktioner for AI-agenter og bidragydere

## Offentligt repository og hemmeligheder

GitHub-repositoryet for Sprog Appen er **public**. Behandl alt, der committes,
pushes eller deles i issues, pull requests og CI-output, som offentligt.
Disse regler gælder både AI-agenter og menneskelige bidragydere.

- Commit eller push aldrig hemmeligheder: API-nøgler, tokens, passwords,
  private nøgler, Android-keystores, signeringsoplysninger eller private
  miljøfiler. Det gælder også testdata, dokumentation og eksempler.
- Opbevar lokal konfiguration i ignorerede filer, fx `.env` og
  `android/key.properties`. Opbevar CI-hemmeligheder i GitHub Actions secrets
  eller en tilsvarende secret manager; skriv dem ikke direkte i workflows.
- Versionsstyrede eksempler som `.env.example` og
  `android/key.properties.example` må kun indeholde tydelige pladsholdere.
  Kopiér aldrig rigtige værdier fra lokale filer til eksemplerne.
- Undgå at udskrive hemmeligheder i terminaloutput, logs, screenshots,
  AI-samtaler, issues eller pull requests. Læs kun private konfigurationsfiler,
  når opgaven kræver det, og vis kun redigerede værdier ved fejlfinding.
- Hemmeligheder må ikke indbygges i Flutter-appen via assets, Dart-kode,
  `--dart-define`, miljøfiler eller Android-ressourcer. En distribueret app kan
  undersøges; klientkonfiguration er ikke et sikkert sted til serverhemmeligheder.
  Funktioner, der kræver en serverhemmelighed, skal bruge en backend.
- Bevar og udvid `.gitignore`, når nye værktøjer eller konfigurationsfiler
  introduceres. Tilføj ikke brede undtagelser, der gør hemmeligheder synlige
  for Git, og brug ikke `git add -f` på private filer.

## Før commit og push

Kontrollér `git status --short`, `git diff --cached --stat` og
`git diff --cached`, før der committes. Gennemgå alle staged filer for
hemmeligheder og utilsigtede lokale filer. Del ikke diff-output, der indeholder
hemmeligheder. Kontrollér desuden, at nye private filtyper ignoreres, fx med
`git check-ignore <sti>`.

`.gitignore` beskytter ikke filer, som allerede er tracked, og fjerner ikke
hemmeligheder fra Git-historikken. Stop commit/push, hvis en hemmelighed opdages.
Hvis den er kommet i et commit, skal den behandles som potentielt eksponeret:
underret ejeren uden at gengive værdien, tilbagekald eller rotér den hos
udbyderen, og aftal oprydning af filer og eventuel historik. Sletning i et nyt
commit er ikke tilstrækkeligt. Omskriv ikke delt historik eller force-push uden
eksplicit aftale.

## Integrationstest på fysisk Android

Brug altid `fvm flutter test ... --no-uninstall` på en telefon med eksisterende
appdata. Flutter afinstallerer ellers som standard testappen efter testen og
fjerner dens lokale data. Kør ikke tests med nulstilling af brugerdata uden
udtrykkelig instruktion. Hold test-backup uden for Git, og gendan testændringer.
