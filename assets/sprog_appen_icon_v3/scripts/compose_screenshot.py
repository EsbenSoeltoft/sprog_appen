#!/usr/bin/env python3
"""Create a real Google Play screenshot using a branded overlay and an actual app capture.
Usage: python scripts/compose_screenshot.py actual_capture.png 01 output.png
       python scripts/compose_screenshot.py --tablet actual_capture.png output.png
Requires: pip install pillow
No fake screenshots generated: actual capture is mandatory.
"""
from pathlib import Path
from PIL import Image, ImageOps
import argparse
p=argparse.ArgumentParser()
p.add_argument('input',type=Path,help='Actual screen capture from Android emulator/device')
p.add_argument('template_or_output',help='Phone template 01,02,03,04 (omit for tablet)')
p.add_argument('output',type=Path,nargs='?')
p.add_argument('--tablet',action='store_true',help='Use tablet landscape template')
a=p.parse_args()
root=Path(__file__).resolve().parents[1]
if a.tablet:
    if a.output is not None:p.error('tablet mode: pass only capture and output path')
    template=root/'play_store/screenshots/templates/tablet_landscape_overlay_2560x1600.png'
    dest=Path(a.template_or_output)
    x,y,w,h=400,410,1760,1100
else:
    if a.template_or_output not in {'01','02','03','04'}:p.error('Choose phone template 01, 02, 03, or 04')
    if a.output is None:p.error('Pass an output PNG path')
    template=root/f'play_store/screenshots/templates/phone_{a.template_or_output}_overlay_1080x1920.png'
    dest=a.output
    x,y,w,h=144,358,792,1408
if not a.input.is_file():p.error('Input screenshot not found')
shot=Image.open(a.input).convert('RGB')
if abs(shot.width/shot.height-w/h)>0.01:
    print('Warning: screenshot aspect ratio differs from template; adding borders instead of cropping')
    sized=ImageOps.contain(shot,(w,h),Image.Resampling.LANCZOS)
    image=Image.new('RGB',(w,h),(9,12,50))
    image.paste(sized,((w-sized.width)//2,(h-sized.height)//2))
else:
    image=shot.resize((w,h),Image.Resampling.LANCZOS)
    
base=Image.new('RGBA',Image.open(template).size,(9,12,50,255))
base.paste(image,(x,y))
base.alpha_composite(Image.open(template).convert('RGBA'))
dest.parent.mkdir(parents=True,exist_ok=True)
base.convert('RGB').save(dest,optimize=True)
print('Created',dest)
