**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 82: Clasificación por Edades

## Problema
El juego "Isla Ancestral" necesita obtener clasificación por edades (rating) en todas las jurisdicciones donde se comercializará. La clasificación es obligatoria para publicar en Steam, consolas y mobile. El rating debe reflejar fielmente el contenido del juego y ser consistente entre plataformas.

## Objetivos
1. **Obtener rating IARC** (International Age Rating Coalition) como rating global base
2. **Obtener ratings regionales** donde IARC no es aceptado (ESRB, PEGI, CERO, GRAC, ACB, USK)
3. **Documentar proceso de submission** para cada sistema de clasificación
4. **Definir descriptores de contenido** aplicables al juego (violencia, lenguaje, etc.)
5. **Diseñar validación automática** de que el contenido es consistente con el rating
6. **Integrar rating en store pages** y materials de marketing
7. **Mantener consistencia** entre todos los ratings obtenidos

## Alcance
- **Dentro del alcance**:
  - Análisis de cada sistema de clasificación (IARC, ESRB, PEGI, CERO, GRAC, ACB, USK)
  - Proceso de submission y costos por sistema
  - Descriptores de contenido aplicables al juego
  - Validación automática de contenido vs. rating
  - Integración con M96 Plataformas, M97 Steam Store Page
  - Documentación de proceso para futuras actualizaciones

- **Fuera del alcance**:
  - Implementación técnica de IARC Validator (corresponde a M81 Legal — Menores)
  - Gestión de certificación por plataforma (corresponde a M96 Plataformas)
  - Contenido visual/textos de store pages (corresponde a M97 Steam Store Page)

## Restricciones
- **Rating IARC obligatorio antes de M141 Beta**
- **Consistencia entre todas las plataformas**
- **Contenido del juego debe ser compatible con rating objetivo (Everyone o Teen)**
- **Costos de certificación contemplados en M134 Presupuesto**
- **Idioma: Español (documentación), Inglés (submissions oficiales)**

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M078** — Legal — Propiedad Intelectual | Base para legal — propiedad intelectual |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M078** — Legal — Propiedad Intelectual | Depende de este módulo |

