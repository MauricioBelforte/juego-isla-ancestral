**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 143: Lanzamiento

## 1. Arquitectura general
El lanzamiento **no toca el juego**: opera sobre el **entorno de publicación y operación** que rodea a la build:

```
[Build RC final (M142)] ──▶ [Plataformas: Página, Build, Tráiler, Comunicado]
                                    │
        [Operación T0-T72] ◀────────┤
        ├── Dashboards (crashes M105, reviews M106, backend M104, ventas M149)
        ├── Guardias por turnos (roles del runbook M142)
        ├── Triaje de bugs (M101) → cola hotfix 2.0.x
        └── Comunidad (soporte M152 + redes M149)
                                    │
        [Cierre T72-T96] ◀──────────┘
        ├── Informe 72 h (4 ejes) → M144
        ├── Agradecimiento público
        └── Preservación de builds (manifiestos M142)
```

## 2. Flujos principales

### 2.1 Publicación día 0 (T0)
Orden fijo del runbook M142, con verificación a cada paso:
1. **Página** visible (store) — verificar "disponible" en cada plataforma.
2. **Build** liberada — verificar hash igual al `rc-final` + manifest.
3. **Tráiler** publicado en canales oficiales.
4. **Comunicado** (prensa + comunidad) multi-idioma.
- Registro de horas por paso; si una plataforma falla → **detener el resto** (runbook de incidentes).

### 2.2 Monitorización (T0-T72)
- **Crashes**: dashboard M105 con alerta automática al cruzar 0.5%; stacktraces agrupados por zona.
- **Reviews**: ingesta de reviews de todas las plataformas (M106); triaje diario: positivas (respuesta en 48 h), negativas (respuesta en 24 h), urgentes (P0/P1 → comité).
- **Servidores/backend**: latencia, errores 4xx/5xx, disponibilidad; objetivo 99.9%.
- **Compras** (si aplica): transacciones, reembolsos, errores de pago.
- **Saves**: errores de guardado/cloud en sesiones reales; correlación con versiones.
- Guardias por turnos: roles definidos (comunidad, técnico, comercial) en el runbook M142.

### 2.3 Triaje de bugs (T0-T72)
```
Reporte (telemetría/review/soporte) → ticket M101 con buildId
   └─ severidad P0/P1 → comité de release → hotfix 2.0.x
   └─ severidad P2 → cola de actualización (M144)
```
- 100% de reportes con respuesta < 24 h; urgentes < 12 h.

### 2.4 Cierre (T72-T96)
- **Informe 72 h** con 4 ejes de métricas (estabilidad, comunidad, adopción, ventas) → aprobado por el equipo → entregado a M144.
- **Agradecimiento**: post multi-idioma con firmas y fecha; enlace a canales.
- **Preservación de builds**: RC final + hotfixes archivados con manifiestos (M142) en un bucket/carpeta de backups con accesos documentados.

## 3. Estados y decisiones de escalado
| Evento | Umbral | Acción |
|--------|--------|--------|
| Crash rate real | ≥ 0.5% | Alerta + comité en < 4 h + hotfix candidato |
| P0 (bloqueo de juego) en reviews | ≥ 3 reportes únicos | Ticket P0 inmediato + respuesta pública |
| Backend caído | > 15 min | Escalado técnico + comunicación de estado |
| Errores de pago | ≥ 1% de transacciones | Detener promociones + verificación de pasarela |
| Save perdido en cloud | ≥ 5 reportes | Ticket P1 + revisión de S3/servidor + hotfix |

## 4. Organización de guardias (runbook M142)
| Turno | Responsable | Foco |
|-------|-------------|------|
| T0-T24 | Todo el equipo | Publicación + primeros incidentes |
| T24-T48 | Equipo core | Bugs críticos + hotfix |
| T48-T72 | Equipo reducido | Comunidad + estabilidad |
| T72-T96 | Equipo core | Informe + cierre de fase |

## 5. Qué NO se hace en Lanzamiento
- No se modifica la build publicada (solo hotfix aprobado).
- No se promete contenido futuro sin fecha (M144).
- No se revelan datos internos de métricas a la comunidad.
- No se responde a trolls: solo se da respuesta oficial a quejas legítimas.