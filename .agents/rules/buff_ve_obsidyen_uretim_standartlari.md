# Süreli Bufflar ve Obsidyen Üretimi

- Oyun üretim ve envanter tick'i saniyede bir çalışır; `x/sn` gelirleri aynı bir saniyelik döngüde kaynak stoğuna işlenir.
- Üst bardaki 10x geri sayımı yalnızca ödüllü reklamın frenzy buffını gösterir. Görev ve sipariş buffları kendi katsayı ve kalan süreleriyle ayrı saklanır, kayda yazılır ve süreleri birbirinden bağımsız azalır.
- Görev/sipariş buffı üretim ve taşıma hesaplarında aynı çarpanla uygulanır; reklam buffının 10x değerini veya zamanlayıcısını değiştiremez.
- Obsidyen Dökümhanesi temel üretimini obsidyen olarak verir. Net gelir, kaynak dökümü, anlık tick, çevrimdışı kazanç ve envanter görünümü aynı `ResourcesModel.obsidian` alanını kullanır.
