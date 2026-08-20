**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 94: Retención sin FOMO

## 1. Arquitectura general
```
[MotivacionManager (nuevo)]
   ├── TableroObjetivos        (diario/semanal/mensual; rotatorios; sobremesa M55)
   ├── MotorEventosVariantes   (reutiliza M74; 3+ variantes por festividad)
   ├── RecompensaAcumulada     (sin expiración; cola en diario)
   ├── AntiFomoAuditor         (scan de mecánicas prohibidas en CI)
   └── PostgameOrquestador     (3 bloques tras epílogo M22)

[Clavijas existentes]  M29 (reloj de sesión) · M55 (diario) · M74 (eventos)
                        M71 (progresión) · M20 (relaciones) · M73 (colecciones)
```

## 2. Reglas de diseño (inmutables)
| Regla | Detalle |
|-------|---------|
| R1 | 0 streaks: ninguna recompensa depende de sesiones consecutivas |
| R2 | 0 expiración: ninguna recompensa/cosmético pierde validez por fecha |
| R3 | 0 penalización de ausencia: el mundo no avanza cuando no se juega (M29) |
| R4 | 0 contenido exclusivo temporal: los ítems de evento son del catálogo general |
| R5 | El tiempo real nunca produce pérdida; solo acumula pendientes |

## 3. Tablero de objetivos (RF1/RF9)
- **Diarios (2 rotatorios)**: ej. "pesca 3 especies de la marea", "entrega un regalo". Recompensa moderada (oro + puntos amistad). Al vencer -> sobremesa.
- **Semanales (2 rotatorios)**: ej. "colecta 10 fósiles", "completa 5 encargos". Recompensa mayor (ítem + boost).
- **Mensuales (1-2 rotatorios)**: ej. "coleccioná 3 artefactos de la isla X", "cosechá 50 frutos de invierno". Recompensa de colección (M73).
- **Sobremesa (M55)**: lo vencido sin cobrar se lista; límite 50; el excedente se liquida en oro al cobrar (sin pérdida de valor).

## 4. Motor de eventos repetibles (RF4)
- Cada festividad (M74) tiene **3+ variantes** (decorado, encargos, minijuegos menores, diálogos).
- Al completar la festividad, se desbloquea la siguiente variante; al completar todas, se repite en ciclo con la variante menos vista.
- Recompensa por participación **acumulada** (cada participaciones suma un "sello de fiesta" coleccionable, M73).
- El calendario se rige por **días de juego** (M29): volver tras 2 semanas reales no pierde la festividad; solo se reanuda el ciclo del mundo.

## 5. Descubrimientos inesperados (RF5/M148)
- Eventos aleatorios del mundo (cometas, mareas rojas, aves migratorias) con ventana de 1-2 días de J UEGO (no de calendario real).
- Se anuncian en el diario con anticipación; al no participar no hay pérdida: el siguiente ciclo lo repite.
- Los misterios (M22/M148) no tienen prisa: quedan abiertos hasta que el jugador los persiga.

## 6. Metas de largo plazo (RF1-RF8)
| Meta | Sistema | Sin FOMO: |
|------|---------|-----------|
| 6 Sellos + Acto 3 | M22 | Avanzan a ritmo propio |
| Museo 100% | M37/M73 | Sin fecha límite |
| Ciudad/islas construidas | M17/M68 | Proyectos persisten |
| Amistad max con 30 NPC | M20 | No decae con la ausencia |
| Misterios completos | M148/M22 | Sin prisa |
| Postgame (3 bloques) | M94 | Se desbloquea tras epílogo |

## 7. Postgame (RF8)
Bloques tras el epílogo del faro (M22):
1. **Desafíos de la Isla**: cartel de retos (pesca legendaria, minero maestro, chef estelar) con recompensas de colección.
2. **Misterio Final**: arco de 3-5 h que cierra el hilo de Elysia y añade una décima ruina (M148).
3. **Proyecto Isla Perfecta**: ciudadela personalizable con objetivo de "población máxima" (M65/M68).

## 8. Persistencia (M59)
- Save v3.x: `objetivos: {diarios: [], semanales: [], mensuales: [], sobremesa: []}`, `evento: {varianteActual, participaciones}`.
- Sin dependencia de horas reales: todos los ciclos se calculan con `diaDeJuego` (M29).
- Migración v3.2 para saves previos (campo nuevo con valores por defecto).

## 9. Qué NO se hace
- No streaks, no content exclusivo temporal, no pérdida por ausencia.
- No UI de "¡Vuelve pronto!" con penalización; el tablero es motivador, no amenazante.
- No recompensas que dupliquen el catálogo general (todo es del inventario/colección M16/M73).