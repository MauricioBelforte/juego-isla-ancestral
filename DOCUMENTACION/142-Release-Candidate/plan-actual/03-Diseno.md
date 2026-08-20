**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 142: Release Candidate

## 1. Arquitectura general
La arquitectura del juego **no cambia** en RC: se agrega la **capa de validación y congelación** alrededor de la build final:

```
[Build Beta estable (M141)]  ──freeze──▶  rc-1 (etiquetada)
        │
        ├── ReleaseGate (CI): checklist RC automático
        ├── CrashHandler256 (M105): telemetría de crashes con símbolos
        ├── VersionManifest: hash + buildId + fecha + plataforma
        ├── LegalChecklist / CertChecklist (M149): aprobaciones por plataforma
        ├── LaunchRunbook (M143): pasos del día 0
        └── SupportChannels (M152): FAQ, reportes, SLAs
```

## 2. Flujos principales

### 2.1 Freeze (G1)
```
ComitéRelease.Votar(hotfix)
   └─ aprobado → HotfixPipeline: branch \x27hotfix/rc-N\x27 → test regresión (M112) → build rc-N
   └─ rechazado → se documenta como P2 para la primera actualización
```
- `VersionManifest.json` (generado por CI): `{buildId, gitSha, hashContenido, plataforma, fecha}` — auditable y firmado.
- Cualquier diff sobre `beta-rc-candidate` debe estar autorizado en el comité (minutas).

### 2.2 Validación técnica (G2)
- `ReleaseGate` (CI) ejecuta en cada build RC:
  1. **InstallCleanTest**: instalación en OS limpio (VM) → juego arranca sin errores.
  2. **UpdateTest**: parche Beta→RC → saves intactos, versión correcta.
  3. **SaveCompatTest**: save de Beta v3.x → carga en RC → guarda → recarga.
  4. **CloudSyncTest**: 30 ciclos con latencia simulada; conflicto → último ganador + backup.
  5. **AchievementMatrix**: matriz hitos→logros; desbloqueo local sin red.
  6. **LangMatrix**: 6 idiomas × pantallas clave; claves sin huecos (M87).
  7. **PerfGate**: ruta fija 20 min en mínimo/recomendado (M61-M63).

### 2.3 Pilotaje (G4)
- Build `rc-2+` con telemetría completa (M104/M105) a 200+ invitados seleccionados → apuntan a 1000 sesiones.
- Panel de métricas: crash rate, FPS p99, tiempo medio de sesión, guardados cloud OK, logros desbloqueados.
- Umbral de cierre: crash rate < 0.5%; sin P0/P1 nuevos; saves sin pérdida reportada.

### 2.4 Validación de negocio (G3)
- `CertChecklist` por plataforma (M149): items de política (build, contenido, cloud, edad, regiones).
- `LegalChecklist`: términos, privacidad, atribuciones de assets, clasificación etaria (ESRB/PEGI) — firmado por responsable legal.
- `MarketingReady`: store publicada en la plataforma (visible en fecha), tráiler final, comunicado de prensa, kit de medios.
- `SupportReady`: canales abiertos, FAQ publicada, proceso de reportes (M152), SLA de respuesta definido.

### 2.5 Soporte (RF13)
- Canal de reportes versionado por build (M101 importa buildId).
- Triage de soporte: bugs → tracker; preguntas → FAQ; críticas → métricas de reviews (M106).
- Reporte semanal de soporte desde el arranque de piloto hasta día 30.

## 3. Estado del RC (builds etiquetadas)
| Build | Contenido | Estado |
|-------|-----------|--------|
| `beta-rc-candidate` | Build W6 de Beta | Congelada (referencia) |
| `release-candidate-1` | Beta + fixes de piloto inicial | Validación G2 |
| `release-candidate-N` | Hotfixes aprobados | Validación completa |
| `release-candidate-final` | Checklist RC 100% verde | Entrega a M143 |

## 4. Plan de gates (≤ 4 semanas)
| Gate | Semana | Criterio de salida |
|------|--------|--------------------|
| G1 Congelar | 1 | Freeze firmado; `rc-1` etiquetada; manifest OK |
| G2 Validar técnica | 1-2 | ReleaseGate verde en todas las plataformas |
| G3 Validar negocio | 2-3 | Certificación, legal, marketing y soporte firmados |
| G4 Pilotar | 3-4 | 1000 sesiones; crash < 0.5%; 0 P0/P1 nuevos |
| G5 Congelar final | 4 | `rc-final` + checklist 17 frentes verde; entrega a M143 |

## 5. Qué NO se hace en RC
- No features, no contenido, no balance (freeze total).
- No cambios de arquitectura; solo hotfixes aprobados.
- No actualizaciones de idiomas nuevas (fueron cerradas en Beta).
- No trabajo de diseño/arte excepto fixes de bugs visuales P1.