# Snapwatch

**Gördüğün film ya da dizinin ekran görüntüsünü at; AI tanısın, akşam ne izleyeceğini o seçsin.**

## Ekran kaydı

▶️ **[Ekran kaydını izle (35 sn)](https://github.com/omergkmn/snapwatch/releases/download/v1.0.0/snapwatch-demo.mp4)** · [Release sayfası](https://github.com/omergkmn/snapwatch/releases/tag/v1.0.0)

Kayıt gerçek bir iPhone'da alındı: onboarding → paywall → galeriden ekran görüntüsü seçme → tarama → sonuç → izleme listesi.

## Fikir

Filmleri ve dizileri her yerde görüyoruz: bir Instagram gönderisinde, arkadaşın attığı bir fragmanda, bir hikâyedeki afişte. Ekran görüntüsünü alıyoruz, sonra galeride kayboluyor. Snapwatch bu ekran görüntüsünü izleme listesine dönüştürür: AI görseldeki yapımı tanır; yılını, türünü, süresini, yönetmenini, konusunu ve nerede izleneceğini çıkarır. Akşam olunca kullanıcı "Bu akşam ne izleyelim?" diye sorar, AI da **kullanıcının kendi listesinden** o anki ruh haline en uygun yapımı seçer. Hedef kullanıcı, izlediğinden fazlasını kaydeden herkes. Kullanıcı Premium için para öder, çünkü Premium tarama sınırını kaldırır ve "bu akşam" önerilerini açar.

Snapwatch daha büyük bir fikrin ilk modülü: MOMENTBOX, yani gördüğün her şeyi kaydet, AI doğru anda hatırlatsın. Bu çalışma için tek ve net bir amaçla sınırlandı: film ve dizi.

## Ekranlar ve akış

| Ekran | Ne yapıyor |
|---|---|
| Splash | Yükleme çubuğu. İlk açılışta onboarding'e, sonrasında Ana Sayfa'ya yönlendirir. |
| Onboarding | 4 sayfa: problem, nasıl çalışır, sevdiğin türler, ad. Son sayfada arka planda misafir hesabı oluşturulur ve paywall açılır. |
| Paywall (statik) | Ücretsiz / Premium karşılaştırma tablosu; haftalık, yıllık ve aylık planlar; abone ol, geri yükle, kullanım koşulları ve gizlilik bağlantıları. Kapat butonu 3 saniye sonra görünür. |
| Ana Sayfa (navigation bar yok) | Ekran görüntüsü tarama, "Bu akşam ne izleyelim?" (Premium), İzlenecekler ve İzlediklerim sekmeleri. |
| Tarama → Sonuç | Seçilen görselin üstünde tarama adımları, ardından AI sonucu: ad, yıl, süre/sezon, türler, yönetmen, konu, nerede izlenir, listeye ekle / izledim. |
| Öneri | Ruh hali seçenekleri ve serbest metin; listeden en fazla 3 öneri, her birinin gerekçesiyle. |
| Profil | Misafir hesabı, abonelik durumu, dil (Türkçe / English), sevdiğin türler, koşullar, gizlilik, verileri sıfırlama. |

**Ücretsiz / Premium:** Ücretsiz kullanıcının 3 başarılı tarama hakkı var; başarısız tarama hakkı düşürmez. Premium sınırsız tarama ve "bu akşam" önerilerini açar. Satın alma taklit ediliyor, gerçek ödeme alınmıyor.

## Mimari

Üç katman ve tek kural: **ekran → cubit → repository → servis**. Ekran servise hiç dokunmaz, cubit de Firebase'i doğrudan çağırmaz.

```
lib/
  main_dev.dart / main_prod.dart   giriş noktaları, ikisi de main_common.dart'ı çağırır
  main_common.dart                 Firebase, App Check, çeviri, yerel kayıt, runApp
  app/                             uygulama widget'ı, router (go_router), tema, ortam
  core/                            hatalar, çeviri yardımcıları, linkler, ortak widget'lar
  data/
    models/                        el ile yazılmış fromJson/toJson ile sade Dart modelleri
    services/                      dış dünyayla konuşur: Gemini, Firebase Auth, SharedPreferences
    repositories/                  servislerin üstündeki uygulama kuralları: tarama hakkı, liste, hatalar
  features/<ekran>/                <ekran>_screen.dart, <ekran>_cubit.dart, <ekran>_state.dart, widgets/
```

- **Servisler** sadece bir şeyi nasıl çağıracağını bilir: Gemini, Firebase Auth, SharedPreferences.
- **Repository'ler** uygulamanın kurallarını tutar:
  - 3 ücretsiz tarama;
  - listede aynı yapımın iki kez olmaması;
  - Firebase ve ağ hatalarının tek bir `AppException` tipine çevrilmesi;
  - AI cevaplarının kontrol edilmesi.
- **Cubit'ler** ekranın state'ini tutar ve repository'leri çağırır. Ekranla birlikte oluşturulurlar (`BlocProvider`); ekran kapanınca state'leri de gider.
- **Repository'ler** uygulamanın en üstünde bir kez oluşturulur (`MultiRepositoryProvider`) ve `context.read<...>()` ile alınır. Bu boyuttaki bir uygulama için ayrı bir servis bulucu paketine gerek yok.
- **dev / prod:** `main_dev.dart` DEV şeridini ve debug şeridini gösterir, `main_prod.dart` ikisini de göstermez. İkisi de ortak `main_common.dart`'ı kullanır.

### State management: flutter_bloc (Cubit)

Cubit'i seçtim; çünkü state değişimi açıkça yazılıyor (`emit(...)`), test etmesi kolay ve production projelerinde kullandığım yapı. State'in biçimi ekranın ihtiyacına göre seçildi:

| State biçimi | Nerede | Neden |
|---|---|---|
| `sealed class` | Splash, Tarama | Belirli adımları olan bir süreç (bekliyor → sürüyor → başarılı / hatalı). Arayüz `switch` kullanıyor; bir durum unutulursa derleyici uyarıyor. |
| Tek sınıf + `copyWith` | Onboarding, Paywall, Öneri | Birden fazla alanın ayrı ayrı değiştiği form benzeri ekranlar. |
| Tek bir değer | Detay (`WatchStatus?`) | Değişen tek şey yapımın listedeki durumu. |

Sadece arayüzü ilgilendiren state'ler cubit'te değil, widget'ın kendi `State`'inde tutuluyor: onboarding'in hangi sayfada olduğu, seçili sekme, paywall'un 3 saniyelik zamanlayıcısı.

## AI entegrasyonu

AI uygulamanın merkezinde ve **Gemini (Firebase AI Logic)** üzerinden iki iş için kullanılıyor:

1. **Görselden yapımı tanıma.** Ekran görüntüsü küçültülür (en fazla 1600 px) ve bir prompt ile birlikte **JSON şeması** verilerek gönderilir; cevap serbest metin değil, yapılandırılmış veri olarak gelir. Modelden, emin değilse tahmin etmek yerine `isMediaTitle: false` dönmesi isteniyor. Bu durumda uygulama "Bu görselde bir film ya da dizi bulamadım" der ve ücretsiz hak düşmez.
2. **"Bu akşam ne izleyelim?"** Modele kullanıcının **izlenecekler** listesi numaralı olarak, sevdiği türler ve ruh hali gönderilir. Model önerileri numarayla ve tek cümlelik gerekçeyle döner. İzlenenler hiç gönderilmez, bu yüzden önerilmeleri mümkün değil.

**AI çıktısına körü körüne güvenilmiyor, kodla kontrol ediliyor:**
- "Sadece film / Sadece dizi" filtresi istekten önce kodla uygulanıyor.
- Listede olmayan ya da tekrar eden öneri numaraları atılıyor; model kullanıcının listesinde olmayan bir yapım ekleyemiyor.
- Boş metinler eksik alan sayılıyor.
- Cevaplar uygulamanın seçili dilinde (Türkçe veya İngilizce) geliyor.

**Model seçimi:** `gemini-3.5-flash-lite` (stable, kapanma tarihi yok). `gemini-3.8-flash` testler sırasında bu projede cevap vermedi; daha hızlı olan lite modeli ölçülerek seçildi. Tanıma birkaç saniye sürüyor.

**Güvenlik:** Gemini API anahtarı uygulamanın içinde değil; istekler Firebase AI Logic üzerinden gidiyor ve **Firebase App Check** ile korunuyor. App Check, Kasım 2026'dan beri AI Logic için zorunlu. Mağaza sürümlerinde Play Integrity / App Attest, geliştirme sürümlerinde kayıtlı bir debug token kullanılıyor.

## Paketler

| Paket | Neden |
|---|---|
| `flutter_bloc` | State management (Cubit) ve bağımlılıkların ekranlara verilmesi. |
| `go_router` | Sayfa geçişleri; rota adları `AppRoutes` içinde sabit. |
| `firebase_core`, `firebase_ai` | Firebase AI Logic üzerinden Gemini (uygulamada API anahtarı yok). |
| `firebase_app_check` | Firebase AI Logic için zorunlu; AI kotasını korur. |
| `firebase_auth` | Anonim misafir hesabı; ileride Google / Apple hesabına bağlanabilir. |
| `easy_localization` | Türkçe (varsayılan) ve İngilizce, Profil'den değiştirilebilir; anahtarlar `LocaleKeys` olarak üretiliyor. |
| `shared_preferences` | Profil, plan, tarama sayısı ve izleme listesi cihazda. |
| `image_picker` | Galeriden ekran görüntüsü seçme. |
| `url_launcher` | Platform linkleri, kullanım koşulları ve gizlilik. |
| `integration_test`, `flutter_driver` (dev) | Bütün akışın ekran görüntüleriyle uçtan uca testi. |

Bilerek kullanılmayanlar: kod üretimi (freezed / json_serializable), get_it / injectable ve use-case katmanı. Bu boyutta fayda sağlamadan dosya sayısını artırırlardı.

Fontlar (Poppins, Cormorant Garamond) `assets/fonts` altında projeye gömülü (SIL Open Font License).

## Kurulum

Gereksinimler: Flutter **3.47.1** (stable), iOS için Xcode, Android için Android SDK.

```bash
flutter pub get
```

**App Check debug token.** Firebase ayar dosyaları repoda var, ama Firebase AI Logic sadece App Check'ten geçen uygulamalara cevap veriyor. Simülatör, emülatör ve yerel derlemelerde bunun için bir debug token gerekiyor:

1. `config/app_check.example.json` dosyasını `config/app_check.json` olarak kopyala. Bu dosya git'e girmez.
2. İçine her platform için bir debug token yaz. Aynı token'ları Firebase Console → App Check → Apps → Manage debug tokens'a kaydet.

Çalıştırma:

```bash
flutter run -t lib/main_dev.dart  --dart-define-from-file=config/app_check.json
flutter run -t lib/main_prod.dart --dart-define-from-file=config/app_check.json
```

`assets/translations/*.json` dosyalarına metin ekledikten sonra anahtarları yeniden üret:

```bash
dart run easy_localization:generate -S assets/translations -s tr.json -f keys -O lib/core/l10n -o locale_keys.g.dart
```

## Test

`integration_test/app_flow_test.dart`, uygulamanın tamamını gerçek Firebase ve Gemini ile bir simülatörde ya da cihazda çalıştırır. Test şu adımlardan geçer:
- onboarding;
- paywall: geri yükle ve kapat;
- bir film afişi, bir dizi afişi ve film olmayan bir görsel taranır;
- bir yapım izlendi olarak işaretlenir;
- plan satın alınır;
- izlenen yapımın **önerilmediği** kontrol edilir;
- dil değiştirilir ve uygulama sıfırlanır.

Her adımın ekran görüntüsünü `build/screenshots/` klasörüne kaydeder.

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define-from-file=config/app_check.json -d <cihaz-id>
```

Sistemin galeri seçicisi testle kullanılamadığı için test, tarama ekranını `integration_test/sample_images.dart` içindeki örnek görsellerle açıyor. Bunlar gerçek afiş değil, basit üretilmiş görseller. Test Android emülatöründe ve iOS simülatöründe geçiyor.

## Bilinen sınırlar ve sonraki adımlar

- **Nerede izlenir** bilgisi AI'dan geliyor ve yanlış ya da eski olabilir. Ekranda bu belirtiliyor; platform bulunamazsa web araması öneriliyor. Sonraki adım: TMDB'den (JustWatch verisi) gerçek platform bilgisi ve afişler.
- Paywall statik; mağaza `SubscriptionRepository` içinde taklit ediliyor. RevenueCat ya da `in_app_purchase` eklenince sadece bu dosya değişir.
- Galeriden seçmek yerine paylaş menüsü (Instagram'dan "Snapwatch'a paylaş").
- Misafir hesabına bağlanan Google / Apple girişi ve izleme listesinin bulutta senkronu.

## Geliştirmede kullanılan AI araçları

Bu proje, kodlama asistanı olarak **Claude Code** (Anthropic) ile geliştirildi. Ürün, akış ve mimari kararlarını adım adım ben verdim; her değişikliği inceledim ve uygulamayı simülatörlerde ve kendi telefonumda test ettim. Uygulamanın içindeki AI özellikleri ise yukarıda anlatıldığı gibi Google Gemini kullanıyor.
