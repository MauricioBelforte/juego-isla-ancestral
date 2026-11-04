# -*- coding: utf-8 -*-
"""Actualiza el aviso de defecto dentro de la ficha N.6 tras el saneamiento."""
p = r"DOCUMENTACION\GUIA-COMPARATIVA-MODELOS\GUIA-COMPARATIVA-MODELOS-V1.md"
tex = open(p, encoding="utf-8").read()
viejo = '**AVISO DE DEFECTO DEL ARCHIVO (registrado 2026-10-25):** este documento acumula **212.220 líneas con 64 copias casi idénticas** del bloque de fichas (patrón "append del historial completo" repetido por los agentes). La ficha N.6 se apendó al FINAL (bloque vigente único) sin multiplicar más copias. Se propuso al fundador saneamiento aparte (respaldo en Obsoletos + dedup script) como tarea previa al próximo gran uso del archivo.'
nuevo = ('**AVISO DE DEFECTO DEL ARCHIVO — SANEADO (2026-10-25):** este documento llegó a acumular **212.250 líneas con 64 copias casi idénticas** '
         'del bloque de fichas (patrón "append del historial completo" repetido por los agentes). El fundador confirmó el saneamiento: '
         'respaldo íntegro previo en `DOCUMENTACION/GUIA-COMPARATIVA-MODELOS/obsoletos/2026-10-25_18-19-14_10-GUIA-COMPARATIVA-MODELOS.md` y corrección por GLM-5.3-Flash (agente): '
         'quedan las líneas 1-3013 originales + fichas N + notas des-fusionadas + LECCION 15:17 + esta ficha N.6 (en total 3.350 líneas), '
         'con verificación de cero pérdida de líneas únicas (2.467/2.467 cubiertas).')
assert viejo in tex, "aviso no encontrado"
open(p, "w", encoding="utf-8", newline="\n").write(tex.replace(viejo, nuevo))
print("aviso actualizado OK")
