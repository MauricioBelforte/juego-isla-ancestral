# Estado del proyecto y trabajo pendiente

## 1. Qué existe hoy

Todo lo entregado son **generadores reproducibles**, no assets aprobados. No he ejecutado Blender ni visto una sola captura.

| Entregable | Estado |
|---|---|
| Fauna procedural (nutria, elefante, jirafa, oso, pulpo, pez) | Scripts completos |
| NPC base — Luna (receta de referencia) | Script completo |
| Catálogo 35 NPCs ALTA | Script por lotes |
| LOD MEDIA / BAJA + validación | Script por lotes |
| Revisión artística 02 — Isla Raíz | Script por lotes |
| Revisión artística 02 — Ceniza / Coral / Aurora | Script por lotes (con deuda) |
| Rig deformable + IDLE / CAMINAR / SALUDO | Script por lotes |
| Godot: `NPCVisualLOD` + `NPCAnimado` | Scripts listos |

---

## 2. Deuda técnica conocida (arreglar antes de escalar)

| # | Problema | Dónde | Impacto |
|---|---|---|---|
| 1 | `color_attributes.new()` con args posicionales | `revision_artistica_restantes.py` | Falla en ejecución |
| 2 | Bloque de búsqueda de NPCs duplicado y confuso | `rig_base_npcs.py` | Puede saltarse NPCs |
| 3 | Accesorios de ambos brazos añadidos a `ARM_L` | Revisión 02 restantes | Adorno en brazo equivocado |
| 4 | Coordenadas relativas usadas como absolutas (telescopio, báculo, farol) | Revisión 02 restantes | Geometría flotante |
| 5 | Accesorios duplicados respecto al ALTA (collares, linternas) | Revisión 02 restantes | Doble geometría |
| 6 | LODs generados **antes** de la revisión 02 | `LODS/` existentes | Desincronizados |

---

## 3. Lo que falta, por bloques

### A. Validación (bloqueante — nada avanza sin esto)

- [ ] Ejecutar el catálogo ALTA y revisar los 35 informes JSON
- [ ] Revisar 6 capturas orbitales por NPC
- [ ] Detectar intersecciones, agarres flotantes, siluetas ilegibles
- [ ] Aprobar o corregir **Isla Raíz** antes de tocar el resto
- [ ] Importar 1 NPC en Godot 4.7.2 y confirmar: escala 1.8 m, pies en Y=0, mira a −Z, `COLOR_0` como albedo

### B. Corrección de la revisión artística

- [ ] Aplicar los 4 arreglos de código (ítems 1, 3, 4, 5)
- [ ] Re-ejecutar revisión 02 en Ceniza / Coral / Aurora
- [ ] Regenerar LODs **desde** `REVISION_02/`

### C. Rig y animación

- [ ] Probar rig deformable en 3 NPCs (Luna, Roca, Hielo)
- [ ] Verificar codos/rodillas sin colapso
- [ ] Confirmar que las herramientas siguen a la mano
- [ ] Añadir huesos de falda/túnica (12 NPCs afectados)
- [ ] Adaptar SALUDO a manos ocupadas
- [ ] Decidir si MEDIA se riggea (multitudes lejanas)

### D. Godot — integración real

- [ ] Escena `NPC_BASE.tscn` reutilizable
- [ ] `CharacterBody3D` + `CollisionShape3D` + `NavigationAgent3D`
- [ ] Máquina de estados: Idle → Caminar → Hablar
- [ ] Conectar CAMINAR a velocidad real (sin root motion)
- [ ] Sistema de spawn por isla
- [ ] Área de interacción / diálogo

### E. Fauna

- [ ] Ejecutar y validar las 6 especies
- [ ] Generar sus variantes MEDIA / BAJA
- [ ] Rig de fauna (cola, cabeza, patas)
- [ ] Comportamiento en Godot (deambular, huir, curiosidad)

### F. Pulido final

- [ ] Bordados y microaccesorios restantes
- [ ] Coherencia de paleta entre las 4 islas juntas
- [ ] Colores oficiales HR-01…08 y EY-01…05 (**me faltan los hex de M161**)
- [ ] Presupuesto total en escena con 12 NPCs visibles

---

## 4. Ruta crítica sugerida

```
1. Ejecutar ALTA (35)          → revisar JSON + capturas
2. Arreglar revisión 02        → re-ejecutar Ceniza/Coral/Aurora
3. Regenerar LODs              → desde REVISION_02
4. Rig en 3 NPCs               → validar deformación
5. Escena NPC_BASE en Godot    → probar 1 NPC completo
6. Extender a los 35
7. Fauna
8. Pulido
```

---

## 5. Qué puedo darte en el siguiente mensaje

Elige una:

| Opción | Entrega |
|---|---|
| **A** | Parche corregido de `revision_artistica_restantes.py` (los 4 bugs) |
| **B** | `NPC_BASE.tscn` + `CharacterBody3D` + máquina de estados + navegación |
| **C** | Huesos de falda/túnica y SALUDO adaptado a manos ocupadas |
| **D** | Rig + LOD para las 6 especies de fauna |
| **E** | Script de contacto sheet: 1 PNG por isla con los 12 NPCs juntos (revisión visual rápida) |

**Mi recomendación: E → A → B.** El contact sheet te deja aprobar las siluetas de golpe en lugar de abrir 210 capturas una a una.

**Un dato que necesito de ti:** los hex oficiales de cabello (HR-01…08) y ojos (EY-01…05) de M161. Los actuales son propuestas mías y afectan a los 35 personajes.