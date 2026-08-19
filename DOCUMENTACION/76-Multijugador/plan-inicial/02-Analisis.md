**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 76: Multijugador

## 1. Análisis del Dominio

**La pregunta base:** ¿un cozy de vida isleña necesita multijugador para ser exitoso? Evidencia del género: Animal Crossing (online periódico, no esencial), Stardew Valley (coop como complemento opcional, jamás requerido), Cozy Grove (single-player puro). Conclusión de producto: **el multijugador es un potenciador, no un requisito.** El riesgo mayor no es "no tener MP": es arrastrar al proyecto a costes de infraestructura, moderación y soporte que un equipo de hobby/indie no está obligado a sostener.

**Los 25 puntos del plan maestro se agrupan en 5 temas:**

| Tema | Puntos | Naturaleza |
|---|---|---|
| Decisión de producto | 1-4 (¿habrá? ¿local? ¿online? ¿cantidad?) | Decisión de negocio |
| Arquitectura | 5-10 (anfitrión, servidor, sincronización, autoridad, persistencia, permisos) | Diseño técnico (M77) |
| Social | 11-15 (invitaciones, cuentas, identidad, chat, emotes) | UX y servicios |
| Cooperación | 16-20 (intercambio, construcción, puzzles, progreso compartido/individual) | Gameplay |
| Operación | 21-25 (seguridad, anti-griefing, moderación, costes) | Operación y coste |

## 2. Alternativas Consideradas

### 2.1 Forma del multijugador futuro
- **A1. Local cooperativo (couch) primero — 2 jugadores, mismo dispositivo.** **ELEGIDA:** cero costes de servidor, sin cuentas, sin moderación, la isla se comparte en pantalla dividida; respeta la regla cozy (progreso individual). Es la puerta de entrada natural del género.
- **A2. Online directo (P2P/dedicado):** exige M77 completo: cuentas, NAT traversal, anti-cheat, moderación, costes. Diferido — si el product upfront se amortiza, entonces se suma.
- **A3. "Visita de fantasmas" (jugadores asíncronos):** ángulos y mensajes entre islas sin presencia simultánea. Rechazada por ahora (M75 postgame ya cubre vida de la isla; esto añade valor solo con online).

### 2.2 Persistencia en MP
- **A1. Solo el host persiste la isla; el invitado persiste su avatar/progreso global.** **ELEGIDA:** elimina conflictos de escritura y duplicación de mundos (M59 no se toca).
- **A2. Isla compartida persistente:** cruza el anti-griefing y acopla saves. Rechazada.

### 2.3 Sincronización futura
- **A1. Host autoritativo (split-screen):** el host simula todo el mundo; el invitado envía inputs. **ELEGIDA para local:** simple, determinista, sin red.
- **A2. Snapshot + reconciliación (online):** documentado en M77 como extensión. Contrato aquí.

### 2.4 Costes de servidores (RF24)
- **A1. P2P sin servidores (v1 futura local): $0.**
- **A2. Online con servidor dedicado (si algún día):** estimación por jugador-concurrente — servidor 8 vCPU/16 GB ≈ $120-180/mes para ~200 jugadores simultáneos; + moderación (1 responsable a tiempo parcial) — el documento estima el presupuesto y lo marca como decisión de hit del roadmap.
- **ELEGIDO:** el contrato fija local ($0) y condiciona online a un hit de métricas (p. ej. >10k descargas) — ver 03-Diseno.

## 3. Decisiones Técnicas

1. **Single-player en v1 (decisión de producto):** el postgame (M75) y los eventos (M74) sostienen la vida de la isla sin red; el equipo evita costes recurrentes y soporte.
2. **Contrato MP futuro = local primero:** 2 jugadores, split-screen, host autoritativo, progreso individual, anti-griefing por diseño (permisos RF10).
3. **Online diferido con condiciones de hit:** métricas de descargas >10k antes de abrir M77-MP como proyecto.
4. **Cero acoplamiento (M15):** el single-player no referencia M76; el contrato vive en documentos + `validate_mp_contract.gd` (editor).
5. **Seguridad por diseño:** sin chat libre (frases rápidas + emotes); código de visita con expiración; invitado sin permisos destructivos.
6. **Economía protegida (M38):** el intercambio futuro jamás transfiere ítems de historia (M22/M23) ni colecciones de avance (M73) — solo decoración.
7. **Rendimiento (M61/M62):** split-screen local comparte el mundo simulado (un solo render de gameplay en dos viewports — GPU cost, cabeza: 2 viewports; el contrato exige probar frame budget 60 FPS antes de aprobar la feature).
8. **Persistencia (M59/M60):** los saves no cambian de formato: el invitado es un perfil local (M92) dentro del mismo slot de preferencias.
9. **Moderación:** si el futuro online habilita texto libre, se exige sistema de reporte (contrato) — el cozy NO tiene chat abierto por defecto.
10. **QA:** cualquier implementación futura corre el plan de testings (M14) con pruebas de red local simulada (M77).

## 4. Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Scope creep (MP en v1) | Media | Alto | Decisión documentada + argumentos de coste |
| Costes de servidores imprevistos | Alta (si online) | Medio | Online condicionado a hit de métricas |
| Griefing en visitas | Baja (sin MP v1) | Alto | Permisos por diseño (RF10/RF22) |
| Griefing futuro con items de historia | Baja | Alto | Intercambio restringido (M38 decorativo) |
| Rendimiento split-screen | Media | Medio | Frame budget 60 FPS antes de aprobar |
| Dependencias ocultas del núcleo | Media | Medio | Check automático: cero refs a M76 en código v1 |

## 5. Conclusiones del Análisis

- El multijugador se **difiere con contrato completo**, no se descarta ni se hace a medias.
- La **forma local (couch) es la única puerta sin coste de infraestructura** del género.
- El **contrato protege el núcleo**: progreso individual, permisos, anti-griefing y economía (M38).
- Los **25 puntos del plan maestro quedan definidos** en `01-Requerimientos.md` (tabla RF), cumpliendo el espíritu del checklist sin simular implementación.