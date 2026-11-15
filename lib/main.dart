import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(
    title: 'Kelime Bul',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xff167e92)),
    home: WordGame(prefs: prefs),
  ));
}

class Pack {
  final String name;
  final String letters;
  final List<String> words;
  const Pack(this.name, this.letters, this.words);
}

const packs = <Pack>[
  Pack('Gün Batımı Vadisi','KALEM',['KALEM','KALE','ELMA','ALEM','KEL','MAL']),
  Pack('Mercan Sahili','BALON',['BALON','BALO','OLAN','BAL','NAL','BOL']),
  Pack('Masal Bahçesi','MASAL',['MASAL','MASA','ASMA','ASLA','SAL','MAL']),
  Pack('Altın Kanyon','KARTAL',['KARTAL','TARAK','KARA','ARKA','KART','KAR']),
  Pack('Saklı Şelale','SEVDA',['SEVDA','VEDA','DEVA','SEDA','DEV','EDA']),
  Pack('Bilgelik Kulesi','KİTAP',['KİTAP','PATİ','KAP','KAT','KİP','TİP']),
  Pack('Zümrüt Orman','KAPLAN',['KAPLAN','KALAN','KANAL','ALAN','KAN','KAP']),
  Pack('Sisli Göl','SİNEK',['SİNEK','İNEK','ESİN','SİNE','KESİ','KİN']),
  Pack('Melodi Tepesi','KEMAN',['KEMAN','MEKAN','KAN','NAM','KAM']),
  Pack('Rüzgâr Limanı','ÇORAP',['ÇORAP','ÇARP','ÇAP','PAR','RAP']),
  Pack('Toprak Yolu','TOPRAK',['TOPRAK','ORTAK','PARK','KART','TOP','KAR']),
  Pack('Çınar Vadisi','ÇINAR',['ÇINAR','ÇIRA','NAR','ARI','ÇAR']),
  Pack('Beyaz Zirve','BİLEK',['BİLEK','BEL','BİL','KİL','İLE']),
  Pack('Kayıp Şehir','KARDEŞ',['KARDEŞ','KADER','KARE','ŞARK','KAR','ŞER']),
  Pack('Dostluk Adası','DOSTLUK',['DOSTLUK','DOST','DOLU','KUT','SOL','TOK']),
  Pack('Zafer Yolu','BAŞARI',['BAŞARI','BAŞ','AŞI','ARI','BAR','ARA']),
  Pack('Kurtuluş Kalesi','KURTAR',['KURTAR','KART','KUR','TUR','KAR','ART']),
  Pack('Usta Mutfağı','MUTFAK',['MUTFAK','KUMA','KAT','TAM','MUT']),
];

String pos(int x, int y) => x.toString() + ',' + y.toString();

class Slot {
  final String word;
  final int x, y;
  final bool vertical;
  const Slot(this.word, this.x, this.y, this.vertical);
  String cell(int i) => pos(x + (vertical ? 0 : i), y + (vertical ? i : 0));
}

class BoardData {
  final List<Slot> slots;
  final Map<String,String> cells;
  final int columns, rows;
  const BoardData(this.slots, this.cells, this.columns, this.rows);

  static BoardData make(List<String> words) {
    final sorted = List<String>.from(words)..sort((a,b) => b.length.compareTo(a.length));
    final placed = <Slot>[Slot(sorted.first,0,0,false)];
    Map<String,String> used() {
      final m = <String,String>{};
      for (final s in placed) {
        for (var i=0;i<s.word.length;i++) {m[s.cell(i)] = s.word[i];}
      }
      return m;
    }
    bool fits(Slot s) {
      final m=used();
      final before=pos(s.x-(s.vertical?0:1),s.y-(s.vertical?1:0));
      final after=pos(s.x+(s.vertical?0:s.word.length),s.y+(s.vertical?s.word.length:0));
      if(m.containsKey(before)||m.containsKey(after))return false;
      var crossed=0;
      for(var i=0;i<s.word.length;i++){
        final x=s.x+(s.vertical?0:i), y=s.y+(s.vertical?i:0), key=pos(x,y);
        if(m.containsKey(key)){
          if(m[key]!=s.word[i])return false;
          for(final old in placed){
            if(old.vertical!=s.vertical)continue;
            for(var j=0;j<old.word.length;j++){if(old.cell(j)==key)return false;}
          }
          crossed++;
        } else {
          final a=s.vertical?pos(x-1,y):pos(x,y-1);
          final b=s.vertical?pos(x+1,y):pos(x,y+1);
          if(m.containsKey(a)||m.containsKey(b))return false;
        }
      }
      return crossed>0;
    }
    for(final word in sorted.skip(1)){
      Slot? best;
      var bestScore=999999;
      for(final old in placed){
        for(var i=0;i<old.word.length;i++){
          for(var j=0;j<word.length;j++){
            if(old.word[i]!=word[j])continue;
            final cx=old.x+(old.vertical?0:i);
            final cy=old.y+(old.vertical?i:0);
            final vertical=!old.vertical;
            final next=Slot(word,cx-(vertical?0:j),cy-(vertical?j:0),vertical);
            if(!fits(next))continue;
            final all=[...placed,next];
            var minX=999,maxX=-999,minY=999,maxY=-999;
            for(final s in all){
              minX=math.min(minX,s.x); minY=math.min(minY,s.y);
              maxX=math.max(maxX,s.x+(s.vertical?0:s.word.length-1));
              maxY=math.max(maxY,s.y+(s.vertical?s.word.length-1:0));
            }
            final w=maxX-minX+1,h=maxY-minY+1;
            final score=w*h+(w-h).abs()*2;
            if(score<bestScore){best=next;bestScore=score;}
          }
        }
      }
      if(best!=null){
        placed.add(best);
      }else{
        final y=placed.map((s)=>s.y+(s.vertical?s.word.length-1:0)).reduce(math.max)+3;
        placed.add(Slot(word,0,y,false));
      }
    }
    final minX=placed.map((s)=>s.x).reduce(math.min),minY=placed.map((s)=>s.y).reduce(math.min);
    final clean=placed.map((s)=>Slot(s.word,s.x-minX,s.y-minY,s.vertical)).toList();
    final m=<String,String>{};
    var mx=0,my=0;
    for(final s in clean){
      for(var i=0;i<s.word.length;i++){
        final x=s.x+(s.vertical?0:i),y=s.y+(s.vertical?i:0);
        m[pos(x,y)]=s.word[i];mx=math.max(mx,x);my=math.max(my,y);
      }
    }
    return BoardData(clean,m,mx+1,my+1);
  }
}

class WordGame extends StatefulWidget {
  final SharedPreferences prefs;
  const WordGame({super.key,required this.prefs});
  @override
  State<WordGame> createState()=>_WordGameState();
}

class _WordGameState extends State<WordGame> {
  final rand=math.Random();
  late int level,coins,score;
  late BoardData board;
  List<String> wheel=[];
  final solved=<String>{}, revealed=<String>{}, picked=<int>[];
  bool pressed=false,dragged=false;
  String message='Harfleri sürükleyerek kelime oluştur.';
  Pack get pack=>packs[level];
  String get currentWord=>picked.map((i)=>wheel[i]).join();

  @override
  void initState(){
    super.initState();
    level=math.max(0,math.min(packs.length-1,widget.prefs.getInt('level')??0));
    coins=widget.prefs.getInt('coins')??120;
    score=widget.prefs.getInt('score')??0;
    loadLevel();
  }
  void loadLevel(){
    board=BoardData.make(pack.words);
    wheel=pack.letters.split('');
    solved..clear()..addAll(widget.prefs.getStringList('solved_'+level.toString())??[]);
    revealed..clear()..addAll(widget.prefs.getStringList('hints_'+level.toString())??[]);
    picked.clear();
    message='Harfleri sürükleyerek kelime oluştur.';
  }
  void save(){
    widget.prefs.setInt('level',level);
    widget.prefs.setInt('coins',coins);
    widget.prefs.setInt('score',score);
    widget.prefs.setStringList('solved_'+level.toString(),solved.toList());
    widget.prefs.setStringList('hints_'+level.toString(),revealed.toList());
  }
  int? hit(Offset p,double size){
    final mid=size/2,r=size*.355;var distance=1000.0;int? which;
    for(var i=0;i<wheel.length;i++){
      final a=-math.pi/2+2*math.pi*i/wheel.length;
      final target=Offset(mid+math.cos(a)*r,mid+math.sin(a)*r);
      final d=(target-p).distance;
      if(d<32&&d<distance){distance=d;which=i;}
    }
    return which;
  }
  void select(int i){if(!picked.contains(i)){setState(()=>picked.add(i));}}
  void submit(){
    if(picked.length<2)return;
    final word=currentWord;
    setState(()=>picked.clear());
    if(solved.contains(word)){setState(()=>message='Bu kelimeyi zaten buldun.');return;}
    if(!pack.words.contains(word)){setState(()=>message='Bu kelime bu bölümde yok.');return;}
    setState((){
      solved.add(word);coins+=12;score+=100;
      message='✨ '+word+' doğru! +100 puan, +12 altın';
    });
    save();
    if(solved.length==pack.words.length){
      Future.delayed(const Duration(milliseconds:500),(){if(mounted)complete();});
    }
  }
  void hint(){
    if(coins<35){setState(()=>message='İpucu için 35 altın gerekiyor.');return;}
    final shown=<String>{...revealed};
    for(final s in board.slots) {
      if(solved.contains(s.word)){for(var i=0;i<s.word.length;i++){shown.add(s.cell(i));}}
    }
    for(final s in board.slots){
      if(solved.contains(s.word))continue;
      for(var i=0;i<s.word.length;i++){
        if(shown.contains(s.cell(i)))continue;
        setState((){
          revealed.add(s.cell(i));coins-=35;message='💡 Bulmacada bir harf açıldı.';
        });
        save();return;
      }
    }
    setState(()=>message='Açılacak harf kalmadı.');
  }
  void complete(){
    showDialog<void>(
      context:context,barrierDismissible:false,
      builder:(ctx)=>AlertDialog(
        backgroundColor:const Color(0xfffff9e9),
        title:const Text('🏆 Rota Tamamlandı!',textAlign:TextAlign.center),
        content:Text(pack.words.length.toString()+' kelimeyi çözdün!\n+50 altın ödül seni bekliyor.',textAlign:TextAlign.center),
        actionsAlignment:MainAxisAlignment.center,
        actions:[FilledButton(
          onPressed:(){
            Navigator.pop(ctx);
            if(level+1>=packs.length){
              setState(()=>message='🎉 Bütün rotaları tamamladın!');
            }else{
              setState((){level++;coins+=50;loadLevel();});save();
            }
          },child:Text(level+1<packs.length?'Sonraki Rota →':'Harika!'),
        )],
      ),
    );
  }
  void openMap(){
    showModalBottomSheet<void>(
      context:context,showDragHandle:true,isScrollControlled:true,
      backgroundColor:const Color(0xfffffbf4),
      builder:(ctx)=>SafeArea(child:SizedBox(
        height:math.min(560,MediaQuery.sizeOf(ctx).height*.7),
        child:Column(children:[
          const Padding(padding:EdgeInsets.all(12),child:Text('🧭 Keşif Haritası',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900))),
          Expanded(child:ListView.builder(itemCount:packs.length,itemBuilder:(context,i)=>ListTile(
            title:Text(packs[i].name),leading:CircleAvatar(child:Text((i+1).toString())),
            subtitle:Text(i>level?'Kilitli':i==level?'Oynanıyor':'Tamamlandı'),
            trailing:Icon(i>level?Icons.lock:i==level?Icons.play_arrow:Icons.check_circle),
            enabled:i<=level,onTap:(){
              Navigator.pop(ctx);
              if(i!=level){setState((){level=i;loadLevel();});save();}
            },
          ))),
        ]),
      )),
    );
  }
  @override
  Widget build(BuildContext context){
    final height=MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor:const Color(0xff142440),
      body:SafeArea(child:Column(children:[
        Expanded(child:landscape()),
        SizedBox(height:math.min(350.0,height*.53),child:controls()),
      ])),
    );
  }
  Widget landscape(){
    final colors=[const Color(0xff092850),const Color(0xff2b568b),const Color(0xffce88a6),const Color(0xfff2c095)];
    return Container(
      decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:colors)),
      child:Stack(children:[
        const Positioned.fill(child:CustomPaint(painter:LandPainter())),
        const Positioned.fill(child:IgnorePointer(child:CustomPaint(painter:GoldCorners()))),
        Positioned(top:11,left:12,right:12,child:Row(children:[
          Material(color:const Color(0xff082f58),shape:const CircleBorder(side:BorderSide(color:Color(0xffffc66b),width:2)),child:IconButton(onPressed:openMap,icon:const Icon(Icons.map_outlined,color:Color(0xffffd78b)))),
          const SizedBox(width:5),
          Expanded(child:Column(children:[
            const Text('KELİME BUL',style:TextStyle(color:Color(0xffffdc92),fontWeight:FontWeight.w900,fontSize:12,letterSpacing:2)),
            Container(margin:const EdgeInsets.only(top:4),padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:const Color(0xd9082c54),border:Border.all(color:const Color(0xffffc66b),width:1.5),borderRadius:BorderRadius.circular(14)),child:Text(pack.name,textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w900))),
          ])),
          Container(padding:const EdgeInsets.all(9),
            decoration:BoxDecoration(color:const Color(0xee072f54),border:Border.all(color:const Color(0xffffc66b)),borderRadius:BorderRadius.circular(16)),
            child:Text('🪙 '+coins.toString(),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900))),
        ])),
        Positioned(top:84,left:16,right:16,child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text('BÖLÜM '+(level+1).toString()+'/'+packs.length.toString(),
            style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w900)),
          Text('⭐ '+solved.length.toString()+'/'+pack.words.length.toString(),
            style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w900)),
        ])),
        Positioned.fill(top:121,bottom:7,left:12,right:12,child:crossword()),
      ]),
    );
  }
  Widget crossword(){
    final shown=<String>{...revealed};
    for(final s in board.slots){
      if(solved.contains(s.word)){
        for(var i=0;i<s.word.length;i++){shown.add(s.cell(i));}
      }
    }
    const u=48.0;
    return Center(child:FittedBox(fit:BoxFit.contain,child:SizedBox(
      width:board.columns*u,height:board.rows*u,
      child:Stack(children:[
        for(final cell in board.cells.entries)
          Positioned(
            left:int.parse(cell.key.split(',')[0])*u+2,top:int.parse(cell.key.split(',')[1])*u+2,
            child:Container(width:u-4,height:u-4,alignment:Alignment.center,
              decoration:BoxDecoration(
                color:shown.contains(cell.key)?const Color(0xffffd677):const Color(0xfffffdf5),
                border:Border.all(color:const Color(0xffd9a24d),width:1.6),
                borderRadius:BorderRadius.circular(8),
                boxShadow:const [BoxShadow(color:Color(0x442c405b),blurRadius:5,offset:Offset(0,3))]),
              child:Text(shown.contains(cell.key)?cell.value:'',
                style:const TextStyle(color:Color(0xff314e62),fontSize:25,fontWeight:FontWeight.w900))),
          ),
      ]),
    )));
  }
  Widget controls(){
    final size=math.min(210.0,math.max(181.0,MediaQuery.sizeOf(context).width*.54));
    return Container(
      padding:const EdgeInsets.fromLTRB(14,9,14,5),
      decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff0a436e),Color(0xff032a51),Color(0xff001d3a)]),border:Border.all(color:const Color(0xffffc36b),width:1.5),
        borderRadius:const BorderRadius.vertical(top:Radius.circular(25))),
      child:SingleChildScrollView(child:Column(children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          const Text('🔤 KELİME OLUŞTUR',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:Colors.white)),
          Text('⭐ '+score.toString()+' puan',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:Color(0xffffd17a))),
        ]),
        SizedBox(height:32,child:Center(child:Text(currentWord.isEmpty?'Harfleri birleştir':currentWord,
          style:TextStyle(fontSize:currentWord.isEmpty?13:25,fontWeight:FontWeight.w900,letterSpacing:currentWord.isEmpty?0:4,
            color:currentWord.isEmpty?const Color(0xffffe0a2):const Color(0xffffcc73))))),
        SizedBox(width:size,height:size,child:Listener(
          behavior:HitTestBehavior.opaque,
          onPointerDown:(e){final i=hit(e.localPosition,size);if(i!=null){pressed=true;dragged=false;select(i);}},
          onPointerMove:(e){
            if(!pressed)return;
            final i=hit(e.localPosition,size);
            if(i!=null&&!picked.contains(i)){dragged=true;select(i);}
          },
          onPointerUp:(e){if(pressed){pressed=false;if(dragged&&picked.length>=2)submit();}},
          onPointerCancel:(e){pressed=false;},
          child:Stack(children:[
            Positioned.fill(child:Container(margin:const EdgeInsets.all(6),
              decoration:BoxDecoration(shape:BoxShape.circle,gradient:const RadialGradient(colors:[Color(0xff0b5581),Color(0xff052a50),Color(0xff001d38)]),
                border:Border.all(color:const Color(0xffffca65),width:3),boxShadow:const [
                  BoxShadow(color:Color(0x445a8596),blurRadius:12,offset:Offset(0,6))]))),
            const Center(child:Icon(Icons.auto_awesome,color:Color(0xffffc66b),size:24)),
            Positioned.fill(child:CustomPaint(painter:LinePainter([
              for(final i in picked)Offset(
                size/2+math.cos(-math.pi/2+2*math.pi*i/wheel.length)*size*.355,
                size/2+math.sin(-math.pi/2+2*math.pi*i/wheel.length)*size*.355,
              ),
            ]))),
            for(var i=0;i<wheel.length;i++)
              Positioned(
                left:size/2+math.cos(-math.pi/2+2*math.pi*i/wheel.length)*size*.355-26,
                top:size/2+math.sin(-math.pi/2+2*math.pi*i/wheel.length)*size*.355-26,
                child:Container(width:52,height:52,alignment:Alignment.center,
                  decoration:BoxDecoration(shape:BoxShape.circle,
                    color:picked.contains(i)?const Color(0xffffd170):const Color(0xfffff9ee),border:Border.all(color:const Color(0xffffbc58),width:2),
                    boxShadow:const [BoxShadow(color:Color(0x55658b95),offset:Offset(0,4),blurRadius:5)]),
                  child:Text(wheel[i],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:Color(0xff092b50)))),
              ),
          ]),
        )),
        const SizedBox(height:9),
        Row(children:[
          Expanded(child:action(Icons.shuffle,'Karıştır',(){setState((){wheel.shuffle(rand);picked.clear();message='Harfler karıştırıldı.';});})),
          const SizedBox(width:8),
          Expanded(child:action(Icons.check_circle_outline,'Kontrol',submit,special:true)),
          const SizedBox(width:8),
          Expanded(child:action(Icons.lightbulb_outline,'İpucu 35',hint)),
        ]),
        Padding(padding:const EdgeInsets.only(top:8),child:Text(message,textAlign:TextAlign.center,maxLines:2,
          style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:Color(0xffffd28a)))),
      ])),
    );
  }
  Widget action(IconData icon,String label,VoidCallback tap,{bool special=false}){
    return Material(
      color:special?const Color(0xffffc65b):const Color(0xff073b65),
      shape:StadiumBorder(side:const BorderSide(color:Color(0xffffc46c),width:1.4)),
      child:InkWell(onTap:tap,customBorder:const StadiumBorder(),
        child:Padding(padding:const EdgeInsets.symmetric(vertical:12,horizontal:3),
          child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
            Icon(icon,size:16,color:special?const Color(0xff082d50):const Color(0xffffcf74)),
            const SizedBox(width:3),
            Flexible(child:Text(label,maxLines:1,overflow:TextOverflow.ellipsis,
              style:TextStyle(color:special?const Color(0xff082d50):Colors.white,fontSize:11,fontWeight:FontWeight.w900))),
          ]))),
    );
  }
}
class LinePainter extends CustomPainter {
  final List<Offset> points;
  const LinePainter(this.points);
  @override void paint(Canvas canvas,Size size){
    if(points.length<2)return;
    final paint=Paint()..color=const Color(0xccffb73b)..strokeWidth=11
      ..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round..style=PaintingStyle.stroke;
    final path=Path()..moveTo(points.first.dx,points.first.dy);
    for(final p in points.skip(1)){path.lineTo(p.dx,p.dy);}
    canvas.drawPath(path,paint);
  }
  @override bool shouldRepaint(covariant LinePainter other)=>true;
}
class LandPainter extends CustomPainter {
  const LandPainter();
  @override void paint(Canvas c,Size s){
    final w=s.width,h=s.height;
    c.drawCircle(Offset(w*.78,h*.54),w*.10,Paint()..color=const Color(0x55ffe0a8));
    final crescent=Offset(w*.52,h*.22);
    c.drawCircle(crescent,10,Paint()..color=const Color(0xffffdb9d));
    c.drawCircle(crescent.translate(5,-4),10,Paint()..color=const Color(0xff2c4e83));
    for(var i=0;i<30;i++){
      c.drawCircle(Offset((i*37%97)/97*w,(i*23%51)/100*h),.8,Paint()..color=const Color(0x77fff4ce));
    }
    final mountain=Path()..moveTo(0,h*.84)..lineTo(w*.24,h*.53)..lineTo(w*.43,h*.83)
      ..lineTo(w*.71,h*.54)..lineTo(w,h*.87)..lineTo(w,h)..lineTo(0,h)..close();
    c.drawPath(mountain,Paint()..color=const Color(0x776d6383));
    c.drawRect(Rect.fromLTWH(0,h*.92,w,h*.08),Paint()..color=const Color(0x88d4c4bf));
    // Illustrative mosque on the left, kept behind interactive crossword tiles.
    final baseX=w*.15,ground=h*.88;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(baseX-w*.14,ground-h*.12,w*.32,h*.12),const Radius.circular(3)),
      Paint()..color=const Color(0xffe7d4bb));
    c.drawOval(Rect.fromCenter(center:Offset(baseX+w*.02,ground-h*.13),width:w*.24,height:h*.13),
      Paint()..color=const Color(0xff276e66));
    for(final d in [-.15,.20]){
      final x=baseX+w*d;
      c.drawRect(Rect.fromLTWH(x,ground-h*.28,w*.024,h*.27),Paint()..color=const Color(0xffead8bd));
      final tip=Path()..moveTo(x-w*.009,ground-h*.28)..lineTo(x+w*.012,ground-h*.35)
        ..lineTo(x+w*.033,ground-h*.28)..close();
      c.drawPath(tip,Paint()..color=const Color(0xff367d70));
    }
    // Kaaba in the distance at right.
    final x=w*.75,y=h*.75,bw=w*.17,bh=h*.115;
    c.drawRect(Rect.fromLTWH(x,y,bw,bh),Paint()..color=const Color(0xff181a21));
    c.drawRect(Rect.fromLTWH(x,y+h*.025,bw,h*.013),Paint()..color=const Color(0xffdfb86a));
    final side=Path()..moveTo(x+bw,y)..lineTo(x+bw+w*.026,y-h*.02)
      ..lineTo(x+bw+w*.026,y+bh-h*.02)..lineTo(x+bw,y+bh)..close();
    c.drawPath(side,Paint()..color=const Color(0xff313038));
  }
  @override bool shouldRepaint(covariant LandPainter old)=>false;
}
class GoldCorners extends CustomPainter {
  const GoldCorners();
  @override void paint(Canvas c,Size s){
    final p=Paint()..color=const Color(0xffffc56b)..strokeWidth=1.4..style=PaintingStyle.stroke;
    final shape=Path()..moveTo(0,85)..quadraticBezierTo(0,0,85,0)
      ..moveTo(s.width-85,0)..quadraticBezierTo(s.width,0,s.width,85);
    c.drawPath(shape,p);
    for(var i=0;i<5;i++){c.drawCircle(Offset(i*11+5,5),1.3,p);c.drawCircle(Offset(s.width-i*11-5,5),1.3,p);}
  }
  @override bool shouldRepaint(covariant GoldCorners old)=>false;
}