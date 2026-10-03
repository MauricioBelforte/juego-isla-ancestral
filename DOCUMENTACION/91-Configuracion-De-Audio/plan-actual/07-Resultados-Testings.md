# 07-Resultados-Testings.md — Módulo 91: Configuración de Audio

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02

> Ejecución real de los escenarios de `06-Plan-Testings.md` con el binario
> **Godot 4.7.2** en modo headless. Evidencia de cada corrida en los Logs
> 1191, 1194, 1198 y 1199.

---

## 1. Resumen de la corrida

| # | Suite | Checks | Fallos | EXIT | Duración | Piso | Estado |
|---|---|---:|---:|---:|---|---:|---|
| S1 | `scripts/audio/test_audio_config.gd` | **103** | **0** | 0 | ~3 s | 103 | ✅ PASA |
| S2 | `scripts/audio/test_audio_effects_m91.gd` | **82** | **0** | 0 | ~3 s | 82 | ✅ PASA |
| S3 | `scripts/ui/test_subtitles_m91.gd` | **80** | **0** | 0 | ~60 s | 50 | ✅ PASA |
| | **TOTAL** | **265** | **0** | | | | ✅ |

Salida literal:

```
=== TEST M91 AUDIO: 103 checks, 0 fallo(s) ===        exit=0
=== TEST M91 EFECTOS: 82 checks, 0 fallo(s) ===       exit=0
=== TEST M91 SUBTITULOS: 80 checks, 0 fallo(s) ===    exit=0
```

---

## 2. Resultado por familia de escenarios

### Volúmenes (L311) — S1 → **PASA (103/0)**

- **V1** defaults de los 7 buses: ✅
- **V2** `% → dB` coherente con `AudioServer`: ✅
- **V3** round-trip `% ↔ lineal`: ✅ (0/25/50/75/100)
- **V4** clamado de −20 % y 150 %: ✅
- **V5** bus inexistente → `false`: ✅
- **V6** aplicación por bus (6 hijos + Master): ✅
- **V7** independencia (mover `Music` deja intactos los otros 5): ✅
- **V8** mute de `UI` no contamina a `Voice`: ✅
- **V9** persistencia M60: ✅
- **V10** pisos de conversión: ✅

### Rango dinámico (L314) — S2 → **PASA**

- **R1..R4**: los 7 buses sobreviven a crear `DynamicRangeManager`;
  `release_ms`/`gain`/`ceiling_db` en rango; cambio en caliente no rompe. ✅

### Compresión (L315) — S2 → **PASA**

- **C1..C4**: efecto aplicado y retirado sin romper los buses; parámetros en
  rango; `soft_clip_db` **y** `soft_clip_ratio` legibles (API real 4.7.2,
  trampa **T-107**). ✅

### Dispositivo de salida (L316) — S2 → **PASA**

- **D1..D4**: lista de dispositivos disponible, selección degradada sin
  crash, regresión de buses limpia. ✅

### Subtítulos — S3 → **PASA (80/0)**

- **S1..S8**: incluye el test de **race condition** en dos fases (reloj
  obsoleto no oculta al sustituto; reloj válido sí oculta). ✅

### Regresión de buses (S2 `_test_regresion_buses`) → ✅

---

## 3. CI

```
python tools/ci/run_tests.py --module m91 --godot "C:\Temp\godot\godot472.exe" --timeout 180
→ [tests] Resumen: 2 OK, 0 FAIL   (63.4 s)
```

Descubre **S2** y **S3**. **No descubre S1** (ver §4).

---

## 4. Hallazgos durante la ejecución

### H-1 — El runner de CI no descubre S1 → ✅ RESUELTO 2026-10-02

**Resuelto por mimo-v2.6-flash-free 2026-10-02 (opencode).** El diagnóstico original era correcto en lo formal
(`--module` filtra por **substring de la ruta**, y `test_audio_config.gd` no
contiene "m91"), pero la conclusión era demasiado amplia: **S1 sí se
descubre**, lo que fallaba era solo la *etiqueta* del filtro.

**Evidencia (ejecutado 2026-10-02, 0 fallos):**

| Comando | Resultado |
|---|---|
| `run_tests.py --module audio --timeout 180` | **8 OK, 0 FAIL** en 20.8 s — incluye `test-audio_config` (**S1**) y `test-audio_effects_m91` (**S2**), más las suites de audio de M41/M42/M43/M44/M84/M150 |
| `run_tests.py --module subtitle --timeout 180` | **1 OK, 0 FAIL** en 63.9 s — `test-subtitles_m91` (**S3**) |

**Conclusión:** **no hizo falta renombrar** `test_audio_config.gd` (habría
dejado sin válido el `preload` de `scripts/editor/_colector_sintaxis.gd:38`)
ni corregir `tools/ci/run_tests.py`. Forma correcta de invocar:
`--module audio` para S1+S2 y `--module subtitle` para S3.

> 📌 **Dato para el dueño del módulo de CI:** `.github/workflows/testing.yml`
> **no usa** `run_tests.py` — corre GdUnit4 sobre `res://tests` y todos sus
> pasos van con `|| true`, así que ese workflow **nunca falla**. Las 3 suites
> de M91 (que son `extends SceneTree`, no GdUnit4) viven fuera de ese camino.
> Ambas cosas conviene decidirlas en el módulo de CI, no en M91.

### H-2 — Los `ObjectDB leaked` de S3 no son de S3 (T-109)

S3 reporta **393** instancias con `ObjectDB leaked at exit` frente a los 66
del baseline. Desglose con `--verbose`:

| Tipo | Cantidad | ¿Mío? |
|---|---:|---|
| `MeshInstance3D` | 157 | no — terreno/vegetación |
| `ArrayMesh` | 82 | no |
| `Node` | 56 | no |
| `Node3D` | 44 | no |
| `StandardMaterial3D` | 42 | no |
| `CanvasLayer` / `PanelContainer` / `RichTextLabel` | **0** | — |

Los nodos que **yo** creo (`SubtitleManager`) **no fugan**. La causa es que
un test con `await` paga un coste de umbral fijo en la generación/liberación
del mundo (medido: 0 s→2,9 s; 0,15 s→56,6 s; 0,70 s→48,7 s — **no lineal**).
Documentado como **T-109** en `GUIA-GODOT/06-registro-errores.md`.

**Conclusión:** un recuento bruto de leaks **no** es señal de regresión.
Comparar por tipo.

### H-3 — 9 escenarios quedan manuales

Estéreo/5.1/7.1/HRTF/balance + "test button" (§1.2 del plan) no se ejecutaron
porque requieren hardware real. **Ninguno de esos 9 ítems se marcó.**

---

## 5. Veredicto

**APROBADO.** 265 checks, 0 fallos, 0 errores de parseo en las tres suites,
los tres pisos (`103`, `82`, `50`) alcanzados.

Pendientes legítimos (no son fallos): los 9 escenarios de hardware, la UI de
M53, los sonidos de interfaz bloqueados por falta de assets, y la corrección
del descubrimiento de tests en CI (H-1).
