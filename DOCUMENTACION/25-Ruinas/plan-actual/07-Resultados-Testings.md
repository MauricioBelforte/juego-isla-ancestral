# 07 — Resultados de Testings — M25: Ruinas (plantilla, hy3 / WorkBuddy, 2026-09-19)

**Uso:** completar al ejecutar `06-Plan-Testings.md` en la fase de implementación.
Una fila por script headless. Regla anti-falso-verde: registrar `EXIT` real y
conteo de `SCRIPT ERROR`; "0 fallos" sin `EXIT 0` + 0 `SCRIPT ERROR` = NO pasada.

## Resumen

| Fecha | Binario | Scripts | EXIT total | SCRIPT ERROR | Checks | Fallos | Veredicto |
|-------|---------|---------|-----------|--------------|--------|--------|-----------|
| — | Godot 4.7.2.stable | — | — | — | — | — | PENDIENTE |

## Detalle por categoría

### 1. Validación del kit (V1–V5)
| ID | Caso | Script | EXIT | SCRIPT ERROR | Resultado |
|----|------|--------|------|--------------|-----------|
| V1 | Pivote esquina inf-izq | — | — | — | — |
| V2 | 6 snaps/cara compatibles | — | — | — | — |
| V3 | Traslape → build fail | — | — | — | — |
| V4 | Fail si validación falla | — | — | — | — |
| V5 | 8 grupos vs catálogo | — | — | — | — |

### 2. Armado de 13 tipos (T1–T13)
| ID | Tipo | Ensambla sin traslape | Activadores M24 OK | Resultado |
|----|------|----------------------|---------------------|-----------|
| T1 | Choza/ermita | — | — | — |
| T2 | Caserío | — | — | — |
| T3 | Atalaya | — | — | — |
| T4 | Templo (cruz) | — | — | — |
| T5 | Fortín mediano | — | — | — |
| T6 | Templo/fortín grande | — | — | — |
| T7 | Ciudad antigua | — | — | — |
| T8 | Observatorio | — | — | — |
| T9 | Estación (M66) | — | — | — |
| T10 | Faro (M24) | — | — | — |
| T11 | Puente arco | — | — | — |
| T12 | Puente colgante | — | — | — |
| T13 | Jardín terrazas | — | — | — |

### 3. Progresión (P1–P7)
| ID | Caso | EXIT | SCRIPT ERROR | Resultado |
|----|------|------|--------------|-----------|
| P1 | Detección 15 m | — | — | — |
| P2 | Hint horizonte (M63) | — | — | — |
| P3 | Explorada al 50% | — | — | — |
| P4 | Completada (relicto) | — | — | — |
| P5 | Eventos (diario/M58/M36) | — | — | — |
| P6 | Guardado atómico | — | — | — |
| P7 | Persistencia por ruina | — | — | — |

### 4. Rendimiento LOD (R1–R4)
| ID | Caso | Draw calls LOD0 | LOD2 vs LOD0 | Resultado |
|----|------|-----------------|--------------|-----------|
| R1 | Ruina 60 piezas ≤ budget M166 | — | — | — |
| R2 | Reducción ≥40% LOD1/2 | — | — | — |
| R3 | Culling región (M63) | — | — | — |
| R4 | Sin Update/simulación | — | — | — |

## Criterio de éxito
Suite completa `EXIT 0` + 0 `SCRIPT ERROR` + 0 fallos en todas las filas → ✅.
