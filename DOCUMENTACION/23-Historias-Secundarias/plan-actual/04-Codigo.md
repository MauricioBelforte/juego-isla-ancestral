# 04 — Código — M23: Historias Secundarias

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/Story2/CadenaSecundaria.cs` | Modelo de cadena (pasos, recompensa, consecuencia) |
| `Assets/_Project/Scripts/Story2/CatalogoCadenas.cs` | Registro de las 60 cadenas (JSON) |
| `Assets/_Project/Scripts/Story2/ValidadorCadenas.cs` | Editor/CI: contexto, referencias, alcanzabilidad |
| `Assets/_Project/Scripts/Story2/Consecuencias.cs` | 12 consecuencias persistentes en estado de mundo |
| `Assets/_Project/Scripts/Story2/RecompensasNarrativas.cs` | Capítulos de diario + recetas de conversación |
| `Assets/_Project/Scripts/Story2/MisionesOcultas.cs` | Descubrimiento sin marcador |
| `Assets/_Project/Scripts/Story2/Postgame.cs` | 4 cadenas post-final |
| `Assets/_Project/Scripts/Data/HistoriaSec/*.json` | Contenido de todas las cadenas |

## API clave (borrador)

```csharp
public class CadenaSecundaria
{
    public string Id;
    public string Contexto;                 // obligatorio (anti-repetición)
    public List<Paso> Pasos;                // 3..5
    public Recompensa Recompensa;           // diario / cosmetico (nunca stats)
    public Consecuencia Consecuencia;       // estado de mundo
    public bool Oculta;
    public bool Postgame;
}

public class ValidadorCadenas
{
    public static List<string> Validar(CatalogoCadenas c);   // contexto/referencias/alcanzabilidad
}
```

## Reglas de implementación (para quien concrete)

1. Las cadenas viven en JSON; el validador corre en Editor y CI (falla ⇒ no build).
2. El campo `contexto` es obligatorio (anti-repetición dura); sin excepciones.
3. Las consecuencias se aplican vía hook a M68 (estado de mundo) y se persisten atómicamente.
4. Las recompensas narrativas/cosméticas son únicas (nunca duplicables — M66) y nunca otorgan stats.
5. Los diálogos posteriores se guardan por NPC + estado global (guardado atómico + `.bak`).
6. No tocar M22 (trama) ni M68 (ejecución) — solo contratos y datos.
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 23 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 25/25 puntos de la sección 22 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: requiere M68 (misiones) para ejecutar; se integra con M22, M25, M26, M32, M36, M37 y M66.
- Clave: catálogo de 60 cadenas con `contexto` obligatorio (anti-repetición dura) y 12 consecuencias persistentes.
- Al implementar, actualizar fila 23 del CHECKLIST-GLOBAL y crear el Log correspondiente.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 16:45:00
**Estado:** Parcial (motor + validador + cadenas ejemplo implementados y verificados; módulo liberado 🟡)

### Lo que hice
- SecondaryStoriesService autoload (scripts/historias/secondary_stories_service.gd): motor de cadenas del esquema del diseño — iniciar_cadena (ocultas/postgame gating), reportar_paso con validación de tipo y evidencia (hablar/explorar/puzzle/entregar), reportar_entrega que consume el objeto del inventario M14, _completar_cadena con consecuencia → WorldState M21 (flags tipo faro_encendido), recompensa.diario → M55 (registrada en la categoría misiones) y recompensa.cosmetico → quest_updated (M71 escucha), señales quest_started/quest_completed M07 (M55/M71 ya consumían).
- Validador anti-repetición (§regla dura): contexto no vacío (>=10 chars), pasos >= 3, tipos conocidos (hablar/explorar/puzzle/entregar), ids de paso únicos, recompensa/consecuencia presentes, títulos únicos. El catálogo base pasa limpio.
- Ocultas (§misiones ocultas): no figuran en cadenas_disponibles() hasta iniciarse; postgame (§postgame) requiere final_elegido de M22.
- Persistencia ISaveProvider M59 sección "secondary_stories" (activas + completadas; huérfanas purgadas).
- Catálogo data/historias/secundarias.json con 4 cadenas ejemplo (faro, invernadero, epílogo plaza postgame, luciérnagas secreta).
- Validador como script ejecutable: validar_cadenas() (para CI/editor — checklist QA).
- Test test_historias.gd: carga, validador, cadena completa (4 pasos con tipos mixtos + rechazo de tipo incorrecto + consecuencia aplicada + registro en M55), entrega con/sin objeto, ocultas, postgame (bloqueada sin final de M22, abre tras final), persistencia con huérfana → **0 fallos**.
- Regresiones: test_diario M55 0 fallos, test_progresion M71 0 fallos, test_historia M22 0 fallos.
- Checklist: 10 ítems [x] del núcleo relevados.

### Lo que NO pude hacer (honestidad obligatoria)
- Contenido narrativo de las 60 cadenas del catálogo (escritura con contexto real): 4 cadenas ejemplo entregadas; la escritura es iteración con dueño (recomiendo DeepSeek/narrativa).
- Diálogo posterior de NPCs (diálogo_posterior del esquema): requiere hooks M21 — con dueño.
- Recompensas cosméticas visibles (ropa/sombreros): requiere M53/M45 — la señal quest_updated ya emite.
- Consecuencias visuales del mundo (faro encendido visible): M17/M18/M27 — los flags de WorldState ya están aplicados.
- M68 (misiones: cada cadena como objetivos): M68 no existe; las señales quest_started/updated/completed ya siguen el contrato.
- Ejecución de pasos "puzzle" real: la ejecución del puzzle la hace M25/M26 (el motor valida evidencia); con dueño.

### Recomendaciones para el próximo agente
- Escritura de cadenas: seguir el esquema del 03-Diseno (contexto narrativo >= 10 chars — el validador rechaza "recoge N" genéricos); validar con validar_cadenas() antes de commit.
- M55: agregar la entrada "mision_{cadena_id}" al diario_catalog.json por cada cadena nueva (o extender M55 para auto-purgar categorías de cadenas).
- M25/M26: al implementar puzzles, reportar reportar_paso(cadena_id, "puzzle", ref) cuando el jugador resuelva el puzzle asociado.
- La evidencia de pasos se compara con _slug (minúsculas/sin tildes) — mantener ids ascii-plana.
