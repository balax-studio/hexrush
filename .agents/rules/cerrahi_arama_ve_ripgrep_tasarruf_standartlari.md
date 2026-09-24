# Cerrahi Arama, Ripgrep, Graft ve Token Tasarrufu Standartları

Bu kural, projede çalışan tüm yapay zeka ajanları ve geliştiriciler için arama, kod okuma, mimari haritalama ve düzenleme verimliliğini bağlar.

## 1. Cerrahi Arama ve Kademeli Keşif (Phased Retrieval)
- Kod tabanında bir analiz veya düzenleme yaparken tüm dosyaları körü körüne hafızaya doldurmak (bulk read) yasaktır.
- Mimari ve bağımlılık keşfinde `graft` (`graft/` context graph & nodes) kullanılarak ilgili modül sınırları ve bağlantılar haritalanır.
- Hedef sınıf, fonksiyon, değişken veya metin tespiti için öncelikle `grep_search` veya `ripgrep` (`rg`) motoru kullanılmalıdır.
- Kademeli arama protokolü uygulanır:
  1. Adım: Mimari/bağımlılık haritası veya Graft bağlam düğümlerini kontrol et (`graft/` veya knowledge items).
  2. Adım: Standart arama (`rg pattern` veya `grep_search`).
  3. Adım: Sonuç bulunamazsa gizli ve yapılandırma dosyalarını dahil et (`-u` bayrağı).
  4. Adım: Yalnızca gerektiğinde dosya tipi filtresi (`-tdart`, `-tjson` vb.) ile aramayı daralt.

## 2. Bağlam Bütünlüğü ve Güvenli Düzenleme (Context Integrity)
- `ripgrep` ve `graft` ile konumu tespit edilen kod bloğunun yaşam döngüsü (`dispose`, state dinleyicileri, importlar) incelenmeden körlemesine değişiklik yapılamaz.
- Kod düzenlemeleri yalnızca hedeflenen satırlara cerrahi olarak uygulanmalıdır.

## 3. Global ve Yerel Çöp İzolasyonu (Zero-Noise Filtering)
- `build/`, `.dart_tool/`, `node_modules/`, `target/`, `.gradle/` ve `*.log` gibi üretim çıktıları aramalardan ve bağlamdan daima izole tutulmalıdır.
