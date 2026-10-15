**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 01: Fundamentos del Proyecto

> **Iter. 1 (2026-10-12, Log 1722).** Archivo creado: estaba **vacío (0 bytes)** desde el 2026-08-26.
> Todas las cifras de este documento están **medidas** (salida real de Godot), no copiadas.

## 1. Entorno

- Godot **4.7.2.stable** headless.
- Ejecutable: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`
  (es un **directorio**).
- Comando: `--headless --path game/isla-ancestral --script res://scripts/proyecto/test_fundamentals_m01.gd`
- Suite: `test_fundamentals_m01.gd` — sha256 `bf8ba7464d43c642091462663b323ce6fe779be38d1aaca48a961a8b24148c2a`
  (LF, sin BOM, 3725 B).

## 2. Resultado global (3 corridas consecutivas)

| Corrida | Checks | Fallos | Bloques cerrados | Exit |
|---|---|---|---|---|
| 1 | 8 | 0 | 3/3 | 0 |
| 2 | 8 | 0 | 3/3 | 0 |
| 3 | 8 | 0 | 3/3 | 0 |

```
=== Resumen M01: 8 checks, 0 fallos ===
TEST M01 OK - todos los checks pasaron
```

**Determinista:** las 3 corridas dieron el mismo total y el mismo conjunto de `[OK]`.

## 3. Desglose por bloque (medido)

| Bloque (`_fin`) | Checks | Qué verifica |
|---|---|---|
| `datos` | 2 | `fundamentos.json` carga y declara **4** fundamentos |
| `validator` | 2 | camino **feliz**: la data real da **0 errores**; `reporte([])` contiene `OK` |
| `errores` | 4 | 4 caminos de error: sin `id`, sin `titulo`, sin `detalle`, sin `politicas` |
| **Total** | **8** | = `CHECKS_MINIMOS` |

## 4. Guardián probado EN ROJO (2 sondas, inyección)

No se heredó el guardián: se **inyectó el fallo** en copias temporales
(`scripts/proyecto/_tmp_sonda_{a,b}_m01.gd`, **borradas** al terminar) y se exigió `EXIT 1`.

| Sonda | Inyección | Resultado medido |
|---|---|---|
| **A** | aborto de **runtime** al inicio del bloque `errores` (`var _n: Node = null; _n.free()`) | `[FAIL] el bloque 'errores' NO se ejecuto` + `[FAIL] solo 4 checks ejecutados (minimo 8)` → `4 checks, 2 fallos` · **EXIT 1** |
| **B** | piso subido 1 por encima del real (`CHECKS_MINIMOS := 9`) | `[FAIL] solo 8 checks ejecutados (minimo 9)` → `8 checks, 1 fallos` · **EXIT 1** |

Detalle de método (trampa AU del skill): la inyección usa un error de **runtime**, no de parseo —
un `Parse Error` mataría el script entero y el guardián nunca correría, dando un «rojo» falso. La
sonda A demuestra que el **aborto silencioso** (checks que no corren y no fallan) ahora **sí** se
detecta, por las **dos** capas independientes (marcador de bloque + piso).

## 5. Medición del índice maestro (152 ítems) y PROPUESTA de flips

Mapeo medido: ítem `**M##**` ↔ carpeta `DOCUMENTACION/{##+1:03d}-{Nombre}`.

| Métrica | Valor medido |
|---|---|
| Ítems parseados del `05-Checklist.md` | **152** |
| Resuelven a una carpeta de componente | **152** |
| Nombre ítem ↔ carpeta coincide | **149** (3 difieren de nombre) |
| Checklists propias **100 % cerradas** (`[?]=0`, `[ ]=0`) | **22** |
| De esos, con fila GLOBAL en `✅` | **21** |
| En curso (`[x]>0` y `[ ]>0`) | **88** |
| Sin iniciar (`[x]=0` y `[?]=0`) | **1** (`M045 Arte 2D` → `46-Arte-2D`, GLOBAL `🟡 Liberado (V1-QA agnes) 0/110`) |
| Suma de los 152 sub-checklists | **14 334 `[x]` / 1 241 `[?]` / 6 421 `[ ]` = 21 996** |

**Los 21 candidatos a `[x]`** (checklist cerrada **y** GLOBAL `✅`), para que los aplique el director
(la regla dura del commit `41ff104` exige **código + testing**, no documentación):

`M006` `M007` `M031` `M037` `M038` `M077` `M078` `M083` `M085` `M096` `M097` `M100` `M101` `M110`
`M112` `M124` `M132` `M133` `M134` `M135` `M151` → **21**.

**NO propuesto:** `M024 Ruinas` (cerrado 122/122 pero GLOBAL `🟡 Con dudas (deuda implementación)`).

**Los 3 desajustes de nombre** (ítem ↔ carpeta), para documentar el mapeo:
`M131`→`132-Produccion-De-Equipo` · `M151`→`152-Principios-Innegociables` ·
`M152`→`153-Objetivo-Final`.

> **Nota de honestidad.** Este módulo **no aplica** los flips: el director los aplica. La medición es
> reproducible con el script de `.workbuddy-ai/tmp/` (no versionado); la fuente de cada conteo es el
> `05-Checklist.md` de cada componente, no una tabla derivada.

### 5.3 Refresco medido (2026-10-14, DeepSeek-V4.1-Flash - iter 6)

Mismo criterio documentado en 5.1/5.2: **checklist propia 100 % cerrada (`[?]=0`, `[ ]=0`) Y fila GLOBAL `✅`**.

| Métrica | Valor medido |
|---|---|
| Checklists propias **100 % cerradas** | **29** |
| De esas, con fila GLOBAL en `✅` | **26** |
| Flipeadas hoy en el índice maestro | **26** |
| **Candidatos NUEVOS** (cerrada Y `✅` Y sin flip) | **0** |
| Cerradas pero GLOBAL **no** `✅` | **3** |
| En curso | **122** |
| Sin iniciar | **1** (`M045` -> `46-Arte-2D`) |
| Suma de los 152 sub-checklists | **17 469 `[x]` / 967 `[?]` / 3 527 `[ ]` = 21 963** |

**Las 3 cerradas sin `✅`** (mismo caso que `M024 Ruinas`: cerrada pero GLOBAL no `✅` -> **NO flipeables** por el criterio):

| Ítem | Carpeta | Estado GLOBAL |
|---|---|---|
| `M018` | `19-NPC-Y-Vecinos` | `🟢 Disponible` |
| `M021` | `22-Historia-Principal` | `🟢 Disponible` |
| `M099` | `100-Community-Management` | `🟡 Con dudas` |

**Conclusión: `26/152` es correcto y NO hay flips disponibles.** Los 126 `[ ]` restantes dependen de que
los otros módulos cierren su checklist **y** su fila GLOBAL pase a `✅`; `M01` no puede avanzar por sí solo.
Se reporta al director para que normalice el estado GLOBAL de los 3 módulos cerrados (si corresponde),
lo que habilitaría 3 flips.

## 6. Integridad de bytes

| Archivo | BOM | EOL | NUL | FFFD |
|---|---|---|---|---|
| `scripts/proyecto/test_fundamentals_m01.gd` | No | LF (107) | 0 | 0 |
| `plan-actual/06-Plan-Testings.md` | No | CRLF | 0 | 0 |
| `plan-actual/07-Resultados-Testings.md` | No | CRLF | 0 | 0 |

## 7. Pendiente / no cubierto

- **Los 21 flips**: los aplica el **director** (no este módulo).
- **Cableado de la suite en `quality.yml`**: no está; hoy la suite sólo corre a mano.
- **`plan-inicial/06` y `07`** siguen **0 bytes**: son el plan histórico; se dejó constancia, no se
  rellenaron (el vivo es `plan-actual/`).
- **`SCRIPT ERROR` ajeno** (`scripts/world/block_type.gd`, `terrain_detector.gd`): contamina el
  `0 SCRIPT ERROR` de cualquier suite. **Se reporta, no se toca** (zona ajena, trampa AF).
