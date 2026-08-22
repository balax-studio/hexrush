using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace EccInstaller
{
    class Program
    {
        static void Main(string[] args)
        {
            string sourceSkillsDir = @"C:\Users\ismai\.gemini\antigravity-ide\brain\23acf333-d29b-4e11-b1f9-11cafc4f6492\scratch\ECC\skills";
            string targetAgentsDir = @"d:\benim antigravitiler\altıgenler\.agents\skills";
            string targetClaudeDir = @"d:\benim antigravitiler\altıgenler\.claude\skills";

            if (!Directory.Exists(sourceSkillsDir))
            {
                Console.WriteLine("Kaynak ECC skills dizini bulunamadı: " + sourceSkillsDir);
                return;
            }

            Directory.CreateDirectory(targetAgentsDir);
            Directory.CreateDirectory(targetClaudeDir);

            var skillDirs = Directory.GetDirectories(sourceSkillsDir);
            Console.WriteLine("Toplam " + skillDirs.Length + " ECC yeteneği bulundu. Kurulum başlıyor...");

            int installedCount = 0;

            foreach (var dir in skillDirs)
            {
                string skillName = Path.GetFileName(dir);
                string skillFile = Path.Combine(dir, "SKILL.md");

                if (!File.Exists(skillFile))
                    continue;

                string destAgentsDir = Path.Combine(targetAgentsDir, skillName);
                string destClaudeDir = Path.Combine(targetClaudeDir, skillName);

                CopyDirectory(dir, destAgentsDir);
                CopyDirectory(dir, destClaudeDir);

                // SKILL.md oku ve description alanını Türkçeleştir
                string content = File.ReadAllText(skillFile, Encoding.UTF8);
                string updatedContent = TranslateSkillDescription(skillName, content);

                File.WriteAllText(Path.Combine(destAgentsDir, "SKILL.md"), updatedContent, new UTF8Encoding(false));
                File.WriteAllText(Path.Combine(destClaudeDir, "SKILL.md"), updatedContent, new UTF8Encoding(false));

                installedCount++;
            }

            Console.WriteLine("Başarıyla " + installedCount + " adet ECC yeteneği kuruldu ve Türkçeleştirildi!");
        }

        static void CopyDirectory(string sourceDir, string targetDir)
        {
            Directory.CreateDirectory(targetDir);

            foreach (string file in Directory.GetFiles(sourceDir))
            {
                string destFile = Path.Combine(targetDir, Path.GetFileName(file));
                File.Copy(file, destFile, true);
            }

            foreach (string subDir in Directory.GetDirectories(sourceDir))
            {
                string destSubDir = Path.Combine(targetDir, Path.GetFileName(subDir));
                CopyDirectory(subDir, destSubDir);
            }
        }

        static string TranslateSkillDescription(string skillName, string content)
        {
            var match = Regex.Match(content, @"^---\r?\n(.*?)\r?\n---", RegexOptions.Singleline);
            if (!match.Success)
                return content;

            string frontmatter = match.Groups[1].Value;
            string restOfDoc = content.Substring(match.Length);

            // Mevcut description'ı bul
            var descMatch = Regex.Match(frontmatter, @"description:\s*(?:""([^""]*)""|'([^']*)'|([^\r\n]+(?:\r?\n\s+[^\r\n]+)*))", RegexOptions.Multiline);
            
            string originalDesc = "";
            if (descMatch.Success)
            {
                if (descMatch.Groups[1].Success) originalDesc = descMatch.Groups[1].Value;
                else if (descMatch.Groups[2].Success) originalDesc = descMatch.Groups[2].Value;
                else originalDesc = descMatch.Groups[3].Value.Trim();
            }

            string turkishDesc = GenerateTurkishDescription(skillName, originalDesc);

            // Yeni description ile güncelle
            string newFrontmatter;
            if (descMatch.Success)
            {
                newFrontmatter = frontmatter.Substring(0, descMatch.Index) + 
                                 "description: \"" + turkishDesc.Replace("\"", "\\\"") + "\"" + 
                                 frontmatter.Substring(descMatch.Index + descMatch.Length);
            }
            else
            {
                newFrontmatter = frontmatter + "\ndescription: \"" + turkishDesc.Replace("\"", "\\\"") + "\"";
            }

            return "---\n" + newFrontmatter + "\n---" + restOfDoc;
        }

        static string GenerateTurkishDescription(string name, string originalDesc)
        {
            // Özel isim eşlemeleri ve kategori çevirileri
            string cleanName = name.Replace("-", " ");
            
            if (TurkishDictionary.ContainsKey(name))
                return TurkishDictionary[name];

            // Akıllı kural tabanlı çeviri
            if (name.Contains("pattern") || name.Contains("patterns"))
                return cleanName.ToUpper() + " için en iyi mimari desenler, kodlama pratikleri ve tasarım standartları rehberi.";
            if (name.Contains("test") || name.Contains("testing"))
                return cleanName.ToUpper() + " için uçtan uca, birim (unit) ve entegrasyon test stratejileri ve otomasyon rehberi.";
            if (name.Contains("security") || name.Contains("audit"))
                return cleanName.ToUpper() + " için kapsamlı güvenlik denetimi, zafiyet taraması ve sertleştirme standartları.";
            if (name.Contains("review"))
                return cleanName.ToUpper() + " için derinlemesine kod, mimari ve kalite inceleme protokolü.";
            if (name.Contains("workflow") || name.Contains("pipeline"))
                return cleanName.ToUpper() + " için optimize edilmiş geliştirme iş akışı ve CI/CD süreç rehberi.";
            if (name.Contains("perf") || name.Contains("performance"))
                return cleanName.ToUpper() + " için profil oluşturma, bellek yönetimi ve performans optimizasyonu rehberi.";
            if (name.Contains("ops") || name.Contains("operation"))
                return cleanName.ToUpper() + " operasyonları, yönetim araçları ve otomatik süreç kılavuzu.";
            if (name.Contains("design") || name.Contains("ui"))
                return cleanName.ToUpper() + " için modern arayüz tasarımı, UX ilkeleri ve bileşen standartları.";

            if (!string.IsNullOrWhiteSpace(originalDesc))
            {
                string desc = originalDesc.Replace("\r", " ").Replace("\n", " ").Trim();
                if (desc.Length > 200) desc = desc.Substring(0, 197) + "...";
                return desc;
            }

            return cleanName.ToUpper() + " geliştirme, optimizasyon ve yönetim yeteneği.";
        }

        static readonly Dictionary<string, string> TurkishDictionary = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "accessibility", "WCAG 2.2 Seviye AA standartlarına uygun, ekran okuyucu ve klavye destekli kapsayıcı dijital arayüzler tasarlar ve denetler." },
            { "agent-architecture-audit", "Yapay zeka ajan ve LLM uygulamaları için 12 katmanlı yığın denetimi, döngü hataları ve bellek kirliliği teşhisi yapar." },
            { "agent-eval", "Kodlama ajanlarını (Claude Code, Aider, Codex) başarı oranı, maliyet, süre ve tutarlılık metriklerine göre kıyaslar." },
            { "agent-harness-construction", "Yapay zeka ajanlarının aksiyon alanlarını, araç tanımlarını ve gözlem formatlarını daha yüksek başarı için optimize eder." },
            { "agent-introspection-debugging", "Ajan çalışma hatalarını, kilitlenmeleri ve sonsuz döngüleri yapılandırılmış öz-hata ayıklama ile teşhis eder." },
            { "api-design", "RESTful ve GraphQL API'leri için tutarlı, sürümlenebilir, güvenli ve yüksek performanslı uç nokta tasarımı rehberi." },
            { "backend-patterns", "Mikroservisler, veri erişim katmanları, caching ve arka uç mimarileri için endüstriyel standartlar." },
            { "clean-architecture", "Bağımlılık kuralı, domain katmanı ve kullanım senaryolarını (use cases) ayrıştıran Temiz Mimari rehberi." },
            { "cloud-infrastructure", "AWS, GCP ve Azure üzerinde güvenli, ölçeklenebilir ve maliyet etkin bulut altyapı tasarımı." },
            { "database-optimization", "SQL/NoSQL sorgu optimizasyonu, indeksleme stratejileri, bağlantı havuzları ve şema tasarımı rehberi." },
            { "devops-automation", "Docker, Kubernetes, GitHub Actions ve CI/CD hatları için sıfır kesinti otomatik dağıtım rehberi." },
            { "docker-patterns", "Çok aşamalı (multi-stage) derleme, küçük imaj boyutları ve güvenli container yapılandırma standartları." },
            { "fastapi-patterns", "Python FastAPI için asenkron uç noktalar, Pydantic doğrulama ve Dependency Injection standartları." },
            { "frontend-patterns", "React ve Next.js için bileşen kompozisyonu, state yönetimi ve render performans optimizasyonu." },
            { "git-workflow", "Trunk-based development, özellik dalları, semantik commitler ve temiz rebase iş akışları." },
            { "golang-patterns", "Go dilinde eşzamanlılık (concurrency), kanal yönetimi, hata işleme ve idiomatik paket tasarımı." },
            { "graphql-patterns", "GraphQL şema tasarımı, resolver optimizasyonu, N+1 problem çözümü ve caching stratejileri." },
            { "kubernetes-patterns", "Kubernetes dağıtımları, ingress kontrolcüleri, pod güvenliği ve kaynak bütçeleme rehberi." },
            { "nextjs-turbopack", "Next.js App Router, sunucu bileşenleri (RSC), SSR/SSG ve Turbopack optimizasyon rehberi." },
            { "nodejs-patterns", "Node.js olay döngüsü (Event Loop), stream yönetimi ve ölçeklenebilir backend mimarisi." },
            { "performance-profiling", "CPU, bellek sızıntıları, I/O darboğazları ve ağ gecikmeleri için profil çıkarma rehberi." },
            { "python-patterns", "Modern Python 3.12+ type hinting, dataclass'lar, context manager'lar ve temiz kod standartları." },
            { "react-native-patterns", "React Native ve Expo ile yüksek performanslı, akıcı ve yerel hissettiren mobil uygulama mimarisi." },
            { "react-patterns", "React özel hook'ları, Context optimizasyonu, bileşen ayrıştırma ve render verimliliği." },
            { "redis-patterns", "Redis ile önbellekleme, pub/sub mesajlaşma, distributed lock ve hız sınırlama desenleri." },
            { "rest-api-patterns", "HTTP durum kodları, filtreleme/sayfalama standartları ve API güvenlik sertleştirmesi." },
            { "rust-patterns", "Rust dilinde sahiplik (ownership), trait tasarımı, eşzamanlılık ve sıfır maliyetli soyutlamalar." },
            { "security-review", "OWASP Top 10 açıkları, veri sanitizasyonu, JWT/OAuth2 ve şifreleme denetim protokolü." },
            { "seo", "Arama motoru optimizasyonu, Core Web Vitals, semantik etiketleme ve yapılandırılmış veri rehberi." },
            { "tailwindcss-patterns", "Tailwind CSS ile tasarım tokenleri, responsive yapılar ve temiz stil kompozisyonu." },
            { "tdd-workflow", "Test-Güdümlü Geliştirme (TDD) kırmızı-yeşil-refactor döngüsü ve yüksek test kapsamı." },
            { "typescript-patterns", "İleri seviye TypeScript generic'ler, conditional type'lar ve tip güvenliği mimarisi." },
            { "vue-patterns", "Vue 3 Composition API, Pinia state yönetimi ve reaktif bileşen optimizasyon rehberi." },
            { "web-security", "XSS, CSRF, CORS, CSP ve güvenli oturum yönetimi için web güvenlik protokolü." },
            { "websockets-patterns", "Gerçek zamanlı iki yönlü iletişim, bağlantı kurtarma ve heartbeat protokolleri." }
        };
    }
}
