using System;
using System.IO;
using System.IO.Compression;
using System.Security;
using System.Text;

public class DocxBuilder
{
    public static void Main(string[] args)
    {
        string baseDir = Directory.Exists(Path.Combine(Environment.CurrentDirectory, "docs")) 
            ? Environment.CurrentDirectory 
            : Directory.GetParent(AppDomain.CurrentDomain.BaseDirectory).FullName;

        string mdPath = Path.Combine(baseDir, @"docs\YAPAY_ZEKA_KOMUT_REHBERI.md");
        string docxPath = Path.Combine(baseDir, "Hex_Idle_Komut_Rehberi.docx");

        if (!File.Exists(mdPath))
        {
            Console.WriteLine("HATA: Markdown dosyasi bulunamadi: " + mdPath);
            return;
        }

        string[] lines = File.ReadAllLines(mdPath, Encoding.UTF8);
        StringBuilder body = new StringBuilder();

        bool inCodeBlock = false;
        StringBuilder codeBuf = new StringBuilder();

        foreach (string rawLine in lines)
        {
            string line = rawLine.Trim();

            if (line.StartsWith("```"))
            {
                if (inCodeBlock)
                {
                    inCodeBlock = false;
                    string code = SecurityElement.Escape(codeBuf.ToString().Trim());
                    body.Append("<w:p>");
                    body.Append("<w:pPr>");
                    body.Append("<w:pBdr><w:left w:val=\"single\" w:sz=\"24\" w:space=\"15\" w:color=\"3182CE\"/></w:pBdr>");
                    body.Append("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"EDF2F7\"/>");
                    body.Append("<w:spacing w:before=\"60\" w:after=\"160\" w:line=\"240\" w:lineRule=\"auto\"/>");
                    body.Append("<w:ind w:left=\"240\" w:right=\"240\"/>");
                    body.Append("</w:pPr>");
                    body.Append("<w:r>");
                    body.Append("<w:rPr><w:rFonts w:ascii=\"Consolas\" w:hAnsi=\"Consolas\"/><w:sz w:val=\"20\"/><w:color w:val=\"2B6CB0\"/></w:rPr>");
                    body.Append("<w:t xml:space=\"preserve\">" + code + "</w:t>");
                    body.Append("</w:r>");
                    body.Append("</w:p>");
                    codeBuf.Clear();
                }
                else
                {
                    inCodeBlock = true;
                    codeBuf.Clear();
                }
                continue;
            }

            if (inCodeBlock)
            {
                if (codeBuf.Length > 0) codeBuf.Append("\n");
                codeBuf.Append(rawLine);
                continue;
            }

            if (string.IsNullOrEmpty(line) || line == "---")
            {
                continue;
            }

            if (line.StartsWith("# "))
            {
                string text = SecurityElement.Escape(line.Substring(2).Trim());
                body.Append("<w:p>");
                body.Append("<w:pPr><w:jc w:val=\"center\"/><w:spacing w:before=\"360\" w:after=\"100\"/></w:pPr>");
                body.Append("<w:r>");
                body.Append("<w:rPr><w:rFonts w:ascii=\"Calibri Light\" w:hAnsi=\"Calibri Light\"/><w:b/><w:color w:val=\"1A365D\"/><w:sz w:val=\"44\"/></w:rPr>");
                body.Append("<w:t>" + text + "</w:t>");
                body.Append("</w:r>");
                body.Append("</w:p>");
            }
            else if (line.StartsWith("## "))
            {
                string text = SecurityElement.Escape(line.Substring(3).Trim());
                body.Append("<w:p>");
                body.Append("<w:pPr><w:jc w:val=\"center\"/><w:spacing w:before=\"0\" w:after=\"260\"/><w:pBdr><w:bottom w:val=\"single\" w:sz=\"18\" w:space=\"10\" w:color=\"CBD5E0\"/></w:pBdr></w:pPr>");
                body.Append("<w:r>");
                body.Append("<w:rPr><w:color w:val=\"4A5568\"/><w:sz w:val=\"24\"/><w:i/></w:rPr>");
                body.Append("<w:t>" + text + "</w:t>");
                body.Append("</w:r>");
                body.Append("</w:p>");
            }
            else if (line.StartsWith("### "))
            {
                string text = SecurityElement.Escape(line.Substring(4).Trim());
                body.Append("<w:p>");
                body.Append("<w:pPr><w:pStyle w:val=\"Heading1\"/><w:spacing w:before=\"320\" w:after=\"120\"/></w:pPr>");
                body.Append("<w:r>");
                body.Append("<w:rPr><w:b/><w:color w:val=\"1A365D\"/><w:sz w:val=\"32\"/></w:rPr>");
                body.Append("<w:t>" + text + "</w:t>");
                body.Append("</w:r>");
                body.Append("</w:p>");
            }
            else if (line.StartsWith("#### "))
            {
                string text = SecurityElement.Escape(line.Substring(5).Trim());
                body.Append("<w:p>");
                body.Append("<w:pPr><w:pStyle w:val=\"Heading2\"/><w:spacing w:before=\"200\" w:after=\"60\"/></w:pPr>");
                body.Append("<w:r>");
                body.Append("<w:rPr><w:b/><w:color w:val=\"2B6CB0\"/><w:sz w:val=\"26\"/></w:rPr>");
                body.Append("<w:t>" + text + "</w:t>");
                body.Append("</w:r>");
                body.Append("</w:p>");
            }
            else if (line.Contains("Görevi:**") || line.Contains("Gorevi:**"))
            {
                int idx = line.IndexOf(":**");
                string desc = SecurityElement.Escape(line.Substring(idx + 3).Trim());
                body.Append("<w:p>");
                body.Append("<w:r><w:rPr><w:b/><w:color w:val=\"2B6CB0\"/></w:rPr><w:t>📌 Görevi: </w:t></w:r>");
                body.Append("<w:r><w:t>" + desc + "</w:t></w:r>");
                body.Append("</w:p>");
            }
            else if (line.Contains("Bu Projede Kullanımı:**") || line.Contains("Projede Kullanım Alanı:**"))
            {
                int idx = line.IndexOf(":**");
                string usage = SecurityElement.Escape(line.Substring(idx + 3).Trim());
                body.Append("<w:p>");
                body.Append("<w:r><w:rPr><w:b/><w:color w:val=\"276749\"/></w:rPr><w:t>💡 Bu Projede Kullanımı: </w:t></w:r>");
                body.Append("<w:r><w:t>" + usage + "</w:t></w:r>");
                body.Append("</w:p>");
            }
            else if (line.Contains("Örnek İstem:**") || line.Contains("Ornek Istem:**"))
            {
                body.Append("<w:p>");
                body.Append("<w:r><w:rPr><w:b/><w:color w:val=\"744210\"/></w:rPr><w:t>🎯 Örnek İstem (Prompt):</w:t></w:r>");
                body.Append("</w:p>");
            }
            else
            {
                string cleanText = SecurityElement.Escape(line.Replace("**", ""));
                body.Append("<w:p>");
                body.Append("<w:r><w:rPr><w:color w:val=\"2D3748\"/><w:sz w:val=\"22\"/></w:rPr><w:t>" + cleanText + "</w:t></w:r>");
                body.Append("</w:p>");
            }
        }

        string documentXml = @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<w:document xmlns:w=""http://schemas.openxmlformats.org/wordprocessingml/2006/main"">
  <w:body>
" + body.ToString() + @"
    <w:sectPr>
      <w:pgSz w:w=""11906"" w:h=""16838""/>
      <w:pgMar w:top=""1440"" w:right=""1440"" w:bottom=""1440"" w:left=""1440"" w:header=""720"" w:footer=""720"" w:gutter=""0""/>
    </w:sectPr>
  </w:body>
</w:document>";

        string contentTypesXml = @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Types xmlns=""http://schemas.openxmlformats.org/package/2006/content-types"">
  <Default Extension=""rels"" ContentType=""application/vnd.openxmlformats-package.relationships+xml""/>
  <Default Extension=""xml"" ContentType=""application/xml""/>
  <Override PartName=""/word/document.xml"" ContentType=""application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml""/>
  <Override PartName=""/word/styles.xml"" ContentType=""application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml""/>
</Types>";

        string dotRelsXml = @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships"">
  <Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"" Target=""word/document.xml""/>
</Relationships>";

        string docRelsXml = @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships"">
  <Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"" Target=""styles.xml""/>
</Relationships>";

        string stylesXml = @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<w:styles xmlns:w=""http://schemas.openxmlformats.org/wordprocessingml/2006/main"">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii=""Calibri"" w:hAnsi=""Calibri"" w:cs=""Calibri""/>
        <w:sz w:val=""22""/>
        <w:color w:val=""2D3748""/>
        <w:lang w:val=""tr-TR""/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:after=""140"" w:line=""276"" w:lineRule=""auto""/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type=""paragraph"" w:styleId=""Heading1"">
    <w:name w:val=""heading 1""/>
    <w:pPr>
      <w:spacing w:before=""360"" w:after=""160""/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii=""Calibri Light"" w:hAnsi=""Calibri Light""/>
      <w:b/>
      <w:color w:val=""1A365D""/>
      <w:sz w:val=""32""/>
    </w:rPr>
  </w:style>
  <w:style w:type=""paragraph"" w:styleId=""Heading2"">
    <w:name w:val=""heading 2""/>
    <w:pPr>
      <w:spacing w:before=""240"" w:after=""120""/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii=""Calibri"" w:hAnsi=""Calibri""/>
      <w:b/>
      <w:color w:val=""2B6CB0""/>
      <w:sz w:val=""26""/>
    </w:rPr>
  </w:style>
</w:styles>";

        if (File.Exists(docxPath)) File.Delete(docxPath);

        using (FileStream fs = new FileStream(docxPath, FileMode.Create))
        using (ZipArchive archive = new ZipArchive(fs, ZipArchiveMode.Create))
        {
            WriteZipEntry(archive, "[Content_Types].xml", contentTypesXml);
            WriteZipEntry(archive, "_rels/.rels", dotRelsXml);
            WriteZipEntry(archive, "word/_rels/document.xml.rels", docRelsXml);
            WriteZipEntry(archive, "word/styles.xml", stylesXml);
            WriteZipEntry(archive, "word/document.xml", documentXml);
        }

        Console.WriteLine("DOCX BASARIYLA OLUSTURULDU: " + docxPath);
    }

    private static void WriteZipEntry(ZipArchive archive, string entryName, string content)
    {
        ZipArchiveEntry entry = archive.CreateEntry(entryName, CompressionLevel.Optimal);
        using (Stream s = entry.Open())
        using (StreamWriter sw = new StreamWriter(s, Encoding.UTF8))
        {
            sw.Write(content);
        }
    }
}
