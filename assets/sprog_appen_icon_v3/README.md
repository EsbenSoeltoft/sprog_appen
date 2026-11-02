> **Integreret i appen:** De fire launcher-kildefiler er flyttet til
> `assets/icon/` i projektroden. Konfigurationen er flyttet til projektets
> `flutter_launcher_icons.yaml`. Android-ressourcer genereres med
> `fvm dart run flutter_launcher_icons`. Nedenstående pakkebeskrivelse og
> `manifest.json` beskriver den oprindeligt leverede pakkestruktur.

# Sprog Appen — ikonpakke v3 (samme motiv i alle varianter)

**Ændring i forhold til v2:** `assets/icon/app_icon.png` er nu den eneste visuelle kilde til både standard, adaptive og monokrome launcher-ikoner. Det separate, anderledes tegnede ansigt fra v2 er fjernet. **Standardikonet og alle Play Store-grafikker fra v2 er bevaret uændret.**

## Installér i Flutter

Kopiér `assets/icon/` og `flutter_launcher_icons.yaml` til roden af dit Flutter-projekt (ved `pubspec.yaml`). Erstat tidligere konfiguration.

```bash
flutter pub add --dev flutter_launcher_icons
flutter pub get
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
```

Vær opmærksom på: adaptive ikoner kræver en forgrund og en baggrund i Android, og Android beskærer ikonet efter launcherens form. Derfor er forgrundens originalmotiv skaleret ind i sikkerhedszonen, mens baggrunden er mørkeblå, ligeledes udledt fra originalikonet. **Det er ikke pixel-for-pixel samme størrelse som standardikonet**.

Monokrome ikoner kan ikke bevare originale blå/røde farver eller Dannebrog i rødt og hvidt: Android temafarver ikonet automatisk. Silhuetten med ansigt, flagets form og lydbølger følger dog standardikonet.

## Indeholder

- `assets/icon/app_icon.png` — standard 1024×1024 (præcis samme fil som i v2)
- `assets/icon/adaptive_foreground.png` — transparent originalmotiv, beskåret til sikkerhedsområdet
- `assets/icon/adaptive_background.png` — blå baggrund baseret på standardikonet
- `assets/icon/adaptive_monochrome.png` — samme motiv i hvid med alfa-transparens
- `source/adaptive_subject_from_standard.png` — udtrukket originalmotiv, transparent
- `play_store/` — uændrede Google Play-filer fra v2, inklusive appikon 512×512 og feature graphic 1024×500
- `android_reference/` — referencevisninger, ikke filer der skal kopieres til `android/`
- `scripts/compose_screenshot.py` — skærmbilledskabeloner; indsæt kun rigtige app-skærmbilleder
- `scripts/build_icons_v3.py` — genskaber adaptive/monokrome ikonfiler ud fra `assets/icon/app_icon.png`

## Play Store

- `play_store/app_icon_512x512.png`: 512×512 PNG, uændret fra v2.
- `play_store/feature_graphic_1024x500.png`: 1024×500 PNG, uændret fra v2.
- `play_store/screenshots/`: skabeloner og demonstrationer, **IKKE** autentiske skærmbilleder af din app. Udskift med reelle optagelser inden upload.

Kør `python3 scripts/build_icons_v3.py` ved senere genbygning (kræver Pillow og numpy).

Android safe zone og tematisering: https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
Flutter-plugin: https://pub.dev/packages/flutter_launcher_icons
