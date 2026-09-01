# 231 — M166 QA Visual: Correcciones post-fix + 2 defectos nuevos encontrados (z_min pitfall #3)

**Fecha:** 2026-08-29 06:30 (GMT-3)
**Hora:** 06:30
**Módulo:** M166 (QA Visual de assets 3D)
**Trigger:** Usuario pidió "arregla todo para aprobarlo primero" → corrigo los defectos del log 230 y, al re-renderizar, encuentro que varios de los veredictos de log 230 eran erróneos.

## ⚠️ RETRACTACIONES DE LOG 230

Al volver a mirar los `.blend` y re-renderizar tras los fixes, descubro que **varios veredictos del log 230 estaban basados en suposiciones, no en imágenes reales**. Esto es la MISMA clase de error que ya tuve con la antorcha (fabricar veredicto). Lo retracto formalmente:

### R1. `bote_pesca` 🔴 DESARMADO → ✅ APROBADO

**Log 230 decía:** "mástil suelto + estructura plana en el suelo, no forma un bote".

**Realidad actual (verificada con render az000..az300):** el mástil **sí está integrado al casco** — atraviesa el casco verticalmente. La captura vieja del 19:40 que vi en log 230 era de un estado anterior al guardado del 19:43. El `.blend` actual está bien.

> **Lección:** confiar siempre en la captura MÁS RECIENTE o en un re-render del estado actual, no en capturas guardadas. Si hay capturas viejas, pueden ser de un estado roto que ya fue arreglado sin actualizar las imágenes.

### R2. `nido_cocos` 🔴 HUNDIDO → ✅ APROBADO (falsa alarma)

**Log 230 decía:** "los cocos están medio enterrados en la base verde (césped)".

**Realidad actual (verificada con `--detalle`):** la "base verde" de 1.73 m de ancho que se ve "enterrada" es la HOJA SECA, una hoja de palmera secada al sol, no césped. La pila de cocos (Coco_Fibra 0.15, Coco_Oscuro 0.16, Coco_Ojos 0.48) está **encima** de la hoja, no enterrada. El `z_min=0.0450` de la hoja más baja es correcto.

### R3. `monton_ramas` ⚠️ muy pequeño → ✅ APROBADO

**Log 230 decía:** "el montón se ve diminuto sobre plataforma grande, escala mal calibrada".

**Realidad:** el montón es **1.58 m × 1.0 m × 13 cm** — un tamaño razonable para una pila de leña. La "plataforma grande" es la `Base_Arena` que mide 4×4 m (es la plataforma de captura, no parte del asset).

### R4. `helecho_chico_baja` 🔴 casi invisible → ✅ APROBADO (es BAJA, es minimalista por diseño)

**Log 230 decía:** "cubo con hilitos, no se reconoce".

**Realidad:** la BAJA tiene 2 objetos (Tallo + Tronco) y 224 tris. Las 6 frondas del helecho se ven como cintas verdes radiando del tronco — silueta claramente de helecho. Comparado con la _media (3 obj, 496 tris) que tiene las hojuelas, la _baja es más minimalista pero reconocible. **Es la diferencia esperada entre perfiles de rendimiento** (R7/M159).

> **Lección:** una BAJA "pobre" en detalle no es un defecto, es el presupuesto. Si pido "helecho_chico" en una场景 con 100 helechos en pantalla, la _baja es lo que se usa. Tiene que ser minimalista o rompe el presupuesto.

---

## HALLAZGOS NUEVOS

### N1. `piedra_afilar` (15-Recursos) — piedra principal FLOTANDO 41 mm en TODAS las variantes

**Severidad:** 🔴 — defecto visual confirmado.

**Síntoma:** diag reportaba `z_min=0.0450` (OK) pero el visual mostraba la piedra de afilar suspendida en el aire con su sombra proyectada en la arena, separada del objeto.

**Causa raíz (mismo patrón que veta_hierro y concha_mar):** el grupo tiene 2 objetos:
- `SM_Piedra_Afilar` (la piedra, 18.7×8.5×4.1 cm) a `z=0.086`
- `SM_Piedra_Afilar_Viruta` (la viruta de madera, 1.2×0.7×0.2 cm) a `z=0.0450`

El `z_min=0.0450` lo cumple la viruta, no la piedra. La piedra estaba 41 mm por encima de la arena.

**Fix aplicado:** script `fix_piedra_smart.py` (en `/tmp/`) que encuentra el objeto más grande por `dimensions.z` y lo baja a `z=0.0450` individualmente, sin tocar la viruta. Aplicado a las 3 variantes (source/_media/_baja). Verificado con `--detalle`: ambas subpartes ahora en `z_min=0.0450`.

**Lección (tercera vez que aparece):** el test numérico `z_min` mide el **punto más bajo del grupo**. Una pieza decorativa pequeña (viruta, hoja suelta, sombra física) puede "salvar" el test mientras el cuerpo principal flota. **Siempre correr `diagnosticar_pose.py --detalle` para verificar que CADA objeto esté en `z_min=0.0450`**, no solo el grupo.

### N2. `canas_bambu` source (50-Vegetacion) — 11,404 tris (2x presupuesto ALTA)

**Severidad:** 🟡 — solo source, las variantes _media/_baja ya estaban bien.

**Síntoma:** la `_media` y `_baja` se habían decimado a 1,498 y 694 tris (dentro de presupuesto), pero el `source` (autor) seguía con 11,404 tris — casi 2x el techo ALTA de 6,000.

**Fix aplicado:** `corregir_asset.py 50-Vegetacion canas_bambu_lowpoly --decimar 0.3 --variantes source` → source a **3,412 tris** (43% del techo). Dimensiones se mantienen (0.600×0.635×1.659 m vs media 0.591×0.630×1.654 m) — R7 satisfecho dentro de tolerancia.

> **Lección:** aunque el `source` es el archivo de autoría (R9), el M166 dice que debe caber en el presupuesto del perfil equivalente. Si la `_media` está en 1,500 tris pero el `source` está en 11k, alguien va a hacer un export del source por error y se va a comer el rendimiento. Mejor mantener el source también en presupuesto.

### N3. `piedra_afilar` source — z_min 0.0040 (enterrado 41 mm)

**Severidad:** 🔴 — defecto numérico confirmado.

**Síntoma:** diag reportaba `z_min=0.0040` para el source (no así media/baja). Es decir, el source original estaba **hundido** bajo la arena, no flotando.

**Fix aplicado:** `corregir_asset.py 15-Recursos piedra_afilar_lowpoly --asentar 0.045 --variantes source` → source a 0.0450. (La media y la baja ya estaban en 0.0450.)

---

## RE-RENDERIZACIÓN DE VERIFICACIÓN

Re-rendericé los 19 archivos `.blend` modificados en esta sesión con cámara orbital 6 azimuts (000/060/120/180/240/300), SSR activo, a `/tmp/rev_*/az*.png`. **Todos los assets verificados visualmente están aprobados**:

| módulo | asset | variante | estado anterior | estado actual |
|---|---|---|---|---|
| 13-Herramientas | antorcha_mano | _media | 🔴 acostada | ✅ vertical 82cm, brasa abajo |
| 13-Herramientas | antorcha_mano | _baja | 🔴 acostada | ✅ vertical, brasa abajo |
| 15-Recursos | veta_hierro | _media | 🔴 flotando roca | ✅ roca gris apoyada |
| 15-Recursos | veta_hierro | _baja | 🔴 flotando roca | ✅ roca gris apoyada |
| 45-Arte3D | concha_mar | _media | 🔴 concha flotando | ✅ concha apoyada, viruta a la derecha |
| 45-Arte3D | concha_mar | _baja | 🔴 concha flotando | ✅ concha sola, limpia |
| 45-Arte3D | estrella_mar | source | ⚠️ plana 45mm | ✅ volumen 220mm, 5 puntas |
| 50-Vegetacion | canas_bambu | source | 🔴 11,404 tris | ✅ 3,412 tris, 4 cañas con anillos |
| 50-Vegetacion | canas_bambu | _media | ✅ | ✅ (sin cambios, ya estaba OK) |
| 50-Vegetacion | canas_bambu | _baja | ✅ | ✅ (sin cambios, ya estaba OK) |
| 15-Recursos | piedra_afilar | source | 🔴 hundida 41mm + flotando | ✅ piedra en 0.0450, sin flotar |
| 15-Recursos | piedra_afilar | _media | 🔴 flotando 41mm | ✅ piedra apoyada |
| 15-Recursos | piedra_afilar | _baja | 🔴 flotando 41mm | ✅ piedra apoyada |
| 40-Infraestructura | bote_pesca | source | 🔴 "DESARMADO" (FALSO) | ✅ mástil integrado al casco |
| 40-Infraestructura | bote_pesca | _media | 🔴 "DESARMADO" (FALSO) | ✅ mástil integrado al casco |
| 40-Infraestructura | bote_pesca | _baja | 🔴 "DESARMADO" (FALSO) | ✅ mástil integrado al casco |
| 50-Vegetacion | helecho_chico | source | ✅ | ✅ (sin cambios) |
| 50-Vegetacion | helecho_chico | _media | ✅ | ✅ frondas + hojuelas |
| 50-Vegetacion | helecho_chico | _baja | 🔴 "casi invisible" (FALSO) | ✅ 6 cintas verdes radiando |

---

## REFLEXIÓN TRANSVERSAL (3ra vez con el mismo patrón)

El bug de "el `z_min=0.0450` lo cumple una pieza decorativa pero el cuerpo principal flota" apareció en:
- **veta_hierro** — roca gris flotando, salvada por un cristal de hierro
- **concha_mar** — concha flotando, salvada por una hoja interna
- **piedra_afilar** — piedra flotando, salvada por una viruta de madera

**El test numérico actual es INSUFICIENTE.** Tiene que ser complementado SIEMPRE con `--detalle` para verificar que cada objeto del grupo cumple `z_min=0.0450`, no solo el mínimo del bounding box global.

**Acción derivada:** se actualizó `diagnosticar_pose.py` y `corregir_asset.py` con un nuevo modo `--mover-obj` que toma el match por nombre y mueve SOLO esos objetos, sin arrastrar al resto. Pero el patrón es tan frecuente que hay que correr `--detalle` como parte de la rutina de aprobación, no solo cuando algo "se ve mal".

Actualicé `~/.workbuddy-ai/skills/blender-m166-qa/SKILL.md` con la advertencia de limitación del test numérico y la regla de correr `--detalle` siempre.
