**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Implementación operativa (entregable M133)

---

# Cómo escribir un ADR en este proyecto (README de la carpeta)

Un **ADR (Architecture/Decision Record)** registra una decisión relevante de proceso, alcance o arquitectura, con su contexto, para que cualquier agente futuro entienda el *por qué* sin preguntar (RF10, flujo §6 de `plan-actual/03-Diseno.md`).

## Cuándo escribir uno

- Cambiar una decisión ya tomada (herramienta, metodología, política).
- Cambiar de alcance a mitad de hito (ver `guia-hitos.md` §5).
- Introducir una excepción permanente a una regla del protocolo.
- Decisiones de arquitectura técnica que afecten a varios módulos.

Si la decisión es pequeña y reversible, basta un log o una nota; no todo merece ADR.

## Numeración y archivo

- Nombre: `NNNN-titulo-en-kebab-case.md` (ej: `0002-adopcion-herramienta-tablero.md`).
- Los números no se reutilizan; un ADR rechazado conserva su número con estado `Rechazado`.
- No editar un ADR `Aceptado` para cambiar su decisión: se escribe uno nuevo que lo **reemplace** (referenciando al anterior).

## Plantilla

```markdown
# ADR-{N}: {Título de la decisión}
**Fecha:** {YYYY-MM-DD} · **Estado:** Aceptado / Propuesto / Rechazado

## Contexto
{Qué problema nos llevó a decidir}

## Decisión
{Qué se decidió, en una frase clara}

## Opciones descartadas
- {Opción A} → descartada por {motivo}
- {Opción B} → descartada por {motivo}

## Consecuencias
{Positivas y negativas conocidas}

**Firma:** {Modelo} / {Plataforma}
```

## Ciclo de vida

`Propuesto` (esperando confirmación del fundador o de otro agente) → `Aceptado` o `Rechazado`. Un ADR `Aceptado` que afecta a otro módulo exige además: log en `Logs/` y actualización de la documentación del módulo afectado.

**Firma del último agente que modificó este README:**

**Modelo:** GLM
**Plataforma:** Kilo
