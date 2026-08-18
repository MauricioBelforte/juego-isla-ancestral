**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 135: Riesgos del Proyecto

## ID del Módulo
- **Código:** M135 (tabla `CHECKLIST-GLOBAL.md`)
- **Carpeta:** `DOCUMENTACION/135-Riesgos-Del-Proyecto/`
- **Dependencias:** M133 (Gestión del Proyecto, en proceso — se referencia sin bloquear)
- **Consumidores:** M136 (Roadmap), M137 (Prototipo). Relacionado con M134 (Presupuesto)
- **Carácter:** Módulo administrativo de gestión (sin código de gameplay)

## 1. Problema

"isla-ancestral" se desarrolla como juego indie cozy de mundo voxel (Godot 4.x + Voxel Tools, GDScript) por un fundador solitario asistido por agentes de IA. En este modelo de desarrollo los riesgos son amplios y variados: dependencia de la IA, calidad variable del código generado, assets de terceros, tamaño del mundo voxel, tiempos de carga, plataforma de distribución, financiamiento y, sobre todo, la salud del fundador (burn-out). Sin un registro formal, los riesgos se olvidan, se descubren tarde y se gestionan de forma reactiva, cuando ya es tarde para mitigar.

## 2. Objetivo

Establecer un registro de riesgos del proyecto (RISK-REGISTER) que permita: identificar riesgos de forma sistemática, evaluarlos por probabilidad × impacto, definir mitigaciones con responsable y fecha, y monitorearlos con una revisión trimestral. El registro debe ser mantenible por una sola persona, de costo cero y en idioma español.

## 3. Alcance

- Riesgos técnicos (motor, mundo voxel, generación procedural, IA, assets).
- Riesgos de alcance (scope creep, tamaño del mundo, hitos).
- Riesgos de equipo (fundador único, unicidad de conocimiento, burn-out).
- Riesgos de financiamiento (presupuesto, reservas, sustentabilidad).
- Riesgos de mercado (nicho cozy, plataforma, comunidad).
- Proceso de revisión trimestral y monitoreo continuo.

Fuera de alcance: ejecución de las mitigaciones (le pertenece a cada módulo dueño), evaluación financiera detallada (M134) y planificación de hitos (M136).

## 4. Restricciones

- Costo cero: sin herramientas SaaS de gestión de riesgos.
- Mantenible por UNA persona (el fundador) en pocos minutos por revisión.
- Todo en español, formato Markdown, versionado en git.
- No debe bloquear el avance de M133 (Gestión del Proyecto): el registro funciona standalone.
- Sin código del juego: documento de gestión, no sistema de gameplay.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Identificación de riesgos | Proceso sistemático para detectar riesgos nuevos y recurrentes |
| RF2 | Categorización | Clasificación en 6 categorías (técnicos, alcance, equipo, financiamiento, mercado, burn-out) |
| RF3 | Registro estructurado | Plantilla de entrada con campos obligatorios (ID, descripción, fechas, estado) |
| RF4 | Evaluación de probabilidad | Escala 1–5 con criterios explícitos |
| RF5 | Evaluación de impacto | Escala 1–5 considerando tiempo, dinero, calidad y salud |
| RF6 | Nivel de riesgo | Cálculo P × I y clasificación en rangos (bajo, medio, alto, crítico) |
| RF7 | Matriz de riesgo | Mapa visual 5×5 con zonas de tolerancia |
| RF8 | Mitigación | Plan de acciones preventivas con responsable y fecha límite |
| RF9 | Responsables | Asignación de dueño por riesgo y por acción de mitigación |
| RF10 | Monitoreo | Seguimiento continuo del estado de cada riesgo |
| RF11 | Revisión periódica | Ciclo trimestral obligatorio alineado a M133 |
| RF12 | Escalamiento | Disparadores que elevan un riesgo a crítico o activan contingencia |
| RF13 | Riesgo materializado | Plan de contingencia e ingreso del evento al registro |
| RF14 | Historial y lecciones | Registro de decisiones, eventos y aprendizaje post-cierre |

## 6. Requisitos No Funcionales

- Documento Markdown legible en cualquier editor y plataforma de hosting (GitHub).
- Idiomas: contenido íntegro en español.
- Un único archivo principal (`RISK-REGISTER.md`) + guía opcional de revisión.
- Compatible con el protocolo de documentación por módulos del proyecto (firma, plan-inicial/plan-actual, Logs).
- Revisión trimestral con duración objetivo menor a 1 hora.
- Riesgos con nivel ≥ 12 deben tener mitigación obligatoria antes de cerrar la revisión.
- El registro debe poder ser consultado por los agentes de IA durante cualquier tarea.

## 7. Criterios de Aceptación

1. Los 6 tipos de riesgo (técnico, alcance, equipo, financiamiento, mercado, burn-out) cubiertos.
2. La matriz probabilidad × impacto definida con los 4 rangos de nivel.
3. La plantilla de entrada y la de plan de mitigación definidas.
4. Cinco ejemplos de entrada del registro escritos con riesgos reales del proyecto.
5. El ciclo de revisión trimestral documentado paso a paso.
6. La integración con M133 / M134 / M136 / M137 especificada sin bloquearlos.
7. Checklist de 130 ítems con todos los subitems resueltos.