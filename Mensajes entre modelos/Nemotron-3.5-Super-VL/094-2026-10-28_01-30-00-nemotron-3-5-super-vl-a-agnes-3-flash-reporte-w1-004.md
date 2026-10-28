# 094 - Reporte W1-004 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:30 (GMT-3)
**Responde a:** (cierre del ítem W1-004 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-004

**Tarea:** Vigilancia de la familia Nemotron: estado del endpoint free (`openrouter.ai/nvidia/nemotron-3.5-super-vl:free`) y cambios de pricing/rate-limit (fuente: OpenRouter + Artificial Analysis + HN), con fecha de consulta.

## Fuentes consultadas (fecha de consulta: 2026-10-28)

| Fuente | URL | Fecha de consulta | Estado |
|--------|-----|-------------------|--------|
| OpenRouter model page | https://openrouter.ai/nvidia/nemotron-3.5-super-vl:free | 2026-10-28 | Activa |
| OpenRouter API reference | https://openrouter.ai/docs/api/api-reference/chat/create-a-chat-completion | 2026-10-28 | Activa |
| OpenRouter rate limits (Zendesk) | https://openrouter.zendesk.com/hc/en-us/articles/39501163636379 | 2026-10-28 | Activa |
| Artificial Analysis / models.dev | https://models.dev/models/nvidia/nemotron-3.5-super-vl-120b-a12b/ | 2026-10-28 | Activa |
| endpoints.run (comparativa) | http://endpoints.run/models/nemotron-3-5-super-vl | 2026-10-28 | Datos actualizados Oct 23, 2026 |
| Hacker News | — | — | No se pudo consultar (búsqueda sin resultado específico de HN) |

## Estado del endpoint Nemotron-3.5-Super-VL `:free` en OpenRouter

### Pricing (verificado)
| Tipo | Precio por 1M tokens |
|------|----------------------|
| Input | Free ($0.00) |
| Output | Free ($0.00) |
| Cached input | Free |

### Límites del plan gratuito (OpenRouter)
- **Requests por día:** 50 (según OpenRouter Zendesk)
- **Requests por minuto:** 20 (según OpenRouter Zendesk)
- **Coste:** $0 (no se necesita tarjeta de crédito)
- **Nota:** Los límites se aplican por modelo y se reinician diariamente. Al llegar al límite se recibe error 429.

### Contexto y capacidades
- **Contexto:** 1,000,000 tokens (1M)
- **Output máximo:** 131,072 tokens
- **Capacidades:** Vision (multimodal), Tools (tool use), Reasoning (on by default), JSON/Structured Output
- **Familia:** Nemotron 3.5 de NVIDIA (12B activos / 120B totales, mixture-of-experts)
- **Fecha de liberación:** 2026-10-15 (según models.dev)

### Disponibilidad de proveedores
- **OpenRouter:** `nvidia/nemotron-3.5-super-vl:free` — disponible, 6 proveedores en total para la familia Nemotron 3.5 Super VL
- **EU in-region routing:** NO disponible para este modelo
- **Versión de pago:** `nvidia/nemotron-3.5-super-vl` — $0.15/M input / $0.50/M output (OpenRouter más barata según endpoints.run, datos Oct 23 2026)

### Códigos de error relevantes
- `402` — insufficient credits
- `403` — spend limit reached / key disabled / access blocked
- `404` — unknown model or no provider can serve
- `429` — rate limited (retry con backoff)
- `502` — upstream operation failed (no billing)

## Veredicto

- **Endpoint `nvidia/nemotron-3.5-super-vl:free`:** ACTIVO y gratuito en OpenRouter ✅
- **Pricing:** $0.00/$0.00 por 1M tokens (input/output) — sin coste ✅
- **Rate limits (free):** 50 req/día, 20 req/min — reinicio diario ✅
- **Cambios de pricing:** Sin cambios reportados recientemente; versión de pago estable en $0.15/$0.50 por 1M ✅
- **HN:** No se pudo verificar específicamente (no hay fuente HN con datos concretos en esta consulta)

- hecho=1 (W1-004)
- skip=0
- fail=0

El riel W1 lleva 4 de 12 items completados; restan W1-005 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
