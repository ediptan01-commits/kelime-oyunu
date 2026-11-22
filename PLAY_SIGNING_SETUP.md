# Kelime Bul için Google Play paketi

Paket adı `com.teknolojix.kelime_rotalari`. Sürüm adı ve kodu `pubspec.yaml` dosyasındaki `version` alanından gelir. Yeni yüklemeden önce Play Console'da kullanılan en yüksek sürüm kodunu kontrol edin.

GitHub Actions repository secrets bölümünde mevcut kalıcı yükleme anahtarına ait dört değeri kullanın:

- `UPLOAD_KEYSTORE_BASE64` — mevcut keystore dosyasının Base64 içeriği
- `UPLOAD_STORE_PASSWORD` — depo parolası
- `UPLOAD_KEY_ALIAS` — mevcut anahtarın takma adı
- `UPLOAD_KEY_PASSWORD` — anahtarın parolası

Play Console yükleme sertifikasının SHA-256 parmak izini gösteriyorsa `PLAY_UPLOAD_SHA256` adlı Actions değişkenine kaydedin. Google'ın uygulama imzalama sertifikası farklı bir amaç taşır.

Actions → **Google Play - Signed Release** → **Run workflow**. İş akışı imzayı, paket adını ve sürüm kodunu doğrular. **kelime-bul-signed-aab** arşivinden `app-release.aab` dosyasını çıkarıp Kelime Bul sürüm taslağına yükleyin. İş akışı Play Console'da yayın başlatmaz.
