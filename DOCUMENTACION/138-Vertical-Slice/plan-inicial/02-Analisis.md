**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 138: Vertical Slice

## 1. Análisis del Dominio

### 1.1 ¿Qué valida un Vertical Slice?

| Pregunta | Cómo la responde el slice |
|---|---|
| ¿El loop completo funciona junto? | Se juega de punta a punta: explorar→extraer→hablar→resolver→recompensa |
| ¿La producción es viable? | Se produce una zona real con pipeline estándar (M108) |
| ¿El feel es correcto? | Cámara, animaciones, VFX, sonido, timing (playtest M114) |
| ¿El árte/audio alcanzan calidad? | Se muestra a otros: publishers, amigos (feedback externo) |
| ¿La visión resiste la prueba? | El slice se compara contra el contrato O1-O19 (M153) |
| ¿El rendimiento aguanta? | Medición FPS real en el slice (M61) |

### 1.2 Diferencias con el Prototipo (M137)

| Aspecto | Prototipo (M137) | Vertical Slice (M138) |
|---|---|---|
| Meta | Validar el núcleo | Validar la producción completa |
| Arte | Placeholders | Estándar mínimo (M46/M47/M108) |
| Audio | Nada o mínimo | Música + SFX + ambiente (M41-M44) |
| UI | Depuración | Funcional (M53) |
| Alcance | 15 min | 20-30 min de principio a fin |
| Rendimiento | FPS bruto | Frame budget por categoría (M61) |
| Mostrable | No | Sí (demo) |

### 1.3 Riesgos del Vertical Slice

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Choclos de integración | Los sistemas "funcionan solos pero no juntos" | Slice obliga a integrar en cascada desde la zona |
| Scope creep ("agreguemos otra cosa") | Nunca termina | Congelación de alcance: lista RF1-RF17 cerrada |
| Calidad desigual | Una parte pulida y el resto feo | Criterio "cada sistema del slice cumple su módulo mínimo" |
| Pengantedeudas técnicas | Se arrastran al resto | Deuda listada en RETROSPECTIVA, no silenciada |
| Tiempo | Se excede de 10 semanas | Semanal: si un sistema no entra, se corta (enmarcable) |

### 1.4 Referencias de otras vertaslices

| Referencia | Lección |
|---|---|
| Stardew Valley teaser | Un pueblo + 1 temporada + 1 misión basta para vender el sueño |
| Unpacking | Muestran la mecánica central con lore mínimo |
| A Short Hike demo | Mundo chico + libertad + belleza = demo memorable |
| Zelda BOTW presentation | El "campo abierto" se muestra con UNA meseta (la semilla del slice) |

## 2. Alternativas Consideradas

### 2.1 Zona: esquina de Aurora vs. isla aparte
Se elige una **esquina de Aurora** (el hub): reutilizable en el juego final, escala natural y cumple la promesa de "hogar". Una isla aparte (ej. Coral) duplicaría assets sin aportar al núcleo.

### 2.2 NPC: nuevo vs. uno del canon (Finneas)
Se elige un NPC del canon existente — **Finneas** (guía, capa 1 del canon, M147) — para validar el consumo de `world_data.json` (M147/M21) desde el primer contenido jugable.

### 2.3 Puzzle: ruina vs. templo
Se elige **ruina pequeña** (M25): bajo costo, alta reutilización y encaja en la zona sin spoilear templos (M26 llega en Pre-Alpha). El Templo Subterráneo (M26) queda para fases posteriores.

### 2.4 Guardado: automático al dormir vs. manual
Se elige **guardado automático al dormir** (M18/M59): valida el hábito comfortable "dormir al final del día" del juego final, sin UI extra de guardado manual (M53 lo difiere).

### 2.5 Tutorial: texto vs. guiado visual
Se elige **guiado visual** (M92): flechas, resaltado y rumores del NPC; sin texto instructivo. El slice también valida si la curva de aprendizaje funciona sin palabras.

## 3. Decisiones Tomadas

1. **Esquina de Aurora** como zona del slice; Finneas como NPC (valida canon M147).
2. **Ruina con puzzle** (M25/M24), no templo (M26/26 se reserva).
3. **Guardado automático al dormir** (M18/M59) + autosave en hitos.
4. **Tutorial visual sin texto** (M92).
5. **Frame budget M61** aplicado desde el primer día del slice (no al final).
6. **Congelación de alcance:** RF1-RF17 cerrado; todo lo nuevo entra en `docs/vslice/IDEAS-DESCARTADAS.md`.
7. **Demo compartible:** el slice se sube como demo interna (Steam/itch) para feedback externo.
8. **Criterio de escalado a Pre-Alpha (M139):** slice completo + 90% de aceptación en encuesta + FPS OK + deuda documentada.
9. **Presupuesto de riesgo de producción:** si el slice excede 10 semanas, se cortan VFX (M52) y ambiente (M42) y se evalúa el pipeline (M108) antes que recortar mecánicas.
10. **Música co-escrita con el lore:** el tema de Aurora se compone sobre el sonido ambiental del slice (M41/M42).

## 4. Integración con Otros Módulos

| Módulo | Qué consume del Slice | Qué aporta al Slice |
|---|---|---|
| M137 Prototipo | Sistemas validados | Base del código |
| M19/M64 NPC | Necesidades de IA simple | Finneas con rutina |
| M21 Diálogos | Texto del canon (M147) | Líneas de Finneas |
| M41-M44 | Brief de audio | Música, SFX, ambiente |
| M53 UI | Pantallas | Inventario, diálogo, pausa |
| M59/M60 | Hitos de guardado | Autosave y serialización |
| M48/M52 | Necesidades de animación/VFX | Animación y efectos |
| M61 | Frame budget | Reporte FPS |
| M114 | Encuesta | Feedback del slice |
| M92 | Guiado | Tutorial visual |
| M139 (siguiente) | — | Decide qué escalar a Pre-Alpha |

## 5. Edge Cases Identificados

1. **Tester nuevo que nunca jugó voxel** — el guiado visual (M92) debe funcionar; si no, se ajusta antes de escalar.
2. **Save con el mundo del slice medio modificado** — el save guarda el slice completo (no delta del prototipo) ya que la zona es fija.
3. **Dormir con el puzzle sin resolver** — el guardado conserva el estado del puzzle (flag).
4. **FPS < 60 en el punto denso (bosque + lluvia + NPC)** — el reporte indica qué sistema roba del budget (M61) y se corrige antes de escalar.
5. **Finneas repite líneas tras repetir el slice** — su diálogo respeta flags de progreso (M21), evitando loop de exposición.
6. **Recompensa que rompe la economía de prueba** — la recompensa sigue el margen M93 (5-15% del siguiente desbloqueo).