# Módulo 119: Actualizaciones — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:28:00

## 1. Análisis del Dominio

### Tipos de Actualizaciones

| Tipo | Contenido | Frecuencia |
|------|-----------|------------|
| **Parche crítico** | Bug fixes, seguridad | Cuando sea necesario |
| **Actualización menor** | Mejoras, balance, QoL | Cada 2-4 semanas |
| **Actualización mayor** | Features nuevas, contenido | Cada 3-6 meses |
| **DLC** | Contenido nuevo pagado | Según roadmap |
| **Free Update** | Contenido nuevo gratuito | Según roadmap |

### Plataformas de Distribución

| Plataforma | Sistema de Updates | Notas |
|------------|-------------------|-------|
| Steam | Steamworks | Auto-update, patches incrementales |
| GOG | Galaxy | Similar a Steam |
| Epic Games Store | EOS | Auto-update |
|itch.io| Manual | Upload de builds |
| Consolas | Certificación | Requiere aprobación |

## 2. Decisiones de Diseño

### Decisión 1: Estrategia de Versionado

**Opción A:** Semver estricto (MAJOR.MINOR.PATCH)
- Pro: Claro, predecible
- Contra: Riguroso para juegos

**Opción B:** Calver (Calendar Versioning)
- Pro: Fácil de recordar
- Contra: No indica breaking changes

**Decisión:** Semver para código interno, Calver para comunicar a jugadores. Ejemplo: "v1.2.3 (2026-08-21)".

### Decisión 2: Compatibilidad de Saves

**Opción A:** Saves siempre compatibles (forward-compatible)
- Pro: Sin pérdida de datos
- Contra: Limita cambios de schema

**Opción B:** Migración automática de saves
- Pro: Permite cambios de schema
- Contra: Riesgo de corrupción

**Decisión:** Opción B con migración automática + backup del save original antes de migrar.

### Decisión 3: Notificación al Jugador

**Opción A:** Notificación in-game (popup)
- Pro: Visible
- Contra: Molesto si es frecuente

**Opción B:** Notificación en menú principal
- Pro: No molesto
- Contra: Puede pasar desapercibido

**Decisión:** Opción B + opción de "buscar actualizaciones" manual en settings.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Actualización corrompe saves | Baja | Crítico | Backup automático + migración test |
| Rollback falla | Baja | Alto | Mantener versión anterior accesible |
| Jugador rechaza update crítica | Media | Medio | Forzar solo updates de seguridad |
| DLC no es compatible con versión base | Media | Alto | Verificar versión antes de instalar DLC |
| Auto-update falla en conexión lenta | Media | Medio | Updates incrementales + resume |
