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