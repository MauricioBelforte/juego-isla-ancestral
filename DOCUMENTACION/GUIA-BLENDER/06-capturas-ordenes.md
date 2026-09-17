**Modelo:** opencode/mimo-v2-pro-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

---

# 06 — Capturas, Órdenes de Creación y Estructura de Carpetas

## 5. Caso de estudio: palmera lowpoly (2026-08-27)

- Tronco: tubo curvo único bmesh (radio 0.30→0.18, curvatura `x = 0.70·t²`, altura 3.9).
- 7 frondas: tiras de vértices, ancho `sin(πs)^0.6`, caída parabólica; alternando largo.
- 3 cocos: ico-esferas (subdiv 1) bajo la corona.
- Evidencia: `capturas/154-Vision-Del-Agente/cap_154_2026-08-27_23-09-22_palmera-07.png` (final) + historial 01–06.


## 6. Directivas de Orden de Creación y Capturas por Objeto (2026-08-27, directiva del usuario)

### 6.1 Checklist maestro de objetos

Existe un **checklist maestro de todos los assets 3D a crear en Blender**, organizado por módulo:

> 📋 **`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`**

Reglas:
1. **Toda tarea de modelado parte de ese archivo:** se elige el objeto del checklist (módulo habilitado según `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`), se crea el script `crear_{objeto}_lowpoly.py` y al terminar se marca `[x]` con fecha.
2. **Prohibido modelar objetos fuera del checklist** sin agregarlos primero al archivo (con su módulo correspondiente).
3. Los contadores al pie del checklist deben actualizarse (total / completados).

### 6.2 Captura de constancia por objeto (obligatoria)

Igual que en Godot (M154): **todo objeto creado en Blender debe dejar captura de constancia**.
- Cada iteración de modelado genera una captura con timestamp nuevo (nunca sobrescribir).
- Carpeta destino: `tools/mcp/blender-mcp/{ID-Modulo}-Nombre/capturas/` (ej. `50-Vegetacion/capturas/cap_50_2026-08-27_23-15-00_palmera.png`). Ver §6.3.
- La captura final aprobada + la anterior se conservan siempre como comparativa antes/después.
- **Un ítem del checklist sin captura NO cuenta como completado** (criterio de la DoD de este checklist).
- Durante el desarrollo se guardan TODAS las capturas; la limpieza solo cuando el usuario lo pida (AGENTS.md §24).

### 6.2bis Procedimiento de captura multi-ángulo (obligatorio, E-13)

Una sola captura frontal puede ocultar por completo la flotación. **Está prohibido aprobar un asset con una sola captura**. Procedimiento:

1. Correr el script del asset (debe terminar con su bloque de autocorrección de apoyo, E-12).
2. Correr `scripts-reutilizables/capturar_angulos.py SM_<asset> capturas/cap_XX_YYYY-MM-DD_HH-MM-SS_<asset>-orbita.png 6` para generar 6 capturas equi-espaciadas alrededor del objeto.
3. **Revisar las 6 capturas** y confirmar que en NINGUNA se ve luz/aire entre el objeto y su base.
4. Si una sola captura muestra flotación → corregir el script (cubrir la zona, asentar más, lo que sea) y volver a correr desde 1.

Comando de referencia:

```bash
python scripts-reutilizables/capturar_angulos.py \
    SM_Nido_Base \
    capturas/cap_15_2026-08-28_15-52-00_nido-orbita.png \
    6
```

El script crea `*_az000.png`, `*_az060.png`, `*_az120.png`, `*_az180.png`, `*_az240.png`, `*_az300.png` (con N=6). La DoD del checklist exige las 6 capturas con timestamp. Sin todas las capturas, el ítem **no** está aprobado.

Si el modelo en curso no acepta imágenes (E-10), pedir al usuario (o a un modelo multimodal) que las revise. No zanjarlo solo con la auditoría numérica.

### 6.3 Estructura de carpetas por módulo (2026-08-27, directiva del usuario)

Cada módulo con objetos 3D tiene **su propia carpeta** dentro de `tools/mcp/blender-mcp/`, con prefijo = ID del módulo según `CHECKLIST-GLOBAL.md`:

```
tools/mcp/blender-mcp/
├── {ID-Modulo}-Nombre/           ← UNA carpeta por módulo
│   ├── crear_*.py                ← scripts de los objetos de ese módulo
│   ├── *.blend                   ← archivos Blender del módulo
│   └── capturas/                 ← capturas de constancia (formato §6.2)
├── scripts-reutilizables/        ← herramientas transversales (bpy_cliente, cap_blender, servidor)
├── scripts-prueba/               ← scripts esporádicos de prueba
└── CHECKLIST-OBJETOS-BLENDER.md  ← checklist maestro de todos los objetos
```

Reglas:
1. Los scripts de objetos **nunca van en `scripts-reutilizables/` ni en la raíz** — van en la carpeta de su módulo.
2. El `.blend` se guarda **en la carpeta del módulo** con **ruta absoluta** (ver E-04: el cwd de Blender es su carpeta de instalación, `os.getcwd()` no sirve).
3. Las capturas van en `capturas/` **dentro de la carpeta del módulo** (ya no en una carpeta global `capturas/`).
4. Al crear objetos de un módulo sin carpeta, crearla primero con el prefijo de su ID.
5. Estado actual: `50-Vegetacion/` (palmera ✅), `154-Vision-Del-Agente/` (pruebas del pipeline V5).
