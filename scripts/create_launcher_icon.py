#!/usr/bin/env python3
"""Create a navy/gold launcher icon matching Kelime Bul's UI, all resources local."""
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import os
N=512
im=Image.new("RGB",(N,N));p=im.load()
for y in range(N):
 for x in range(N):
  dx=(x-N*.5)/N;dy=(y-N*.42)/N
  glow=max(0,1-(dx*dx+dy*dy)*1.9)
  p[x,y]=(int(3+7*glow),int(20+30*glow),int(44+58*glow))
d=ImageDraw.Draw(im)
gold=(255,205,92);ivory=(255,248,226);navy=(3,27,58)
d.rounded_rectangle((18,18,494,494),radius=84,outline=gold,width=12)
d.ellipse((125,55,387,317),outline=gold,width=12)
try:
 big="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
 font=ImageFont.truetype(big,74)
 title=ImageFont.truetype(big,68)
 small=ImageFont.truetype(big,74)
except Exception:font=ImageFont.load_default();title=font;small=font
for letter,x,y in [("K",256,107),("E",150,212),("L",362,212),("İ",256,315)]:
 r=52
 d.ellipse((x-r+3,y-r+6,x+r+3,y+r+6),fill=(109,65,19))
 d.ellipse((x-r,y-r,x+r,y+r),fill=ivory,outline=gold,width=7)
 b=d.textbbox((0,0),letter,font=font)
 d.text((x-(b[2]-b[0])/2,y-(b[3]-b[1])/2-b[1]),letter,fill=navy,font=font)
d.polygon([(256,186),(265,202),(283,210),(265,218),(256,235),(247,218),(229,210),(247,202)],fill=gold)
d.rounded_rectangle((72,385,440,473),radius=27,fill=(153,19,34),outline=gold,width=7)
b=d.textbbox((0,0),"BUL",font=small)
d.text(((512-(b[2]-b[0]))/2,390-b[1]),"BUL",font=ivory,font=small)
for name,size in [("mipmap-mdpi",48),("mipmap-hdpi",72),("mipmap-xhdpi",96),("mipmap-xxhdpi",144),("mipmap-xxxhdpi",192)]:
 folder="android/app/src/main/res/"+name
 os.makedirs(folder,exist_ok=True)
 im.resize((size,size),Image.Resampling.LANCZOS).save(folder+"/ic_launcher.png")
os.makedirs("assets/branding",exist_ok=True)
im.save("assets/branding/kelime_bul_icon.png")
