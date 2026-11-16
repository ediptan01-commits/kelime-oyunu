# Kelime Bul 🧭

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

> Mağaza adı: Kelime Bul. Aynı adı kullanan başka oyunlar bulunabilir; yayımlamadan önce marka/mağaza karışıklığı ayrıca değerlendirilmelidir.


## Fotoğraf kaynakları ve lisanslar
- **Kâbe:** [Al-Kaaba in Mecca.jpg](https://commons.wikimedia.org/wiki/File:Al-Kaaba_in_Mecca.jpg), Farazbinyusuf, **CC0 1.0** (2025).
- **Cami:** [Sultan Ahmed Mosque - Istanbul.jpg](https://commons.wikimedia.org/wiki/File:Sultan_Ahmed_Mosque_-_Istanbul.jpg), neverbutterfly, **CC BY 2.0**. Lisans: https://creativecommons.org/licenses/by/2.0/ . Oyunda görüntü ölçeklendirilip üstüne şeffaf karartma uygulanır.

Fotoğraflar GitHub Actions derlemesi sırasında Wikimedia Commons'tan alınarak APK ve AAB içerisine gömülür; oyun oynanırken internete ihtiyaç yoktur.
