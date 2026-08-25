# Oturum İyileştirmeleri ve Kuralları Kaydetme İlkesi

Bu kural, her sohbette kararlaştırılan mimari iyileştirmelerin, zorunlulukların ve kullanıcı tercihlerinin kalıcı hale getirilmesini sağlar:

1. **Sürekli Kural ve Standart Kaydı:**
   - Her sohbet ve oturumda uygulanan teknik iyileştirmeler, mağaza uyumluluk gereksinimleri, paket adlandırmaları ve mimari kararlar `.agents/rules/` altındaki ilgili kural dosyalarına veya `AGENTS.md` dosyasına anında yansıtılmalıdır.

2. **Gereksiz Karmaşıklıktan Kaçınma (YAGNI & Ponytail Prensibi):**
   - Talep edilmeyen gereksiz soyutlamalar ve şişkin kütüphaneler eklenmemelidir.
   - En yalın, performansı en yüksek ve standartlara en uygun yaklaşım seçilmelidir.

3. **Kanıt Temelli Doğrulama:**
   - İyileştirme tamamlandı demeden önce mutlaka ilgili testler (`flutter test`) ve uyumluluk kontrolleri (`greenlight preflight .`) çalıştırılarak doğrulanmalıdır.
