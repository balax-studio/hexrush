# Güvenilir Müzik Başlatma ve Ses Efekti İzolasyonu

- Arka plan müziği oynatıcısı, oyun açılırken ses efekti oynatıcı havuzundan bağımsız başlatılır.
- Her ses efekti oynatıcısı ayrı hazırlanır; tek bir hazırlama hatası müzik oynatıcısını veya havuzdaki diğer efektleri iptal etmez.
- Başlangıç ayarları müzik zaten açıksa `resume()` çağırmamalıdır. Müziği aç/kapat güncellemesi yalnızca etkinlik durumu değiştiğinde uygulanır.
- Müzik kaynağı yüklenmemişse devam ettirme isteği `resume()` yerine parçayı başlatır. Tekil oynatma hatası, eklentiyi kalıcı olarak desteklenmiyor işaretlememelidir.
