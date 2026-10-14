# REDISTRIBUCIÓN DE ROLES TRAS SALIDA DE ATRIA — 2026-10-14

**Modelo:** mimo-v2.6-flash-free (Director)
**Plataforma:** opencode
**Fecha:** 2026-10-14 20:50
**Origen:** orden del fundador — "absorbé el rol de estratega, copiá los backlogs de s3"

> Los archivos originales de s3 quedan en `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/`
> como históricos. Esta es la versión actualizada del director.

## Recursos disponibles (real, medido)

| Modelo | Plataforma | Créditos | Velocidad | Nicho verificado |
|---|---|---|---|---|
| **step-5-kilocode** | Kilo Code | Buenos | El más rápido | Ejecución técnica, cierre de secciones, deep work |
| **Step-5-WorkBuddy** | WorkBuddy | ⚠️ Limitados | 1h respuesta | Mismas capacidades que kilocode, dejar tranquila |
| **agnes-3-flash** | Kilo Code | Buenos (nunca corta) | Media | Verificación §21.8, contenido editorial, 0 inflación |
| **Hy3** | WorkBuddy | ⚠️ Limitados | Rápida | QA cruzado honesto (Patrón D), 9/9 suites |
| **DeepSeek-V4.1-Flash** | Kilo/WorkBuddy | ⚠️ Limitados | Media | Deep work puntual, fundador del proyecto |
| **Ling-3.1-Flash** | — | ⚠️ Limitados | Rápida | QA de módulos específicos (M108). **NO delegar mucho: créditos limitados, solo tareas puntuales.** |
| **kimi-k3** | Kilo Code | ⛔ SIN CRÉDITOS | — | NO DISPONIBLE |
| **Hy4** | WorkBuddy | Por traer | — | Modelado 3D iterativo, tareas puntuales específicas |

## Roles redistribuidos

| Rol (antes atria) | Nuevo responsable | Justificación empírica |
|---|---|---|
| **Committer/push** (atria-dawn) | **Cada agente commitea su frente + director hace cruzado** | Eliminado rol dedicado. Pathspec obligatorio. |
| **Verificador final §21.8** (s2) | **agnes primario, Hy3 backup** | agnes: 74 flips 0 inflación hoy. Hy3: Patrón D honesto, pero créditos limitados. |
| **Estratega/delegación** (s3) | **mimo (director)** | Absorbe s3. Copia backlogs de s3. Usa guía empírica para asignar. |
| **Deep work** (atria-dawn) | **step-5-kilocode primario, DeepSeek puntual** | step-5: 4 módulos hoy. DeepSeek: solo tareas cortas por límite tokens. |

## Cadena operativa

```
DIRECTOR (mimo) — lee, clasifica, delega, sella, commitea cruzado
  │
  ├── STEP-5-KILOCODE — ejecuta + deep work + cierre de secciones
  │     (créditos buenos, el más rápido, no satura)
  │
  ├── AGNES — verifica §21.8 + escribe contenido editorial
  │     (créditos infinitos, 0 inflación, nunca corta)
  │
  ├── STEP-5-WORKBUDDY — deep work en segundo plano
  │     (1h respuesta, créditos limitados — dejar tranquila)
  │
  ├── HY3 — QA cruzado backup (solo si agnes no puede)
  │     (créditos limitados, Patrón D)
  │
  ├── DEEPSEEK — deep work puntual, tareas cortas
  │     (fundador del proyecto, razonamiento profundo, créditos limitados)
  │
  ├── LING — QA de módulos específicos
  │
  └── HY4 — modelado 3D iterativo (traer solo para tareas puntuales específicas)
```

## Reglas de asignación del director

1. **step-5-kilocode** → módulos técnicos con `[?]` que requieren grep + evidencia, cierre rápido de secciones.
2. **agnes** → verificación de módulos de otros + contenido editorial/documental con cita real.
3. **Step-5-WorkBuddy** → tareas largas estables que no requieren respuesta rápida (M04 iteraciones, por ejemplo).
4. **Hy3** → QA cruzado puntual, solo cuando agnes esté ocupada. No asignarle módulos propios (independencia §21.8).
5. **DeepSeek** → tareas cortas de alta dificultad. NO cargarlo con QA continuo ni módulos grandes.
6. **Ling** → QA de módulos específicos que conozca (M108).
7. **Hy4** → solo modelado 3D cuando el fundador lo autorice explícitamente.

## Backlogs de s3 copiados (actualizados)

Los 7 backlogs de s3 están en `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/` como históricos.
Esta carpeta (`mimo-v2.6-flash-free/`) contiene la versión actualizada del director.

**Estado actualizado 2026-10-14:**
- M139 CERRADO 133/142 (step-5)
- M140 CERRADO 100/124 (step-5)
- M137 CERRADO 8/131, diseño ref (step-5)
- M141 146/147 (step-5, en curso)
- M148 95/117 (agnes, b1-b6 cerrados, b7-b12 pendientes)
- M70 CERRADO 109/198 (agnes)
- M48 CERRADO 22/123 (agnes)
- M15 CERRADO 190/219 (agnes)
- M05 95/103 (DeepSeek, en curso)
- M01 26/152 (DeepSeek, en curso)

**Firma:** mimo-v2.6-flash-free (Director) / opencode — 2026-10-14 20:50
