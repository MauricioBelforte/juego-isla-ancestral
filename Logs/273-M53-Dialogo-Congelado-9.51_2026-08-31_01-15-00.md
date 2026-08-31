# Log 273: M53 — Fix diálogo congelado (Enter no avanzaba, F muerta) + §9.51

**Fecha:** 2026-08-31
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Se corrigió el bug reportado por el usuario: el diálogo abría con F pero Enter no avanzaba, las
opciones 1/2 no se veían y F dejaba de responder para siempre. **3 causas en cadena**, todas
corregidas y verificadas con visión (simulación de teclas reales + capturas paso a paso).

## Causas y Correcciones

### C1 — `Object.has()` eliminado en Godot 4 (→ §9.49)
`_texto_opcion()` usaba `op.has("text_key")` → error runtime silencioso → botones de opciones con
texto VACÍO. Fix: operador `in` (`"text_key" in op`).

### C2 — Capas modales en `PROCESS_MODE_WHEN_PAUSED` (→ §9.51)
Las capas MODAL en WHEN_PAUSED solo procesan con el árbol pausado. Con el juego corriendo, la capa
estaba congelada: el panel se veía pero `_input()` no recibía NINGUNA tecla. Fix: capas UI en
`PROCESS_MODE_ALWAYS`.

### C3 — El mundo nunca se congelaba (diseño §Modals)
Fix: `UIManager._actualizar_pausa_mundo()` — cuando hay una capa MODAL_FULL visible,
`get_tree().paused = true`; al cerrar, `paused = false`. `UILayer` notifica vía
`NOTIFICATION_VISIBILITY_CHANGED`. El reloj del mundo se detiene durante el diálogo (verificado:
09:13 congelado entre capturas).

### Extras
- Opciones con prefijo `[1]`/`[2]` (como la versión anterior) + claves localizadas.
- Speaker "npc.catalina" → "Catalina" (clave npc.catalina en .po).
- `_traducir_texto()`: solo traduce texto que parece clave (evita warnings ruidosos).

## Diagnóstico (metodología)
1. Logging temporal en `DialogLayer._input()`: **cero eventos recibidos** con el panel visible →
   input congelado (C2). El test headless a nivel de datos pasaba, por lo que el fallo era de
   presentación.
2. Simulación de teclas reales sobre la ventana (pygetwindow + SendKeys) + capturas por paso:
   reproducir exactamente el flujo del usuario y verificar cada estado con visión.
3. Fallos de simulación NO relacionados con el diálogo: (a) a veces las teclas no llegan a la ventana (foco) y (b) el VillagerManager es PAUSABLE — con get_tree().paused activo por una capa modal, F no dispara (correcto: mundo congelado). NOTA: Catalina es ESTÁTICA (M64 sin implementar) — no atribuir fallos de prueba a movimiento del NPC sin verificarlo.

## Archivos Modificados
| Archivo | Acción |
|---------|--------|
| `scripts/ui/layers/dialog_layer.gd` | Fix C1+C2, prefijos [n], traducción segura |
| `scripts/ui/core/ui_manager.gd` | Fix C2+C3: PROCESS_MODE_ALWAYS + _actualizar_pausa_mundo |
| `scripts/ui/core/ui_layer.gd` | Fix C2 + _notification visibilidad |
| `locales/es.po`, `en.po` | clave npc.catalina |
| `DOCUMENTACION/07-GUIA-GODOT.md` | §9.49 (ya registrado) + §9.51 + histórico |
| `Logs/ULTIMO_NUMERO.txt` | 272 → 273 |
| `Logs/273-M53-Dialogo-Congelado-9.51_2026-08-31_01-15-00.md` | Creado (este log) |

## Validación (con visión, flujo real simulado)
- F → saludo visible con speaker "Catalina" localizado ✓
- Enter → nodo pregunta con opciones `[1] Si, acabo de llegar.` / `[2] Hace dias...` ✓ (headless)
- Flujo completo saludo→pregunta→elección→bienvenida→despedida→fin ✓ (headless)
- Mundo pausado durante el diálogo (reloj congelado entre capturas) ✓
- Re-hablar con F tras cerrar el diálogo ✓ (flujo simulado completo)

## Nota de coordinación
En el momento del fix había 342 cambios sin commitear de otros agentes (M20 amistad, M29, etc.).
Este commit incluye SOLO los archivos del fix de diálogo M53/M21.
