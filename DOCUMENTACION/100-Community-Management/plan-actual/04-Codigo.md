**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 100: Community Management

## 1. Carácter del Componente

Módulo de **Community Management** que define la gestión de comunidad del juego Isla Ancestral. Este módulo es principalmente documental y de procesos, con algunos scripts de automatización para Discord/Steam. No requiere implementación de código en el juego (Godot), pero sí requiere configuración de plataformas externas (Discord, Steam, redes sociales).

**06-Plan-Testings.md:** NO APLICA (módulo de procesos y documentación, sin código de gameplay)

## 2. Archivos involucrados (implementación)

```
community/
├── rules.md                                    → Reglas comunitarias (documento para sitio web)
├── roles.json                                  → Configuración de roles de moderación
├── report_categories.json                       → Categorías de reportes
├── faq.json                                    → Base de conocimiento (FAQ)
├── roadmap.json                                 → Roadmap público
├── changelog.md                                 → Changelog público (Keep a Changelog)
├── communication_guidelines.md                 → Directrices de comunicación
├── moderation_protocol.md                      → Protocolo de moderación
├── dmca_template.txt                            → Plantilla de DMCA
└── official_accounts.md                         → Listado de cuentas oficiales

scripts/
├── discord_setup.py                            → Script de configuración de Discord (opcional)
├── steam_announcement.py                       → Script para publicar anuncios en Steam (opcional)
└── report_analyzer.py                           → Script para analizar reportes (opcional)

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M99 (Marketing):** Información sobre comunidad para campañas de marketing
- **M102 (Bug Tracking):** Bugs reportados por comunidad integrados en sistema de tracking
- **M101 (QA General):** Feedback de comunidad integrado en QA

### Entrada (desde otros módulos)
- **M99 (Marketing):** Campañas de marketing que requieren soporte comunitario
- **M102 (Bug Tracking):** Información sobre bugs resueltos para changelog
- **M101 (QA General):** Información sobre testing para roadmap

### Configuración
- `community/rules.md` define reglas comunitarias
- `community/roles.json` define roles y permisos
- `community/faq.json` define base de conocimiento

## 4. Implementación de rules.md (esqueleto)

```markdown
# Reglas Comunitarias de Isla Ancestral

## Principios fundamentales
- Respeto mutuo
- Comunidad acogedora e inclusiva
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

## 5. Implementación de roles.json (esqueleto)

```json
{
  "roles": {
    "admin": {
      "permissions": ["all"],
      "color": "#FF0000",
      "hoist": true,
      "description": "Administrador con control total"
    },
    "mod": {
      "permissions": ["moderate", "timeout", "ban", "manage_reports"],
      "color": "#00FF00",
      "hoist": true,
      "description": "Moderador con permisos de moderación"
    },
    "helper": {
      "permissions": ["respond", "report", "basic_moderate"],
      "color": "#0000FF",
      "hoist": false,
      "description": "Helper con permisos básicos de moderación"
    },
    "usuario": {
      "permissions": ["participate", "report"],
      "color": "#FFFFFF",
      "hoist": false,
      "description": "Usuario regular con permisos de participación"
    }
  }
}
```

## 6. Implementación de report_categories.json (esqueleto)

```json
{
  "report_categories": {
    "toxic": {
      "name": "Contenido tóxico",
      "description": "Acoso, discriminación, odio, spam",
      "severity": "high"
    },
    "spoiler": {
      "name": "Spoilers no etiquetados",
      "description": "Contenido de historia sin etiquetar",
      "severity": "medium"
    },
    "nsfw": {
      "name": "NSFW inapropiado",
      "description": "Contenido sexualmente explícito o gráfico",
      "severity": "high"
    },
    "impersonation": {
      "name": "Impersonación",
      "description": "Pretender ser desarrollador oficial",
      "severity": "high"
    },
    "copyright": {
      "name": "Copyright infringement",
      "description": "Contenido que viola derechos de autor",
      "severity": "high"
    },
    "other": {
      "name": "Otro",
      "description": "Otros problemas (con descripción)",
      "severity": "low"
    }
  }
}
```

## 7. Implementación de faq.json (esqueleto)

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
      },
      {
        "question": "¿Habrá multijugador?",
        "answer": "Isla Ancestral está diseñado como una experiencia single-player en v1.0. Multijugador es una característica que podríamos evaluar para expansiones futuras, pero no está en el roadmap actual."
      }
    ],
    "technical": [
      {
        "question": "¿Qué requisitos de sistema necesito?",
        "answer": "Requisitos mínimos: Windows 10/11, Intel i5-6500 / AMD Ryzen 3 1200, 8GB RAM, GTX 1050 Ti / RX 570. Requisitos recomendados: Windows 10/11, Intel i7-8700K / AMD Ryzen 5 3600, 16GB RAM, GTX 1660 / RX 5600 XT."
      },
      {
        "question": "¿El juego soporta controladores?",
        "answer": "Sí, soportamos controladores Xbox, PlayStation y Switch Pro (a través de Steam Input). También soportamos input de teclado y ratón."
      }
    ],
    "gameplay": [
      {
        "question": "¿El juego tiene combate?",
        "answer": "El combate es completamente opcional en Isla Ancestral. Puedes jugar todo el juego sin combatir, enfocándote en exploración, construcción, agricultura, pesca, minería, y relación con NPCs."
      },
      {
        "question": "¿Hay permadeath?",
        "answer": "No, no hay permadeath. Cuando mueres, reapareces en tu casa con toda tu inventario intacto. La filosofía del juego es cozy y sin castigos irreversibles."
      }
    ]
  }
}
```

## 8. Implementación de roadmap.json (esqueleto)

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
        "description": "Prototipo vertical slice con mecánicas core",
        "completion_date": "2026-08-15"
      },
      {
        "id": "M2",
        "title": "Alpha",
        "category": "Content",
        "status": "En desarrollo",
        "description": "Alpha con contenido base del juego",
        "estimated_completion": "cuando esté listo"
      },
      {
        "id": "M3",
        "title": "Beta",
        "category": "Technical",
        "status": "Planeado",
        "description": "Beta con optimización y polish",
        "estimated_completion": "futuro"
      },
      {
        "id": "M4",
        "title": "Lanzamiento",
        "category": "Polish",
        "status": "Futuro",
        "description": "Lanzamiento 1.0 del juego",
        "estimated_completion": "futuro"
      }
    ]
  }
}
```

## 9. Implementación de changelog.md (esqueleto - Keep a Changelog)

```markdown
# Changelog de Isla Ancestral

Todos los cambios notables en este proyecto se documentarán en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- (nada aún)

## [1.0.0] - 2026-08-19

### Added
- Sistema de crafting con 9 herramientas
- Sistema de construcción de casas
- 13 biomas procedurales
- Sistema de NPCs y amistad
- Sistema de agricultura, pesca y minería
- Sistema de transporte y navegación
- Sistema de fast travel

### Changed
- Mejoras de rendimiento en vegetación
- Optimización de streaming de chunks
- Mejoras de accesibilidad (tamaño de fuente, alto contraste)

### Fixed
- Bug de guardado/carga de savegames
- Bug de colisión en puentes
- Bug de audio 3D en interiores
- Bug de NPCs atascados en puertas

### Removed
- Sistema de combate (posible DLC futuro)
```

## 10. Implementación de communication_guidelines.md (esqueleto)

```markdown
# Directrices de Comunicación de Isla Ancestral

## Principios fundamentales
- Honestidad y transparencia
- Comunicación amigable y profesional
- Respuesta oportuna (SLA de 48 horas)
- Gestión de expectativas realistas

## Respuesta a dudas
- SLA: 48 horas máximo para respuesta
- Dudas simples: 24 horas
- Dudas complejas: 48 horas
- Dudas técnicas: escalado a desarrolladores si necesario

## Respuesta a críticas
- Críticas constructivas: responder con agradecimiento
- Críticas destructivas: ignorar o moderar si viola reglas
- Documentar feedback recurrente para mejora

## Comunicación de expectativas
- No prometer fechas irreales
- Comunicar hitos genéricos en lugar de fechas específicas
- Ser transparente sobre retrasos cuando ocurran
- Establecer expectativas realistas desde el inicio

## Comunicación proactiva
- Mensual: estado general del desarrollo
- Hitos importantes: anuncios específicos
- Retrasos significativos: comunicación transparente
- AMAs: cada 3-6 meses
- Showcases: cada 1-2 meses
```

## 11. Implementación de moderation_protocol.md (esqueleto)

```markdown
# Protocolo de Moderación de Isla Ancestral

## Sistema de reportes
1. Usuario reporta contenido (selecciona categoría, describe)
2. Sistema notifica a moderadores
3. Moderador revisa reporte
4. Moderador toma acción (advertencia, mute, ban, nada)
5. Sistema notifica al usuario que reportó
6. Sistema notifica al usuario reportado (si aplica acción)
7. Sistema loggea acción

## Acciones de moderación
- Primera ofensa: advertencia (warning)
- Segunda ofensa: mute temporal (24-48 horas)
- Tercera ofensa: ban temporal (7 días)
- Cuarta ofensa: ban permanente

## Contenido tóxico
- Acoso: ataque personal repetido
- Discriminación: comentarios basados en raza, género, orientación sexual, religión, etc.
- Odio: lenguaje de odio, amenazas
- Spam: contenido repetitivo sin valor
- NSFW: contenido sexualmente explícito o gráfico

## Sistema de apelación
- Usuario puede apelar ban injustificado
- Contacto: community@islaancestral.com
- Revisión por admin
- Respuesta en 7 días
```

## 12. Implementación de dmca_template.txt (esqueleto)

```
Subject: DMCA Takedown Request - Isla Ancestral

Dear [Platform Name],

I am writing to request the removal of unauthorized content from our game Isla Ancestral. The content at [URL] is infringing our copyright and was not authorized for distribution.

The copyrighted work is the video game "Isla Ancestral" developed by [Developer Name]. The unauthorized content includes [description of content, e.g., assets, builds, code, leaked footage].

I have a good faith belief that the use of the copyrighted material described above is not authorized by the copyright owner, its agent, or the law.

I declare that the information in this notification is accurate and, under penalty of perjury, that I am the copyright owner or am authorized to act on behalf of the owner of an exclusive right that is allegedly infringed.

Please remove this content immediately.

Sincerely,
[Developer Name]
[Contact Information: email@islaancestral.com]
[Website: https://islaancestral.com]
```

## 13. Implementación de official_accounts.md (esqueleto)

```json
{
  "official_accounts": {
    "discord": {
      "server_id": "DISCORD_SERVER_ID",
      "developer_role_id": "DEVELOPER_ROLE_ID",
      "verified_developers": ["USER_ID_1", "USER_ID_2"]
    },
    "steam": {
      "developer_id": "STEAM_DEVELOPER_ID",
      "community_url": "https://steamcommunity.com/app/APPID"
    },
    "twitter": {
      "handle": "@IslaAncestral",
      "verified": true
    },
    "reddit": {
      "subreddit": "r/IslaAncestral",
      "moderators": ["MOD_USER_1", "MOD_USER_2"]
    },
    "youtube": {
      "channel": "IslaAncestral",
      "verified": true
    }
  }
}
```

## 14. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear community/rules.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/roles.json | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/report_categories.json | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/faq.json | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/roadmap.json | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/changelog.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/communication_guidelines.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/moderation_protocol.md | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/dmca_template.txt | **IMPLEMENTACIÓN INMEDIATA** |
| Crear community/official_accounts.md | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar servidor de Discord con roles y canales | **IMPLEMENTACIÓN MANUAL** |
| Configurar Steam Community Hub | **IMPLEMENTACIÓN MANUAL** |
| Crear cuentas oficiales en redes sociales | **IMPLEMENTACIÓN MANUAL** |
| Integrar con M102 (Bug Tracking) para bugs reportados | **M102 (Bug Tracking)** |
| Integrar con M99 (Marketing) para campañas | **M99 (Marketing)** |
| Integrar con M101 (QA General) para feedback | **M101 (QA General)** |

## 15. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 03:53:00
**Estado:** Completado (especificación; implementación manual requerida)

### Lo que hice
- Resolví los 17 puntos de la sección 99 del plan maestro.
- Definí reglas comunitarias (respeto, spoilers, contenido tóxico, copyright, impersonación, expectativas).
- Definí sistema de moderación con roles (Admin, Mod, Helper, Usuario) y permisos.
- Definí sistema de reportes con categorías (tóxico, spoiler, NSFW, impersonación, copyright, otro).
- Definí canales de feedback estructurados (Discord, Steam, redes sociales).
- Definí roadmap público (opcional) con hitos genéricos sin fechas irreales.
- Definí changelog público con formato Keep a Changelog.
- Definí sistema de respuesta a dudas con SLA de 48 horas y FAQ.
- Definí sistema de identificación de bugs reportados con triage e integración con M102.
- Definí sistema de recopilación de sugerencias con categorización e integración con M102.
- Definí directrices de gestión de expectativas (no prometer fechas irreales, hitos genéricos).
- Definí directrices de gestión de críticas (constructivas vs destructivas).
- Definí protocolo de gestión de contenido tóxico (advertencia, mute, ban).
- Definí protocolo de gestión de spoilers (etiquetado, canales específicos, temporales).
- Definí protocolo de gestión de filtraciones (eliminación, takedown, comunicación).
- Definí protocolo de gestión de impersonación (verificación oficial, etiquetas, ban).
- Definí protocolo de gestión de copyright claims (política de contenido de fans, atribución).
- Definí comunicación proactiva (actualizaciones periódicas, anuncios, AMAs, showcases).
- Diseñé estructura de archivos para configuración de comunidad (rules.md, roles.json, etc.).
- Diseñé scripts opcionales para automatización (discord_setup.py, steam_announcement.py, report_analyzer.py).

### Lo que NO pude hacer (honestidad obligatoria)
- Configurar servidor de Discord (requiere acceso manual a Discord)
- Configurar Steam Community Hub (requiere acceso manual a Steamworks)
- Crear cuentas oficiales en redes sociales (requiere creación manual)
- Implementar bots de moderación automática (requiere configuración de Discord)
- Implementar integración real con M102 (Bug Tracking) - es solo diseño de integración

### Recomendaciones para el primer agente (implementador)
- Crear los archivos de configuración en community/ (rules.md, roles.json, etc.)
- Configurar servidor de Discord con roles, canales y bots de moderación
- Configurar Steam Community Hub con secciones de discusión, bugs y sugerencias
- Crear cuentas oficiales en Twitter/X, Reddit, YouTube
- Publicar reglas comunitarias en todos los canales
- Implementar sistema de reportes en Discord (usar bots como Dyno, Carl-bot, etc.)
- Crear FAQ en sitio web y en Steam Community Hub
- Crear roadmap público en sitio web y en Steam Community Hub
- Establecer cadencia de actualizaciones (mensual o cuando haya hitos)
- Entrenar moderadores en protocolos de moderación
- Integrar sistema de reportes con M102 (Bug Tracking) si es posible
- Establecer sistema de apelación para bans injustificados
- Documentar todas las interacciones relevantes con la comunidad
