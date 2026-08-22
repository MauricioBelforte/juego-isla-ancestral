**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 81: Legal — Menores

## Dominio y Marco Regulatorio

### 1. Normativas Internacionales Aplicables

#### COPPA (Children's Online Privacy Protection Act, EE.UU.)
- **Alcance**: Protege privacidad de niños <13 años en EE.UU.
- **Aplicación**: Si el juego tiene funcionalidad online/social accesible desde EE.UU.
- **Requisitos clave**:
  - Consentimiento verificable de padres antes de recolectar cualquier dato personal
  - Notificación clara a padres sobre información recolectada
  - Opción para que padres revisen/eliminen datos de sus hijos
  - Seguridad razonable de los datos recolectados
  - Prohibido condicionar juego al consentimiento
  - Conocimiento real de que hay menores recolectando datos

#### GDPR Art.8 (UE) / GDPR-K
- **Alcance**: Protección de datos para menores en Espacio Económico Europeo
- **Edad de consentimiento**: Varía por país (13-16 años, default 13)
- **Requisitos clave**:
  - Consentimiento parental para menores de edad de consentimiento
  - Información en lenguaje claro y comprensible
  - Derechos del niño específicamente (acceso, rectificación, supresión)
  - Protecciones específicas según edad

#### LGPD (Brasil, Lei General de Protección de Datos)
- **Alcance**: Protección de datos personales en Brasil
- **Relevancia**: Dado proyecto se comercializará vía Steam (global)
- **Requisitos clave**:
  - Consentimiento para menores (interpretación restrictiva)
  - Mapeo de datos y propósitos
  - Anonimización cuando sea posible

#### Otras normativas consideradas
- **PIPL China**: Si hay posibilidad de acceso chino (restricciones actuales)
- **Ley de Protección de Datos de India**: DPDP Act 2023, creciente relevancia
- **Convenio 108**: Consejo de Europa, estándares harmonizados

### 2. Análisis de Plataformas

#### Steam (Windows/macOS/Linux)
- **Steam Subscriber Agreement**: Sección sobre contenido para menores
- **Steam Family View**: Modo restringe acceso a contenido no apto
- **IARC**: International Age Rating Court - rating obligatorio para releases
- **Steamworks SDK**: Familia functions, edad del usuario disponible

#### Consolas (PlayStation, Xbox, Nintendo)
- **Certificación obligatoria**: Cada plataforma tiene requisitos propios
- **Parental controls**: Integradas en cada ecosistema
- **Ratings**: ESRB (EE.UU.), PEGI (Europa), CERO (Japón), etc.
- **Costos adicionales**: Certificación por plataforma (~$10k-50k dependiendo)

#### Mobile (futuro iOS/Android)
- **COPPA compliance**: Requerido por Apple App Store / Google Play
- **App Store Connect**: Family Settings, parental controls
- **Google Play**: Designed for Families program
- **Costos**: Annual developer fees + certification

### 3. Decisiones y Alternativas Analizadas

#### Alternativa A: Bloqueo estricto por edad al inicio
- **Pros**: Cumplimiento garantizado, sin riesgos legales
- **Cons**: Fricción en UX, posible pérdida de audiencia, age gating intrusivo
- **Decisión**: Descartada - impacto negativo en juego "cozy" de acceso fácil

#### Alternativa B: Age gating condicional (solo si hay features online)
- **Pros**: Menor fricción, solo aplica si hay datos menores
- **Cons**: Complejidad en detección, riesgo de subestimación
- **Decisión**: Seleccionada como enfoque base (ver Sección 5)

#### Alternativa C: "All ages" con políticas robustas
- **Pros**: Acceso sin fricciones, políticas de protección completas
- **Cons**: Requiere implementación completa en todos los sistemas
- **Decisión**: Seleccionada como política global (ver Sección 5)

### 4. Brechas y Riesgos Identificados

#### Riesgos Críticos
1. **Recolección inadvertida de datos de menores**: Analytics o telemetría que capture datos sin filtrado por edad
2. **Marketing directo a menores**: Targeting basado en comportamiento de cuentas detectadas como menores
3. **Fallo en consentimiento parental**: Implementación incorrecta de verificación de edad/consentimiento
4. **Crash reporting con datos personales**: Stack traces que incluyan información de cuenta de menor
5. **Contenido UGC inapropiado**: Si hay generación de contenido por usuarios sin moderación age-appropriate

#### Riesgos Medianos
1. **Clasificación IARC incorrecta**: Rating que no refleja realidad del contenido
2. **Políticas de privacidad incompletas**: Secciones sobre menores faltantes o en lenguaje inapropiado
3. **Términos de Servicio ambiguos**: Cláusulas sobre menores que no cumplen normativa
4. **Inconsistencia entre plataformas**: Cumplimiento COPPA en EE.UU. pero no GDPR en UE

### 5. Decisiones Finales

1. **Enfoque "Privacy by Design" integrado**: Todas las sistemas considerados deben ser compatibles con protección de menores, no opt-in opcional
2. **Age gating automático**: Sistema que detecta y clasifica cuentas automáticamente (vs. opt-in del usuario)
3. **Anonimización total para cuentas <13**: Analytics/telemetría completamente anonimizada si edad detectada <13
4. **Crash reporting sanitizado**: Sin datos de cuenta, identificadores, ubicación en reports de menores
5. **IARC rating mandatory**: Antes de cualquier release público, rating debe incluir contenido para menores
6. **ToS y Privacy Policy con secciones explícitas**: Cláusulas claras sobre menores, no "legalese" genérico
7. **Consentimiento parental en features online**: Si hay multiplayer/social, requerir verificación antes de interacción

### 6. Dependencias con Otros Módulos

#### Dependencias directas (módulos que este módulo consume o modifica)

| Módulo | Dependencia | Tipo |
|--------|-------------|------|
| M53 | UI/UX | Age gating UI, parental controls |
| M57 | Arquitectura General | Service Locator para configuraciones legales |
| M58 | Accesibilidad | Configuración de edad, filtros |
| M59 | Guardado | Datos de edad/consentimiento en saves |
| M60 | Datos y Serialización | Persistencia de flags de edad |
| M78 | Legal — Propiedad Intelectual | Contratos con freelancers menores |
| M80 | Legal — Privacidad | Política de privacidad general (base para sección menores) |
| M87 | Localización | Idiomas en políticas legales |
| M96 | Plataformas | Ratings por plataforma, IARC |
| M101 | QA General | Tests de cumplimiento |
| M103 | Logging | Logs sanitizados menores |
| M104 | Analytics | Anonimización por edad |
| M105 | Telemetría de Gameplay | Datos seguros menores |
| M117 | Build System | Builds con configuraciones edad, IARC validator |
| M121 | Crash Reporting | Crash reports sanitizados |
| M125 | Términos de Servicio | ToS con cláusulas menores |

#### Dependencias inversas (módulos que consumen este módulo)

| Módulo | Consumo |
|--------|---------|
| M97 | Steam Store Page — refleja rating IARC obtenido |
| M98 | Trailer — debe ser compatible con rating objetivo |
| M99 | Marketing — guidelines de no targeting a menores |
| M111 | Código de Calidad — checklists age-compliance |
| M133 | Gestión del Proyecto — timeline cumplimiento legal |
| M134 | Presupuesto — costos certification, lawyer review |
| M135 | Riesgos del Proyecto — riesgos legales identificados |
| M136 | Roadmap — hitos cumplimiento legal |
| M151 | Control Final — auditoría incluye compliance menores |
| M152 | Principios Innegociables — protección menores como principio |