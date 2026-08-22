---
name: prompt-optimizer
description: "LLM, yapay zeka modelleri ve kodlama ajanları için istemleri (prompt) analiz eder ve optimize eder."
---

# Prompt Optimizer Skill

Bu yetenek (skill), kullanıcıların LLM'ler, kodlama asistanları ve yapay zeka ajanları için hazırladığı istemleri (prompt) analiz etmek, geliştirmek, optimize etmek ve en yüksek performansı verecek şekilde yeniden yapılandırmak için kullanılır.

---
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
---

## 🛠️ Çıktı Şablonu

Kullanıcı prompt optimizasyonu istediğinde cevabı şu düzende sun:

### 1. 🔍 Mevcut Durum Analizi
- Promptun güçlü ve geliştirilmeye açık yönleri.

### 2. ⚡ Optimize Edilmiş Prompt
Kullanıcının kopyalayıp doğrudan kullanabileceği kod bloğu/markdown içinde tam ve profesyonel prompt.

### 3. 💡 Yapılan İyileştirmeler & Kullanım İpuçları
- Eklenen kritik bileşenler ve modelden en iyi verimi alma taktikleri.
