# Kare Kelime 🧩

Flutter ile geliştirilmiş, Türkçe Q klavyeli ve ilk harfi açık Lingo tarzı kelime tahmin oyunu.

## Özellikler
- 4×4 → 5×5 → 6×6 bulmacalar
- Her satırda ilk harf açık ve değiştirilemez
- Türkçe Q klavye (Q, W, X, Ç, Ğ, İ, Ö, Ş, Ü)
- Yeşil / sarı / gri harf geri bildirimi ve tekrarlanan harflerde doğru değerlendirme
- Çevrimdışı örnek kelime havuzu, ipucu, altın ve puan
- Android APK ve AAB için GitHub Actions

## Yerelde çalıştırma
Flutter SDK yüklüyken:

```sh
flutter create --platforms=android --org com.teknolojix --project-name kare_kelime .
flutter pub get
flutter run
```

## Derleme
GitHub'da **Actions → Android APK + AAB** akışını açın.
`main` dalına gönderilen her değişiklikle otomatik derleme başlar.
Başarılı işin **Artifacts** bölümünden APK ve AAB indirilebilir.

> İlk sürümde tüm harf dizileri tahmin olarak kabul edilir; kapsamlı sözlük kontrolü henüz bulunmaz.
> Varsayılan Android derlemesi test amaçlı anahtar kullanır; Google Play'de yayımlamak için kalıcı upload keystore ile imzalama yapılmalıdır.
