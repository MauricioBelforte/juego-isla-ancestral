**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 100: Community Management

## 1. Arquitectura del módulo

```
Community Management (gestión de comunidad)
├── Reglas comunitarias
│   ├── Documento de reglas
│   ├── Publicación en Discord
│   ├── Publicación en Steam
│   └── Publicación en redes sociales
├── Sistema de moderación
│   ├── Roles (Admin, Mod, Helper, Usuario)
│   ├── Permisos
│   ├── Logs de acciones
│   └── Sistema de apelación
├── Sistema de reportes
│   ├── Categorías de reportes
│   ├── Workflow de revisión
│   ├── Dashboard de reportes
│   └── Notificaciones
├── Canales de feedback
│   ├── Discord (#bugs, #sugerencias, #preguntas, #off-topic, #anuncios)
│   ├── Steam (Discussions, Bugs, Sugerencias)
│   └── Redes sociales (Twitter/X, Reddit)
├── Roadmap público
│   ├── Hitos generales
│   ├── Categorías (Core Gameplay, Content, Technical, Polish)
│   ├── Estados (Completado, En desarrollo, Planeado, Futuro)
│   └── Notas contextuales
├── Changelog público
│   ├── Versiones con fechas
│   ├── Categorías (Added, Changed, Fixed, Removed)
│   ├── Notas importantes
│   └── Links a issues resueltos
├── Respuesta a dudas
│   ├── SLA de 48 horas
│   ├── Base de conocimiento (FAQ)
│   ├── Triaje de dudas
│   └── Respuestas documentadas
├── Identificación de bugs
│   ├── Sistema de triage
│   ├── Categorías (crítico, mayor, menor, trivial)
│   ├── Verificación (reproducible/no reproducible)
│   └── Integración con M102
├── Recopilación de sugerencias
│   ├── Categorización (gameplay, UI, contenido, técnica, performance)
│   ├── Evaluación (alineado, factible, out of scope)
│   ├── Tablero de sugerencias
│   └── Integración con M102
├── Gestión de expectativas
│   ├── Directrices de comunicación
│   ├── Hitos genéricos (sin fechas)
│   ├── Transparencia sobre retrasos
│   └── Comunicación de cambios de dirección
├── Gestión de críticas
│   ├── Distinción (constructivas/destructivas)
│   ├── Respuestas a críticas constructivas
│   ├── Moderación de críticas destructivas
│   └── Documentación de feedback recurrente
├── Gestión de contenido tóxico
│   ├── Definición de contenido tóxico
│   ├── Acciones (advertencia, mute, ban)
│   ├── Sistema de escalado
│   └── Logs de acciones
├── Gestión de spoilers
│   ├── Etiquetado obligatorio
│   ├── Canales específicos
│   ├── Temporales para contenido nuevo
│   └── Canales ocultos para contenido sensible
├── Gestión de filtraciones
│   ├── Protocolo de eliminación
│   ├── Contacto con plataformas
│   ├── Investigación de fuente
│   └── Comunicación con comunidad
├── Gestión de impersonación
│   ├── Verificación oficial
│   ├── Etiquetas de verified dev
│   ├── Reporte a plataformas
│   └── Ban de impersonadores
├── Gestión de copyright claims
│   ├── Política de contenido de fans
│   ├── Directrices de atribución
│   ├── Sistema de reporte de infracción
│   └── Respuesta a claims de terceros
└── Comunicación proactiva
    ├── Actualizaciones periódicas
    ├── Anuncios de hitos
    ├── Comunicación de retrasos
    ├── AMAs ocasionales
    └── Showcases de contenido
```

## 2. Documento de reglas comunitarias

**Archivo: res://community/rules.md (documento para sitio web)**

**Estructura:**
```markdown
# Reglas Comunitarias de Isla Ancestral

## Principios fundamentales
- Respeto mutuo
- Comunidad acogedora y inclusiva
- Comunicación constructiva

## Reglas específicas
1. Sin contenido tóxico, discriminación o acoso
2. Spoilers deben etiquetarse correctamente
3. Contenido NSFW está prohibido
4. No spam ni autopromoción excesiva
5. Respetar derechos de autor
6. No impersonar desarrolladores oficiales
7. Expectativas realistas sobre el desarrollo
8. Feedback constructivo es bienvenido

## Consecuencias
- Primera ofensa: advertencia
- Segunda ofensa: mute temporal (24-48 horas)
- Tercera ofensa: ban temporal (7 días)
- Cuarta ofensa: ban permanente

## Apelación
- Sistema de apelación para bans injustificados
- Contacto: community@islaancestral.com
```

## 3. Sistema de moderación

**Roles en Discord:**
```json
{
  "roles": {
    "admin": {
      "permissions": ["all"],
      "color": "#FF0000",
      "hoist": true
    },
    "mod": {
      "permissions": ["moderate", "timeout", "ban", "manage_reports"],
      "color": "#00FF00",
      "hoist": true
    },
    "helper": {
      "permissions": ["respond", "report", "basic_moderate"],
      "color": "#0000FF",
      "hoist": false
    },
    "usuario": {
      "permissions": ["participate", "report"],
      "color": "#FFFFFF",
      "hoist": false
    }
  }
}
```

**Logs de acciones:**
```json
{
  "action_log": {
    "timestamp": "2026-08-19T03:53:00Z",
    "moderator": "admin",
    "action": "ban",
    "target_user": "usuario123",
    "reason": "contenido tóxico",
    "duration": "permanent"
  }
}
```

## 4. Sistema de reportes

**Categorías de reportes:**
```json
{
  "report_categories": {
    "toxic": "Contenido tóxico (acoso, discriminación, spam)",
    "spoiler": "Spoilers no etiquetados",
    "nsfw": "NSFW inapropiado",
    "impersonation": "Impersonación",
    "copyright": "Copyright infringement",
    "other": "Otro (con descripción)"
  }
}
```

**Workflow de reportes:**
1. Usuario reporta contenido (selecciona categoría, describe)
2. Sistema notifica a moderadores (notificación en canal #mod-logs)
3. Moderador revisa reporte (accede a contenido reportado)
4. Moderador toma acción (advertencia, mute, ban, nada)
5. Sistema notifica al usuario que reportó (acción tomada)
6. Sistema notifica al usuario reportado (si aplica acción)
7. Sistema loggea acción (action_log)

## 5. Canales de feedback

**Canales en Discord:**
- #bugs: reportar bugs y problemas técnicos
- #sugerencias: proponer ideas y mejoras
- #preguntas: dudas sobre el juego
- #off-topic: conversación general
- #anuncios: anuncios oficiales del desarrollo
- #faq: preguntas frecuentes (solo lectura)
- #changelog: changelog de actualizaciones (solo lectura)
- #roadmap: roadmap público (solo lectura)

**Canales en Steam:**
- Steam Community Hub - Discusiones
- Steam Community Hub - Bugs y Problemas
- Steam Community Hub - Sugerencias

**Canales en redes sociales:**
- Twitter/X: @IslaAncestral (respuestas a preguntas, encuestas)
- Reddit: r/IslaAncestral (subreddit dedicado, AMAs ocasionales)

## 6. Roadmap público

**Formato de roadmap:**
```json
{
  "roadmap": {
    "version": "1.0",
    "last_updated": "2026-08-19",
    "milestones": [
      {
        "id": "M1",
        "title": "Prototipo",
        "category": "Core Gameplay",
        "status": "Completado",
        "description": "Prototipo vertical slice con mecánicas core"
      },
      {
        "id": "M2",
        "title": "Alpha",
        "category": "Content",
        "status": "En desarrollo",
        "description": "Alpha con contenido base del juego"
      },
      {
        "id": "M3",
        "title": "Beta",
        "category": "Technical",
        "status": "Planeado",
        "description": "Beta con optimización y polish"
      },
      {
        "id": "M4",
        "title": "Lanzamiento",
        "category": "Polish",
        "status": "Futuro",
        "description": "Lanzamiento 1.0 del juego"
      }
    ]
  }
}
```

## 7. Changelog público

**Formato de changelog (Keep a Changelog):**
```markdown
# Changelog de Isla Ancestral

## [1.0.0] - 2026-08-19

### Added
- Sistema de crafting con 9 herramientas
- Sistema de construcción de casas
- 13 biomas procedurales
- Sistema de NPCs y amistad

### Changed
- Mejoras de rendimiento en vegetación
- Optimización de streaming de chunks

### Fixed
- Bug de guardado/carga de savegames
- Bug de colisión en puentes
- Bug de audio 3D en interiores

### Removed
- Sistema de combate (posible DLC futuro)
```

## 8. Respuesta a dudas

**SLA de 48 horas:**
- Dudas simples: respuesta en 24 horas
- Dudas complejas: respuesta en 48 horas
- Dudas técnicas: escalado a desarrolladores si necesario

**Base de conocimiento (FAQ):**
```json
{
  "faq": {
    "general": [
      {
        "question": "¿Cuándo sale el juego?",
        "answer": "No tenemos fecha de lanzamiento confirmada. Estamos trabajando duro en el desarrollo y anunciaremos cuando esté listo. Síguenos en Discord o Twitter para actualizaciones."
      },
      {
        "question": "¿En qué plataformas estará disponible?",
        "answer": "Planeamos lanzar inicialmente en PC (Steam). Otras plataformas se evaluarán después del lanzamiento."
      }
    ],
    "technical": [
      {
        "question": "¿Qué requisitos de sistema necesito?",
        "answer": "Requisitos mínimos: Windows 10/11, Intel i5-6500 / AMD Ryzen 3 1200, 8GB RAM, GTX 1050 Ti / RX 570. Requisitos recomendados: Windows 10/11, Intel i7-8700K / AMD Ryzen 5 3600, 16GB RAM, GTX 1660 / RX 5600 XT."
      }
    ]
  }
}
```

## 9. Identificación de bugs reportados

**Sistema de triage de bugs:**
```json
{
  "bug_triage": {
    "categories": {
      "critical": "Juego no se puede jugar, crash al inicio",
      "major": "Funcionalidad importante rota",
      "minor": "Funcionalidad menor rota",
      "trivial": "Cosmético, no afecta gameplay"
    },
    "verification": {
      "reproducible": "Puede reproducirse consistentemente",
      "not_reproducible": "No puede reproducirse con información disponible"
    }
  }
}
```

**Workflow de triage:**
1. Usuario reporta bug en #bugs o Steam
2. Moderador o desarrollador revisa reporte
3. Se verifica si es reproducible
4. Se categoriza según severidad
5. Si es bug válido, se crea issue en M102 (Bug Tracking)
6. Si no es bug, se explica al usuario por qué

## 10. Recopilación de sugerencias

**Categorización de sugerencias:**
```json
{
  "suggestion_categories": {
    "gameplay": "Mecánicas de juego, balance, progresión",
    "ui": "Interfaz de usuario, UX, accesibilidad",
    "content": "Contenido adicional, historia, NPCs",
    "technical": "Rendimiento, optimización, features técnicas",
    "performance": "FPS, tiempos de carga, uso de memoria"
  }
}
```

**Evaluación de sugerencias:**
```json
{
  "suggestion_evaluation": {
    "aligned": "Alineado con visión del juego",
    "feasible": "Factible de implementar con recursos actuales",
    "out_of_scope": "Fuera de alcance para v1.0, posible DLC futuro"
  }
}
```

## 11. Gestión de expectativas

**Directrices de comunicación:**
- No prometer fechas irreales
- Comunicar hitos genéricos en lugar de fechas específicas
- Ser transparente sobre retrasos cuando ocurran
- Establecer expectativas realistas desde el inicio
- Comunicar cambios de dirección cuando sean necesarios

**Ejemplos de comunicación:**
- "Estamos trabajando en la siguiente actualización. No tenemos fecha confirmada, pero esperamos anunciar más información pronto."
- "Hemos encontrado un bug crítico que necesitamos resolver antes del lanzamiento. Agradecemos su paciencia mientras trabajamos en esto."
- "Hemos decidido cambiar la dirección de una feature basándonos en feedback de la comunidad. Más información en el roadmap actualizado."

## 12. Gestión de críticas

**Directrices para moderadores:**
- Distinguir entre críticas constructivas y destructivas
- Responder a críticas constructivas con agradecimiento
- Ignorar o moderar críticas destructivas (sin alimentar trolls)
- Aprender de críticas válidas
- Documentar feedback recurrente para mejora

**Ejemplos de respuestas:**
- Crítica constructiva: "Gracias por tu feedback. Tomaremos en cuenta tu sugerencia para futuras actualizaciones."
- Crítica destructiva: (sin respuesta o moderación si viola reglas)

## 13. Gestión de contenido tóxico

**Definición de contenido tóxico:**
- Acoso: ataque personal repetido
- Discriminación: comentarios basados en raza, género, orientación sexual, religión, etc.
- Odio: lenguaje de odio, amenazas
- Spam: contenido repetitivo sin valor
- NSFW: contenido sexualmente explícito o gráfico

**Acciones de moderación:**
- Primera ofensa: advertencia (warning) en DM
- Segunda ofensa: mute temporal (24-48 horas)
- Tercera ofensa: ban temporal (7 días)
- Cuarta ofensa: ban permanente

## 14. Gestión de spoilers

**Etiquetado de spoilers:**
- Discord: usar ||texto|| para ocultar spoilers
- Steam: usar [SPOILER] en título del post
- Redes sociales: usar #spoiler o contenido de texto sin spoilers

**Canales específicos:**
- Discord: #story-spoilers (solo visible con rol)
- Steam: secciones separadas para spoilers

**Temporales para contenido nuevo:**
- 30 días post-lanzamiento: spoilers permitidos en canales generales con etiquetado
- Después de 30 días: spoilers permitidos sin restricciones

## 15. Gestión de filtraciones

**Protocolo de filtraciones:**
1. Identificar contenido filtrado (assets, builds, código)
2. Eliminar contenido inmediatamente
3. Contactar plataforma para takedown (DMCA si aplica)
4. Investigar fuente de filtración (si es posible)
5. Comunicar con comunidad que el contenido no es oficial

**Plantilla de DMCA:**
```
Subject: DMCA Takedown Request - Isla Ancestral

Dear [Platform],

I am writing to request the removal of unauthorized content from our game Isla Ancestral. The content at [URL] is infringing our copyright and was not authorized for distribution.

Please remove this content immediately.

Sincerely,
[Developer Name]
[Contact Information]
```

## 16. Gestión de impersonación

**Verificación oficial:**
- Etiquetas de verified dev en Discord (color especial, icono)
- Cuentas oficiales verificadas en Steam (developer badge)
- Listado de cuentas oficiales en sitio web

**Protocolo de reporte:**
- Reportar cuenta de impersonación a plataforma (Discord, Steam, Twitter/X)
- Comunicar con comunidad sobre cuentas oficiales
- Ban inmediato de impersonadores en canales oficiales

## 17. Gestión de copyright claims

**Política de contenido de fans:**
- Fan art: permitido con atribución al desarrollador
- Fan music: permitido con atribución al desarrollador
- Fan fiction: permitido con atribución al desarrollador
- Videos del juego: permitido (let's plays, streams) con monetización
- Mods: permitidos en v1.0 (framework de modding opcional futuro)

**Directrices de atribución:**
- "Fan art by [Usuario] - Isla Ancestral by [Desarrollador]"
- "Fan music cover of [Canción] - Original by [Desarrollador]"

## 18. Comunicación proactiva

**Cadencia de actualizaciones:**
- Mensual: estado general del desarrollo
- Cuando haya hitos importantes: anuncio específico
- Cuando haya retrasos significativos: comunicación transparente

**Canales de comunicación:**
- Discord: #anuncios (solo desarrolladores)
- Steam: Announcements
- Twitter/X: @IslaAncestral
- Sitio web: blog/updates

**AMAs ocasionales:**
- Cadencia: cada 3-6 meses
- Formato: preguntas y respuestas en Discord o Reddit
- Duración: 1-2 horas
- Reglas: preguntas respetuosas, sin spoilers

**Showcases de contenido:**
- Cadencia: cada 1-2 meses
- Formato: videos o GIFs de contenido en desarrollo
- Plataformas: Twitter/X, YouTube, Discord
- Contenido: features en desarrollo, arte, música, efectos
