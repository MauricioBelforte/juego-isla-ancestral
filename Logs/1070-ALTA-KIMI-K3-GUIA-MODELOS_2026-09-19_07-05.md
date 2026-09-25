# Log 1070: Alta de Kimi K3 en guia comparativa de modelos (§5.P)

**Fecha:** 2026-09-19
**Hora:** 07:05
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen
El usuario confirmo que **Kimi K3 (Moonshot AI) esta disponible para trabajar**. Investigue
sus capacidades en fuentes oficiales y di de alta la ficha §5.P en la guia comparativa —
la pieza que faltaba, ya que K3 tenia autoevaluacion propia (§14, 2026-09-04) y aparece
como referencia en la tabla de Tencent, pero no estaba en el catalogo §5.

## Cambios Realizados
- **Ficha §5.P completa** con specs verificadas en `github.com/MoonshotAI/Kimi-K3` (README
  oficial) + `platform.kimi.ai/docs/guide/kimi-k3-quickstart` + `/docs/pricing/chat`:
  - 2.8T params / 104B activos — **primer open-weight clase 3T**; 896 expertos, 16 por
    token + 2 shared; 93 capas; KDA + AttnRes + Stable LatentMoE (~2.5x K2)
  - Contexto 1.048.576; MoonViT-V2 (401M); MXFP4/MXFP8 quantization-aware
  - Precios: input $0.30 cache hit / $3.00 miss, **output $15.00 = el mas caro del
    catalogo** (3.4x GLM 5.3); acceso requiere top-up min $1
  - **25+ benchmarks tabulados** con comparacion contra los modelos del catalogo
- **Veredicto honesto:** K3 es el **coder agentic mas fuerte disponible hoy** (TB 2.1
  **88.3** > Nex 82.7 > Atria 78.3 > Hy3 71.7; MCPMark 94.5 #1) con contexto 1M y vision
  nativa (respaldo de Agnes 3 en QA visual). **NO** para: batch documental (caro),
  orquestacion de MCPs (Atria #1 BFCL 77.0/AutomationBench 53.8), investigacion web
  (Atria #1 y web search oficial de K3 no recomendada), QA cruzado §21.8 (Hy3), arte (Hy4).
- **Caveats documentados:** todos los benchmarks vendor-reported con harness propio (Kimi
  Code); DeepSWE baja a 67.3 con mini-SWE-agent; thinking siempre on; preservar
  reasoning_content + tool_calls en multi-turn; proactividad excesiva declarada; licencia
  Kimi K3 License != MIT; sin validacion independiente al 2026-09-19.
- **Actualizadas** matriz comparativa, tabla de capacidades (nueva fila "sesiones de
  contexto masivo"), flujo de delegacion (paso 14) y reglas de asignacion (complejidad
  4-5 y 3 + entrada propia + lista de descartes 4→5 modelos).
- **Modelos disponibles: 4 → 5** (Agnes 3, Hy3, MiMo V2.5, Atria Dawn, Kimi K3).

## Corrección posterior (2026-09-19 07:20) — el costo NO es criterio de asignación

El usuario aclaró la filosofía del proyecto: **todos los modelos activos se usan por acceso
gratuito por tiempo limitado** (Kilo Code / OpenCode / WorkBuddy / OpenRouter free tier);
la idea es **aprovechar al máximo sus capacidades mientras estén disponibles**, sin
optimizar costo. Mi recomendación inicial ("no usar K3 para batch documental porque su
output es el más caro") era **incorrecta para este proyecto** y se corrigió:

- El pricing queda en la ficha §5.P como **dato de referencia para trazabilidad**, no como
  criterio de asignación.
- Se eliminó la prohibición de "no usar para batch documental" — K3 es **plenamente apto**
  para documentación masiva (su contexto 1M + razonamiento lo favorecen).
- La regla de asignación, el flujo de delegación y la matriz comparativa se reescribieron
  en consecuencia (7 ediciones).
- Si a futuro el proyecto pasa a modelos de pago, recién ahí el pricing vuelve a importar.

**Modelos disponibles: 4 → 5** (Agnes 3, Hy3, MiMo V2.5, Atria Dawn, Kimi K3).

## Archivos Modificados/Creados
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — ficha §5.P + headers + matriz +
  capacidades + delegacion + reglas
- `Logs/NUMEROS_DISPONIBLES.txt` (numero 1070 consumido)

## Fuentes (todas oficiales de Moonshot AI)
- `https://github.com/MoonshotAI/Kimi-K3` — README: arquitectura, tabla completa de
  benchmarks, despliegue (vLLM/SGLang/TokenSpeed), licencia
- `https://platform.kimi.ai/docs/guide/kimi-k3-quickstart` — vision, tools, reasoning
  effort, limites operativos, FAQ
- `https://platform.kimi.ai/docs/pricing/chat` — tabla de precios exacta
- Autoevaluacion previa del propio modelo: §14 (2026-09-04, `qwencloud/kimi-k3` / Kilo Code)
