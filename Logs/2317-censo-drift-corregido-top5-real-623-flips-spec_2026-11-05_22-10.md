# Log 2317: censo de drift corregido — el top-5 real cambia y 623 flips citan una spec

**Fecha:** 2026-11-05
**Hora:** 22:10
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (mensaje 247)
**Rol:** gate-1 (auditor). **No sella.**
**Continua:** Log 2316 (verificador de pools ciego a long-path).

---

## Resumen

El censo de drift (`scripts/censo_drift_totales.py`), que es la herramienta con la que se elige a
quien auditar, tenia **siete defectos de lectura**. El mas caro: leia lineas tachadas o de prosa como
si fueran la declaracion vigente. Consecuencia: **el top-5 que la flota estaba usando incluia un
modulo sin drift (M71) y omitia a M92**, y M122 aparecia con un falso -79.

Corregido y reinstalado (read-only). Top real: **72 (+92), 28 (+76), 56 (+72), 27 (+54), 92 (+53)**.

Ademas se midio el alcance de la firma `FLIP ... spec en 03-Diseno.md`: **623 flips en 88 modulos**,
de los cuales **36 revierten una degradacion `[x]→[?]` ya dictada por gate-1**.

## 1. Defectos y efecto medido

| # | Defecto de la v1 | Caso real |
|---|---|---|
| 1 | Ignoraba blockquotes (`> **Totales:**`) | parseaba numeros de prosa ("M30 98/104") |
| 2 | No detectaba tachado tras el `>` | M151: leia una linea tachada (112/49/6) como vigente (+44 falso) |
| 3 | Aceptaba prosa que menciona totales | M122: `**Totales inventados** (335/335/0)` → falso tipo B -79 |
| 4 | No conocia ``N `[x]` · M `[ ]` · K `[?]` `` | M32 listado como "sin Totales" |
| 5 | No filtraba subtotales | M112: `**Totales T-M112:** 17 [x]` tomado como total del modulo |
| 6 | Exigia `**Totales` al inicio de linea | perdia declaraciones legitimas |
| 7 | "No resueltos" ausente = desconocido | falso tipo B delta 0 en M110 y M157 |

## 2. Regla nueva de vigencia

No hay orden fijo: M49/M151 tienen la vigente arriba, M71/M27 abajo, y M27 tiene una linea vieja
con otro formato al pie. Por eso se abandono "la ultima" y se usa el **maximo declarado**:

- tipo A si disco `[x]` > maximo declarado (delta contra el maximo = **piso** del drift);
- tipo B si disco `[x]` < minimo declarado;
- tipo C si el `[x]` cae dentro del rango sin coincidencia exacta;
- limpio si alguna declaracion coincide exacto en las tres cifras.

## 3. Medicion v1 → v2.3 (168 checklists, mismo disco)

| Metrica | v1 | v2.3 |
|---|---|---|
| limpios | 81 | **86** |
| tipo A | 82 (+1274) | **80 (+1176)** |
| tipo B | 2 (-6) | **2 (-6)** |
| tipo C | no existia | **0** |
| sin Totales | 3 | **0** |

Cambios por modulo: M71 A+71→limpio, M151 +44→limpio, M49 +5→limpio, M110 A+29→limpio,
M113 A+1→limpio, M157/M32 sin-Totales→limpios, M122 B-79→**A+2**, M112 sin-Totales→**A+4**,
M129 A+3→A+5, M164 A+8→A+5.

## 4. Top-5 corregido y pre-flight

| Modulo | Disco | Declara (max) | +[x] | Flips `spec en` |
|---|---|---|---|---|
| 72-Sistema-De-Logros | 200/0/0 | 108/89/3 | +92 | 6 |
| 28-Viajes | 129/1/0 | 53/77/0 | +76 | **0** |
| 56-Fotografia | 132/5/1 | 60/76/2 | +72 | 3 |
| 27-Islas-Del-Mundo | 189/0/3 | 135/0/57 | +54 | **37** |
| 92-Tutorial | 185/0/0 | 132/51/2 | +53 | 5 |

- **M27:** muestreo 5/5 falso (L74/L104/L117/L220/L277): cada item tiene auditoria previa que dice
  "no implementado" y el FLIP cita la spec.
- **M72:** 3 `[?]` legitimos con dueño externo (M59, M87, M117/M118) flipeados.
- **M56:** 3 flips con la misma firma (L275, L286, L342).
- **M92:** 5 flips; L55 dice "REVERTIDO por re-auditoria H2-estricta BUG-070" y aun asi esta `[x]`.
- **M28:** cero flips fechados; unico del top-5 normalizable sin degradar.
- **M112:** los 4 items dicen "pendiente / NO MEDIBLE" en su propio texto; atria-dawn los degrado
  (BUG-070 LOTE 13) y Beam los re-flipeo.

## 5. Alcance global de la firma `spec en`

- **623 flips** en **88 modulos**.
- **36** revierten ademas una degradacion `[x]→[?]`: **M11 25**, M69 4, M112 4, M61 2, M83 1.
- Top por modulo: M12 Camara 43, M11 Personaje 38, M27 37, M162 34, M156 30, M34 28, M63 22,
  M61 21, M64 19, M31 18, M110 17.

## 6. Archivos

- `scripts/censo_drift_totales.py` (v2.3, 10.824 B; respaldo `scripts/Obsoletos/2026-11-05_22-09-38_censo_drift_totales.py`).
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 2317).
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/247-...md` (informe).
- Cronometro propio (V116).

**No se toco ninguna marca de modulo ni `CHECKLIST-GLOBAL.md`.** Acumulado gate-1: 451 marcas en 9 modulos.
