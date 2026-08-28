**Modelo:** GLM
**Plataforma:** Kilo
**Última actualización:** 2026-08-28
**Estado global:** Fase actual → Fase 1 (Prototipo, en preparación) · Hito en curso → M137 (módulos de entrada 🔵: M13, M14)

# Roadmap de Isla Ancestral (v1.0)

## Resumen ejecutivo (leer en 2 minutos)

- Visión: mundo voxel cozy en la isla Aurora (Godot 4.7.2 + Voxel Tools, GDScript).
- Meta: v1.0 con el loop cozy completo y la isla Aurora navegable (contrato O1-O19 de M153).
- Estrategia de lanzamiento: EA vs full release decidida en la beta (M141) con datos.
- Estado real hoy (2026-08-28): fundación técnica completa y verificada (motor, voxel, generación, isla, jugador, cámara ✅), herramientas e inventario en curso; el primer hito formal (M137) está **en preparación** — sus módulos Must restantes son M13 (herramientas conectadas al voxel) y M14/M59 (inventario/guardado mínimo).

## Fases e hitos

| Hito | Fase | Estado | Criterios de salida clave | Duración estimada |
|------|------|--------|---------------------------|-------------------|
| M137 | Prototipo | ⬜ En preparación (entradas 🔵) | Mundo voxel, cavar/colocar, guardar/cargar, build etiquetado | 4-8 semanas |
| M138 | Vertical Slice | ⬜ | Slice jugable punta a punta, interacción, objetivo del GDD, playtest | 8-14 semanas |
| M139 | Pre-Alpha | ⬜ | Loop de ~30 min completo (recolectar/crear/construir/economía) | 12-20 semanas |
| M140 | Alpha | ⬜ | Contenido v1.0 jugable (NPC, historia, templos) | 12-20 semanas |
| M141 | Beta | ⬜ | Feature complete, equilibrio, decisión EA | 8-12 semanas |
| M142 | RC | ⬜ | Estable, compatible, performance en presupuesto | 4-8 semanas |
| M143 | Lanzamiento | ⬜ | v1.0 publicada + soporte | 2-6 semanas |

Regla: las duraciones son rangos orientativos; **la confirmación con la disponibilidad real del fundador es decisión humana** (pendiente). Primer punto de recalibración obligatorio: cierre de M137.

## Módulos por fase (resumen MoSCoW — primera pasada)

> Primera pasada delegable, hecha 2026-08-28 con los estados reales de `CHECKLIST-GLOBAL.md`. La asignación definitiva la confirma el fundador. Fuente de orden detallada: `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fases F1-F9).

### M137 Prototipo (Must)
- M08 Mundo Voxel ✅ · M10 Generación ✅ · M11 Personaje ✅ · M12 Cámara ✅ · M13 Herramientas 🔵 (integración voxel real) · M14 Inventario 🔵 (núcleo) · M15 Recursos 🟢 (bloqueado por M14) · M59 Guardado 🟡 (núcleo implementado) · M137 Prototipo (integrador, GO/NO-GO).
- Won't en esta fase: todo lo no voxel (templos, historia completa, islas nuevas).

### M138 Vertical Slice
- Must: M27 (zona del slice) · M70 Interacciones · M53 UI mínima · M14 Inventario · M63 cargas mínimas · M138 integrador.
- Should: M19 NPC básico · M41 música base.
- Could/Won't: sistemas profundos (templos, historia).

### M139 Pre-Alpha
- Must: M15/M16/M17 (recolectar/crear/construir) · M38 economía mínima · M31 día/noche · M32 clima básico.
- Should: M36 fauna básica · M29 tiempo (✅ servicio implementado).
- Could: M20 amistad · M21 diálogos.

### M140 Alpha
- Must: contenido v1.0 (M19/M22/M23/M24) · M66 anti-softlock · M60 datos estable.
- Should: pulido UX/UI (M53/M57) · M58 accesibilidad.
- Could: M37 museos.

### M141 Beta
- Must: estabilidad y equilibrio (M93/M101/M112) · M58 accesibilidad · M90/M91 configuraciones · M97 página Steam.
- Should: audio final (M41-M44) · M88 fuentes.
- Could: contenido extra.

### M142 RC
- Must: estabilidad/compatibilidad/performance (M61/M62/M122) · builds etiquetados (M117).
- Should: último pulido.
- Won't: features nuevas (congeladas).

### M143 Lanzamiento
- Must: publicación (M97), anuncio (M99/M98), hotfixes, soporte (M121).
- Should: post-lanzamiento (M144/M120).
- Could: contenido mayor poslanzamiento.

## Dependencias entre hitos (con estado real 2026-08-28)

| Hito | Depende de | Estado de las dependencias clave |
|------|------------|----------------------------------|
| M137 | M08, M10, M11, M12, M60/M59, M13 | ✅ ✅ ✅ ✅ · M59 🟡 núcleo · M13 🔵 → **M137 habilitado parcialmente; apertura formal cuando M13 y el núcleo M14 cierren** |
| M138 | M137 + M27, M63, M70, M53, M14 | M53 🔵 core UI; resto 🟢 documentado |
| M139 | M138 + M15, M16, M17, M38, M31, M32 | M38 🟡 núcleo; resto 🟢 documentado |
| M140 | M139 + M19, M20, M21, M22, M23, M24, M66 | M19 🔵 primer NPC; M20 🔵 núcleo; M66 🟡 núcleo |
| M141 | M140 + M90/M91, M58, M97, M41-M44 | 🟢 documentados |
| M142 | M141 + M62, M122, M104, M61 | 🟢 documentados |
| M143 | M142 + M97, M131, M78/M80, M118 | 🟢 documentados |

## Riesgos que amenazan el calendario (fuente: M135 `RISK-REGISTER.md`, revisión 2026-08-28)

| Riesgo | Nivel | Impacto en el roadmap |
|---|---|---|
| R-01 dependencia de agentes de IA | 16 Naranja | Velocidad de producción variable entre fases |
| R-10 burn-out del fundador | 15 Naranja | Riesgo máximo de deslizamiento del calendario completo |
| R-02 calidad de código IA | 12 Naranja | Retrabajos en M138-M141 si el gate de calidad (M111) no se aplica |
| R-03/R-11 escalado mundo / financiamiento | 12 Naranja | Afectan M139+ (4 islas) y la sostenibilidad de fases largas |
| R-06 scope creep | 12 Naranja | Amenaza todos los hitos; mitigación operativa en M133 |
| R-07 hitos deslizantes | 9 Amarillo | Activo hasta la primera planificación formal con holgura |
| R-16 build web sin voxel | 9 Amarillo | No afecta v1 (Steam+Deck primero); recuérdalo en M96/M142 |

## Política de builds y releases

| Fase | Etiqueta git | Nombre | Destino |
|------|--------------|--------|---------|
| M137 | `prototype-1` | Prototipo | Interno |
| M138 | `slice-1` | Vertical slice | Playtest interno + comunidad cercana |
| M139 | `prealpha-1` | Pre-Alpha | Playtest ampliado |
| M140 | `alpha-1` | Alpha | Testers seleccionados |
| M141 | `beta-1` | Beta | Comunidad + wishlist (M97) |
| M142 | `rc-1` | RC | Producción |
| M143 | `v1.0.0` | 1.0 | Público |

EA vs full release: decisión de M141 con datos; ambas puertas abiertas hasta entonces.

## Edge cases operativos (añadidos 2026-08-28)

| Situación | Procedimiento |
|---|---|
| Hito bloqueado por módulo crítico sin completar | No abrir el hito; tratar la dependencia como "fallida en curso" (§7.3 de `03-Diseno.md`): alternativa u orden nuevo, coordinado con la regla de orden de la guía 08; reportar a M133/M135 |
| Cambio de plataforma de lanzamiento a mitad del roadmap | Evaluar impacto en M96/M97/M116/M117 con el fundador; registrar por ADR (M133); recalcular el hito M142/M143 y sus criterios de salida |
| Incorporación de un colaborador humano al roadmap | Onboarding con M133 (README de gestión), asignar módulos bajo las mismas reglas §21, revisar capacidad del calendario y registrar el cambio en el historial de este roadmap |
| Features del GDD que exceden la v1.0 | Derivar a `5-FUTURAS-MEJORAS.md` (CCould/Won't) y a M120 (DLC/Expansiones); nunca inflar un hito con ellas |
| Abandono temporal del fundador | Pausa planificada según M133 (README §6-§7): documentación permite retomar; los hitos no avanzan sin decisiones humanas pendientes y se registra la pausa en el historial de este roadmap |

## Historial de cambios del roadmap

| Fecha | Cambio | Motivo | Autor |
|-------|--------|--------|-------|
| 2026-08-28 | Creación del roadmap operativo (fases, MoSCoW primera pasada, dependencias con estado real, riesgos) | Implementación del módulo 136 (log 198) | GLM (Kilo) |

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
