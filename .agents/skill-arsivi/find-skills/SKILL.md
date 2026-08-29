---
name: find-skills
description: "İhtiyaç duyulan yeni veya özel uzmanlık becerilerini (skills) önce yerel arşivden (D:\\github\\skill-arsivi), bulunamazsa skills.sh / npx skills üzerinden arar ve projeye dahil eder."
metadata:
  origin: custom
---

# Find Skills (Beceri Arama ve Dinamik Yükleme)

Bu meta-beceri, HexRush projesinde aktif olmayan veya yeni bir teknolojiye ihtiyaç duyulduğunda en uygun beceriyi bulup sisteme bağlamak için kullanılır.

## Ne Zaman Kullanılır?
- Kullanıcı doğrudan bir beceri ("... ile ilgili skill var mı?", "bana şu kütüphane için skill bul") istediğinde.
- Projede mevcut 12 temel becerinin dışında kalan niş bir teknoloji (örn. özel bir veritabanı, harici SDK, yeni bir animasyon motoru) ile çalışılması gerektiğinde.

## Çalışma Protokolü

### Adım 1: Yerel Arşivi Tara (0 Gecikme, 0 Token Maliyeti)
Öncelikle `D:\github\skill-arsivi\` klasöründeki 350+ hazır beceri taranır:
```powershell
Get-ChildItem 'D:\github\skill-arsivi' -Directory | Where-Object { $_.Name -like "*aranan_kelime*" }
```
- Bulunursa: Doğrudan `D:\github\skill-arsivi\<skill_adi>\SKILL.md` okunur veya geçici olarak projeye kopyalanır.

### Adım 2: Çevrimiçi Dizini Ara (skills.sh / Vercel Labs)
Eğer yerel arşivde bulunamazsa:
```powershell
npx -y skills find <aranan_teknoloji>
```
veya web aramasıyla resmi `SKILL.md` bulunur.

### Adım 3: Temizlik ve Token Tasarrufu Değişmezi
- Görev bittikten sonra, HexRush projesinin temel alanı dışındaki beceriler `.agents/skills/` klasöründe kalıcı bırakılmaz; arşive (`D:\github\skill-arsivi`) aktarılır.
