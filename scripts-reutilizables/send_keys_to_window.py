#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
send_keys_to_window.py

Envía secuencias de teclas a una ventana de Windows específica usando PostMessage
(WM_KEYDOWN / WM_KEYUP). No requiere instalar librerías externas (solo stdlib).

Uso:
    python send_keys_to_window.py "<título parcial de la ventana>" "<tecla1> <tecla2> ..." [título exacto]

Teclas soportadas:
    ESC, ENTER, SPACE, TAB, BACKSPACE, DELETE,
    UP, DOWN, LEFT, RIGHT,
    HOME, END, PAGEUP, PAGEDOWN,
    F1..F12,
    A-Z, 0-9,
    CTRL+<tecla>, ALT+<tecla>, SHIFT+<tecla> (ej: CTRL+C, ALT+F4)

Ejemplo:
    python send_keys_to_window.py "isla-ancestral" ESC DOWN DOWN ENTER "isla-ancestral (DEBUG)"
    python send_keys_to_window.py "Configuracion" ALT F4
"""

import ctypes
from ctypes import wintypes
import time
import sys

user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

# Constantes de Windows
WM_KEYDOWN = 0x0100
WM_KEYUP = 0x0101
WM_CHAR = 0x0102
INPUT_KEYBOARD = 1
KEYEVENTF_KEYUP = 0x0002

# Mapeo de teclas a códigos virtuales de Windows (VK)
VK_MAP = {
    'ESC': 0x1B,
    'ENTER': 0x0D,
    'SPACE': 0x20,
    'TAB': 0x09,
    'BACKSPACE': 0x08,
    'DELETE': 0x2E,
    'UP': 0x26,
    'DOWN': 0x28,
    'LEFT': 0x25,
    'RIGHT': 0x27,
    'HOME': 0x24,
    'END': 0x23,
    'PAGEUP': 0x21,
    'PAGEDOWN': 0x22,
    'F1': 0x70, 'F2': 0x71, 'F3': 0x72, 'F4': 0x73,
    'F5': 0x74, 'F6': 0x75, 'F7': 0x76, 'F8': 0x77,
    'F9': 0x78, 'F10': 0x79, 'F11': 0x7A, 'F12': 0x7B,
    **{chr(i): i for i in range(ord('A'), ord('Z') + 1)},
    **{str(i): 0x30 + i for i in range(10)},
}

MODIFIERS = {
    'CTRL': 0x11,
    'ALT': 0x12,
    'SHIFT': 0x10,
}

# Ventana objetivo global
hwnd_global = 0


class KEYBDINPUT(ctypes.Structure):
    _fields_ = [
        ('wVk', wintypes.WORD),
        ('wScan', wintypes.WORD),
        ('dwFlags', wintypes.DWORD),
        ('time', wintypes.DWORD),
        ('dwExtraInfo', ctypes.c_void_p),
    ]


class INPUT(ctypes.Structure):
    _fields_ = [
        ('type', wintypes.DWORD),
        ('ki', KEYBDINPUT),
    ]


def press_key_sendinput(vk, down=True):
    """Envía un evento de tecla usando SendInput (Windows API)."""
    extra = ctypes.c_void_p(0)
    flags = 0 if down else KEYEVENTF_KEYUP
    ii_ = INPUT(type=INPUT_KEYBOARD, ki=KEYBDINPUT(wVk=vk, wScan=0, dwFlags=flags, time=0, dwExtraInfo=extra))
    user32.SendInput(1, ctypes.byref(ii_), ctypes.sizeof(ii_))


def press_key_postmessage(vk, down=True):
    """Envía un evento de tecla usando PostMessage (WM_KEYDOWN/WM_KEYUP)."""
    global hwnd_global
    if hwnd_global == 0:
        return
    msg = WM_KEYDOWN if down else WM_KEYUP
    user32.PostMessageW(hwnd_global, msg, vk, 0)


def press_key(vk, down=True):
    """Envía un evento de tecla. Intenta PostMessage primero, luego SendInput como fallback."""
    press_key_postmessage(vk, down)
    # También usar SendInput como respaldo
    press_key_sendinput(vk, down)


def find_window(partial_title, exact_title=None):
    """Busca la primera ventana visible cuyo título contenga partial_title (case-insensitive).
    Si exact_title se proporciona, prefiere la ventana cuyo título sea exactamente ese."""
    WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    matches = []

    def callback(hwnd, lParam):
        if user32.IsWindowVisible(hwnd):
            length = user32.GetWindowTextLengthW(hwnd)
            if length > 0:
                buff = ctypes.create_unicode_buffer(length + 1)
                user32.GetWindowTextW(hwnd, buff, length + 1)
                title = buff.value
                if partial_title.lower() in title.lower():
                    matches.append((hwnd, title))
        return True

    user32.EnumWindows(WNDENUMPROC(callback), 0)

    if not matches:
        return 0, ''

    if exact_title:
        for hwnd, title in matches:
            if title.lower() == exact_title.lower():
                return hwnd, title

    return matches[0]


def send_sequence(hwnd, keys):
    """Envía una secuencia de teclas a una ventana."""
    global hwnd_global
    if hwnd == 0:
        print("ERROR: HWND inválido (ventana no encontrada)")
        return False

    hwnd_global = hwnd

    # Poner la ventana en primer plano y darle foco
    user32.SetForegroundWindow(hwnd)
    user32.SetFocus(hwnd)
    time.sleep(0.5)

    for token in keys:
        token = token.strip().upper()
        if not token:
            continue

        if '+' in token:
            parts = token.split('+')
            mod_name = parts[0]
            key_name = parts[1]
            if mod_name not in MODIFIERS:
                print(f"ADVERTENCIA: modificador desconocido '{mod_name}', ignorando")
                continue
            if key_name not in VK_MAP and len(key_name) != 1:
                print(f"ADVERTENCIA: tecla desconocida '{key_name}', ignorando")
                continue

            mod_vk = MODIFIERS[mod_name]
            key_vk = VK_MAP.get(key_name, ord(key_name)) if len(key_name) == 1 else VK_MAP.get(key_name, 0)

            press_key(mod_vk, down=True)
            time.sleep(0.05)
            press_key(key_vk, down=True)
            press_key(key_vk, down=False)
            time.sleep(0.05)
            press_key(mod_vk, down=False)
        else:
            if token not in VK_MAP and len(token) != 1:
                print(f"ADVERTENCIA: tecla desconocida '{token}', ignorando")
                continue
            vk = VK_MAP.get(token, ord(token)) if len(token) == 1 else VK_MAP.get(token, 0)
            press_key(vk, down=True)
            press_key(vk, down=False)
            time.sleep(0.15)

    return True


def main():
    if len(sys.argv) < 3:
        print("Uso: python send_keys_to_window.py \"<título parcial>\" <tecla1> [tecla2] ... [título exacto]")
        print("")
        print("Ejemplo: python send_keys_to_window.py \"isla-ancestral\" ESC DOWN DOWN ENTER \"isla-ancestral (DEBUG)\"")
        print("Teclas: ESC, ENTER, SPACE, TAB, UP, DOWN, LEFT, RIGHT, F1-F12, A-Z, 0-9")
        print("Combinaciones: CTRL+C, ALT+F4, SHIFT+TAB")
        sys.exit(1)

    partial_title = sys.argv[1]
    keys = sys.argv[2:]
    exact_title = sys.argv[3] if len(sys.argv) > 3 else None

    hwnd, title = find_window(partial_title, exact_title)
    if hwnd == 0:
        print(f"No se encontró ninguna ventana con título que contenga: '{partial_title}'")
        sys.exit(1)

    print(f"Ventana encontrada: HWND={hwnd} | '{title}'")
    print(f"Enviando secuencia: {' '.join(keys)}")
    send_sequence(hwnd, keys)
    print("Secuencia enviada.")


if __name__ == '__main__':
    main()
