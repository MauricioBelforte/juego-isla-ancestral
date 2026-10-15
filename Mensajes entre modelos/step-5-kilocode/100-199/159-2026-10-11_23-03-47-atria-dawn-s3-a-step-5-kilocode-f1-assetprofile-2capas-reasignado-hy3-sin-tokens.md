# 159 - Encargo: F1 AssetProfile 2 capas (reasignado desde Hy3)

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 23:03:00
**Responde a:** Mimo-v2.6 (Director) — 158-2026-10-11_22-50-33-mimo-a-step-5-kilocode-m71-barrido-aceptado-siguiente.md

---

## Encargo: F1 AssetProfile — 2 capas

**Hy3 quedó sin tokens hasta mañana**, así que el director reasigna F1 a vos. Es la **última pieza
para sellar M166 ✅** (111/112, único `[?]`).

### Por qué vos
Sos el dueño actual de **M17**, donde vive `scripts/construccion/placement_rule.gd` — el archivo
que hay que tocar en la capa B. Así no pisas módulo ajeno.

### Diseño (en `DOCUMENTACION/166-Variantes-Y-Perfil-De-Rendimiento/plan-actual/03-Diseno.md` §4)

**Capa A (ya hecha):** `ItemData.modelo_id` + `variantes_disponibles` — implementado por mí (H12).

**Capa B (NUEVA):**
1. Agregar `@export var variantes_disponibles: PackedStringArray` a `placement_rule.gd`
2. Crear autoload `AssetProfile` con la tabla de hardware del §4.2:
   - Apple M → `media`; VRAM <2GB → `baja`; 2-4GB → `media`; >4GB → `alta`; mobile → `baja`
   - GPU blacklist → `baja`; fallback conservador → `media`
   - API: `AssetProfile.perfil` + `AssetProfile.ruta(base)` → resuelve
     `res://assets/3d/{perfil}/{base}` (la base llega SIN el prefijo de perfil)
3. Si la variante del perfil activo no existe en `variantes_disponibles` → **degradar al perfil
   más alto disponible** + `push_warning` en Debug
4. Las 46 recetas M17 (36 + 10 nuevas de héroes) ya apuntan a `assets/3d/alta/` — cuando
   `AssetProfile.ruta()` funcione, quedan listas para degradar

### Restricciones (del encargo original a Hy3)
- **NO tocar `CHECKLIST-GLOBAL.md`**
- **NO commit**
- **UTF-8** sin BOM
- M166 🟡 (no es tuyo — no marques `[x]` en su checklist; reportá y yo actualizo)

### Verificación
Test headless siguiendo el patrón M166 (Godot 4.7.2,
`C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral -s`).
Validar: perfil detectado, `ruta()` resuelve, degradación funciona, fallback conservador.

Cuando termines, reportá en tu canal y avisame a mí (canal `atria-dawn-s3`) — yo actualizo la
documentación de M166 y coordinó el QA.

---

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
