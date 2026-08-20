**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 94: Retención sin FOMO

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/Gameplay/Motivacion/MotivacionManager.cs` | Manager | Tablero de objetivos + sobremesa + postgame |
| `Assets/_Project/Scripts/Gameplay/Motivacion/ObjetivoDiario.cs` | SO | Definición de objetivo (plazo, condición, recompensa) |
| `Assets/_Project/Scripts/Gameplay/Motivacion/ObjetivoActivo.cs` | Modelo | Estado vivo de un objetivo (progreso, cobrado) |
| `Assets/_Project/Scripts/Gameplay/Motivacion/MotorEventosVariantes.cs` | Motor | Variantes de festividades (M74 extendido) |
| `Assets/_Project/Scripts/Gameplay/Motivacion/RecompensaAcumulada.cs` | Motor | Cola de recompensas sin expiración |
| `Assets/_Project/Scripts/Gameplay/Motivacion/PostgameManager.cs` | Postgame | 3 bloques: desafíos, misterio final, isla perfecta |
| `Assets/Editor/Motivacion/AntiFomoAuditor.cs` | Editor/CI | Scan de mecánicas prohibidas |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `DiarioManager.cs` (M55) | Sección "Objetivos" + "Sobremesa" |
| `CalendarioManager.cs` (M74) | Hook de variante activa (M29) |
| `RelojDeJuego.cs` (M29) | Día de juego como única fuente tempor la |
| `SaveManager.cs` (M59) | Campo motivación v3.2 + migración |
| `HistoriaManager.cs` (M22) | Desbloqueo de postgame tras epílogo |

## 2. Funciones clave
```csharp
// MotivacionManager
public List<ObjetivoActivo> ObjetivosPorPlazo(Plazo p);   // día/semana/mes
public void Cobrar(objetivoId);                            // → RecompensaAcumulada
public void RotarObjetivos();                              // al empezar día/semana/mes de juego

// RecompensaAcumulada
public void Agregar(objetivoId, recompensa);               // sin expiración
public void CobrarPendientes();                            // diario sobremesa (límite 50)

// MotorEventosVariantes
public Variante SiguienteVariante(festividadId);           // 3+ ciclo
public int Participaciones(festividadId);                  // sello de fiesta M73

// AntiFomoAuditor (Editor)
public Reporte ScanMecanicas()   // detecta streak/expiración/penalización
// CI: falla si hay alguna de las 5 reglas violadas

// PostgameManager
public void Desbloquear();                                 // tras epílogo
public bool DesafiosActivos();  public bool IslaPerfecta();
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Objetivos | SO por objetivo (plazo, condición, recompensa) | ObjetivoDiario |
| Variantes por festividad | SO (3+) | MotorEventosVariantes |
| Recompensas pendientes | save v3.2 + diario | RecompensaAcumulada |
| Retos postgame | SO | PostgameManager |
| Reglas anti-FOMO | Config del auditor | AntiFomoAuditor |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `AntiFomoAuditTests` | EditMode | Scan detecta streak/expiración/penalización agregados a propósito |
| `ObjetivosTests` | PlayMode | Rotación diaria/semanal/mensual; 2 simultáneos; sobremesa tras vencer |
| `AusenciaTests` | PlayMode | 7 días de no-juego simulados → 0 pérdida (cultivos vivos, amistad intacta) |
| `EventosVariantesTests` | PlayMode | 3+ variantes en ciclo; particições acumuladas |
| `RecompensaAcumuladaTests` | PlayMode | 50 pendientes límite; excedente liquidado en oro |
| `PostgameTests` | PlayMode | Desbloqueo tras epílogo; 3 bloques operativos |
| `MigracionMotivacionTests` | PlayMode | Save v3.1 → v3.2 sin pérdida |

## 5. CI/CD
- Job **AntiFomoGate**: corre en cada build; falla si el videojuego tiene mecánicas prohibidas (R1-R5).
- Job **ObjetivosGate**: verifica que haya 2 objetivos por plazo en cada estación.

## 6. Notas de integración
- El reloj (M29) define TODO: ningún script usa DateTime.Now para gameplay (solo UI informativa).
- El diario (M55) muestra el tablero de objetivos y la sobremesa (listo para cobrar).
- Los eventos repiten con variantes; el sello de fiesta es colección de M73 (siempre completable).
- El postgame se guarda en el mismo save v3.2 (sin segundo archivo).
- Compatibilidad con M74 (eventos) y M22 (historia): solo se agregan hooks no destructivos.