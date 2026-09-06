# Log 695: M36 Gaviota — Rediseño Blender + plegado v15 + pose erguida + ciclo vivo

**Fecha:** 2026-09-05
**Hora:** 12:05
**Modelo:** glm-5.3-free
**Plataforma:** Kilo Code

## Resumen
Jornada completa de la gaviota: fix histórico del plegado, rediseño del
asset en Blender (patas x2 + alas cortas + pies), pose parada erguida
aprobada por el usuario, porteo al NPC y verificación del ciclo completo
vuelo→aterrizaje→caminata→despegue EN VIVO en main_island.

## Cambios Realizados

### 1. Fix del plegado (v13, Log 694 continuado)
Causa raíz: ejes equivocados para el GLB real (pico +X, span alas ±Z).
Roll=rotation.z (mismo signo), yaw=rotation.y (negado por lado),
pitch por MEDICIÓN (búsqueda de 41 valores contra el objetivo).

### 2. Rediseño Blender (v14)
- Alas: span 0.82 → 0.60 (achicadas, a pedido del usuario)
- Patas: 0.09 → 0.18 (dobles de largas), pose de VUELO recogidas hacia
  atrás bajo la cola (pedido explícito), taper cadera-gruesa→pie-fino
- Pies nuevos: pads planos pegados al extremo de las patas
- Backup previo en 36-Fauna/Obsoletos/ (blend + 3 GLBs)
- Incidente: otra sesión (nutria) pisó gaviota_lowpoly.blend guardando
  encima — recuperado desde .blend1; todo el trabajo pasó a headless

### 3. Pose parada erguida (v15, aprobada por el usuario)
- POSE_PARADA 0.10 → 0.42 rad: pecho arriba, cola ~4 cm del suelo
- Alas caídas: objetivo rel_y −0.20 (puntas 20 cm bajo el hombro,
  pegadas al flanco, pueden rozar la arena) — iterado con el usuario
  (0.05 → −0.10 → −0.20, aprobado)
- Patas verticales por QUATERNION (rotación más corta al eje mundo,
  ajenas al pitch del cuerpo) + pies re-parentados y aplanados
- Asentado por bounding REAL de patas/pies medido en runtime

### 4. Porteo al NPC + verificación en vivo (main_island.tscn)
- gaviota_npc.gd: plegado v15 completo, despliegue de patas al aterrizar
  (factor 1.0 instantáneo + recalibrado de altura), replegado al despegar
  (rotación base del GLB capturada en _ready)
- En vivo (45 s): 2 ciclos completos vuelo→aterrizaje(asentado medido
  min_y)→caminata→despegue. Sin trabas.

### 5. Fix de emergencia del BOOT del proyecto (M110, no solicitado)
scripts/debug/debug_menu.gd tenía 4 errores de sintaxis estilo Python
que IMPIDÍAN EL BOOT de todo el proyecto (otro agente lo dejó así):
- arr[-200:] → Array.slice(-200)
- String.encode("utf-8") → String.to_utf8_buffer()
- ProjectSettings.get(clave, default) → get_setting()
- OS.get_dynamic_memory_usage() → Performance MEMORY_STATIC
- docstrings `\"\"\"...\"\"\"` → comentarios ##

## Archivos Modificados
- game/isla-ancestral/scripts/fauna/gaviota_demo.gd (v15c final)
- game/isla-ancestral/scripts/fauna/gaviota_npc.gd (v15 portado)
- game/isla-ancestral/scripts/debug/debug_menu.gd (boot fix)
- tools/mcp/blender-mcp/36-Fauna/gaviota_lowpoly.blend (rediseño)
- game/isla-ancestral/assets/3d/alta/36-Fauna_gaviota.glb (re-exportado)
- tools/mcp/blender-mcp/36-Fauna/Obsoletos/ (backups)

## Pendiente
- Exportar variantes media/baja del nuevo diseño.
- QA visual del usuario en vivo (V1) del ciclo completo.
- Documentar E-11/E-12 en 07-GUIA-GODOT §8 (pendiente de log 694).

## Addenda (v16 — hop de escalón, pedido del usuario)
**Problema:** en modo terrestre el hop saltaba pero no llegaba a subir el
escalon de 1 m del terreno voxel (apex 1.04 m, caia en el borde).
**Fix:** _v_salto 5.4 → 6.5 (apex ~1.51 m) + empuje frontal x2.5
durante el arco para superar el labio del escalon (gaviota_npc.gd).
**Verificación en vivo (60 s):** 2 posadas completas caminando y despegue
normal; CERO eventos "tierra muy bloqueada" (antes despegaba por bloqueo).
