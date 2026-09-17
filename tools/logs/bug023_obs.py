# -*- coding: utf-8 -*-
# Temporal: registrar observación como BUG-023. Se borra tras ejecutar.
import io, sys
sys.stdout.reconfigure(encoding='utf-8')
path = r'D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\11-BUGS.md'
with io.open(path, 'r', encoding='utf-8') as f:
    c = f.read()

obs = """### BUG-023 — [OBSERVACIÓN] Luz invisible en la espalda del jugador (no reapareció tras fix BUG-014)

- **Fecha de reporte:** 2026-09-04 06:40 (reportado por el usuario)
- **Módulo(s) afectado(s):** M49 (iluminación) / posible M163 (chamán glow) / M65 (fauna emissive)
- **Severidad:** ⚪ Trivial (no reapareció tras fix BUG-014)
- **Estado:** [?] Observación a vigilar

**Descripción:**
El usuario reportó que ANTES del fix de BUG-014 había 'una luz rara que en alguna parte me daba en la espalda como si hubiera una fuente de luz invisible'. Tras el fix de la matriz de la DirectionalLight (Log 643), el usuario NO volvió a verla.

**Hipótesis candidatas** (si reaparece, revisar en orden):
1. Residuo de la DirectionalLight invertida (BUG-014) — ya corregida, improbable
2. M163 Chaman del Monte spawneado en (320, 300) — verificar si tiene material emissive
3. M65 Gaviota con material emissive pasando cerca del jugador
4. OmniLight/SpotLight huérfano de otro módulo (M49 faroles aún no implementados)

**Acción:** A VIGILAR. Si reaparece: capturar posición+hora del juego y revisar las 4 hipótesis.

**Referencias:** Log 643 (fix BUG-014)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-04 07:00
---

## 9. Historial de Modificaciones de Este Archivo"""

if 'BUG-023' not in c:
    c = c.replace('---\n\n## 9. Historial de Modificaciones de Este Archivo', obs + '\n\n## 9. Historial de Modificaciones de Este Archivo', 1)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.write(c)
    print('11-BUGS: BUG-023 [?] registrada')
else:
    print('BUG-023 ya existía')
