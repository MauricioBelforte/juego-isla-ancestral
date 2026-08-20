**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 126: Marketing Legal

## 1. Carácter del Componente

Módulo de **marketing legal** para revisión legal de marketing. Define derechos de screenshots, derechos de música, derechos de terceros, branding, influencers, contratos promocionales y giveaways. Implementable inmediatamente (depende de M78 para legal general, M99 para marketing, M128 para identidad de marca). Es un módulo de documentación legal y procesos.

**06-Plan-Testings.md:** NO APLICA (módulo de marketing legal, sin código de gameplay; tests pueden ser manuales de verificación legal)

## 2. Archivos involucrados (implementación)

```
legal/
└── marketing_legal_review.md                 → Revisión legal de marketing

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M78 (Legal General):** Revisión legal de marketing como parte del marco legal
- **M99 (Marketing):** Requisitos legales para marketing (disclosure, licencias)
- **M128 (Identidad de Marca):** Branding legal (logos, nombres, marcas registradas)

### Entrada (desde otros módulos)
- **M78 (Legal General):** Marco legal general para marketing
- **M99 (Marketing):** Plan de marketing para revisión legal
- **M128 (Identidad de Marca):** Branding para revisión legal

### Configuración
- `legal/marketing_legal_review.md` define revisión legal de marketing

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear legal/marketing_legal_review.md | **IMPLEMENTACIÓN INMEDIATA** |
| Verificar que screenshots sean legales para usar | **IMPLEMENTACIÓN MANUAL** |
| Verificar que música sea legal para usar en trailers | **IMPLEMENTACIÓN MANUAL** |
| Verificar licencias de fonts y software | **IMPLEMENTACIÓN MANUAL** |
| Verificar que branding no infrinja marcas registradas | **IMPLEMENTACIÓN MANUAL** |
| Verificar contratos con influencers | **IMPLEMENTACIÓN MANUAL** |
| Verificar contratos promocionales | **IMPLEMENTACIÓN MANUAL** |
| Verificar giveaways cumplan normativas locales | **IMPLEMENTACIÓN MANUAL** |
| Revisar con abogado | **IMPLEMENTACIÓN MANUAL** |

## 5. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 15:42:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Revisé derechos de screenshots (screenshots creados in-house son propiedad del desarrollador).
- Revisé derechos de música (música original del juego tiene licencia de uso para marketing).
- Revisé derechos de terceros (assets originales son propiedad del desarrollador; fonts y software tienen licencias).
- Revisé branding (nombre y logos creados in-house; verificar que no infrinja marcas registradas).
- Revisé influencers (contratos requieren disclosure FTC, pagos documentados).
- Revisé contratos promocionales (prensa y plataformas requieren revisión legal).
- Revisé giveaways (normativas locales FTC, GDPR, CAP Code).
- Diseñé marketing_legal_review.md con revisión legal de marketing.

### Lo que NO pude hacer (honestidad obligatoria)
- Verificar legalmente que screenshots sean legales para usar (requiere abogado)
- Verificar legalmente que música sea legal para usar en trailers (requiere abogado)
- Verificar legalmente licencias de fonts y software (requiere abogado)
- Verificar legalmente que branding no infrinja marcas registradas (requiere abogado/USPTO)
- Verificar legalmente contratos con influencers (requiere abogado)
- Verificar legalmente contratos promocionales (requiere abogado)
- Verificar legalmente giveaways cumplan normativas locales (requiere abogado)

### Recomendaciones para el primer agente (implementador)
- Crear marketing_legal_review.md con revisión legal de marketing.
- Verificar que screenshots sean legales para usar (abogado).
- Verificar que música sea legal para usar en trailers (abogado).
- Verificar licencias de fonts y software (abogado).
- Verificar que branding no infrinja marcas registradas (USPTO, EUIPO, abogado).
- Verificar contratos con influencers (abogado).
- Verificar contratos promocionales (abogado).
- Verificar giveaways cumplan normativas locales (abogado).
- Probar que screenshots sean legales para usar en marketing.
- Probar que música sea legal para usar en trailers.
- Probar que branding no infrinja marcas registradas.
- Probar que influencers disclosure cumpla FTC Guidelines.
- Probar que giveaways cumplan normativas locales.
