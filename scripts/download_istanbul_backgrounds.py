#!/usr/bin/env python3
"""Download 18 individual Istanbul architectural photographs licensed by Unsplash.
Each source is a specific free photo page, not Unsplash+ search. Generates attribution.
"""
import html,json,os,re,time,urllib.parse,urllib.request,sys
photos=[
("Sultanahmet Camii","ttuqgwJuvb4"),
("Süleymaniye Camii","B2lgGJ3l_rA"),
("Ortaköy Camii","gXdZ87dK254"),
("Ayasofya","Tlq23akfSOc"),
("Galata Kulesi","knh6-CMHs5M"),
("Sultanahmet ve Haliç","mwrDmnsVkMc"),
("Dolmabahçe Sarayı","QLLZhLf27QE"),
("Galata Manzarası","HRhS-mMExhE"),
("Boğaz ve Camiler","HlOcBSZ71R0"),
("Boğaziçi Köprüsü","6jAkoGp9lfI"),
("Topkapı Sarayı","yWu2CV5WlBc"),
("İstanbul Hisarları","6YCzJ6hq99U"),
("Ortaköy Sahili","5fKKNEmM4nM"),
("Kız Kulesi","oX244DoPdb4"),
("İstanbul Tarihi Yarımada","BnhI8kYMpzs"),
("Boğaz Köprüsü Gece","9HYZQQRPwVM"),
("Boğaziçi Gün Batımı","YIllgmj50Nc"),
("İstanbul Camileri","q3JSX6H4osg"),
]
os.makedirs("assets/backgrounds",exist_ok=True)
credits=[]
def get(url):
  req=urllib.request.Request(url,headers={"User-Agent":"Mozilla/5.0 (compatible; KelimeBul/1.1; offline puzzle)","Accept":"text/html,image/*"})
  with urllib.request.urlopen(req,timeout=45) as r: return r.read()
for i,(place,id) in enumerate(photos,1):
  page=f"https://unsplash.com/photos/{id}"
  raw=None
  for trial in range(3):
    try:
      raw=get(page).decode("utf-8","replace")
      break
    except Exception as ex:
      print("Page retry",i,trial,str(ex)[:100],flush=True)
      time.sleep(3*(trial+1))
  if raw is None:sys.exit(f"Cannot retrieve free photo page {place}: {page}")
  patterns=[r'<meta[^>]+property="og:image"[^>]+content="([^"]+)"',r'<meta[^>]+content="([^"]+)"[^>]+property="og:image"']
  match=next((m for p in patterns if (m:=re.search(p,raw))),None)
  if not match:sys.exit(f"No og:image for {place}")
  img=html.unescape(match.group(1))
  if "images.unsplash.com" not in img:sys.exit(f"Unexpected image host {place} {img[:120]}")
  img=img.split("?")[0]+"?auto=format&fit=crop&w=900&h=1200&q=76&fm=jpg"
  result=None
  for trial in range(4):
    try:
      data=get(img)
      if data[:2]!=b"\xff\xd8" or len(data)<25000:raise ValueError(f"Bad image data {len(data)}")
      result=data;break
    except Exception as ex:
      print("Image retry",i,trial,str(ex)[:120],flush=True);time.sleep(3*(trial+1))
  if result is None:sys.exit(f"Could not download {place}: {img[:120]}")
  filename=f"assets/backgrounds/level_{i:02}.jpg"
  with open(filename,"wb") as f:f.write(result)
  artist=re.search(r'"author":\s*\{[^}]*"name":\s*"([^"]+)"',raw)
  credits.append({"level":i,"place":place,"photo":page,"image_id":id,"author":artist.group(1) if artist else "Unsplash photographer (see source link)","license":"Unsplash License","license_url":"https://unsplash.com/license"})
  print(f"{i:02}/18 {place} downloaded {len(result)} bytes",flush=True)
  time.sleep(.4)
assert len({x["image_id"] for x in credits})==18
with open("assets/backgrounds/credits.json","w",encoding="utf8") as f:json.dump(credits,f,ensure_ascii=False,indent=2)
