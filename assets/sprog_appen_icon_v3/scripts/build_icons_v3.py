#!/usr/bin/env python3
"""Derive Sprog Appen v3 adaptive / Android themed icon assets from app_icon.png.

Use: pip install pillow numpy && python3 scripts/build_icons_v3.py
The source standard icon is never modified. Play Store assets remain untouched.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import numpy as np
out=Path(__file__).resolve().parents[1]
(out/'source').mkdir(exist_ok=True)
(out/'android_reference').mkdir(exist_ok=True)
icon=Image.open(out/'assets/icon/app_icon.png').convert('RGB')
S=1024
raw=np.asarray(icon).astype(np.float32)
# Derive alpha solely from original standard pixel colors. Dark blue is the background;
# blue/cyan face, red-white flag and cyan wave columns are separated by their color/luminance.
r,g,b=(raw[:,:,c] for c in range(3))
yy,xx=np.mgrid[0:S,0:S]
base_blue=36+34*(xx/S)+12*(yy/S)
blue_delta=np.clip((b-base_blue-27)/110,0,1)
green_delta=np.clip((g-13)/42,0,1)
red_delta=np.clip((r-23)/85,0,1)
score=np.maximum.reduce([blue_delta,green_delta,red_delta]); score=np.minimum(1.,score)
# Retain body shading, smooth feathered glow, and suppress dark icon background.
score=np.power(score,0.78)
# suppress mostly decorative background near bottom where original has a purple halo
bottom=np.clip((920-yy)/90,0.0,1.0)
score=np.clip(score*bottom,0,1)
# Feather the original artwork's left cut-off edge into the navy background
# and remove stray low-luminance background gradients at upper-right edge.
left_fade=np.clip(xx/92.,0,1)
right_fade=np.clip((1017-xx)/65.,0,1)
top_right_fade=1.-np.clip((xx-600)/260,0,1)*np.clip((180-yy)/180,0,1)
score=np.clip(score*left_fade*right_fade*top_right_fade,0,1)
# eliminate diffuse noise (but preserve original color imagery in foreground)
alpha=Image.fromarray(np.uint8(np.round(score*255)),'L').filter(ImageFilter.GaussianBlur(1.4))
cut=icon.convert('RGBA'); cut.putalpha(alpha)
cut.save(out/'source/adaptive_subject_from_standard.png',optimize=True)
# Android safe circle diameter 66/108 ~= 61.1% of the canvas. Retain content within this region.
# Scaling full image to 0.58 keeps bright face, Dannebrog and sound arcs recognisable.
size=594
subject=cut.resize((size,size),Image.Resampling.LANCZOS)
foreground=Image.new('RGBA',(S,S),(0,0,0,0)); foreground.alpha_composite(subject,((S-size)//2,(S-size)//2))
foreground.save(out/'assets/icon/adaptive_foreground.png',optimize=True)
# Background derived from the original app icon itself, not a separate illustration.
# Only keep its very dark navy base and soft blue-violet ambiance.
blur=icon.filter(ImageFilter.GaussianBlur(240))
blur_arr=np.asarray(blur).astype(np.float32)
base=np.zeros((S,S,3),dtype=np.float32)
base[:,:,0] = 3
base[:,:,1] = 5 + 5*(xx/S)
base[:,:,2] = 40 + 30*(xx/S) + 3*(yy/S)
bg_np=np.uint8(np.clip(.20*blur_arr + .80*base,0,255))
bg=Image.fromarray(bg_np,'RGB')
bg.save(out/'assets/icon/adaptive_background.png', optimize=True)
# Monochrome: same exact silhouette/flag/waves as foreground, no alternative person or waveform.
# Android monochrome themed icons tint using alpha; color contents are solid white.
mono_a=np.asarray(foreground.getchannel('A')).astype(np.float32)
# Retain gradients, but make blue face and curves reliably visible when tinted.
mono_a=np.clip(255*np.power(mono_a/255,0.70),0,255)
# Preserve Dannebrog's cross visually even when red and white become one Android tint.
# Source-derived red part stays translucent, while the white cross stays opaque.
colors=np.asarray(foreground.convert('RGB')).astype(np.float32)
rr,gg,bb=colors[:,:,0],colors[:,:,1],colors[:,:,2]
red_field=(rr>85)&(rr>gg*1.6)&(rr>bb*1.35)&(gg<140)
mono_a[red_field]*=0.38
mono_a=np.uint8(np.clip(mono_a,0,255))
mono=Image.new('RGBA',(S,S),(255,255,255,0))
mono.putalpha(Image.fromarray(mono_a,'L'))
mono.save(out/'assets/icon/adaptive_monochrome.png', optimize=True)
# Previews apply Android-style mask to full layer, no fake changes to art.
comp=Image.alpha_composite(bg.convert('RGBA'),foreground).convert('RGBA')
ref=out/'android_reference'; ref.mkdir(parents=True,exist_ok=True)
comp.convert('RGB').save(ref/'adaptive_square_preview.png', optimize=True)
for shape in ['circle','squircle']:
  m=Image.new('L',(S,S),0); d=ImageDraw.Draw(m)
  if shape=='circle':d.ellipse((0,0,S-1,S-1),fill=255)
  else:d.rounded_rectangle((8,8,S-9,S-9),radius=215,fill=255)
  layer=comp.copy(); layer.putalpha(m)
  layer.resize((512,512),Image.Resampling.LANCZOS).save(ref/f'adaptive_{shape}_preview.png',optimize=True)
# Preview monochrome on two potential wallpaper theme combinations
for name,fgcol,bgcol in [('light',(27,48,107),(210,228,249)),('dark',(218,237,255),(27,47,89))]:
  tinted=Image.new('RGBA',(S,S),fgcol+(0,)); tinted.putalpha(mono.getchannel('A'))
  result=Image.new('RGBA',(S,S),bgcol+(255,)); result.alpha_composite(tinted)
  mask=Image.new('L',(S,S),0); ImageDraw.Draw(mask).ellipse((0,0,S-1,S-1),fill=255)
  result.putalpha(mask)
  result.resize((512,512),Image.Resampling.LANCZOS).save(ref/f'monochrome_{name}_preview.png',optimize=True)
# Compose QA panel
PW,PH=1440,690
canvas=Image.new('RGB',(PW,PH),(244,247,252)); dr=ImageDraw.Draw(canvas)
font_path=next((p for p in ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf','/System/Library/Fonts/Supplemental/Arial.ttf','/Library/Fonts/Arial.ttf'] if Path(p).exists()),None)
fb_path=next((p for p in ['/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf','/System/Library/Fonts/Supplemental/Arial Bold.ttf','/Library/Fonts/Arial Bold.ttf'] if Path(p).exists()),None)
if not font_path or not fb_path: raise FileNotFoundError('Please install DejaVu Sans or Arial for previews')
font=ImageFont.truetype(fb_path,26); small=ImageFont.truetype(font_path,18)
items=[('Standard (uændret)',icon),('Adaptive (samme motiv)',Image.open(ref/'adaptive_circle_preview.png')),('Monokrom (samme motiv)',Image.open(ref/'monochrome_dark_preview.png'))]
for i,(title,img) in enumerate(items):
  cx=240+480*i
  im=img.convert('RGBA').resize((372,372),Image.Resampling.LANCZOS)
  # preview displays original standard square on a neutral card; other two clipped to circle
  canvas.paste(im,(cx-186,115),im if im.mode=='RGBA' else None)
  bbox=dr.textbbox((0,0),title,font=font)
  dr.text((cx-(bbox[2]-bbox[0])//2,515),title,font=font,fill=(20,38,65))
  subtitle=['Original 1024 × 1024','Ansigt + Dannebrog + lyd','Android 13+ dynamisk tema'][i]
  bb=dr.textbbox((0,0),subtitle,font=small)
  dr.text((cx-(bb[2]-bb[0])//2,565),subtitle,font=small,fill=(81,96,113))
canvas.save(out/'sprog_appen_icon_v3_preview.png',optimize=True)

print("Rebuilt adaptive, monochrome and previews from assets/icon/app_icon.png")
