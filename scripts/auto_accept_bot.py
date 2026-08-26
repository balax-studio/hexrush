import sys
import os
import time
import argparse
import ctypes
import ctypes.wintypes

try:
    import win32gui
    import win32con
    import win32api
    import win32ui
    import win32process
except ImportError:
    print("Gerekli kütüphaneler bulunamadı. Lütfen terminale şu komutu yazarak kurun:")
    print("pip install pywin32 psutil")
    sys.exit(1)

try:
    import psutil
except ImportError:
    psutil = None

# Bilinen IDE süreçleri ve pencere anahtar kelimeleri
KNOWN_PROCESS_NAMES = {
    "antigravity ide.exe",
    "antigravity.exe",
    "code.exe",
    "cursor.exe",
    "windsurf.exe",
    "vscodium.exe",
    "electron.exe",
}

KNOWN_TITLE_KEYWORDS = [
    "antigravity",
    "visual studio code",
    "cursor",
    "windsurf",
    "vscodium",
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
    if cls_name == "Chrome_WidgetWin_1":
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


def click_in_background(hwnd, x, y):
    lParam = win32api.MAKELONG(int(x), int(y))
    win32gui.PostMessage(hwnd, win32con.WM_LBUTTONDOWN, win32con.MK_LBUTTON, lParam)
    time.sleep(0.08)
    win32gui.PostMessage(hwnd, win32con.WM_LBUTTONUP, 0, lParam)


def is_blue_pixel(b, g, r):
    # Standart IDE mavi onay butonları: B belirgin şekilde yüksek, R düşük
    return b > 125 and r < 95 and (b - r) > 35 and b >= (g - 15)


def find_and_click_blue_button(hwnd):
    hwndDC = None
    mfcDC = None
    saveDC = None
    saveBitMap = None
    try:
        rect = win32gui.GetWindowRect(hwnd)
        w = rect[2] - rect[0]
        h = rect[3] - rect[1]

        if w <= 100 or h <= 100:
            return False

        hwndDC = win32gui.GetWindowDC(hwnd)
        mfcDC = win32ui.CreateDCFromHandle(hwndDC)
        saveDC = mfcDC.CreateCompatibleDC()

        saveBitMap = win32ui.CreateBitmap()
        saveBitMap.CreateCompatibleBitmap(mfcDC, w, h)
        saveDC.SelectObject(saveBitMap)

        result = ctypes.windll.user32.PrintWindow(hwnd, saveDC.GetSafeHdc(), 2)
        if not result:
            return False

        # Güvenli Tarama Alanı:
        # 1. En alttaki 75 piksel (Chat prompt giriş kutusu, mikrofon ve mavi gönderme oku) KESİNLİKLE TARANMAZ.
        # 2. Onay/İşlem butonları input kutusunun hemen üzerinde (h-75 ile h-350 arasında) yer alır.
        scan_w = min(400, int(w * 0.45))
        start_x = max(0, w - scan_w)
        end_x = min(w - 20, w - 1)

        start_y = max(0, h - 350)
        end_y = max(start_y + 10, h - 75)  # Alt 75 pikseli hariç tutarak mesaj gönderme okuna tıklanmasını engeller

        bmpstr = saveBitMap.GetBitmapBits(True)
        row_bytes = w * 4

        # 3 piksel atlamalı tarama
        for y in range(start_y, end_y + 1, 3):
            y_offset = y * row_bytes
            for x in range(start_x, end_x + 1, 3):
                idx = y_offset + (x * 4)
                if idx + 2 >= len(bmpstr):
                    continue

                b = bmpstr[idx]
                g = bmpstr[idx + 1]
                r = bmpstr[idx + 2]

                if is_blue_pixel(b, g, r):
                    # 1. Aşama: 4x4 blok doğrulaması (Tek piksel parazitleri eler)
                    is_block = True
                    for cy in range(y, min(y + 4, end_y + 1)):
                        cy_offset = cy * row_bytes
                        for cx in range(x, min(x + 4, end_x + 1)):
                            c_idx = cy_offset + (cx * 4)
                            if c_idx + 2 >= len(bmpstr) or not is_blue_pixel(bmpstr[c_idx], bmpstr[c_idx + 1], bmpstr[c_idx + 2]):
                                is_block = False
                                break
                        if not is_block:
                            break

                    if not is_block:
                        continue

                    # 2. Aşama: Genişlik kontrolü (Küçük ikonları / okları eleyip gerçek dikdörtgen butonları bulur)
                    # Gerçek 'Accept', 'Submit', 'Run' butonları en az 35-40 piksel genişliğindedir.
                    span_width = 0
                    for check_x in range(x, min(x + 50, end_x + 1)):
                        c_idx = y_offset + (check_x * 4)
                        if c_idx + 2 < len(bmpstr) and is_blue_pixel(bmpstr[c_idx], bmpstr[c_idx + 1], bmpstr[c_idx + 2]):
                            span_width += 1
                        else:
                            # Buton içi metin boşluğu toleransı (1-2 açık renk piksel varsa devam et)
                            continue

                    # Buton genişliği en az 30 piksel olmalıdır (küçük 15-25px ok ikonlarını engeller)
                    if span_width >= 25:
                        title = win32gui.GetWindowText(hwnd) or "IDE Window"
                        print(
                            f"[{time.strftime('%H:%M:%S')}] Gerçek onay butonu algılandı ({x}, {y}) [Genişlik: ~{span_width * 3}px] -> Pencere: {title[:40]}..."
                        )
                        click_in_background(hwnd, x + 15, y + 5)
                        return True

        return False
    except Exception:
        return False
    finally:
        if saveBitMap is not None:
            try:
                win32gui.DeleteObject(saveBitMap.GetHandle())
            except Exception:
                pass
        if saveDC is not None:
            try:
                saveDC.DeleteDC()
            except Exception:
                pass
        if mfcDC is not None:
            try:
                mfcDC.DeleteDC()
            except Exception:
                pass
        if hwndDC is not None:
            try:
                win32gui.ReleaseDC(hwnd, hwndDC)
            except Exception:
                pass


def main():
    parser = argparse.ArgumentParser(description="Evrensel IDE Auto-Accept Bot (Antigravity, VS Code, Cursor, Windsurf)")
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
        default=0.2,
        help="Kontrol sıklığı saniye cinsinden (varsayılan: 0.2 saniye)",
    )
    args = parser.parse_args()

    print("=" * 60)
    print("🚀 Evrensel Windows Auto-Accept Bot Başlatıldı")
    print("=" * 60)
    if args.title:
        print(f"🎯 Hedef Filtresi: Başlığında '{args.title}' geçen pencereler")
    else:
        print("🌐 Mod: EVRENSEL (Tüm açık Antigravity / VS Code / Cursor projeleri aktif)")
    print("🛡️ Güvenlik: Chat mesaj gönderme oku ve input kutusu tarama dışı bırakıldı.")
    print("⚡ Tarama Alanı: Sadece gerçek geniş onay butonları (Accept/Run/Submit)")
    print("⏱️ Kontrol Sıklığı:", f"{args.interval} sn")
    print("🛑 Çıkış için CTRL+C tuşlarına basın.\n")

    last_window_count = -1
    last_log_time = 0

    try:
        while True:
            hwnds = find_target_windows(filter_title=args.title)

            if len(hwnds) != last_window_count or (time.time() - last_log_time > 15):
                last_window_count = len(hwnds)
                last_log_time = time.time()
                if hwnds:
                    titles = [win32gui.GetWindowText(h) or "IDE Window" for h in hwnds]
                    print(f"[{time.strftime('%H:%M:%S')}] Takip edilen aktif pencere sayısı: {len(hwnds)}")
                    for t in titles:
                        print(f"   ↳ {t[:70]}")
                else:
                    print(f"[{time.strftime('%H:%M:%S')}] Aktif IDE penceresi aranıyor...")

            for hwnd in hwnds:
                if find_and_click_blue_button(hwnd):
                    time.sleep(1.0)  # Butona tıklandıktan sonra peş peşe tıklamaları engelle

            time.sleep(args.interval)

    except KeyboardInterrupt:
        print("\n👋 Bot durduruldu. İyi çalışmalar!")


if __name__ == "__main__":
    main()
