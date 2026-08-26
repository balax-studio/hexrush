# HexRush Buton Boyut, Yükseklik ve Taktil Düzen Standartları

Bu kural belgesi, HexRush projesindeki tüm arayüz bileşenleri, modal pencereler, alt menüler ve HUD katmanlarındaki butonların geometrik ve hiyerarşik uyumunu garanti altına alır.

## 1. Temel İlke: Sıfır Ham Buton (Zero Raw Buttons)
Flutter'ın varsayılan `ElevatedButton`, `OutlinedButton`, `TextButton` veya stilize edilmemiş `InkWell + Container` yapıları KESİNLİKLE YASAKTIR.
Tüm interaktif butonlar `TactileNeoButton` bileşeni üzerinden inşa edilmelidir.

## 2. Buton Boyut Jetonları (Size Tokens)

| Jeton Adı | Yükseklik | Genişlik / MinGenişlik | Kullanım Alanları |
|---|---|---|---|
| **ButtonSize.xs** | 24px - 28px | 24x24px / 28x28px | Diyalog/Takvim Kapat Butonları, Otağ Seviye & Sinerji Rozetleri |
| **ButtonSize.sm** | 26px - 30px | Değişken / Otomatik | TopBar Kaynak Sayaçları (30px), Frenzy (30px), Mevsim Rozeti (26px), Kehanet & Göç Bannerları (26px), Kurgan & Kervan Butonları (30px), Töre Meclis Sekmeleri & Aksiyonları (30px) |
| **ButtonSize.md** | 32px - 38px | 36x36px (FAB) / Değişken | Görev Ödül Alma (32px), Pazar Takas (34px), Dil Seçim Butonları (34x50px), Harita Hızlı Erişim FAB (36x36px), Bina Topla/Yükselt/Isıt (38px), Bina Yık (38x38px) |
| **ButtonSize.lg** | 40px - 42px | Geniş / Tam Genişlik | Ana Karo Fetih Butonu (42px), Kağan Otağı Geliştir & İaşe (40px), Tam Ekran Diorama (40px) |
| **BuildGridCard** | 56px (Sabit) | Grid Sütun Genişliği | Bina İnşaat Seçim Kartları (2 sütunlu grid) |

## 3. Hizalama ve Tipografi Kuralları
- **Dikey Ortalama:** Butonların içindeki metin ve ikonlar daima `alignment: Alignment.center` veya `MainAxisAlignment.center` ile dikeyde tam ortalanmalıdır. Keyfi dikey padding (`padding: EdgeInsets.symmetric(vertical: ...)` yerine doğrudan `height` token'ı tercih edilmelidir.
- **Yazı Tipi:** Buton etiketleri daima `Cinzel` veya `JetBrains Mono`, `fontWeight: FontWeight.w900`, `text-transform: uppercase` ve `letterSpacing: 0.3 - 0.5px` olmalıdır.
- **Dokunsal Geri Bildirim:** Tıklamalarda `HapticFeedback.lightImpact` ve temaya uygun taktil ses (`TactileSoundType`) tetiklenmelidir.
