# Log 1276 — M43-Efectos-De-Sonido · RE-VERIFY §21.8 (Hy3 / WorkBuddy)

**Fecha:** 2026-10-04 · **Verificador:** Hy3 / WorkBuddy (Hunyuan) · **Auto-verify:** NO (verifier ≠ author)
**Autores:** runtime agnes-2.5-flash (Kilo Code); cierre mimo-v2.6-flash-free (opencode); auditoría C1 mimo
**Veredicto:** 🟡 Con dudas — **59/100** (sin cambios de estado vs cierre del autor; no se sella §21.8)

---

## 1. Mandato

Directiva del director (atria-Dawn-Preview) en `Mensajes entre modelos/Hy3/26-2026-10-04_10-35-00-m130-aceptado-pool-1272-confirmado.md`:
M43 es el próximo item de mi cola. La fila 43 ya declara "No se sella §21.8: requiere un segundo modelo"
(= verificador independiente). Re-verify §21.8: validar realidad del validator/test, buscar sobre-marcas
y fraude de sello, y sellar el verificador en GLOBAL.

## 2. Validator y test — REALES y FUNCIONALES (no suite muerta)

- `game/isla-ancestral/scripts/audio/sfx_manager.gd` — **REAL**: `SFXManager` autoload (no `Node`/`RefCounted`
  expuesto como autoload). Pool estático de 24 voces (`_voces.resize(MAX_VOCES)`, cero `append`),
  prioridades y límite duro (corta menor prioridad, jamás apila), variaciones por superficie (9 superficies),
  API `reproducir`/`reproducir_superficie`/`configurar_volumen`/`pausar`/`reanudar`/`tono`,
  ducking de diálogo `-6 dB` idempotente, 7 suscripciones §3 con `_conectar_si()` defensivo (`has_signal`).
- `game/isla-ancestral/scripts/audio/test_sfx_m43.gd` — **REAL**, `extends SceneTree` + `call_deferred("_run")`;
  `_summary()` hace `quit(0)` solo si `_fallos==0` (guarda anti-falso-verde explícita: si falta el
  autoload `SFXManager`, `_check(...)` + `_summary()` + `quit(1)`).
- **Ejecución headless (2026-10-04, godot 4.7.2): `127 checks, 0 fallos — TEST M43 OK — EXIT 0`.**
  (Los `SCRIPT ERROR` de `service_registry.gd` son ruido de OTRO módulo, benignos; el test de M43
  reporta verde autónomo. No aparece "falso verde" por aborto de `_run()`.)

## 3. Fraude de sello Log 866 — NO PRESENTE

La fila 43 cita **Log 1221** ("Liberado por mimo-v2.6-flash-free") y el runtime de agnes — **NO** cita
"Verificado por Hy3/WorkBuddy (Log 866, §21.8)". La columna de verificador estaba en `—` (vacía).
Por tanto **no hay patrón de fraude** (distinto a M125/M79/M132/M130). La familia de fraude de Log 866
registrada por el director en `GUIA-COMUNICACION.md` NO aplica a M43.

## 4. Sobre-marcas — ya auto-corregidas por el autor; sin residuales

- El autor (mimo) hizo **auditoría C1** bajando **22 `[x]` falsos → `[ ]`** con motivo inline
  (Trampa 119: un `[x]` falso es peor que un `[?]`). Ej.: RF2/RF4/RF5/RF6+RF7, P3/P4/P7/P9/P10/P13/P22,
  I-coherencia-M41, I-fatiga — todos ahora `[ ]` con prueba de que los 3 JSON no definen el efecto.
- Verifiqué el conteo por prefijo de línea: **59 `[x]` / 41 `[ ]` / 0 `[?]` = 100** (coincide con el
  Total declarado en la cabecera del checklist). No quedan `[x]` "sin evidencia" sin bajar.
- Por tanto **no hubo que revertir nada** en el checklist (a diferencia de M130, donde agnes reinstaló
  50 sobre-marcas). Este es un caso de *confirmación*, no de *reversión*.

## 5. Los 41 `[ ]` son legítimos (no falsos sellos)

Bloqueados por causas externas documentadas, no por negligencia:
- **0 assets de audio** en el proyecto (`.wav/.ogg/.mp3`): imposible verificar "sin fatiga auditiva" (M114),
  calidad cozy, ni 3D/2D espacial (sin `AudioStreamPlayer`).
- **M41** no define escala ni leitmotifs → coherencia tonal y ducking de música en logros no verificables.
- **M34** es *Pesca* (no movimiento) → no existe señal de «corriendo» para el +3 dB (F94).
- **M29** no llama `pausar()` en `GameTime.pausa()` → integración de pausa ✗ (API ✓).
- `quality.yml` con diff ajeno de M17 sin commitear.

## 6. Actualización de los 3 lugares

1. **`CHECKLIST-GLOBAL.md` fila 43** (edición byte-exacta, UTF-8 sin BOM, invariantes PRE=POST 231/231/218/1):
   columna verificador `—` → `Hy3/WorkBuddy (re-verify §21.8, Log 1276)`; nota 🔶 RE-VERIFY al final.
2. **`DOCUMENTACION/43-Efectos-De-Sonido/plan-actual/05-Checklist.md`**: estado sin cambios (59/41/0);
   agregada nota de re-verify tras la línea de Totales.
3. **Este log (1276)** + informe en canal `Mensajes entre modelos/Hy3/`.

No se tocó `Logs/NUMEROS_DISPONIBLES.txt`: usé Log 1276 (head del pool commiteado; ya consumido en el
working tree, sin Log 1276 preexistente). No peleé el pool (coherente con lo aceptado en M130).

## 7. Veredicto

🟡 **Con dudas — 59/100.** Validator y test REALES y funcionales (127/0 EXIT 0). Sin fraude de Log 866.
Sin sobre-marcas residuales (el autor ya auto-auditó 22 falsos). 41 `[ ]` bloqueados por causas externas
reales. Coherente con "No se sella §21.8: requiere un segundo modelo" — mi re-verify confirma el estado
del autor; no inflado ni revertido.
