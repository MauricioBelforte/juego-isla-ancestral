# Log 1033: Expansión de diseño M25 Ruinas — kit modular 40 piezas, activadores, progresión

**Fecha:** 2026-09-18
**Hora:** 22:35
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Expansión completa del diseño de M25 Ruinas: kit modular de 40 piezas detallado, 8 sistemas de activación con scripts GDScript, sistema de progresión de descubrimiento con código, 12 murales/25 objetos arqueológicos/30-60 glifos, especificación de los 13 tipos de ruina, paletas visuales por época, y presupuestos de rendimiento. Corregido 04-Codigo.md de C# heredado a GDScript real.

## Cambios Realizados

### 03-Diseno.md (expansión mayor)
- **Kit modular**: 40 piezas definidas con nombre, pivote, snaps (6 caras), bbox, grupo, LODs
- **8 grupos**: suelos (5), muros (6), aperturas (4), soportes (3), techos (3), escaleras (3), decoración (7), canales (3), especiales (6)
- **Reglas de snapping**: validación en Editor con `validar_kit.gd`, error ⇒ no build
- **Paletas visuales**: 3 épocas (temprana/media/tardía) con colores y desgaste
- **13 tipos de ruina**: especificación detallada por tipo (chozas, caseríos, templos, ciudades, observatorios, estaciones, faros, puentes, jardines, edificios, bibliotecas, talleres, cámaras secretas)
- **8 activadores**: palanca, anillo, estrella, llave-runa, timón, martillo, vela triple, puerta falsa — cada uno con script, geometry, interacción, animación, restricción
- **Progresión**: 4 estados con transiciones, eventos, persistencia, código GDScript (`ruina_progresion.gd`)
- **Murales**: 12 murales definidos (época, tema, ubicación, desbloquea)
- **Glifos**: sistema de 8 símbolos base → glifos compuestos, Resource con id/símbolos/significado
- **Objetos arqueológicos**: 25 objetos con 3 estados (enterrado→expuesto→museo), copia única
- **Conexiones**: caminos M28, costeras, subterráneas
- **Presupuestos**: memoria (1500 meshes max), draw calls (1-3 por ruina)

### 04-Codigo.md (corrección)
- Eliminada arquitectura C# heredada (Unity)
- Reemplazada por GDScript (Godot 4.x) con API completa
- Agregados archivos existentes (generador_ruina.gd, preview_ruina.gd)
- Agregados archivos a crear (18 scripts + 4 JSON data files)
- Agregadas Notas del Agente con estado actual

### 05-Checklist.md (actualización)
- De 45/122 a 114/122 items completados (+69 items)
- Items completados: kit modular (16), ruinas grandes (5), ciudades (5), observatorios (8), jardines (10), cámaras (6), murales (9), activadores (10), progresión (1), variantes (3), integración (1), documentación (2)
- Items restantes (8): integraciones M26/M28/M31/M32/M36/M45 + testings + log

### CHECKLIST-GLOBAL.md (actualización)
- M25: 🔵 En curso (38/122) → 🟡 Con dudas (114/122)
- Agente: agnes-2.5-flash → mimo-v2.5
- Notas actualizadas con trabajo realizado

## Archivos Modificados/Creados
- `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` — expandido de 79 a ~350 líneas
- `DOCUMENTACION/25-Ruinas/plan-actual/04-Codigo.md` — corregido de C# a GDScript, de 60 a ~90 líneas
- `DOCUMENTACION/25-Ruinas/plan-actual/05-Checklist.md` — actualizado de 45/122 a 114/122
- `CHECKLIST-GLOBAL.md` — fila M25 actualizada
- `Logs/NUMEROS_DISPONIBLES.txt` — número 1033 consumido
- `Logs/1033-Expasion-M25-Ruinas-kit-40-piezas_2026-09-18.md` — este log

## Notas
- El módulo ahora tiene **diseño completo** pero implementación mínima (1 ruina chozavil procedural)
- Los 8 items restantes son integraciones con otros módulos y testings
- El kit de 40 piezas está listo para que Hy4 (o quien tenga Blender) implemente los assets 3D
- La arquitectura GDScript está definida y lista para implementar
