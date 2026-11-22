"""Pinned freely licensed Istanbul photos. Avoids Commons search rate limits."""
import hashlib,json,os,sys,time,urllib.parse,urllib.request
items=[
("Sultanahmet Camii","New Mosque (Foreground) and Sultan Ahmed Mosque (Background), Istanbul, Türkiye.jpg","CC0",""),
("Süleymaniye Camii","Süleymaniye Mosque, Istanbul, 20260606 0805 1307.jpg","CC BY 4.0","https://creativecommons.org/licenses/by/4.0/"),
("Ortaköy Camii","Ortaköy Square and Mosque Istanbul Turkey.jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Ayasofya","Hagia Sophia in Istanbul 03.01.2015.jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Galata Köprüsü","Under the Galata Bridge, Istanbul (6165295969).jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Fatih Camii","Istanbul Fatih Mosque (54527265756).jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Dolmabahçe Sarayı","Dolmabahce-Palace-Istanbul.jpg","CC BY 4.0","https://creativecommons.org/licenses/by/4.0/"),
("Galata Kulesi","Views from Galata Tower - Galata Kulesi - Christea Turris - Istanbul, Turkey (10583413774).jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Yeni Camii","New Mosque, Istanbul.jpg","CC BY 2.0","https://creativecommons.org/licenses/by/2.0/"),
("Boğaziçi Köprüsü","The First Bosphorus Bridge (1973) in Istanbul.jpg","CC BY 4.0","https://creativecommons.org/licenses/by/4.0/"),
("Topkapı Sarayı","Topkapi Palace, Istanbul.jpg","CC BY-SA 4.0","https://creativecommons.org/licenses/by-sa/4.0/"),
("Rumeli Hisarı","Rumeli Fortress Istanbul Turkey (216145221).jpeg","CC BY 3.0","https://creativecommons.org/licenses/by/3.0/"),
("Mihrimah Sultan Camii","Mihrimah Sultan Mosque (Üsküdar) (1).jpg","CC BY-SA 4.0","https://creativecommons.org/licenses/by-sa/4.0/"),
("Kız Kulesi","Maiden's Tower (Istanbul).jpg","Public domain",""),
("Eyüp Sultan Camii","Eyüp Sultan Mosque.jpg","CC BY-SA 4.0","https://creativecommons.org/licenses/by-sa/4.0/"),
("Fatih Sultan Mehmet Köprüsü","Fatih sultan mehmet koprüsü - panoramio.jpg","CC BY 3.0","https://creativecommons.org/licenses/by/3.0/"),
("Beylerbeyi Sarayı","People entering through the Bosporus Gate, Beylerbeyi Palace, Istanbul, 2008.jpg","CC0",""),
("Rüstem Paşa Camii","Istanbul - Rüstem-Pascha-Moschee - panoramio (cropped and retouched).jpg","CC BY-SA 3.0","https://creativecommons.org/licenses/by-sa/3.0/"),
]
def get(url):
 req=urllib.request.Request(url,headers={"User-Agent":"KelimeBul/1.1 (GitHub Android build; contact via GitHub)","Accept":"image/*"})
 with urllib.request.urlopen(req,timeout=50) as res:return res.read()
def url_for(name,thumb=True):
 file=name.replace(" ","_")
 md=hashlib.md5(file.encode("utf8")).hexdigest()
 base="https://upload.wikimedia.org/wikipedia/commons/"
 part=md[0]+"/"+md[:2]+"/"+urllib.parse.quote(file,safe="()'.,-")
 if thumb:return base+"thumb/"+part+"/960px-"+urllib.parse.quote(file,safe="()'.,-")
 return base+part
os.makedirs("assets/backgrounds",exist_ok=True)
credits=[]
for i,(place,filename,license,license_url) in enumerate(items,1):
 data=None;error=None
 for url in ["https://wsrv.nl/?"+urllib.parse.urlencode({"url":url_for(filename,False),"w":960,"output":"jpg"}),url_for(filename,True)]:
  for attempt in range(2):
   try:
    blob=get(url)
    if blob[:2]!=b"\xff\xd8" or len(blob)<10000:raise ValueError("invalid JPEG")
    data=blob;break
   except Exception as e:
    error=e;print("retry",i,attempt,type(e).__name__,str(e)[:90],flush=True)
    time.sleep(3*(attempt+1))
  if data:break
 if not data:sys.exit(f"Cannot fetch {place}, {filename}: {error}")
 with open(f"assets/backgrounds/level_{i:02}.jpg","wb") as fp:fp.write(data)
 credits.append({"level":i,"place":place,"file":filename,"author":"See original Commons file page",
                 "license":license,"licenseUrl":license_url,
                 "source":"https://commons.wikimedia.org/wiki/File:"+urllib.parse.quote(filename.replace(" ","_"))})
 print(f"{i:02}/18 {place}: {len(data)} bytes",flush=True)
 time.sleep(.3)
with open("assets/backgrounds/credits.json","w",encoding="utf8") as fp:json.dump(credits,fp,ensure_ascii=False,indent=2)
