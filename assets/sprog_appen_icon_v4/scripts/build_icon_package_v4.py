#!/usr/bin/env python3
"""Reproduce Sprog Appen v4 assets from the approved green speech-bubble image.

Requirements: Pillow, numpy. Run in any directory:
    python3 scripts/build_icon_package_v4.py

The approved drawing is not redrawn. Foreground layers are extracted only by
matting the supplied raster master; variants use its original composition.
"""
from pathlib import Path
import hashlib, json, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'source' / 'sammensat_taleboble_gron_v1_original.png'
ICON = ROOT / 'assets' / 'icon'
PLAY = ROOT / 'play_store'
PRE = ROOT / 'android_reference'
for directory in [ICON, PLAY, PLAY/'screenshots'/'templates', PLAY/'screenshots'/'previews', PLAY/'extra', PRE]:
    directory.mkdir(parents=True, exist_ok=True)
R = Image.Resampling.LANCZOS
PALETTE = {'primary':'#056B5C', 'base':'#24685B','dark':'#005145','mint':'#A0F2DE','cream':'#F8F9F5'}

def font(size:int,bold=False):
    if bold:
        candidates = ['/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', '/usr/share/fonts/truetype/lato/Lato-Bold.ttf']
    else:
        candidates = ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', '/usr/share/fonts/truetype/lato/Lato-Regular.ttf']
    f = next((p for p in candidates if Path(p).exists()), None)
    if not f: raise RuntimeError('No system font available for feature graphic')
    return ImageFont.truetype(f, size)

def rgb(hexcolor):return tuple(int(hexcolor[i:i+2], 16) for i in (1,3,5))

# Source is an approved, unchanged 1254 x 1254 image. Only resampling for delivery.
original=Image.open(SRC).convert('RGB')
master=original.resize((1024,1024),R)
master.save(ICON/'app_icon.png', optimize=True)
master.resize((512,512),R).convert('RGBA').save(PLAY/'app_icon_512x512.png', optimize=True)

# Derive a transparent foreground from the ORIGINAL artwork, not another generated design.
# The image's paper/teal objects have lighter color than its deep green field.
a=np.array(original).astype(np.float32)
rr,gg,bb=[a[:,:,i] for i in range(3)]
y,x=np.mgrid[0:original.height,0:original.width]
bright_r=np.clip((rr-10)/28,0,1)
bright_g=np.clip((gg-90)/24,0,1)
# Low alpha on diffuse edges; paper & teal retain their existing colors and shading.
score=np.maximum(bright_r,bright_g)
# Central original speech bubble is circular with a small tail (also part of the drawing).
rad=np.sqrt(((x-612)/440)**2+((y-590)/447)**2)
geom=np.clip((1.035-rad)/0.075,0,1)
# Tail is a tapered part of the same source image. A soft geometric mask prevents
# the outer dark-green icon backing from being copied into the foreground.
tail=Image.new('L',original.size,0)
td=ImageDraw.Draw(tail)
td.polygon([(685,914),(801,914),(877,1024),(905,1110),(852,1105),(744,1022),(698,970)],fill=255)
tail=tail.filter(ImageFilter.GaussianBlur(9))
geom=np.maximum(geom, np.asarray(tail, dtype=np.float32)/255)
alpha=np.uint8(np.clip(score*geom*255,0,255))
# Remove isolated noisy background while keeping the interior green pieces of the bubble.
alpha=Image.fromarray(alpha,'L').filter(ImageFilter.GaussianBlur(0.8))
subject=original.convert('RGBA');subject.putalpha(alpha)
subject.save(ROOT/'source'/'speech_bubble_isolated_from_original.png',optimize=True)

# Android adaptive layers use the Android safe zone (66dp in a 108dp canvas).
# Full original image is scaled, making the largest part of the artwork about 53%
# of the canvas. No additional foreground padding is applied by the Flutter plugin.
S=1024
subject_side=770
fg=Image.new('RGBA',(S,S),(0,0,0,0))
scaled=subject.resize((subject_side,subject_side),R)
fg.alpha_composite(scaled,((S-subject_side)//2,(S-subject_side)//2))
fg.save(ICON/'adaptive_foreground.png',optimize=True)

# Soft green background uses only the agreed palette, no new illustration.
yy,xx=np.mgrid[0:S,0:S]
base=np.array(rgb(PALETTE['dark']),dtype=float)
primary=np.array(rgb(PALETTE['primary']),dtype=float)
radial=np.clip(.27+0.65*(1-np.sqrt(((xx-500)/790)**2+((yy-560)/790)**2)),0,1)
bg_np=(base[None,None,:]*(1-radial[:,:,None])+primary[None,None,:]*radial[:,:,None]).astype('uint8')
bg=Image.fromarray(bg_np,'RGB')
bg.save(ICON/'adaptive_background.png', optimize=True)

# Theme icon: exact source silhouette, white pixels with coverage as alpha.
# Slight texture separation remains, but Android will supply the foreground tint.
# The dark-green interior is a negative space in the original composition;
# exclude it so Android themed icons show the interlocking PAPER pieces,
# rather than an undifferentiated dark circular disk.
fg_arr=np.asarray(fg).astype(np.float32)
light_piece=np.clip((fg_arr[:,:,0]-13)/25.,0,1)
mono_alpha=np.clip(fg_arr[:,:,3]*np.power(light_piece,0.72),0,255)
mono_alpha=np.uint8(mono_alpha)
mono=Image.new('RGBA',(S,S),(255,255,255,0))
mono.putalpha(Image.fromarray(mono_alpha,'L'))
mono.save(ICON/'adaptive_monochrome.png',optimize=True)

# Flutter generates all Android mipmaps. These are reference PNGs, not runtime copies.
for dpi,dim in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    master.resize((dim,dim),R).save(PRE/f'ic_launcher_{dpi}_{dim}.png',optimize=True)

composite=Image.alpha_composite(bg.convert('RGBA'),fg)
def system_mask(kind, size=S):
    mask=Image.new('L',(size,size),0);draw=ImageDraw.Draw(mask)
    if kind=='circle':draw.ellipse((0,0,size-1,size-1),fill=255)
    elif kind=='squircle':draw.rounded_rectangle((3,3,size-4,size-4),radius=228,fill=255)
    elif kind=='square':draw.rectangle((0,0,size-1,size-1),fill=255)
    return mask
for kind in ['circle','squircle','square']:
    c=composite.copy();c.putalpha(system_mask(kind));c.resize((512,512),R).save(PRE/f'adaptive_{kind}_preview.png',optimize=True)
for kind,fgcolor,bgcolor in [('light','#005145','#A0F2DE'),('dark','#D4FAEF','#005145')]:
    tinted=Image.new('RGBA',(S,S),rgb(fgcolor)+(0,));tinted.putalpha(mono.getchannel('A'))
    result=Image.new('RGBA',(S,S),rgb(bgcolor)+(255,));result.alpha_composite(tinted)
    result.putalpha(system_mask('circle'))
    result.resize((512,512),R).save(PRE/f'monochrome_{kind}_preview.png',optimize=True)

# A branded Play Store feature graphic. Original artwork (rather than an alternative
# logo) appears as a freestanding speech mark on the right, with whitespace left
# for store text; no artificial app UI or screenshot is presented.
def marketing_background(w,h):
    xx,yy=np.meshgrid(np.linspace(0,1,w),np.linspace(0,1,h))
    blend=np.clip(.15+.44*xx+.12*(1-yy),0,1)
    c0=np.array(rgb(PALETTE['dark'])); c1=np.array(rgb(PALETTE['primary']))
    pix=np.uint8(c0[None,None,:]*(1-blend[:,:,None])+c1[None,None,:]*blend[:,:,None])
    return Image.fromarray(pix,'RGB')

def feature(w,h,with_text=True):
    b=marketing_background(w,h).convert('RGBA')
    dr=ImageDraw.Draw(b)
    scale=h/500
    # large, subtle decorations that echo the interlocking speech shapes
    for i in range(3):
        x0=int(w*(.63+.085*i)); y0=int(h*(.14+.12*i));
        x1=x0+int(h*.78); y1=y0+int(h*.78)
        dr.arc((x0,y0,x1,y1), 200,330,fill=(37,129,114,255),width=max(4,int(10*scale)))
    # Show the approved central subject with its paper texture, no rounded-square edge.
    subj=subject.copy()
    side=int(h*.98)
    art=subj.resize((side,side),R)
    # The logo's source object does not reach left edge, leaving room to breathe.
    at=(int(w*.525), (h-side)//2)
    b.alpha_composite(art,at)
    if with_text:
        xpad=int(55*scale)
        dr=ImageDraw.Draw(b)
        # Mint accent stripe and natural Danish typography.
        dr.rounded_rectangle((xpad,int(75*scale),xpad+int(68*scale),int(82*scale)),radius=int(4*scale),fill=PALETTE['mint'])
        dr.text((xpad,int(115*scale)), 'Sprog Appen',font=font(int(58*scale),True),fill=PALETTE['cream'])
        dr.text((xpad,int(215*scale)), 'Fra lyd til ord',font=font(int(33*scale),True),fill=PALETTE['mint'])
        dr.text((xpad,int(322*scale)), 'Lyt  ·  Lær  ·  Leg',font=font(int(25*scale)),fill=PALETTE['cream'])
    return b.convert('RGB')
feature(1024,500).save(PLAY/'feature_graphic_1024x500.png',optimize=True)
feature(1024,500,False).save(PLAY/'feature_graphic_textfree_1024x500.png',optimize=True)
feature(1200,630).save(PLAY/'extra'/'social_banner_1200x630.png',optimize=True)

# Screenshot templates are NOT screenshots. They have transparent areas for real
# captures and are intentionally named NOT_FOR_UPLOAD in their mock previews.
captions=[('01','Lyt til dansk','Træn udtale i dit tempo'),('02','Udforsk lydene','Lær med tydelige eksempler'),('03','Øv og gentag','Bliv tryg ved sproget'),('04','Fra lyd til ord','Byg videre på det, du lærer')]
def phone_template(num,heading,subheading):
    w,h=1080,1920
    ov=marketing_background(w,h).convert('RGBA')
    d=ImageDraw.Draw(ov)
    d.rounded_rectangle((74,112,158,122),radius=5,fill=PALETTE['mint'])
    d.text((74,160),heading,font=font(59,True),fill=PALETTE['cream'])
    d.text((74,246),subheading,font=font(29),fill=PALETTE['mint'])
    # Main phone screenshot slot, 792x1408 == exact 9:16 ratio.
    box=(144,368,936,1776)
    ov.paste(Image.new('RGBA',(box[2]-box[0],box[3]-box[1]),(0,0,0,0)),(box[0],box[1]))
    d=ImageDraw.Draw(ov)
    d.rounded_rectangle((box[0]-4,box[1]-4,box[2]+4,box[3]+4),radius=25,outline=PALETTE['mint'],width=4)
    d.text((74,1835),'SPROG APPEN',font=font(23,True),fill=PALETTE['mint'])
    ov.save(PLAY/'screenshots'/'templates'/f'phone_{num}_overlay_1080x1920.png',optimize=True)
    pv=Image.new('RGBA',(w,h),rgb(PALETTE['cream'])+(255,))
    ghost=Image.new('RGBA',(792,1408),rgb(PALETTE['cream'])+(255,))
    gd=ImageDraw.Draw(ghost)
    gd.text((80,550),'INDSÆT ET ÆGTE',font=font(43,True),fill=PALETTE['primary'])
    gd.text((80,625),'SKÆRMBILLEDE',font=font(47,True),fill=PALETTE['primary'])
    gd.text((80,722),'Kun skabelon',font=font(32),fill=PALETTE['base'])
    pv.alpha_composite(ghost,(144,368));pv.alpha_composite(ov)
    pv.convert('RGB').save(PLAY/'screenshots'/'previews'/f'phone_{num}_preview_NOT_FOR_UPLOAD.png',optimize=True)
for fields in captions:phone_template(*fields)

# Visual proof: show standard at realistic 48px, Play icon, adaptive mask and themed.
PW,PH=1560,1465
sheet=Image.new('RGB',(PW,PH),rgb(PALETTE['cream']))
d=ImageDraw.Draw(sheet)
d.text((62,40),'SPROG APPEN  /  IKONPAKKE V4',font=font(43,True),fill=PALETTE['dark'])
d.text((62,108),'Samme sammensatte taleboble i alle Android-varianter',font=font(24),fill=PALETTE['base'])
parts=[('Standardikon',master),('Adaptivt ikon',Image.open(PRE/'adaptive_circle_preview.png')),('Monokromt ikon',Image.open(PRE/'monochrome_light_preview.png'))]
for i,(title,im) in enumerate(parts):
    left=62+i*505
    d.rounded_rectangle((left,185,left+454,714),radius=24,fill='white')
    d.text((left+28,207),title,font=font(28,True),fill=PALETTE['dark'])
    item=im.convert('RGBA').resize((402,402),R)
    sheet.paste(item,(left+26,273),item)
    small=im.resize((48,48),R).convert('RGBA')
    sheet.paste(small,(left+345,214),small)
d.rounded_rectangle((62,751,1492,1408),radius=24,fill='white')
d.text((88,765),'Google Play  /  feature graphic',font=font(27,True),fill=PALETTE['dark'])
banner=Image.open(PLAY/'feature_graphic_1024x500.png').resize((1160,566),R)
sheet.paste(banner,(194,824))
sheet.save(ROOT/'sprog_appen_icon_v4_preview.png',optimize=True)

# Automated format validation and hash manifest.
checks={
'assets/icon/app_icon.png':((1024,1024),'RGB'),
'assets/icon/adaptive_foreground.png':((1024,1024),'RGBA'),
'assets/icon/adaptive_background.png':((1024,1024),'RGB'),
'assets/icon/adaptive_monochrome.png':((1024,1024),'RGBA'),
'play_store/app_icon_512x512.png':((512,512),'RGBA'),
'play_store/feature_graphic_1024x500.png':((1024,500),'RGB'),
'play_store/feature_graphic_textfree_1024x500.png':((1024,500),'RGB'),
}
for name,(dims,mode) in checks.items():
    fp=ROOT/name;im=Image.open(fp)
    assert im.size==dims,(name,im.size)
    assert im.mode==mode,(name,im.mode)
assert (PLAY/'app_icon_512x512.png').stat().st_size<=1024*1024, 'Play icon >1MiB'
assert Image.open(ICON/'adaptive_foreground.png').getpixel((0,0))[3]==0
assert Image.open(ICON/'adaptive_monochrome.png').getpixel((0,0))[3]==0
manifest=[]
for p in sorted(ROOT.rglob('*.png')):
    im=Image.open(p)
    manifest.append({'file':str(p.relative_to(ROOT)),'size':list(im.size), 'mode':im.mode,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'manifest.json').write_text(json.dumps({'name':'Sprog Appen','version':'4','master_source':'source/sammensat_taleboble_gron_v1_original.png','palette':PALETTE,'assets':manifest},indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print('Validated',len(manifest),'PNG files', 'Play icon', (PLAY/'app_icon_512x512.png').stat().st_size,'bytes')
