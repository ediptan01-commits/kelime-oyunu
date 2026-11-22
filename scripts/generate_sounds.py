import math,os,struct,wave
os.makedirs("assets/sounds",exist_ok=True)
N=22050
def make(name,duration,tones):
 out=[]
 for i in range(int(N*duration)):
  t=i/N;freq=tones[min(int(t/duration*len(tones)),len(tones)-1)]
  sample=.28*math.sin(2*math.pi*freq*t)*min(1,t/.009)*math.exp(-3.8*t/duration)
  out.append(struct.pack("<h",int(max(-1,min(1,sample))*32767)))
 with wave.open("assets/sounds/"+name+".wav","wb") as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(N);w.writeframes(b"".join(out))
make("tap",.08,[660])
make("button",.12,[430,620])
make("error",.26,[265,190])
make("hint",.30,[490,660,880])
make("success",.48,[523,659,784])
make("complete",.88,[523,659,784,1047])
