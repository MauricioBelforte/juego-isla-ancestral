# 01 — Conexión con Blender (V5) y Convenciones de Código bpy

> **Modelo:** glm-5.3-free (Kilo Code) / MiMo V2.5 (OpenCode)
> **Fecha:** 2026-09-05
>
> Guía de conexión MCP (V5), herramientas reutilizables, convenciones de código
> bpy y tabla de alturas objetivo por tipo de objeto.

---

## 1. Conexión con Blender (V5)

La vía V5 usa Blender en modo servidor + un cliente Python de la venv del proyecto. **No requiere addon de terceros**: Blender corre headless con un socket que ejecuta código `bpy` enviado por el cliente.

| Pieza | Ruta (`tools/mcp/blender-mcp/scripts-reutilizables/`) | Función |
|---|---|---|
| Servidor | `arrancar_servidor_mcp.py` | Arranca Blender 4.2 headless, socket `127.0.0.1:9876` |
| Cliente | `bpy_cliente.py` | `blender_command('execute_code', {'code': ...})` |
| Captura | `cap_blender.py` | Screenshot offscreen del viewport → PNG en `capturas/` |
| **QA numérico** | `verificar_bounds.py` | `python verificar_bounds.py SM_Coco_` → nº objetos, `z_min`/`z_max`/alto, rango X/Y de centros, duplicados. Sustituye a la revisión visual cuando el modelo no acepta imágenes (E-10). Ver también E-09. |
| **Asentar en base** | `asentar_en_base.py` | `python asentar_en_base.py SM_Tronco_Caido 0.045` → baja el grupo hasta `z_min = 0.045`. Para correcciones one-off fuera del script. |
| **Auditar todos** | `auditar_apoyos.py` | `python auditar_apoyos.py 15-Recursos` → ejecuta todos los `crear_*_lowpoly.py` del módulo y reporta cuáles tocan el suelo (FLOTA si `z_min > 0.05` y `< 0.50`). Ver E-12. |
| **Captura multi-ángulo** | `capturar_angulos.py` | `python capturar_angulos.py SM_Coco_ base.png 6` → genera 6 capturas equi-espaciadas alrededor del asset. **Obligatorio** para aprobar (E-13, §6.2bis). |
| Ejemplo | `crear_palmera_lowpoly.py` | Asset reutilizable completo |

### Flujo estándar (PowerShell)

```powershell
# 1) Arrancar servidor (el socket 9876 NO se mantiene en background; ver E-07).
#    Blender debe estar con GUI; el addon abre el socket al iniciar.
& 'D:\Archivos de programa\Blender Foundation\Blender 4.2\blender.exe' --python tools/mcp/blender-mcp/scripts-reutilizables/arrancar_servidor_mcp.py
#    (Alternativa: abrir Blender normalmente, N -> BlenderMCP -> "Connect to MCP server".)

# 2) Ejecutar un script dentro de Blender
& 'tools/mcp/.venv/Scripts/python.exe' -c "import sys, json; sys.path.insert(0, r'tools/mcp/blender-mcp/scripts-reutilizables'); from bpy_cliente import blender_command; code = open(r'<SCRIPT>.py', encoding='utf-8').read(); print(json.dumps(blender_command('execute_code', {'code': code})))"

# 3) Capturar resultado (SIEMPRE, timestamp nuevo — nunca sobrescribir)
& 'tools/mcp/.venv/Scripts/python.exe' 'tools/mcp/blender-mcp/scripts-reutilizables/cap_blender.py' "tools/mcp/blender-mcp/capturas/{ID-Modulo}-Nombre/cap_{ID}_{AAAA-MM-DD_HH-MM-SS}_nota.png"
```

### Reglas
- Verificar puerto 9876 antes de enviar código.
- Capturas en `capturas/{ID-Modulo}-Nombre/` con timestamp; conservar la anterior como comparativa (AGENTS.md §24).

---

## 2. Convenciones de código bpy

- **Nombres tipo Godot:** prefijos `SM_` (static mesh), `M_` (mesh data), `MAT_` (materiales). Facilita exportar sin renombrar.
- **Una malla por pieza estructural:** preferir `bmesh` (una malla) antes que apilar primitivas de `bpy.ops` (ver E-01).
- **Materiales lowpoly:** nombres claros y roughness alto.
- **Escena de prueba:** incluir `CAM_<Asset>` encuadrada + sol rasante para validar sombras en cada captura.
- **Idempotencia:** el script debe limpiar la escena para poder re-ejecutarse sin duplicar.
- **Guardado:** terminar con `bpy.ops.wm.save_as_mainfile(filepath=...)` a la carpeta del módulo (ruta absoluta — ver §6.3 y E-04).

---

## 2.5 — Patrón de referencia de ALTURAS por tipo de objeto (obligatorio)

> **Fuente:** feedback directo del usuario (2026-09-04, iter. 5-10 de M50 con visión).
> **Referencia aprobada:** `arbol_frutal = 6.0 m` (el usuario lo validó como "tamaño más acorde").
> **Referencia de mundo:** personaje = 1.8 m, voxel = 1 m.

### Regla
Todo asset nuevo (vegetación, fauna, NPC, prop) se modela para alcanzar una **altura objetivo en metros** de esta tabla. El multiplicador se calcula como `altura_objetivo / altura_GLB_actual` y se **hornea en Blender** (`transform_apply(scale=True)`) — NO se escala en runtime. Después de hornear, la entrada en `data/escalas/escalas.json` pasa a `1.0`.

### Tabla validada (2026-09-04)

| Categoría | Objeto | Altura objetivo | Notas del usuario |
|---|---|---|---|
| **Vegetación** | arbol_frutal | **6.0 m** | **REFERENCIA APROBADA** |
| Vegetación | palmera / palmera_inclinada | 8.0 m | ×1.6 sobre frutal (copa arriba, tronco visible menor) |
| Vegetación | liana_colgante | 8.0 m | colgante — alcanza el suelo |
| Vegetación | palmera_joven | 4.5 m | entre frutal y arbusto |
| Vegetación | helecho_gigante | 0.8 m | el usuario los quería MÁS BAJOS |
| Vegetación | helecho_chico | 0.35 m | |
| Vegetación | arbusto_redondo/floral | 0.5 m | el usuario los quería MÁS CHICOS |
| Vegetación | musgo_roca | 0.3 m | |
| Vegetación | hongo_luminoso | 0.5 m | |
| Vegetación | canas_bambu | 2.5 m | |
| Vegetación | flor_isla | **1.2 m** | ⚠️ iterativo: 0.8 "no la vi" → 2.4 "muy grande" → 1.2 ✓ |
| Vegetación | hierba_alta | ~0.1 m (runtime 1.5x) | GLB plano en XZ — escala runtime |
| Vegetación | raices_expuestas | ~0.3 m (runtime) | GLB plano en XZ — escala runtime |
| **Fauna** | jabalí adulto | 1.1 m | |
| Fauna | tortuga_marina | 0.8 m | |
| Fauna | gaviota | 0.5 m | |
| Fauna | conejo | 0.35 m | ✅ aprobado por usuario (v5) |
| Fauna | nutria | 0.7 m | |
| Fauna | cangrejo | 0.25 m | |
| Fauna | lechuza | 0.5 m | |
| Fauna | abeja | 0.1 m | |
| **NPC** | todos los vecinos | 1.0 (GLB) = 1.8 m | igual al personaje |

### Errores de esta tabla documentados (NO repetir)
- **E-58 — Alturas objetivo sin medir el GLB actual:** la iter. 9 (Log 742) usó multiplicadores fijos de la tabla asumiendo GLBs de ~1m, pero los GLB tenían alturas originales variadas (0.05m a 3.86m). Palmera ×5 = 19.3m gigante. **Fix:** multiplicador dinámico = `altura_objetivo / altura_actual` (medir con `altura_maxima(objs)` en bpy ANTES de escalar).
- **E-59 — flor iterativa:** 0.25m "no la vi" → 0.8m "no la vi" → 2.4m "muy grande" → 1.2m ✓. Lección: los cambios de tamaño requieren confirmación visual del usuario en cada paso; no ajustar de más.

### Pipeline de escalado (scripts reutilizables)
1. Medir altura actual del GLB con bpy (`altura_maxima(objs)`).
2. `multiplicador = altura_objetivo / altura_actual`.
3. `bpy.ops.transform.resize(value=(m, m, m))` + `transform_apply(scale=True)` (horneado — normales y colisiones correctas).
4. Re-exportar GLB a la misma ruta.
5. Actualizar `data/escalas/escalas.json` → entrada a `1.0` (horneado).
6. **Verificación E-13:** render orbital (6 azimuts) + confirmación del usuario.

Scripts: `reescalar_vegetacion_v2.py` (v2, multiplicador dinámico), `reescalar_v4_feedback.py` (v4 ajustes puntuales), `reescalar_v5.py` (v5 palmeras/arbustos/lianas), `reescalar_fauna_v1.py` (fauna).

### Fuente única de verdad en runtime
`data/escalas/escalas.json` + autoload `EscalasGlobales` (scripts/core/escalas_globales.gd): `EscalasGlobales.escala_de(tipo)` con match exacto + substring. GLBs horneados = entrada 1.0. GLBs planos (hierba, raíces) = escala runtime.

---

**Fecha:** 2026-09-04 (glm-5.3-flash / Kilo Code, con feedback directo del usuario en M50 iter. 5-10)
