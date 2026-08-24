# Módulo 83: Licencias de Software — Requerimientos

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:24:00

## Problema

El juego Isla Ancestral utiliza múltiples componentes de software de terceros (librerías, frameworks, herramientas) que requieren licenciamiento. Sin un módulo de gestión de licencias, existe riesgo de:
- Infracción de licencias (multas legales, retiro del juego)
- Distribución de código licenciado sin atribución requerida
- Uso de licencias incompatibles entre sí (GPL + propietario)
- Olvido de atribuciones en builds de distribución

## Objetivos

1. Inventario completo de todas las dependencias de software y sus licencias
2. Validación automática de compatibilidad de licencias
3. Generación automática de atribuciones/license notices
4. Cumplimiento de obligaciones de distribución (source code offer para GPL)
5. Auditoría de licencias en build pipeline

## Alcance

- **Incluye:** Licencias de dependencias (GDScript/Python/C#), herramientas de build, assets de terceros con licencia de software, plugins de Godot
- **No incluye:** Licencias de assets artísticos (M71), contenido generado por IA (M139), audio bajo Creative Commons (M60)

## Restricciones

- Obligación legal de incluir atribuciones en cada build de distribución
- Licencias GPL/LGPL requieren ofrecer source code al usuario
- Algunas licencias prohíben uso comercial (verificar cada dependencia)
- Licencias de engines (Godot: MIT) son permisivas, pero paquetes de terceros pueden ser restrictivos

## Dependencias del Módulo

| Tipo | Módulos |
|------|---------|
| Antes de empezar | 55-Gestión de Dependencias |
| Durante el desarrollo | 117-Build Pipeline, 141-Beta |
| Relacionados | 71-Gestión de Assets, 72-Validación de Builds, 139-IA Generativa |

## Criterios de Aceptación

- [ ] Inventario de todas las dependencias con licencia asociada
- [ ] Validador de compatibilidad de licencias funcional
- [ ] Generador automático de license notices para cada build
- [ ] Integración con build pipeline (M117)
- [ ] Documentación de cada licencia en el inventario

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M055** — Diario del Jugador | Base para diario del jugador |
| **M117** — Build System | Licencias en build |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M055** — Diario del Jugador | Depende de este módulo |
| **M117** — Build System | Depende de este módulo |

