# Log 971: M09 — cierre de sesión: sistema de horizonte definitivo
> **Recuperado 2026-09-17** (ver `Logs/974-...md`, trampa 67).
> Este log vivía sólo en la cuarentena del dedup del 2026-09-16. Se renumeró de
> **Log 806** a **Log 971** porque el 806 quedó ocupado por OTRO log distinto.
> Mapa completo: `PAPELERA/logs-recuperados-2026-09-16/MAPA-RENUMERACION.md`.

**Fecha:** 2026-09-08
**Hora:** 01:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Cierre de la sesión completa de impostores (Logs 758-795). El sistema final aprobado por el usuario:

## La solución definitiva (por qué el plano verde plano no funcionaba)

**El usuario lo diagnosticó correctamente**: "un plano horizontal visto de canto desde lejos es una línea invisible por perspectiva — física pura". El disco/aro/plano verde a nivel del suelo NUNCA se vería de lejos mirando horizontal.

**La solución**: impostor HEIGHTMAP de toda la isla con relieve vertical:
- Grilla de 64m sobre toda la isla (r 2700), celdas de tierra h>=4.
- Cada celda un PRISMA (top + 4 paredes dobles) hasta h×0.85 — visible de cualquier ángulo.
- Colores por bioma de altura (arena → césped → piedra → cima).
- Cimas EXAGERADAS ×4 en el impostor (MONT_EXAG=4.0) — montañas visibles de lejos; al acercarse el impostor se oculta y las reales toman el mando.
- 42 tiles de 640m, ocultos <400m del player (los chunks reales mandan cerca).
- Construcción incremental (6 filas/frame), sin Thread, sin shader discard.

## Verificado por el usuario
- ✅ Montañas impostoras grises en el lugar correcto ("ahora sí están en el lugar correcto")
- ✅ Paseo completo sin tildes ("ya no se traba ni se buguea")
- ✅ Zoom de cámara operativo

## Capa verde rechazada por el usuario
El disco verde plano a nivel del suelo: invisible de canto (línea). La iteración 782 con anillos también rechazada ("nube gris"). EL HORISONTE VERDE REAL solo se logra con relieve vertical (heightmap).

## Archivos Finales
- `terreno_horizonte.gd` (impostor heightmap completo, incremental)
- `main_island.gd` (generador único, VoxelViewer móvil, spawn seguro)
- `player.gd` (suelo fantasma tierra/agua)
- `world_manager.gd` (sin generador competidor)

## Confirmaciones del usuario
- ✅ "Las montañas impostoras están ubicadas en el lugar correcto"
- ✅ "Ya no se traba ni se buguea... paseo mucho tiempo sin tildarse"
- ✅ "El impostor de las montañas verticales lo veo"
