import json,os,re,sys,time,urllib.parse,urllib.request
places=[
("Sultanahmet Camii","Sultan Ahmed Mosque Istanbul"),
("Süleymaniye Camii","Suleymaniye Mosque Istanbul"),
("Ortaköy Camii","Ortakoy Mosque Istanbul"),
("Ayasofya","Hagia Sophia Istanbul"),
("Galata Köprüsü","Galata Bridge Istanbul"),
("Fatih Camii","Fatih Mosque Istanbul"),
("Dolmabahçe Sarayı","Dolmabahce Palace Istanbul"),
("Galata Kulesi","Galata Tower Istanbul"),
("Yeni Camii","New Mosque Eminonu Istanbul"),
("Boğaziçi Köprüsü","Bosphorus Bridge Istanbul"),
("Topkapı Sarayı","Topkapi Palace Istanbul"),
("Rumeli Hisarı","Rumeli Fortress Istanbul"),
("Mihrimah Sultan Camii","Mihrimah Sultan Mosque Istanbul"),
("Kız Kulesi","Maiden's Tower Istanbul"),
("Eyüp Sultan Camii","Eyup Sultan Mosque Istanbul"),
("Fatih Sultan Mehmet Köprüsü","Fatih Sultan Mehmet Bridge Istanbul"),
("Beylerbeyi Sarayı","Beylerbeyi Palace Istanbul"),
("Rüstem Paşa Camii","Rustem Pasha Mosque Istanbul")]
os.makedirs("assets/backgrounds",exist_ok=True)
used=set();credits=[]
def load(url):
 r=urllib.request.Request(url,headers={"User-Agent":"KelimeBulAndroid/1.1 contact info on GitHub","Accept":"*/*"})
 with urllib.request.urlopen(r,timeout=60) as resp:return resp.read()
def clean(s):return re.sub(r"<[^>]+>","",s or "").strip()
for index,(place,q) in enumerate(places):
 result=None
 for attempt in range(3):
  try:
   params={"action":"query","generator":"search","gsrsearch":q+" filetype:bitmap","gsrnamespace":6,"gsrlimit":20,"prop":"imageinfo","iiprop":"url|mime|size|extmetadata","iiurlwidth":1000,"format":"json","formatversion":2}
   doc=json.loads(load("https://commons.wikimedia.org/w/api.php?"+urllib.parse.urlencode(params)))
   items=[]
   for page in doc.get("query",{}).get("pages",[]):
    info=(page.get("imageinfo") or [{}])[0];meta=info.get("extmetadata") or {}
    lic=clean((meta.get("LicenseShortName") or {}).get("value",""))
    allowed=lic.lower().startswith(("cc0","cc by 2","cc by 3","cc by 4")) or "public domain" in lic.lower()
    title=page.get("title","")
    if not allowed or title in used or info.get("mime") not in ("image/jpeg","image/png") or info.get("width",0)<700:continue
    if re.search("painting|engraving|watercolor|drawing|illustration|portrait|interior|people entering|views from",title,re.I):continue
    if "mosque" in q.lower() and not re.search("mosque|camii|cami",title,re.I):continue
    u=info.get("thumburl") or info.get("url")
    if not u:continue
    terms=[x for x in re.findall(r"[a-z]+",q.lower()) if x not in ("mosque","bridge","istanbul","palace")]
    score=sum(10 for x in terms if x in title.lower())
    if "istanbul" in title.lower():score+=2
    if re.search("map|painting|logo|diagram|interior|engraving",title,re.I):score-=20
    items.append((score,title,u,lic,clean((meta.get("Artist") or {}).get("value","")),clean((meta.get("LicenseUrl") or {}).get("value",""))))
   items.sort(reverse=True)
   for score,title,u,lic,artist,lurl in items:
    try:
     data=load(u)
     if not 15000<len(data)<7000000:continue
     ext="jpg" if data[:2]==b"\xff\xd8" else "png" if data[:4]==b"\x89PNG" else None
     if not ext:continue
     filename=f"assets/backgrounds/level_{index+1:02}.{ext}"
     with open(filename,"wb") as fp:fp.write(data)
     used.add(title);result={"number":index+1,"place":place,"file":filename,"title":title,"author":artist,"license":lic,"licenseUrl":lurl,"source":"https://commons.wikimedia.org/wiki/"+urllib.parse.quote(title.replace(" ","_"))}
     break
    except Exception as e:print("image rejected",title,str(e),flush=True)
   if result:break
  except Exception as e:print("Commons attempt",attempt,place,str(e),flush=True)
  time.sleep(12*(attempt+1))
 if result is None:sys.exit("No appropriately licensed image found for "+place)
 credits.append(result);time.sleep(3);print(f'{index+1}/18 {place} -> {result["title"]} [{result["license"]}]',flush=True)
with open("assets/backgrounds/credits.json","w",encoding="utf8") as fp:json.dump(credits,fp,ensure_ascii=False,indent=2)
assert len(used)==18
