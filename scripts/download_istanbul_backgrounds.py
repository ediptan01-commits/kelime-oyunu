#!/usr/bin/env python3
"""18 distinct genuine Istanbul photographs, downloaded from Unsplash image CDN.
Photo pages and Unsplash License recorded alongside assets.
"""
import json,os,time,urllib.request,sys
photos=[["Sultanahmet Camii","photo-1793904468830-7bdc0b8717d3","kxJXRI5i-vU"],["Süleymaniye Camii","photo-1789111212624-075efc7e8dc2","B2lgGJ3l_rA"],["Ortaköy Camii","photo-1778083403279-9332011e1a7e","gXdZ87dK254"],["Ayasofya","photo-1777985329881-d2240f085bca","Tlq23akfSOc"],["Galata Kulesi","photo-1793296600506-c7155e843e6e","knh6-CMHs5M"],["Sultanahmet ve Haliç","photo-1730039252032-9e8d6ed588d0","mwrDmnsVkMc"],["Dolmabahçe Sarayı","photo-1665465651786-988659be475c","QLLZhLf27QE"],["Galata Manzarası","photo-1756760910079-3952b792b0ef","HRhS-mMExhE"],["Boğaz ve Camiler","photo-1778238489194-5db8f4216719","HlOcBSZ71R0"],["Boğaziçi Köprüsü","photo-1794944474505-58f9febad3ef","6jAkoGp9lfI"],["Topkapı Sarayı","photo-1794086977622-330a483146e8","yWu2CV5WlBc"],["İstanbul Tarihi Kıyıları","photo-1752115178206-9561a29012ba","6YCzJ6hq99U"],["Ortaköy Sahili","photo-1759347171756-d54d81f17f9d","5fKKNEmM4nM"],["Kız Kulesi","photo-1766826236680-dc2f5529bac5","oX244DoPdb4"],["Ayasofya Meydanı","photo-1655832975303-9c474a06ed56","BnhI8kYMpzs"],["Boğaz Köprüsü Gece","photo-1608677662924-8b83590f474e","9HYZQQRPwVM"],["Boğaziçi Gün Batımı","photo-1657358441587-2199ae8c790d","YIllgmj50Nc"],["İstanbul Camileri","photo-1789111211915-78914fc655ef","q3JSX6H4osg"]]
os.makedirs("assets/backgrounds",exist_ok=True)
credits=[]
for i,(place,image,photo_id) in enumerate(photos,1):
 url="https://images.unsplash.com/"+image+"?auto=format&fit=crop&w=900&h=1200&q=74&fm=jpg"
 data=None;last_error=None
 for attempt in range(4):
  try:
   req=urllib.request.Request(url,headers={"User-Agent":"Mozilla/5.0","Accept":"image/jpeg,image/*"})
   with urllib.request.urlopen(req,timeout=40) as res: blob=res.read()
   if blob[:2]!=b"\xff\xd8" or len(blob)<25000:raise ValueError("Invalid JPEG: "+str(len(blob)))
   data=blob;break
  except Exception as exc:
   last_error=exc;print("retry",i,attempt,str(exc)[:100],flush=True);time.sleep(3*(attempt+1))
 if data is None:sys.exit("Failed to download "+place+": "+str(last_error))
 path=f"assets/backgrounds/level_{i:02}.jpg"
 with open(path,"wb") as out:out.write(data)
 credits.append({"level":i,"location":place,"source":"https://unsplash.com/photos/"+photo_id,"license":"Unsplash License","license_url":"https://unsplash.com/license"})
 print(f"{i:02}/18 {place} {len(data)} bytes",flush=True)
assert len(set(p[1] for p in photos))==18
with open("assets/backgrounds/credits.json","w",encoding="utf8") as out:json.dump(credits,out,ensure_ascii=False,indent=2)
