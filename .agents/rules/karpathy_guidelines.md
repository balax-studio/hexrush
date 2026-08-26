# Karpathy Davranışsal Kodlama ve Ajan Standartları

Bu kural, Andrej Karpathy'nin büyük dil modellerinin (LLM) kodlama sırasındaki hataları üzerine yaptığı gözlemlerden türetilmiş bağlayıcı prensiplerdir.

## 1. Kodlamadan Önce Düşün (Think Before Coding)
- **Kör Varsayımlarda Bulunma:** Emin olunmayan yerlerde kafaya göre varsayım üretme, kullanıcıya açıkça sor.
- **Alternatifleri ve Trade-off'ları Sun:** Birden fazla geçerli mimari yorum varsa sessizce birini seçme; alternatifleri ve artı-eksilerini belirt.
- **Gerektiğinde İtiraz Et:** Daha basit ve sağlam bir yol varsa bunu dile getir.
- **Kafa Karışıklığında Dur:** Net olmayan bir nokta olduğunda kodu yazmayı durdur ve netleştirme talep et.

## 2. Önce Basitlik ve Minimalizm (Simplicity First)
- **İstenmeyen Özellik Ekleme:** Kullanıcının açıkça istemediği özellikleri, "ileride lazım olur" düşüncesiyle ekleme.
- **Tek Kullanımlık Kodlara Aşırı Soyutlama Yapma:** Sadece tek yerde kullanılan işlemler için karmaşık fabrika, interface veya ara katman mimarisi kurma.
- **İmkansız Senaryolar İçin Hata Yönetimi Şişirme:** Gereksiz defensif kod blokları oluşturma.
- **50 Satırla Çözülecek Kodu 200 Satır Yapma:** Kısa, doğrudan ve okunabilir çözümü tercih et.

## 3. Cerrahi Değişiklikler (Surgical Changes)
- **Sadece İlgili Koda Dokun:** Çalışan çevre kodları, ilgisiz fonksiyonları veya mevcut stil/formatı "iyileştiriyorum" diyerek değiştirme.
- **Bozuk Olmayan Şeyi Yeniden Yazma (Refactor Etme):** Görevle doğrudan ilgisi olmayan yerleri kurcalama.
- **Sadece Kendi Değişikliğinin Artıklarını Temizle:** Yapılan değişiklik nedeniyle yetim kalan import veya değişkenleri sil; ancak önceden var olan dokunulmamış ölü kodları kullanıcı istemedikçe silme (gerekirse bildir).
- **Her Satırın Gerekçesi Olmalı:** Değişen her satır doğrudan kullanıcının talimatına bağlanabilmelidir.

## 4. Hedef Odaklı Yürütme ve Doğrulama (Goal-Driven Execution)
- **Doğrulanabilir Kriterler:** Görevleri net başarı kriterlerine ve test döngülerine bağla (`Adım -> Doğrulama`).
- **Görevi Doğrulamadan Bitirme:** Kod yazıldıktan sonra testleri (`flutter test` vb.) ve sözdizimi doğrulamalarını çalıştırmadan işlemi tamamlandı sayma.
