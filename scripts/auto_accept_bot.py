import sys
import os
import time
import re
import argparse
import ctypes
import ctypes.wintypes

# High DPI Awareness ayarı (Piksel ve koordinat kaymalarını engeller)
try:
    ctypes.windll.shcore.SetProcessDpiAwareness(2)  # Per-monitor DPI aware
except Exception:
    try:
        ctypes.windll.user32.SetProcessDPIAware()
    except Exception:
        pass

try:
    import win32gui
    import win32con
    import win32api
    import win32ui
    import win32process
except ImportError:
    print("pywin32 bulunamadi. pip install pywin32 calistirin.")
    sys.exit(1)

try:
    import psutil
except ImportError:
    psutil = None

try:
    import uiautomation as auto
    auto.SetGlobalSearchTimeout(0.5)
except ImportError:
    auto = None

try:
    from PIL import ImageGrab
except ImportError:
    ImageGrab = None

# Bilinen IDE / Editor süreç isimleri
KNOWN_PROCESS_NAMES = {
    "antigravity ide.exe",
    "antigravity.exe",
    "code.exe",
    "cursor.exe",
    "windsurf.exe",
    "vscodium.exe",
    "electron.exe",
    "flutter.exe",
    "dart.exe",
    "flutter_tester.exe",
    "hex_rush.exe",
    "altigen.exe",
    "main.exe",
}

# Bilinen pencere başlığı anahtar kelimeleri
KNOWN_TITLE_KEYWORDS = [
    "antigravity",
    "visual studio code",
    "cursor",
    "windsurf",
    "vscodium",
    "flutter",
    "hexrush",
    "hex_rush",
    "altigen",
    "dart",
]

# Onaylanması istenen buton metinleri / anahtar kelimeleri (Büyük/küçük harf duyarsız)
APPROVAL_KEYWORDS = [
    "proceed",
    "proceed to execution",
    "accept",
    "accept all",
    "accept (keep)",
    "accept changes",
    "apply",
    "apply changes",
    "run",
    "run command",
    "run task",
    "execute",
    "always run",
    "allow",
    "allow always",
    "always allow",
    "allow once",
    "allow command",
    "allow this time",
    "approve",
    "approve all",
    "submit",
    "confirm",
    "yes",
    "continue",
    "retry",
    "ok",
    "save",
    "save all",
    # Türkçe terimler
    "kabul et",
    "tumunu kabul et",
    "onayla",
    "devam et",
    "calistir",
    "izin ver",
    "her zaman izin ver",
    "uygula",
    "evet",
    "kaydet",
]

# KESİNLİKLE TIKLANMAMASI gereken buton ve işlemler (Güvenlik Koruması)
EXCLUDED_KEYWORDS = [
    "cancel",
    "reject",
    "deny",
    "dismiss",
    "stop",
    "abort",
    "no",
    "close",
    "iptal",
    "reddet",
    "kapat",
    "durdur",
    "sil",
    "delete",
    "clear",
    "send",
    "send message",
    "gonder",
    "microphone",
    "voice",
    "new chat",
    "attach",
    "minimize",
    "maximize",
    "restore",
    "kucult",
    "buyut",
]

user32 = ctypes.windll.user32
WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)


def get_process_name_by_pid(pid):
    if pid <= 0:
        return ""
    if psutil:
        try:
            return psutil.Process(pid).name().lower()
        except Exception:
            return ""
    return ""


def is_ide_window(hwnd, filter_title=None):
    if not win32gui.IsWindowVisible(hwnd) or win32gui.IsIconic(hwnd):
        return False

    rect = win32gui.GetWindowRect(hwnd)
    w = rect[2] - rect[0]
    h = rect[3] - rect[1]
    if w < 300 or h < 300:
        return False

    title = win32gui.GetWindowText(hwnd)

    if filter_title:
        return bool(title and filter_title.lower() in title.lower())

    if title:
        title_lower = title.lower()
        if any(keyword in title_lower for keyword in KNOWN_TITLE_KEYWORDS):
            return True

    cls_name = win32gui.GetClassName(hwnd)
    if cls_name in ("FLUTTER_RUNNER_WIN32_WINDOW", "Chrome_WidgetWin_1"):
        return True

    _, pid = win32process.GetWindowThreadProcessId(hwnd)
    pname = get_process_name_by_pid(pid)
    if pname in KNOWN_PROCESS_NAMES:
        return True

    return False


def find_target_windows(filter_title=None):
    matching_hwnds = []

    def enum_cb(hwnd, _):
        if is_ide_window(hwnd, filter_title):
            if hwnd not in matching_hwnds:
                matching_hwnds.append(hwnd)
        return True

    hdesk = user32.OpenInputDesktop(0, False, 0x0001 | 0x0020 | 0x0040)
    if hdesk:
        user32.EnumDesktopWindows(hdesk, WNDENUMPROC(enum_cb), 0)
        user32.CloseDesktop(hdesk)
    else:
        win32gui.EnumWindows(enum_cb, None)

    return matching_hwnds


def is_approval_text(text):
    if not text:
        return False
    t = text.strip().lower()
    t_clean = re.sub(r"[^\w\s]", " ", t).strip()

    # Reddetme / iptal / gönderme anahtar kelimelerini ele
    for ex in EXCLUDED_KEYWORDS:
        if ex in t_clean.split():
            return False

    # Tam eşleşme veya onay kelimesi kontrolü
    for app in APPROVAL_KEYWORDS:
        if t == app or t_clean == app:
            return True
        if app in t_clean.split():
            return True
        if len(app) > 3 and app in t_clean:
            return True

    return False


def physical_click(x, y, restore_cursor=True):
    """Kullanıcının fare imlecini bozmadan ilgili noktaya donanımsal tıklama yapar."""
    orig_x, orig_y = None, None
    try:
        if restore_cursor:
            pt = ctypes.wintypes.POINT()
            user32.GetCursorPos(ctypes.byref(pt))
            orig_x, orig_y = pt.x, pt.y

        user32.SetCursorPos(int(x), int(y))
        time.sleep(0.02)
        user32.mouse_event(0x0002, 0, 0, 0, 0)  # MOUSEEVENTF_LEFTDOWN
        time.sleep(0.04)
        user32.mouse_event(0x0004, 0, 0, 0, 0)  # MOUSEEVENTF_LEFTUP

        if restore_cursor and orig_x is not None and orig_y is not None:
            time.sleep(0.02)
            user32.SetCursorPos(orig_x, orig_y)
        return True
    except Exception:
        return False


def try_uia_auto_accept(hwnd):
    """Windows UI Automation erişilebilirlik ağacını kullanarak onay butonlarını tıklar."""
    if auto is None:
        return False

    try:
        win_ctrl = auto.ControlFromHandle(hwnd)
        if not win_ctrl or not win_ctrl.Exists(maxSearchSeconds=0.1):
            return False

        # Pencere içindeki buton, link ve etkileşimli elementleri tara
        controls = win_ctrl.GetChildren()
        
        # Derinlemesine arama için kuyruk
        queue = list(controls)
        depth = 0
        max_depth = 12

        while queue and depth < 200:
            depth += 1
            ctrl = queue.pop(0)

            try:
                name = ctrl.Name or ""
                help_text = getattr(ctrl, "HelpText", "") or ""
                combined_text = f"{name} {help_text}".strip()

                if combined_text and is_approval_text(combined_text):
                    # Butonun ekran koordinatlarını al
                    rect = ctrl.BoundingRectangle
                    if rect and rect.width() >= 20 and rect.height() >= 14:
                        # Chat giriş kutusunun altındaki 'gönder' butonlarını ele (pencere yüksekliğine göre)
                        win_rect = win32gui.GetWindowRect(hwnd)
                        win_h = win_rect[3] - win_rect[1]
                        rel_y = rect.top - win_rect[1]
                        
                        # Pencerenin en alt 45 pikselindeki araç çubuklarını hariç tut
                        if rel_y < win_h - 45:
                            cx = (rect.left + rect.right) // 2
                            cy = (rect.top + rect.bottom) // 2

                            # 1. Yöntem: UIA Invoke
                            invoked = False
                            try:
                                invoke_pat = ctrl.GetInvokePattern()
                                if invoke_pat:
                                    invoke_pat.Invoke()
                                    invoked = True
                            except Exception:
                                pass

                            # 2. Yöntem: Fiziksel Tıklama
                            if not invoked:
                                physical_click(cx, cy)

                            title = win32gui.GetWindowText(hwnd) or "IDE Window"
                            print(f"[{time.strftime('%H:%M:%S')}] [UIA] Otomatik Onaylandi: '{combined_text}' ({cx}, {cy}) -> {title[:35]}")
                            return True

                # Alt elementleri kuyruğa ekle
                children = ctrl.GetChildren()
                if children and len(queue) < 150:
                    queue.extend(children)

            except Exception:
                continue

        return False
    except Exception:
        return False


def is_action_button_color(r, g, b):
    # 1. Mavi / Indigo / Mor Butonlar (VS Code, Antigravity, Cursor)
    if b > 120 and (b - r) > 25 and b >= (g - 15):
        return True
    # 2. Yeşil / Zümrüt Onay Butonları (Proceed / Apply / Run)
    if g > 120 and (g - r) > 25 and g >= (b - 20):
        return True
    # 3. Amber / Turuncu Butonlar
    if r > 180 and g > 110 and b < 90:
        return True
    return False


def try_screen_color_auto_accept(hwnd):
    """GPU ile çizilen pencereler için masaüstü ekran görüntüsünü tarayıp renkli butonları tıklar."""
    if ImageGrab is None:
        return False

    try:
        rect = win32gui.GetWindowRect(hwnd)
        x1, y1, x2, y2 = rect
        w = x2 - x1
        h = y2 - y1

        if w <= 200 or h <= 200:
            return False

        # Masaüstü ekran görüntüsünden sadece IDE penceresinin alanını al
        screen_img = ImageGrab.grab(bbox=(max(0, x1), max(0, y1), x2, y2))
        img_w, img_h = screen_img.size

        if img_w < 100 or img_h < 100:
            return False

        # Tarama Alanı:
        # Chat paneli genelde sağ taraftadır veya tüm ekrandır.
        # En alttaki 75 piksel (Prompt input ve send butonu) hariç tutulur.
        scan_start_x = max(0, int(img_w * 0.40))
        scan_end_x = max(scan_start_x + 10, img_w - 20)

        scan_start_y = max(0, img_h - 450)
        scan_end_y = max(scan_start_y + 10, img_h - 80)

        pixels = screen_img.load()

        # 4 piksel aralıklarla hızlı tarama
        for y in range(scan_start_y, scan_end_y, 4):
            for x in range(scan_start_x, scan_end_x, 4):
                p = pixels[x, y]
                r, g, b = p[0], p[1], p[2]

                if is_action_button_color(r, g, b):
                    # Buton genişliğini doğrula (En az 30px genişlik)
                    span_w = 0
                    for check_x in range(x, min(x + 60, scan_end_x)):
                        cp = pixels[check_x, y]
                        if is_action_button_color(cp[0], cp[1], cp[2]):
                            span_w += 1
                        else:
                            # Metin boşluğu toleransı
                            if check_x > x + 10:
                                span_w += 1

                    if span_w >= 24:
                        # Buton yüksekliğini doğrula (En az 16px)
                        span_h = 0
                        for check_y in range(y, min(y + 35, scan_end_y)):
                            cp = pixels[x + 10, check_y]
                            if is_action_button_color(cp[0], cp[1], cp[2]):
                                span_h += 1

                        if span_h >= 10:
                            target_x = x1 + x + 25
                            target_y = y1 + y + 10
                            title = win32gui.GetWindowText(hwnd) or "IDE Window"
                            print(
                                f"[{time.strftime('%H:%M:%S')}] [Ekran Tarayici] Renkli Onay Butonu Algilandi ({target_x}, {target_y}) -> {title[:35]}"
                            )
                            physical_click(target_x, target_y)
                            return True

        return False
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser(description="Evrensel IDE Agent Otomatik Onay Botu (Antigravity, VS Code, Cursor, Windsurf)")
    parser.add_argument(
        "--title",
        "-t",
        type=str,
        default=None,
        help="Sadece belirli bir proje/başlık içeren pencereyi takip etmek için (varsayılan: Tüm açık projeler)",
    )
    parser.add_argument(
        "--interval",
        "-i",
        type=float,
        default=0.25,
        help="Kontrol sıklığı saniye cinsinden (varsayılan: 0.25 sn)",
    )
    args = parser.parse_args()

    print("=" * 65)
    print("🚀 Evrensel IDE Agent Otomatik Onay Botu Aktif")
    print("=" * 65)
    if args.title:
        print(f"🎯 Hedef Filtresi: '{args.title}'")
    else:
        print("🌐 Mod: EVRENSEL (Tüm Antigravity IDE, VS Code, Cursor pencereleri)")
    print("🔍 Motor 1: Windows UI Automation (Erişilebilirlik Ağacı & Akıllı Metin)")
    print("🔍 Motor 2: Yüksek Çözünürlüklü Masaüstü Renk & Geometri Tarayıcısı")
    print("🛡️ Güvenlik: Prompt giriş kutusu ve mesaj gönderme okları koruma altındadır.")
    print("⏱️ Tarama Sıklığı:", f"{args.interval} sn")
    print("🛑 Çıkış için CTRL+C tuşlarına basın.\n")

    last_window_count = -1
    last_log_time = 0

    try:
        while True:
            hwnds = find_target_windows(filter_title=args.title)

            if len(hwnds) != last_window_count or (time.time() - last_log_time > 20):
                last_window_count = len(hwnds)
                last_log_time = time.time()
                if hwnds:
                    titles = [win32gui.GetWindowText(h) or "IDE Window" for h in hwnds]
                    print(f"[{time.strftime('%H:%M:%S')}] Takip edilen aktif IDE sayısı: {len(hwnds)}")
                    for t in titles:
                        print(f"   ↳ {t[:70]}")
                else:
                    print(f"[{time.strftime('%H:%M:%S')}] Aktif IDE penceresi aranıyor...")

            for hwnd in hwnds:
                # 1. Adım: UI Automation ile onay butonu ara ve tıkla
                accepted = try_uia_auto_accept(hwnd)

                # 2. Adım: Bulunamazsa Masaüstü Renk/Geometri Tarayıcısını çalıştır
                if not accepted:
                    accepted = try_screen_color_auto_accept(hwnd)

                if accepted:
                    time.sleep(0.8)  # Peş peşe çift tıklamaları engellemek için bekleme

            time.sleep(args.interval)

    except KeyboardInterrupt:
        print("\n👋 Otomatik Onay Botu durduruldu. İyi çalışmalar!")


if __name__ == "__main__":
    main()
