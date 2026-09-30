# -*- coding: utf-8 -*-
"""Anade el resumen ejecutivo al inicio de clasificacion_final.txt."""
import io, os

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\TAREAS-POR-MODELO\atria-dawn-s2"
REP = os.path.join(BASE, "clasificacion_final.txt")

with io.open(REP, encoding="utf-8") as f:
    cuerpo = f.read()

head = u"""CLASIFICACION DE ARCHIVOS M POR AUTOR - SOPORTE AL MERGE
========================================================
Fecha: 2026-09-25 | Por: atria-dawn-s2 (Kilo Code) | NO se commiteo nada

Total clasificado: 224 archivos M
  Bucket A (modelo identificable):  182 (81%)
  Bucket B (coordinador Atria):      29 (13%)
  Bucket C (conflicto/inclasificable): 13 (6%)  <- bajo el 15%, el metodo sirve

Distribucion bucket A (listo para commits por modelo):
  deepseek-v4.1-flash: 90   <- el mas grande (M93/M94 + P-30/P-32)
  glm-5.3-flash: 21+3 backlog
  mimo-v2.5: 14
  swe: 14
  nemotron: 10
  hy3: 5
  ox-alpha: 4
  kimi-k3: 4
  step-3.7-flash: 3
  agnes-3-flash: 3+1
  atria-dawn (yo, s2): 1+1+GUIA-GODOT/06

Senales usadas (en orden de prioridad):
  1. plan-actual/*.md -> firma **Modelo:** del header (archivo entero)
  2. game/ y otros    -> ruta indexada en 04-Codigo.md/03-Diseno.md (978
     rutas) -> modulo -> columna "Agente actual" de CHECKLIST-GLOBAL
  3. Nombre _m{ID}_   -> modulo -> agente global
  4. Overrides        -> subdir shops/=M39(glm), ui/=M53(atria BUG-048),
     audio/=M84(mimo), tests *inventario*=M14(QA propia Log 1013)
  5. Prefijo commit   -> fallback (debil: bulk commits antiguos)

Verificacion extra hecha (mas alla del commit): diff SIN commitear de los
4 archivos compartidos, para detectar multi-autoria real:
  - 11-BUGS.md          -> MULTI-AUTOR, va a C (hunks atria + deepseek)
  - ESTADO-PARALELO.md  -> MULTI-AUTOR, va a C (todos los modelos)
  - GUIA-GODOT/06       -> LIMPIO: T-98..100 commiteados por hy3; el diff
                           sin commitear es SOLO mi T-101 (56+/0-). Va a A.
  - CHECKLIST-GLOBAL.md -> EOL 231/231 + multi-autor, va a C (editar_crlf.py)
  - NUMEROS_DISPONIBLES -> pool sano: 352 libres, primero=1149, 0 conflictos.
                           OJO: dijiste primer libre 1145; el real es 1149
                           (se consumieron 4 desde tu chequeo).

"""

with io.open(REP, "w", encoding="utf-8", newline="\n") as f:
    f.write(head + cuerpo)

print("resumen escrito:", REP)
