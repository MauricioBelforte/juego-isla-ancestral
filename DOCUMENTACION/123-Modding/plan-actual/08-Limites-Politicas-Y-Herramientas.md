# 08-Limites-Politicas-Y-Herramientas.md — Módulo 123: Modding

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 (iteración 2)
**Cubre:** §8 "documentación de uso de las herramientas" · §9 "documentación de
límites y políticas" · §11 "telemetría de subscripciones sin datos personales"

## 1. Límites (duros, aplicados por código)

| Límite | Valor | Constante | Código de error |
|---|---|---|---|
| Tamaño por mod | 100 MB | `ModSandbox.LIMITE_MOD_MB` | — |
| Assets por dominio | 10 MB | `ModSandbox.LIMITE_ASSETS_MB` | `E11` |
| Mods simultáneos | 100 | `ModSandbox.MAX_MODS` | — |
| Esquema de manifiesto | `1.0` | `ModValidator.SCHEMA_VERSION` | `E13` |

Los límites viven en el manifiesto (`limite_mod_mb`, `limite_assets_mb`,
`max_mods`) y en constantes de `ModSandbox`, para que no haya dos fuentes de verdad.

## 2. Políticas

### 2.1 Seguridad
- **Sin ejecución de scripts en V1:** los mods son **solo datos** (JSON + assets).
  La v2 con scripts requiere hash aprobado (M106) y reinicio obligatorio.
- **Sin red:** un mod no puede hacer peticiones de red.
- **Aislamiento de rutas:** toda ruta de un asset se valida con
  `ModSandbox.ruta_segura(ruta, base)`. Se rechaza `..`, rutas absolutas, unidades
  de disco (`C:`) y backslashes con `..`. Una ruta que escape de la base del mod
  es un error `E10` **bloqueante**.
- **Rechazo de paquete corrupto:** un manifiesto sin los campos obligatorios
  (`id`, `version`, `min_build`, `author`) se rechaza con `E06` y un mensaje claro.

### 2.2 Assets
- El **nombre** de un asset sigue el **esquema de M108** (idéntico, no una copia
  divergente): `^(mdl|tex|mat|aud|anim|fnt|ui|vox)_[a-z0-9_]{1,59}$`.
- La **extensión** debe ser coherente con el prefijo (mapeo de M108):
  `glb/gltf/obj`→`mdl` · `png`→`tex|ui|vox` · `webp`→`tex|ui` · `ogg/wav`→`aud` ·
  `ttf/otf`→`fnt`.
- Cada asset se referencia **por id** (`nombre`) más su `ruta` relativa dentro de
  la carpeta `assets/` del paquete.
- **Readme obligatorio:** un paquete sin readme se rechaza con `E07`.

### 2.3 Conflictos
- Un **override explícito** en el manifiesto gana.
- Si dos mods apuntan al mismo objetivo, gana el de **mayor `prioridad`**; los
  demás se **omiten** y se reportan como advertencia con el motivo
  (`resolver_prioridad()`).
- Un id **duplicado sin override** es un error `E02`.

### 2.4 Distribución y soporte
- Distribución oficial **solo** por Steam Workshop (V2); sin tienda propia.
- Moderación: reportes → M100. Lista negra de mods retirados.
- Triaje de bugs: **solo** se aceptan si reproducen **sin** mods.
- Flag `--no-mods` para soporte.

### 2.5 Telemetría sin datos personales (§11)
La telemetría de suscripciones (M104) reporta **solo agregados**:
- nº de mods activos por sesión (entero),
- ids de mod (identificadores públicos del Workshop, **no** datos del usuario),
- resultado de la carga (ok / omitido / error por código `E##`).

**Nunca** se envía: ruta local, nombre de usuario, rutas de `user://`, IP
(asociada), ni contenido de los mods. La implementación concreta es de **M104**;
aquí se fija la política.

## 3. Códigos de error (`ModValidator.CODIGOS`)

| Código | Significado |
|---|---|
| `E01` | mod sin id |
| `E02` | id duplicado sin override explícito |
| `E03` | mod sin versión |
| `E04` | mod sin min_build |
| `E05` | override apunta a un mod inexistente |
| `E06` | paquete corrupto (campo obligatorio ausente o de tipo erróneo) |
| `E07` | readme obligatorio ausente |
| `E08` | asset no cumple el esquema M108 |
| `E09` | extensión de asset no coincide con su prefijo |
| `E10` | ruta insegura / path traversal |
| `E11` | asset supera el límite de 10 MB por dominio |
| `E12` | asset duplicado en el paquete |
| `E13` | `schema_version` incompatible |
| `E14` | prioridad inválida (no numérica) |

## 4. Uso de las herramientas

### 4.1 Validar un paquete completo (manifiesto + assets)

```gdscript
const ModValidator := preload("res://scripts/modding/mod_validator.gd")

var errores: Array = ModValidator.validar_paquete(paquete, "user://mods/mi_mod")
if errores.is_empty():
    print("paquete OK")
else:
    print(ModValidator.reporte(errores))
```

### 4.2 Validar el catálogo de mods instalados

```gdscript
var errores: Array = ModValidator.validar(config)   # config = mod_manifest.json parseado
print(ModValidator.reporte(errores))
```

### 4.3 Comprobar una ruta (sandbox)

```gdscript
const ModSandbox := preload("res://scripts/modding/mod_sandbox.gd")

var r: Dictionary = ModSandbox.ruta_segura("assets/mdl_item_espada_01.glb", "user://mods/mi_mod")
if not r.get("ok", false):
    push_error("ruta rechazada: %s" % r.get("error", ""))
```

### 4.4 Resolver prioridades y compatibilidad

```gdscript
var r: Dictionary = ModdingManager.resolver_prioridad()   # {activos, omitidos}
for o in r.get("omitidos", []):
    push_warning("mod omitido: %s (%s)" % [o["id"], o["motivo"]])

var ok: bool = ModdingManager.es_compatible_update("mod_aurora_items", "1.2.0")
```

### 4.5 Ejecutar el test headless

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/modding/test_modding_m123.gd
```

## 5. Lo que NO cubre este documento

- Desempaquetado real de `.zip`/`.mod` (no implementado).
- UI de mods (M89) y Workshop de Steam (M97) — V2.

**Firmado:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-13
