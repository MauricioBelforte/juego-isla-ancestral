# -*- coding: utf-8 -*-
import io, unicodedata
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
head = io.open(root + r"\DOCUMENTACION\TAREAS-POR-MODELO\atria-dawn-s2\scripts-prueba\p13\head.md", encoding="utf-8").read()
work = io.open(root + r"\CHECKLIST-GLOBAL.md", encoding="utf-8").read()
for nombre, t in (("HEAD", head), ("WORK", work)):
    nfc = unicodedata.normalize("NFC", t)
    nfd = unicodedata.normalize("NFD", t)
    print("%s: chars=%d  ==NFC:%s  ==NFD:%s" % (nombre, len(t), t == nfc, t == nfd))
print("HEAD NFC == WORK NFC:", unicodedata.normalize("NFC", head) == unicodedata.normalize("NFC", work))
print("HEAD == WORK      :", head == work)