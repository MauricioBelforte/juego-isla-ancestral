**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 162: Diálogos Contextuales de NPCs

## 1. Análisis del Dominio

### 1.1 Problema Central
Los NPCs tienen personalidad (M19) y apariencia (M161), pero sus diálogos son estáticos. Cuando el jugador avanza en la historia principal (M22), los NPCs no reaccionan. El mundo se siente muerto y el jugador no percibe que sus acciones afectan al entorno.

### 1.2 Fuentes de Contexto
| Fuente | Módulo | Información que aporta |
|--------|--------|----------------------|
| Historia Principal | M22 | 7 capítulos, eventos clave, grafo de escenas |
| Sistema de Diálogos | M21 | Motor nodal, JSON, condiciones, variables de estado |
| NPC y Vecinos | M19 | 23 NPCs, personalidades, rutinas diarias |
| Diseño Visual NPCs | M161 | 23 NPCs con apariencia completa |
| Amistad | M20 | 3 niveles: desconocido, conocido, amigo |
| Tiempo | M29 | Estaciones, hora del día, festivales |
| Ubicaciones | M160 | 46 ubicaciones, LOC-ISLA-TIPO-NUMERO |

### 1.3 NPCs Documentados (23 total)

| Isla | NPCs | Cantidad |
|------|-------|----------|
| RIZ (Raíz) | Mayor, Carpintero, Vendedora, Viejo Sabio, Pescador, Agricultora, Niña, Animador | 8 |
| COR (Coral) | Herrero, Pescadora, Comerciante, Guardia, Niña de la Playa | 5 |
| CEN (Ceniza) | Herrero Avanzado, Minero, Cocinera, Bibliotecario, Guardia de la Mina | 5 |
| AUR (Aurora) | Encantador, Sanadora, Guardia Ancestral, Artista, Viajero Misterioso | 5 |

## 2. Análisis de Alternativas

### 2.1 Enfoque A: Diálogos estáticos por capítulo
- **Descripción:** Cada NPC tiene una lista plana de diálogos por capítulo
- **Ventajas:** Simple de implementar, fácil de balancear
- **Desventajas:** No permite combinaciones complejas (amistad + hora + estación)
- **Veredicto:** ✅ Elegido como base — suficiente para la mayoría de NPCs

### 2.2 Enfoque B: Árbol de decisiones completo
- **Descripción:** Árbol jerárquico con ramas por cada combinación de condiciones
- **Ventajas:** Máxima flexibilidad
- **Desventajas:** Complejidad exponencial (8 capítulos × 3 amistad × 4 estaciones × 3 horas = 288 nodos por NPC × 23 NPCs = 6,624 nodos)
- **Veredicto:** ❌ Rechazado — innecesariamente complejo para cozy game

### 2.3 Enfoque C: Sistema de prioridad con fallback
- **Descripción:** Cada diálogo tiene prioridad. El sistema elige el de mayor prioridad que cumpla condiciones
- **Ventajas:** Flexible, extensible, balanceado
- **Desventajas:** Requiere definir prioridades claras
- **Veredicto:** ✅ Complementario — se usa para resolver conflictos cuando múltiples diálogos son válidos

### 2.4 Decisión Final
**Enfoque A (base) + Enfoque C (complemento):**
- Base: diálogos por capítulo (lista plana por NPC)
- Complemento: sistema de prioridad para combinaciones amistad/estación/hora
- Esto cubre el 90% de los casos sin complejidad excesiva

## 3. Análisis de Integración

### 3.1 Con M21 (Sistema de Diálogos)
- M21 usa nodos JSON con condiciones
- M162 genera el contenido JSON que M21 consume
- Condiciones de M162 se mapean a variables de M21:
  - `game_progress.chapter` → capítulo actual
  - `friendship[npc_id]` → nivel de amistad
  - `world.season` → estación
  - `world.hour` → hora del día
  - `player.location` → ubicación actual

### 3.2 Con M22 (Historia Principal)
- Los diálogos reflejan eventos de cada capítulo
- NO revelan información que el jugador aún no ha descubierto
- Mantienen coherencia temporal (no hablar de algo del capítulo 5 estando en el capítulo 1)
- El Viajero Misterioso (NPC-AUR-005) tiene arco propio que complementa M22

### 3.3 Con M19 (NPC y Vecinos)
- Cada NPC de M162 tiene la misma personalidad definida en M19
- Los diálogos respetan el rol y profession de cada NPC
- Las rutinas diarias de M19 pueden afectar qué diálogos están disponibles (hora)

### 3.4 Con M20 (Amistad)
- 3 niveles de amistad afectan diálogos:
  - Desconocido (0-29): diálogos formales, informativos
  - Conocido (30-69): diálogos más personales, comparten secretos
  - Amigo (70-100): diálogos íntimos, revelan historias personales

### 3.5 Con M160 (Ubicaciones)
- Algunos diálogos dependen de la ubicación del jugador
- Ejemplo: el Pescador solo habla de pesca si está en LOC-RIZ-PUER-001

## 4. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Diálogos contradictorios con M22 | Media | Alto | Revisar cada capítulo contra M21 |
| Demasiados diálogos para balancear | Alta | Medio | Priorizar NPCs principales (8-10), resto simplificado |
| Inconsistencia entre islas | Media | Medio | Tabla resumen global (sección 6 de 03-Diseno) |
| Olvidar combinaciones amistad/hora | Baja | Bajo | Sistema de prioridad con fallback |

## 5. Recomendaciones

1. **Priorizar NPCs principales:** El Mayor, Viejo Sabio y Viajero Misterioso son narrativamente críticos — sus diálogos deben ser perfectos
2. **Simplificar NPCs decorativos:** La Niña del Pueblo y la Niña de la Playa pueden tener menos variantes
3. **Crear templates reutilizables:** Un template por tipo de NPC (líder, comerciante, artesano, misterioso, decorativo)
4. **Testing manual obligatorio:** Cada capítulo debe probarse con al menos 5 NPCs representativos
5. **Extensión futura:** El sistema permite agregar nuevos NPCs sin modificar la arquitectura
