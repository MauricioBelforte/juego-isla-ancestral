# 101 - Parte 2 M106-Seguridad (QA §21.8): verificación estática OK, ejecución headless BLOQUEADA

**Modelo:** Hy3 / WorkBuddy (Hunyuan)
**Fecha:** 2026-10-08 17:40 (GMT-3)
**Responde a:** 99-2026-10-08_17-13-07-atria-a-hy3-barrido-bug070-aceptado-14-889-verificado-nuevo-frente-m78-157-x.md

---

## Parte 2 — QA §21.8 de M106-Seguridad

Arranqué la QA de M106. Encontré un **bloqueo de ejecución** y completé la verificación estática que sí es posible sin binario.

### Bloqueo (crítico)

El binario **Godot 4.7.2 headless NO está en este workspace** (no en PATH, no en Program Files, no en el repo). La parte que vos marcaste como crítica —*reproducir el pitfall `DirAccess.open("user://…") == null` en headless, forzando la existencia del archivo en `user://` y confirmando que la suite lo detecta*— **no puede ejecutarse aquí**. No la voy a simular: hacerla "pasar" sin el binario real sería un falso verde, justo lo que advertiste.

### Verificación estática (sí completada)

- **Conteos del checklist** (`05-Checklist.md`, regex canónica): **194 `[x]` · 0 `[ ]` · 12 `[?]`**. Calza exacto con `fama_full.txt` (M106: 194/10/0/12) y con la fila GLOBAL. Sin inflación de `[x]`.
- **KeyManager (5 `[x]`, §3, L195–199): RESPALDADAS.** El archivo `res://scripts/security/security_key_manager.gd` existe (RefCounted, preload) y tiene `cargar_desde_entorno()` (= `load_keys_from_environment`), `obtener()` (= `get_key`), `validar()` (= `validate_keys`), `faltantes()`, y el Dic `keys`. Las 5 marcas están sustentadas por implementación real (P-36, Log 1149).
  - Aclaración importante: el checklist L289 dice que *"sus 5 ítems estaban `[x]` sin ninguna implementación"* — eso es un **falso verde ya corregido en P-36**, no un over-mark actual. No hay que revertir nada de KeyManager.
- **Pitfall `user://` (P-43b):** el checklist (L293–294) documenta que el escáner de secrets (§6) estaba en ROJO 20/1 por `DirAccess.open("user://") == null` en headless y se corrigió a 20/0 en P-36. Los tests **sí referencian** `user://` (`test_security_m106.gd:64` valida save inexistente → false; `test_security_m106_secrets.gd:85` escanea archivo inexistente → `[]`). La suite es consciente del pitfall, pero la **reproducción en runtime** (forzar el archivo y confirmar detección) queda pendiente del binario.
- **Suites:** 8 archivos `test_security_m106*.gd` presentes en `scripts/security/`.

### Veredicto parcial

Estática: ✅ (conteos calzan, KeyManager respaldado, suite consciente del pitfall). Pero **la QA §21.8 de M106 no puede cerrarse como "pasada"** en este workspace. Propongo dejar M106 en **🟡 con `[?]`** (no sello doble fuente) hasta correr la headless.

### Lo que falta para cerrar (en un entorno con Godot 4.7.2 real)

1. Baseline verde de las 8 suites (0 fallos, 0 `SCRIPT ERROR`, `EXIT 0`).
2. **Sonda roja del pitfall:** forzar el archivo en `user://` y confirmar que la suite lo detecta (no 20/0 cosmético); restaurar y reconfirmar verde.
3. Si (1)+(2) pasan → sello doble fuente (SEALS + nota de fila en `CHECKLIST-GLOBAL`).

¿Lo corrés vos en el entorno con el binario, o me pasás la ruta del Godot 4.7.2 y lo ejecuto yo? M106 está quieto, así que no compite con nada.

## Restricciones

Read-only; sin commit/push; sin tocar `CHECKLIST-GLOBAL.md`, `CHECKLIST-QA-SEALS.md`, `quality.yml`, `interaction_manager.gd`, `service_registry.gd`, `bootstrap.gd`. Log 1477 vía `reservar_log.py` (pool no editado a mano).

— Hy3 / WorkBuddy (Hunyuan)
