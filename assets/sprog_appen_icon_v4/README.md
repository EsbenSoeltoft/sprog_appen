# Sprog Appen – ikonpakke v4

**Designkilde:** `source/sammensat_taleboble_gron_v1_original.png` (1254 × 1254 px). Den godkendte sammensatte grønne taleboble er uændret. Ikonvarianter er tekniske tilpasninger af dette rasterbillede – ikke nye illustrationer.

## Farver

- Primær: `#056B5C`
- Grundfarve: `#24685B`
- Mørk: `#005145`
- Lys accent: `#A0F2DE`
- Lys appbaggrund: `#F8F9F5`

## Filoversigt

| Fil | Brug |
|---|---|
| `assets/icon/app_icon.png` | Almindeligt Android-ikon, 1024 × 1024, den oprindelige illustration skaleret uden omtegning |
| `assets/icon/adaptive_foreground.png` | Transparent forgrund udtrukket fra det **samme** logo, 1024 × 1024 |
| `assets/icon/adaptive_background.png` | Opaque grøn baggrund, 1024 × 1024 |
| `assets/icon/adaptive_monochrome.png` | Android 13+ temabaseret ikon, samme logo som transparent hvid form |
| `play_store/app_icon_512x512.png` | Google Play store listing-ikon (512 × 512, RGBA, under 1 MiB) |
| `play_store/feature_graphic_1024x500.png` | Google Play feature graphic (1024 × 500, RGB, ingen alpha) |
| `play_store/feature_graphic_textfree_1024x500.png` | Alternativ Play Store-illustration uden tekst |
| `play_store/extra/social_banner_1200x630.png` | Valgfrit banner til sociale medier; **ikke** et krav i Play Console |
| `android_reference/` | Eksempelstørrelser, adaptive og monokrome previews til kontrol |
| `play_store/screenshots/templates/` | Grafiske overlejringer til **rigtige** telefon-skærmbilleder |
| `play_store/screenshots/previews/` | **Kun previews** mærket NOT_FOR_UPLOAD, ikke faktiske screenshots |
| `scripts/build_icon_package_v4.py` | Reproducerer hele pakken fra originalen |
| `manifest.json` | Oversigt over PNG-størrelser, filtyper og SHA-256 |

## Opsætning i Flutter

1. Kopiér `assets/icon/` og `flutter_launcher_icons.yaml` til roden af dit Flutter-projekt (`sprog_appen`).
2. Sørg for, at pakken `flutter_launcher_icons` er installeret:

   ```bash
   flutter pub add --dev flutter_launcher_icons
   flutter pub get
   ```

3. Generér launcher-ikoner:

   ```bash
   dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
   ```

4. Kontrollér på mindst én Android-enhed med almindeligt ikon, cirkelmaske og (hvis understøttet) **temabaserede ikoner**. Test både lyst og mørkt tema. Nogle launchere kræver geninstallation eller nulstilling af launcher-cache, før et ændret ikon vises.

**Bemærk:** `adaptive_icon_foreground_inset: 0` er bevidst. Padding/sikkerhedszone er allerede indbygget i `adaptive_foreground.png`, og ekstra inset ville gøre taleboblen for lille. Android skærer motivet efter launcherens maske, så den adaptive version vil have en smule anderledes kant/baggrund end det almindelige ikon.

## Google Play Console

Under **Store presence → Main store listing** (menunavn kan variere):

- Upload `play_store/app_icon_512x512.png` som app-ikon.
- Upload `play_store/feature_graphic_1024x500.png` som feature graphic.
- Tilføj **ægte screenshots fra appen**. De vedlagte skabeloner har ikke appindhold og må ikke uploades som app-skærmbilleder. Erstat pladsholderen med skærmbilleder fra den rigtige app, og kontrollér, at tekst beskriver allerede implementerede funktioner.

Den oprindelige 1254 × 1254-kilde er raster (PNG), ikke vektor. Pakken påstår derfor **ikke** at indeholde en redigerbar SVG.

## Reproduktion

```bash
python3 -m pip install pillow numpy
python3 scripts/build_icon_package_v4.py
```

Scriptet ændrer ikke `source/sammensat_taleboble_gron_v1_original.png`. De genererede forgrunde er matting fra den kilde; de originale papirlignende detaljer bevares så vidt muligt. Scriptet genererer ikke faktiske app-skærmbilleder.

## Validering

PNG-størrelser, gennemsigtighed og Google Play-ikonets maksimumstørrelse kontrolleres af scriptet. En komplet Flutter-/Android-bygning er **ikke** udført i denne pakke; den bør verificeres i projektets eget buildmiljø efter installation.
