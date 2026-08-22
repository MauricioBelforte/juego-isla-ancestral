**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 81: Legal — Menores

## Problema
El juego "Isla Ancestral" tiene una estética "cozy voxel" que atrae naturalmente a audiencia menor de edad, aunque no sea el target explícito. Se requiere garantizar cumplimiento legal integral para protección de menores según normativas internacionales (COPPA en EE.UU., GDPR en UE, LGPD en Brasil, etc.) y plataformas (Steam, consolas, mobile futuro).

## Objetivos
1. **Cumplimiento COPPA (Children's Online Privacy Protection Act)**: Si hay cualquier funcionalidad online/social que pueda captar datos de menores de 13 años en EE.UU.
2. **Cumplimiento GDPR-K (GDPR para niños)**: Procesamiento de datos de menores en UE (edad de consentimiento 13-16 según país miembro).
3. **Clasificación por edades apropiada**: Obtención de rating IARC/ESRB/PEGI/USK/GRAC/ACB que refleje contenido apto para menores.
4. **Diseño "Privacy by Design" para menores**: Minimización de datos, consentimiento parental verificable, derecho al olvido facilitado.
5. **Contratos y ToS adaptados**: Cláusulas específicas para menores en Términos de Servicio y Política de Privacidad.
6. **Monetización ética**: Zero dark patterns, zero loot boxes, zero pay-to-win, compras claras con consentimiento parental.
7. **Comunicación y marketing responsable**: No targeting invasivo a menores, disclaimers claros.

## Alcance
- **Dentro del alcance**:
  - Análisis de normativas aplicables por jurisdicción (COPPA, GDPR Art.8, LGPD Art.14, PIPL China, etc.)
  - Diseño de flujo de verificación de edad (age gating) no intrusivo
  - Política de Privacidad con sección específica menores
  - Términos de Servicio con cláusulas menores
  - Configuración de parental controls / family settings
  - Analytics/telemetría: anonimización total para cuentas menores
  - Crash reporting: sin datos personales de menores
  - Community management: moderación age-appropriate
  - Marketing: guidelines para no targeting a menores
  - Checklist de cumplimiento por plataforma (Steam, consolas, future mobile)

- **Fuera del alcance**:
  - Implementación técnica del age gating (corresponde a M53 UI/UX, M59 Guardado, M60 Datos y Serialización)
  - Desarrollo de parental controls UI (corresponde a M53 UI/UX, M58 Accesibilidad)
  - Integración con Steamworks Family View / console parental controls (corresponde a M96 Plataformas, M117 Build System)
  - Logging y telemetría sanitizados (corresponde a M103 Logging, M104 Analytics, M105 Telemetría, M121 Crash Reporting)

## Restricciones
- **Cero datos personales de menores sin consentimiento parental verificado**
- **Cero analytics/telemetría identificable en cuentas marcadas como menores**
- **Cero marketing directo a menores sin consentimiento**
- **Cero dark patterns en monetización (lo prohíbe GDPR, COPPA, y plataformas)**
- **Rating IARC obligatorio antes de cualquier release pública**
- **Documentación legal revisada por abogado especializado en videojuegos y privacidad infantil**
- **Idioma: Español (documentación), Inglés (políticas legales públicas)**
- **Plazo: Completar antes de M139 Pre-Alpha (primer build distribuible externamente)**