# Escenas (.tscn) — Errores Comunes

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §3 + §9.6
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. RayCast3D.target_position espera Vector3, NO Transform3D

```gdscript
# ❌ Incorrecto — genera error de tipo
node.transform = Transform3D(Vector3(0, 0, 1), Vector3(0, 0, -5))

# ✅ Correcto — solo el vector dirección
node.target_position = Vector3(0, 0, -5)
```

**Error típico:** `Invalid assignment of property or key 'target_position' with value of type 'Transform3D' on a base object of type 'RayCast3D'.`

---

## 2. load_steps — Declarar EXACTAMENTE

El contador `load_steps` en el header de la escena debe indicar la cantidad **exacta** de recursos cargados:

- **Una vez** por cada recurso nuevo que se carga con `load()` o `preload()`.
- NO contar los recursos reutilizados en la misma escena.
- NO contar la propia escena ni los sub-recursos que Godot crea internamente.

**Ejemplo correcto:**

```
[gd_scene load_steps=2 format=3 uid="uid://abc123"]

[ext_resource type="Script" path="res://scripts/player.gd" id="1"]

[node name="Player" type="Node3D"]
script = ExtResource("1")
```

**Regla práctica:** Declarar `load_steps` igual a 1 más el número de recursos externos (`ext_resource`).

---

## 3. UIDs en Godot 4

- Todo recurso cargado con `load()` genera un UID en el `.import` o en el archivo directamente.
- Los UIDs se usan internamente para cachear referencias en las escenas.
- Si un UID no existe, Godot lo reconstruye automáticamente en el arranque.
- Si un `.tscn` tiene un UID duplicado, puede causar un doble offset en `load_steps`.

**Regla:** No tocar UIDs manualmente. Si aparecen errores de UID duplicados, eliminarlos y dejar que Godot los regenere.

---

## 4. Reutilización de recursos

```gdscript
# ❌ Incorrecto — crear múltiples instancias del mismo recurso
var mat1 = StandardMaterial3D.new()
var mat2 = StandardMaterial3D.new()  # Innecesario

# ✅ Correcto — un solo recurso, reutilizado
var mat = StandardMaterial3D.new()
node1.set_surface_override_material(0, mat)
node2.set_surface_override_material(0, mat)
```

**Impacto:** Cada material duplicado ocupa VRAM independiente. Para optimize draw calls, agrupar nodos que usen el mismo material.

---

## 5. check_tscn_errors.py — Análisis estático

El script `scripts/check_tscn_errors.py` analiza archivos `.tscn` buscando errores conocidos. Ejecutar periódicamente:

```bash
python scripts/check_tscn_errors.py
```

**Errores que detecta:**
- Multiplicador escalado duplicado en el header
- Loads duplicados del mismo recurso
- UIDs duplicados
- Recursos referenciados que no existen

**No reemplaza la validación manual** pero sirve como primera línea de defensa.
