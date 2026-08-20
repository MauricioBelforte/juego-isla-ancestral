**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 138: Vertical Slice

## 1. Arquitectura del Slice

```
┌─────────────────────────────────────────────────────────────────┐
│ Escena: vslice_aurora.tscn (zona = esquina de Aurora)          │
│  ├── Zona (M10): costa + bosque + prado + ruina + casa         │
│  ├── Player (M11/M12/48): movimiento + animaciones             │
│  ├── Recurso y herramienta (M15/M13): madera + hacha con anim  │
│  ├── NPC Finneas (M19/M64/M21): rutina + diálogos              │
│  ├── Casa (M18): dormir/save + interior                        │
│  ├── Ruina + puzzle (M25/M24): recompensa                      │
│  ├── Audio (M41-M44): música + SFX + ambiente                  │
│  ├── VFX (M52): extracción, colocación, recompensa, dormir     │
│  └── Autosave (M59/M60): al dormir y en hitos                  │
├─────────────────────────────────────────────────────────────────┤
│ UI (M53): inventario, diálogo, prompt, pausa                   │
│ Tutorial (M92): guiado visual (flechas + resaltado)            │
│ Misión (M22/M23/M38): 3 pasos + recompensa                     │
├─────────────────────────────────────────────────────────────────┤
│ docs/vslice/                                                   │
│  ├── PLAYTEST.md          (5+ testers, encuesta)               │
│  ├── REPORTE-FPS.md       (M61 por categoría)                  │
│  ├── GONOGO-M139.md       (decisión de escalar)                │
│  └── IDEAS-DESCARTADAS.md (congelación de alcance)             │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Componentes

### 2.1 Zona (RF1)
- Geografía: playa curva + bosque de pinos + prado abierto; 3-5 puntos de interés (casa, ruina, muelle roto, arboleda, altar).
- Altura + iluminación (M49) dentro del budget de render (M61: 5.0ms).
- Vegetación (M50) con instanciado (`MultiMesh`), sin rebalsar draw calls.

### 2.2 Recursos y herramienta (RF3)
- Madera como recurso clave (árboles de la zona, 5 bloques de madera por árbol).
- Hacha: 15 usos, animación de swing (M48), SFX de impacto (M43) y VFX de virutas (M52).
- Modelo M13: durabilidad + mejora simple esbozada (mejora no entra al slice).

### 2.3 Finneas (RF2)
- Rutina de día simple en la zona (waypoints: muelle→faro→plaza→casa; M64 esbozado).
- 6+ líneas de diálogo con rama de LÍNEA 1 misión (búsqueda de la herramienta).
- Regalo de bienvenida conceptual (consistente con M20 futuro).
- Consume `world_data.json` (M147) para mostrar su nombre en el idioma correcto (M87).

### 2.4 Misión y recompensa (RF12)
```
Paso 1: Finneas pide madera (2)  → entregar
Paso 2: Finneas pide el hacha perdida en la ruina → resolver puzzle
Paso 3: Recompensa: 20 AO + semilla de jardín (M33 futuro)
```
Recompensa obedece M93 (margen 5-15%).

### 2.5 Ruina y puzzle (RF5)
- Ruina de 3 salas pequeñas; puzzle de palancas (2 palancas + alineación de símbolos, M24/M147 consulta símbolos del canon).
- Recompensa: el Hacha de Finneas (tool) + mensaje ominoso/cozy (M148/M150 futuro).

### 2.6 Casa y autosave (RF4/RF9)
- Casa: entrada + cama + mesa; dormir: fade a negro, pasa el día, autosave.
- Autosave también en hitos (entrega, puzzle resuelto, compra futura).
- Formato v2 (M60): full zone state, schema_version.

### 2.7 Audio (RF6/RF7)
- Música (M41): tema diurno/noche de Aurora (2 stems), transición suave al dormir.
- SFX (M43): extraer, colocar, swing, moneda, puerta, puzzle.
- Ambiente (M42): viento, mar, pájaros; mezcla con `AudioMixer` (M42).
- Feedback (M44): sprint text cues (música/tonos) para logros de acción.

### 2.8 Rendimiento (RF15)
- Profiler con el perfil M61: gameplay 2.5 / voxel 4.0 / IA 2.0 / partículas 1.0 / culling 0.5 / render 5.0 / UI 1.5 = 16.5ms.
- `VSYNC` off durante el muestreo (medición cruda); reporte en `REPORTE-FPS.md`.

## 3. Flujo de Juego (loop de 20-30 min)

```
Spawn en la playa de Aurora
 → Guiado visual (M92) resalta el faro y al NPC
 → Conocer a Finneas (diálogo + misión: hacha perdida en la ruina)
 → Extraer madera (siente voxel + SFX + VFX + animación)
 → Ir a la ruina (explorar: planta, mar, bosque)
 → Resolver el puzzle de palancas/símbolos → obtener el Hacha
 → Volver donde Finneas → entrega → recompensa (20 AO + semilla)
 → Plantar la semilla (micromomento de jardín)
 → Dormir en la casa → autosave → día 2 con cambio de música
 → Fin del slice (créditos de demo + encuesta)
```

## 4. Criterios de Escala a Pre-Alpha (M139)

| Criterio | Métrica | Escalar si |
|---|---|---|
| Experiencia completa | % testers que terminan el slice | ≥ 90% |
| Encuesta "es my game" | % que identifica Isla Ancestral | ≥ 90% |
| Diversión | Media encuesta | ≥ 7,5/10 |
| Rendimiento | FPS medio + máx frame (P99) | ≥ 60 / +40ms P99 |
| Guardado | Ciclos 10× | 0 pérdidas |
| Deuda técnica | Registrada y aceptada | Documentada |
| Alcance | Congelado | Sin creep |

## 5. Cierre del Slice

1. Tag git `vslice-v1`, demo empaquetada (M116/M117 aplicar build).
2. Playtest ampliado (5+ testers) + feedback externo (publishers).
3. GONOGO-M139.md firmado.
4. Retrospectiva: qué escalar, qué cortar, qué deuda queda.
5. Presupuesto ajustado con los datos reales del slice (M134).