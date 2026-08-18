**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 135: Riesgos del Proyecto

## 1. Arquitectura del registro

```
DOCUMENTACION/135-Riesgos-Del-Proyecto/
├── plan-inicial/                     ← Documentación original (inmutable)
├── plan-actual/                      ← Documentación vigente
│   ├── 01-Requerimientos.md
│   ├── 02-Analisis.md
│   ├── 03-Diseno.md
│   ├── 04-Codigo.md
│   ├── 05-Checklist.md
│   └── RISK-REGISTER.md              ← PENDIENTE DE IMPLEMENTACIÓN (registro vivo)
└── (opcional) GUIA-REVISION-TRIMESTRAL.md   ← PENDIENTE DE IMPLEMENTACIÓN
```

Características:
- **Registro único vivo:** `RISK-REGISTER.md` acumula todas las entradas de riesgo con su estado.
- **Guía opcional:** procedimiento de la revisión trimestral (también puede vivir en 04-Codigo.md).
- **Sin código de gameplay:** son documentos de gestión consumidos por el equipo y los agentes de IA.

## 2. Categorías de riesgos (6)

| Categoría | ID | Ejemplos del proyecto |
|---|---|---|
| Técnicos | TEC | Voxel Tools, generación procedural, streaming, IA generando código |
| Alcance | ALC | Scope creep, tamaño de la isla Aurora, hitos deslizantes |
| Equipo | EQU | Fundador único, unicidad de conocimiento, dependencias de herramientas |
| Financiamiento | FIN | Reservas, costos imprevistos, sustentabilidad mensual |
| Mercado | MER | Nicho cozy, plataforma, comunidad, wishlists |
| Burn-out | BUR | Salud del fundador, jornadas, motivación |

El prefijo del ID de entrada usa la categoría + número: `TEC-01`, `BUR-01`, etc.

## 3. Matriz probabilidad × impacto (5×5)

| P \ I | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| **5** | 5 | 10 | 15 | 20 | **25** |
| **4** | 4 | 8 | 12 | 16 | **20** |
| **3** | 3 | 6 | 9 | 12 | 15 |
| **2** | 2 | 4 | 6 | 8 | 10 |
| **1** | 1 | 2 | 3 | 4 | 5 |

Zonas:
- **Verde (1–4):** aceptar y vigilar.
- **Amarillo (5–9):** mitigación ligera, revisión trimestral.
- **Naranja (10–16):** mitigación activa con responsable y fecha.
- **Rojo (17–25):** plan de contingencia obligatorio + seguimiento mensual.

## 4. Plantilla de entrada de riesgo

```markdown
### [ID] — [Título corto]

| Campo | Valor |
|---|---|
| Categoría | TEC / ALC / EQU / FIN / MER / BUR |
| Fecha de identificación | YYYY-MM-DD |
| Identificado por | Fundador / Agente (modelo) |
| Descripción | [Qué puede pasar y cómo afecta al proyecto] |
| Probabilidad (1-5) | N |
| Impacto (1-5) | N |
| Nivel (P×I) | N — Zona (verde/amarillo/naranja/roja) |
| Estado | Identificado / Evaluado / Mitigándose / Monitoreado / Materializado / Cerrado |
| Dueño | Fundador / Agente (modelo) / Módulo |
| Mitigación | [Acciones preventivas] |
| Contingencia (si zona roja) | [Plan si se materializa] |
| Próxima revisión | YYYY-MM-DD |
| Historial | [Cambios de P/I, fechas, eventos] |
```

Reglas de llenado:
- El `Nivel` se recalcula si cambia P o I.
- Todo riesgo en zona naranja debe tener `Mitigación` con responsable y fecha límite.
- Todo riesgo en zona roja debe tener `Contingencia` escrita.
- El `Historial` es obligatorio: sin historial no se puede cerrar un riesgo.

## 5. Flujo de monitoreo (identificación → cierre)

```
┌────────────────────────────────────────────────────────────┐
│ 1. Identificación (RF1/RF2)                                 │
│    Fuente: revisión trimestral, bugs (M102), testings       │
│    (M101), QA cruzado (21.8), sugerencias del fundador      │
└────────────────────────┬───────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│ 2. Evaluación (RF4-RF7)                                     │
│    P (1-5), I (1-5), Nivel = P×I, zona y ubicación en       │
│    la matriz de riesgos                                     │
└────────────────────────┬───────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│ 3. Mitigación (RF8/RF9)                                     │
│    Acciones con responsable, fecha límite y resultado       │
│    esperado. Zona roja ⇒ contingencia obligatoria           │
└────────────────────────┬───────────────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────────────┐
│ 4. Monitoreo (RF10/RF11)                                    │
│    Estado: Mitigándose → Monitoreado.                       │
│    Seguimiento continuo + revisión trimestral               │
└───────────────┬────────────────────────┬───────────────────┘
                ▼                        ▼
        5a. Cierre (RF14)         5b. Materialización (RF13)
        Riesgo bajo o resuelto:   Evento ocurre: activar
        documentar lección y      contingencia, registrar
        marcar Cerrado            fecha/consecuencias y
                                  recalcular el resto
```

### Estados del riesgo

| Estado | Significado |
|---|---|
| Identificado | Detectado, pendiente de evaluación |
| Evaluado | P, I y nivel calculados |
| Mitigándose | Acciones de mitigación en curso |
| Monitoreado | Mitigado; solo vigilancia periódica |
| Materializado | El evento ocurrió; contingencia activada |
| Cerrado | Superado, inactivo o aceptado explícitamente |

## 6. Ciclo de revisión trimestral (RF11)

1. **Preparación (15 min):** leer el registro completo y la tabla de CHECKLIST-GLOBAL.
2. **Reevaluación (15 min):** revisar P e I de cada entrada activa; recalcular niveles.
3. **Nuevos riesgos (10 min):** registrar riesgos surgidos en el trimestre (bugs, cambios de M136, hallazgos de QA cruzado).
4. **Mitigaciones (10 min):** verificar avance de cada acción; marcar vencidas o en riesgo.
5. **Cierres (5 min):** cerrar riesgos superados con lección aprendida en el historial.
6. **Escalamiento (5 min):** aplicar reglas de la sección 7.
7. **Firma y commit (5 min):** fechar la revisión, firmar (`**Modelo:**` del agente si participó) y commitear con el protocolo de la sección 4 de AGENTS.md.

Duración objetivo total: **menos de 1 hora**.

## 7. Escalamiento y disparadores (RF12)

Un riesgo se **escala a crítico** (seguimiento mensual + revisión por el fundador) si:

- El nivel P×I llega o supera **17**.
- Un riesgo en zona naranja no presenta avance de mitigación en una revisión trimestral.
- Un riesgo afecta directamente un hito de M137 (Prototipo) o M138 (Vertical Slice).
- El fundador declara que un riesgo lo está afectando personalmente (burn-out).

Un **plan de contingencia** se activa cuando el riesgo se materializa (RF13):

1. Registrar fecha, síntomas y consecuencias en la entrada (Historial).
2. Ejecutar la contingencia escrita (o improvisarla y documentarla si no existía).
3. Notificar en `Logs/` y, si afecta hitos, informar a M136 (Roadmap).
4. Revisar el resto del registro: riesgos relacionados suelen subir de nivel.

## 8. Reporte hacia otros módulos

| Módulo | Qué recibe del 135 | Qué aporta al 135 |
|---|---|---|
| M133 (Gestión del Proyecto) | Estado global de riesgos en cada ciclo de gestión | Ciclo de planificación donde se ancla la revisión trimestral |
| M134 (Presupuesto) | Riesgos FIN (reservas, costos imprevistos) | Datos reales de gasto vs. plan para recalcular P |
| M136 (Roadmap) | Riesgos que amenazan hitos y su mitigación | Fechas y prioridades de hitos; MoSCoW por milestone |
| M137 (Prototipo) | Riesgos técnicos TEC que deben validarse primero | Resultados reales del prototipo (bugs, rendimiento) que cambian probabilidades |
| M102 (Bug Tracking) | Riesgos crónicos derivados de bugs repetidos | Métricas de bugs como señal de riesgo técnico |
| CHECKLIST-GLOBAL | Estado del módulo 135 (progreso, bloqueos) | Tabla global como fuente de verdad del estado |

## 9. Reglas de calidad

1. **Sin entradas sin evaluar:** ninguna entrada puede permanecer en estado Identificado más de una revisión trimestral.
2. **Nivel siempre visible:** toda entrada muestra P, I y nivel calculado.
3. **Mitigación obligatoria en zona naranja:** sin acciones no se puede cerrar la revisión.
4. **Contingencia obligatoria en zona roja:** sin plan escrito, el riesgo se reporta a M136.
5. **Historial obligatorio:** todo cambio (P, I, estado, fecha) se anota en la entrada.
6. **Honestidad ante todo:** si un riesgo no puede mitigarse aún, se deja explícito ([?] en el checklist del módulo, no un [x] falso).
7. **Revisión trimestral ineludible:** si se omite una revisión, se registra el motivo y se reprograma dentro de los 30 días.