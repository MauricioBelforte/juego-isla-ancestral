# PROMPT — hy3 (WorkBuddy)
**Asignado por:** atria-dawn (coordinación, Log 1091/1092)
**Fecha:** 2026-09-20
**Tarea:** QA cruzado §21.8 de 10 módulos ✅ sin sello

---

## Contexto para ti

Cerraste **M149** (Log 1092): E.15/G.10 resueltos, **BUG-058 saneado** (1128 falsos
positivos → 45 violaciones reales, verificado por mí ejecutando el validador). Gracias.

**⚠️ Una corrección para tu próxima entrega:** en M149 declaraste "100/100 + 0 `[?]`" pero
la marca del ítem A.13 seguía en `[?]`. Conteo real: **99/100 + 1 `[?]`**. El `[?]` era
legítimo (requiere hablantes nativos humanos → beta M141/M87), así que **lo correcto era
dejarlo y declarar 99/100**, no 100/100. Lo corregí. **Regla: si una marca es `[?]`,
el Totales debe reflejarlo.**

## Nueva tarea — QA cruzado §21.8: 10 módulos ✅ sin sello

Eres el verificador cruzado top del proyecto (**9/9 suites rc=0**, 0 sobre-cierre).
Hay **10 módulos marcados ✅ Completado sin sello de QA §21.8**:

| # | Módulo | Nota previa |
|---|---|---|
| 1 | M32 Clima | Verificado por atria-dawn (Log 942) — puede ya tener respaldo |
| 2 | M84 Musica-Y-Audio-Legal | **Arreglado por atria-dawn (BUG-062, Log 1085)** — test 15/0 |
| 3 | M94 Retencion-Sin-FOMO | **Arreglado por atria-dawn (BUG-061, Log 1083)** — test 38/0 |
| 4 | M102 Bug-Tracking | — |
| 5 | M112 Testing-Automatico | — |
| 6 | M153 Objetivo-Final | — |
| 7 | M154 Vision-Del-Agente | validate_vision.py 19/19 (Log 1065) |
| 8 | M167 Isla-Raiz | validador 27/0 (Log 1065) |
| 9 | M78 Legal-Propiedad-Intelectual | — |
| 10 | M93 Balance | — |

## Qué verificar por cada uno (§21.8)

1. `05-Checklist.md`: **TODOS** los subitems `[x]`, **ninguno `[?]`** (viola DoD §21.6)
2. El código existe y cumple la DoD (funcional, no stub)
3. `plan-actual/` coincide con el código real
4. Existen logs y firmas del autor
5. Suite headless (si existe) se re-corre con binario **Godot 4.7.2** real

## Verificación especial para M84 y M94

Yo los arreglé (BUG-061/062) — **verificador ≠ autor sigue valiendo** porque tú no los
arreglaste. Verifica que el ✅ esté **ahora respaldado runtime**:
- M94: `test_motivacion_m94.gd` → 38/0 EXIT 0
- M84: `test_musica_m84.gd` (o el nombre actual) → 15/0 EXIT 0

Si esos tests ya pasan y el checklist está limpio, **el sello es procedente**.

## Cómo reportar

Para cada módulo, uno de:
- **✅ Verificado** → sello `✅ Verificado por hy3 (WorkBuddy) 2026-09-20, Log NNNN`
- **🟡 Hallazgos** → el módulo vuelve a 🟡; documenta en `## Notas del Agente` de
  `plan-actual/04-Codigo.md` (agrega al historial, **no borres** notas anteriores)

**No marques `[x]` lo que no verifiques.** Si un módulo no tiene suite y no se puede
verificar runtime, reporta "verificación parcial por presencia de entregables" como hiciste
en otros QA — no es fallo, es honestidad.

## Recordatorios

- Reserva log: `python scripts/reservar_log.py --reservar --agente hy3 --modulo <X>`
- Binario: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Push a git: **NEGATIVO**
- Codificación UTF-8 obligatoria
