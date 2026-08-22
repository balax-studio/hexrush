
# Web Güncelleme Zamanlaması Kuralı

Bir özellik eklendikten sonra kullanıcı **farklı bir özellik geliştirmemi veya eklemememi** isterse,
bu önceki özelliğin beğenildiği ve çalıştığının onaylandığı anlamına gelir.
Bu durumda **web güncellemesini (game.js, sw.js, index.html sürüm bump ve zip) otomatik olarak yap.**

Ancak kullanıcı bir **hata bildirip düzeltmemi** isterse (örn: "şunu düzelt", "bu çalışmıyor", "hata var"),
o hata **tamamen giderilene ve kullanıcı onaylayana kadar** ya da **yeni bir özellik isteği gelene kadar**
web güncellemesi yapma.

## Özet:
- ✅ Yeni özellik isteği geldi → önceki özellik tamamdır, web'i de güncelle
- ❌ Hata bildirimi geldi → hata düzelene kadar web güncellemesi beklede tut
