# Kelime Bul — Google Play için kalıcı upload key

İlk Google Play yayını öncesi **bir kez** upload keystore üretin ve güvenli şekilde saklayın.

## 1. Anahtar oluşturma (Windows / JDK 17 veya üstü)

PowerShell'de (`keytool` komutu JDK ile gelir):

```powershell
keytool -genkeypair -v -keystore kelime-bul-upload.jks -alias kelimebul-upload -keyalg RSA -keysize 3072 -validity 10000
```

Anahtar şifresini ve keystore şifresini **güçlü, kalıcı ve özel** seçin. Anahtar dosyasını ve parolalarını sadece size ait, şifreli ve yedekli bir konumda saklayın; GitHub deposuna, sohbete veya e-postaya göndermeyin.

## 2. GitHub Actions Secrets ekleme

GitHub deposu: `ediptan01-commits/kelime-oyunu` → Settings → Secrets and variables → Actions → New repository secret.

Aşağıdaki **dört repository secret** gerekir:

- `UPLOAD_KEYSTORE_BASE64`: .jks dosyasının base64 kodu (dosyanın kendisi değil).
- `UPLOAD_STORE_PASSWORD`: keystore şifresi.
- `UPLOAD_KEY_ALIAS`: `kelimebul-upload`.
- `UPLOAD_KEY_PASSWORD`: anahtar şifresi.

PowerShell'de base64 değerini hesaplama:

```powershell
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Resolve-Path ".\kelime-bul-upload.jks")))
```

Çıktının tamamını `UPLOAD_KEYSTORE_BASE64` gizli değerine koyun. **Buraya veya başka bir sohbete yapıştırmayın.**

## 3. İmzalı AAB'yi üretme

GitHub → Actions → **Google Play - Signed Release** → Run workflow.

İş akışı gizli anahtar dosyasını sadece geçici runner'da açar, Android release signing yapılandırmasını kurar, `jarsigner -verify -strict` ile AAB imzasını doğrular ve iki dosya üretir:
- `kelime-bul-signed-aab`: Google Play Console'a yüklenir.
- `kelime-bul-signed-apk`: telefonda imzalı sürüm testi için.

**Dikkat:** Normal Android APK + AAB iş akışının çıktısı Play yayını için kullanılmamalıdır; yalnızca yukarıdaki imzalı iş akışının AAB'sini yükleyin.

## 4. Google Play'e ilk yükleme

Play Console'da yeni uygulama oluşturun ve Google Play App Signing'i etkinleştirin. Google'ın kendi app signing key'iyle dağıtılan paketi imzalamasına izin verin. Ürettiğiniz keystore burada **upload key** olarak kullanılır; gelecekteki güncellemelerde aynı anahtarı kullanın.

Uygulamanın package ID'si mevcut CI yapılandırmasında `com.teknolojix.kelime_rotalari`. İlk yüklemeden önce bunu kalıcı olarak seçin; yayınlandıktan sonra package ID değiştirilemez. Sürüm numarasını her yüklemede artırın.

Yüklemeden önce gizlilik politikası URL'si, mağaza görselleri, uygulama ikonu, içerik derecelendirmesi ve veri güvenliği formu tamamlanmalıdır. 18 ayrı fotoğraf ve son sözlük incelemesi henüz bitmiş değildir.
