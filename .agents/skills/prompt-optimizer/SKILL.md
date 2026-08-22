---
name: prompt-optimizer
description: >-
  Use this skill when the user asks to optimize, improve, refine, or structure prompts for AI models, LLMs, or coding agents, or when working on prompt engineering.
---

# Prompt Optimizer Skill

Bu yetenek (skill), kullanıcıların LLM'ler, kodlama asistanları ve yapay zeka ajanları için hazırladığı istemleri (prompt) analiz etmek, geliştirmek, optimize etmek ve en yüksek performansı verecek şekilde yeniden yapılandırmak için kullanılır.

---

## 🎯 Temel Görev & Yaklaşım

Kullanıcı bir prompt sunduğunda veya bir konu için optimize edilmiş bir prompt istediğinde aşağıdaki adımları uygula:

1. **Analiz Et:** Orijinal promptun amacını, eksiklerini, muğlaklıklarını ve hedeflenen çıktıyı belirle.
2. **Yapılandır (Framework Uygula):** Modern Prompt Mühendisliği standartlarına uygun olarak yapılandır.
3. **Zenginleştir:** Gerekli bağlam, rol, kısıtlamalar, çıktı formatı ve örnekleri ekle.
4. **Sun ve Açıkla:** Optimize edilmiş versiyonu, yapılan iyileştirmelerin mantığıyla birlikte sun.

---

## 🧱 Prompt Optimizasyon Çatısı (ROCCA Modeli)

Optimize edilen her profesyonel prompt aşağıdaki temel bileşenleri içermelidir:

```xml
<role>
Yapay zekanın üstleneceği uzmanlık rolü ve tonu.
</role>

<context>
Proje arka planı, kullanılan teknolojiler veya mevcut durum.
</context>

<task>
Tam olarak yapılması beklenen eylem veya üretilmesi istenen çıktı.
</task>

<constraints>
Asla yapılmaması gerekenler, sınırlar, kurallar ve uyulması zorunlu kriterler.
</constraints>

<output_format>
Çıktının formatı (JSON, Markdown, kod bloğu, adım adım liste vb.).
</output_format>

<examples>
(Varsa) İstenen girdi/çıktı örnekleri (Few-shot prompting).
</examples>
```

---

## 📋 Optimizasyon Adımları ve Standartları

### 1. Rol Tanımı (Role Prompting)
- "Sen bir yardımcısın" yerine "Sen 10+ yıl deneyimli bir Senior Godot/GDScript oyun motoru mimarısın" gibi net uzmanlık profili belirle.

### 2. Netlik ve Belirsizlik Giderme
- Muğlak ifadeleri ("güzel bir kod yaz", "hızlı olsun") net teknik kriterlere dönüştür ("Big-O karmaşıklığını O(n) seviyesinde tut", "GDScript static typing kullan").

### 3. XML / Markdown Etiketleri ile Ayrıştırma
- Prompt içeriğini `<talimatlar>`, `<kurallar>`, `<ornek_cikti>` gibi belirteçlerle bloklara ayır. LLM'ler bu bloklu yapıları çok daha tutarlı ve halüsinasyonsuz işler.

### 4. Düşünme & Akıl Yürütme Tetikleyicileri (Chain-of-Thought)
- Karmaşık problemler için modele adım adım düşünmesi talimatını ver (`Önce adımları planla, ardından çözümü uygula`).

### 5. Negatif Kısıtlamalar & Güvenlik
- Yapılmaması gerekenleri açıkça listele ("Açıklama yapmadan doğrudan JSON çıktısı ver", "Deprecated API'leri kullanma").

---

## 🛠️ Çıktı Şablonu

Kullanıcı prompt optimizasyonu istediğinde cevabı şu düzende sun:

### 1. 🔍 Mevcut Durum Analizi
- Promptun güçlü ve geliştirilmeye açık yönleri.

### 2. ⚡ Optimize Edilmiş Prompt
Kullanıcının kopyalayıp doğrudan kullanabileceği kod bloğu/markdown içinde tam ve profesyonel prompt.

### 3. 💡 Yapılan İyileştirmeler & Kullanım İpuçları
- Eklenen kritik bileşenler ve modelden en iyi verimi alma taktikleri.
