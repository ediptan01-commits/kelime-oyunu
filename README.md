# Kelime Rotaları 🧭

WOW tarzı dairesel harf çarkı ile sürükleyerek kelime oluşturup kesişen bulmacaları tamamladığın özgün Türkçe Flutter mobil oyunu.

- 18 bölüm, Türkçe harfler, kesişen bulmacalar
- Sürükleme ve dokunarak harf seçme, kontrol, karıştırma, ipucu
- Manzara temaları, puan/altın, ilerleme kaydetme ve harita
- Çevrimdışı oynanış

## Android APK ve AAB

GitHub Actions → **Android APK + AAB** iş akışı her main değişiminde çalışır.
Başarılı derlemenin **Artifacts** bölümünden APK ve AAB indirilebilir.

Yerelde Flutter SDK ile:

```sh
flutter create --platforms=android --org com.teknolojix --project-name kelime_rotalari .
flutter pub get
flutter run
```

**Not:** Bu ilk deneme sürümünde kelimeler yalnızca bölüm havuzlarından kabul edilir. Google Play üretim sürümü öncesinde kalıcı upload keystore imzası, simge, gizlilik politikası ve geniş Türkçe sözlük ayrıca hazırlanmalıdır. WOW'a ait görseller, logo ve içerik kullanılmaz.
