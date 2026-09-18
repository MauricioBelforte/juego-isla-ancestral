# Log 1014: M116 iter. 3 — el test del instalador pasa a gate duro en CI y los totales del checklist se corrigen

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Módulo:** 116-Instalador
**Iteración:** 3 (auditoría honesta: sin funcionalidad nueva)
**Fecha:** 2026-09-18 06:58
**Reserva:** 1014 (protocolo v3 — `Logs/NUMEROS_DISPONIBLES.txt` ahora tiene `primero=1015`)

## Resumen

Iteración de **verificación y honestidad**, sin código de producción nuevo. Tres cosas:

1. El paso de CI de M116 existía pero estaba **neutralizado con `|| true`** → ahora es un **gate duro**.
2. La `05-Checklist.md` declaraba `180 [x] / 6 [?] / 12 [ ]` mientras el cuerpo ya tenía **192 tareas hechas** → totales corregidos a `192/192`.
3. Los **6 ítems del historial** estaban como `- [x]` e inflaban el denominador (198 = 192 + 6) → viñetas simples.

Más la sincronización de la checklist personal y la corrección de `04-Codigo.md`.

## 1. El gate de CI deja de ser decorativo

`quality.yml` tenía:

```yaml
godot --headless --script scripts/build/test_instalador_m116.gd 2>&1 || true
```

El paso existía, corría, y **no podía hacer fallar el build**. El verde lo producía la tubería, no el programa (familia **trampa 75**).

Antes de quitarlo se midió el exit code **del proceso** — no el de un `tail`/`grep` aguas abajo, que es exactamente el error que la trampa 75 describe:

```bash
for i in 1 2 3; do
  "$GODOT" --headless --path game/isla-ancestral \
    --script res://scripts/build/test_instalador_m116.gd > out$i.txt 2>&1
  echo "corrida $i -> RC=$?"
done
```

```
corrida 1 -> RC=0
corrida 2 -> RC=0
corrida 3 -> RC=0
```

Salida:

```
=== Resumen M116: 15 checks, 0 fallo(s) ===
TEST M116 OK - todos los checks pasaron
```

Las 3 salidas son **byte-idénticas** (465 líneas, mismo `sha256`): determinismo confirmado. `SCRIPT ERROR`: **0**.

Recién entonces se quitó el `|| true` (commit `a41caed`).

## 2. Los totales declarados eran falsos

| Qué | Antes | Después |
|---|---|---|
| `05-Checklist.md` (línea de Totales) | `180 [x] / 6 [?] / 12 [ ]` | `192 [x] / 0 [?] / 0 [ ]` |
| Ítems del historial de la iter. 1 | `- [x]` (6) | viñetas simples (6) |
| `CHECKLIST-GLOBAL.md` fila 116 | `198/198` | `192/192` |
| Checklist personal | `182 [x] / 6 [?] / 10 [ ]` | `192 [x] / 0 / 0` |

Los 18 ítems que figuraban abiertos los había cerrado agnes-2.5-flash el 2026-09-14 (con spec/policy documentada en `03-Diseno.md`) **sin actualizar la línea de totales**. El cuerpo del archivo ya estaba 100 % `[x]`.

El historial es el caso de **trampa 42**: `verificar_checklist.py` cuenta **todos** los `- [x]`, incluidos los del historial → el archivo contaba 198 = 192 tareas + 6 de historial.

## 3. Verificación con la herramienta del repo

`scripts/verificar_checklist.py`:

```
📋 116-Instalador:
   - [x] completados: 192
   - [ ] pendientes:  0
   - [?] con dudas:   0
```

Y **M116 no aparece** entre las 13 inconsistencias módulo↔GLOBAL que reporta el verificador (todas ajenas: 131, 14, 150, 153, 155, 168, 30, 49, 53, 61, 71, 72, 84).

Validador sobre el repo real: **61 checks, 0 errores**. El bloque G revisa los 10 artefactos de `installer/` con extensión `.ps1/.bat/.iss/.txt` (todos menos `README.md`): **0 con BOM**.

## 4. Checklist personal sincronizada

La personal (`TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/116-Instalador/checklist.md`) había quedado atrás. Se sincronizó **in-place** (sin regenerar, para no borrar notas de evidencia): 192 tareas + 6 de historial alinean 1:1 por posición con el módulo.

El guard de alineación abortó **tres veces sin escribir nada** hasta quedar correcto — vale la pena registrarlo:

1. `clave()` quitaba `^T-\d+` **antes** de quitar el marcador `- [x] ` → nunca coincidía.
2. Los ítems del historial son viñeta simple en el módulo (`- Texto`) y checkbox en la personal (`- [x] T-193 Texto`) → había que quitar también la viñeta.
3. Diferencias de **acento** (`version`/`versión`) y de **paréntesis** (`(M119)`, `(segunda referencia)`) → normalización NFKD + descarte de paréntesis.
4. Un ítem (índice 197) cierra con `: …` en vez de ` — ` / ` → ` → se documentó como **excepción explícita**, no se relajó el guard.

Resultado: **20 marcadores** cambiados; `[x]` 192 / `[?]` 0 / `[ ]` 0; CRLF puro; sin BOM. Se le añadió el encabezado `## Iteración 1 (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)` para separar el historial (antes colgaba de `## Tareas` y parecía trabajo pendiente), y se corrigió la nota de cabecera, que seguía diciendo "39 pendientes / 2 dudas de 198 ítems".

## 5. Artefacto ausente (dueño externo, reportado)

`installer/icon.ico` **no existe**. El diseño está documentado (`03-Diseno.md` §S.1/§S.6-8) pero el archivo requiere **artista (M46)**. **No se parchea**: un `.ico` inventado por el agente sería peor que la ausencia declarada.

## 6. Un commit ajeno había pisado mi fila del GLOBAL

`CHECKLIST-GLOBAL.md` fila 60 (M60) aparecía como `iter. 4 · 188/196` cuando mi estado real era `iter. 5 · 189/196`. La fila buena se restauró **verbatim** desde `216c1a1` (commit `3b22ca3`). Es el mismo patrón que BUG-034: reescrituras concurrentes de filas del GLOBAL.

## 7. Archivos tocados

- `.github/workflows/quality.yml` — quitado `|| true` del paso M116 (+5 líneas de comentario). Commit `a41caed`.
- `DOCUMENTACION/116-Instalador/plan-actual/05-Checklist.md` — totales reales; historial a viñetas.
- `DOCUMENTACION/116-Instalador/plan-actual/04-Codigo.md` — §12 con columna de estado real; §13 con nota de cierre.
- `DOCUMENTACION/116-Instalador/plan-actual/06-Plan-Testings.md` — §4 nueva (criterio de gate duro).
- `DOCUMENTACION/116-Instalador/plan-actual/07-Resultados-Testings.md` — §8 nueva (re-ejecución, gate, conteos, `icon.ico`).
- `CHECKLIST-GLOBAL.md` — filas 60 (restaurada) y 116.
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/116-Instalador/checklist.md` — sincronizada.
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` — fila A4 + historial 19.
- `Mensajes entre modelos/ESTADO-PARALELO.md` — entrada §21.1.

## 8. Pendiente

- ⏳ **QA §21.8 de esta iteración** (verificador ≠ autor). La iter. 3 no añadió código de producción, pero sí cambió el cableado de CI y los conteos.
- ❌ `icon.ico` — **M46** (artista).
- ⏳ Validación **manual** (no automatizable aquí): compilar con `ISCC.exe`, firmar con certificado, instalación limpia en máquina sin el juego, antivirus. Ver `07-Resultados-Testings.md` §7.

## 9. Colisiones de numeración observadas (ajenas, no tocadas)

`scripts/reservar_log.py --estado`:

```
NUMEROS_DISPONIBLES: 486 libres (primero=1015)
  !! COLISION 1013: ['1013-M128-…agnes…', '1013-QA-M14-Inventario…']
```

- La **colisión 1011** (mi `1011-M60-Iter5` vs el `1011-M128-…` de agnes) **quedó resuelta**: agnes renumeró.
- Aparece una **nueva 1013**: agnes (M128, 09-06) y atria-dawn (M14 QA, 10-05). Es la **carrera read-modify-write** del protocolo v3 documentada en el Log 1006: dos agentes leen "primero = 1013" a la vez y ambos lo consumen. Por convención se renumera **el que llegó después** (atria). No se tocó: es ajeno.
- `Logs/reservas/` está **vacío** y `Logs/ULTIMO_NUMERO.txt` **ya no existe** (el v3 lo reemplazó por `NUMEROS_DISPONIBLES.txt`).
