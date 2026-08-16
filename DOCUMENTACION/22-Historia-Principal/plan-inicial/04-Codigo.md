# 04 — Código — M22: Historia Principal

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/Story/HistoriaPrincipal.cs` | Nodo raíz del grafo; resolver estado y puertas |
| `Assets/_Project/Scripts/Story/Capitulo.cs` | Subgrafo por capítulo (requisitos, siguiente) |
| `Assets/_Project/Scripts/Story/Escena.cs` | Nodo: tipo, requisitos, ramas, hooks (M33/M41) |
| `Assets/_Project/Scripts/Story/Finales.cs` | Finales (principal, 3 alternativos, secreto) y condiciones |
| `Assets/_Project/Scripts/Story/Misterio.cs` | Revelaciones, pistas, foreshadowing (pagos únicos) |
| `Assets/_Project/Scripts/Story/ValidadorGuion.cs` | Editor + tests: grafo, anti-exposición, leaks |
| `Assets/_Project/Scripts/Data/Historia/*.json` | Todo el contenido del arco serializado |

## API clave (borrador)

```csharp
public class HistoriaPrincipal : MonoBehaviour
{
    public Capitulo Actual;
    public event Action<Capitulo> OnCapituloCambio;
    public bool RequisitosCumplidos(Escena e);   // consulta M21/misiones + mundo
    public void Avanzar();                        // si requisitos → siguiente nodo
    public FinalEnum ElegirFinal(bool selloPerfecto, bool salasSecretas);
}

public class ValidadorGuion
{
    public static List<string> Validar(Graph g);  // nodos/requisitos/leaks/exposición
}
```

## Reglas de implementación (para quien concrete)

1. Historia = datos JSON; el código solo resuelve nodos y requisitos (M21/misiones consulta).
2. Los 7 sellos son la llave de los capítulos 4+; el final secreto exige sello perfecto + 4 salas (M26/M66).
3. El test de guion corre en CI: grafo válido, sin exposición excesiva, sin pistas sin pagar.
4. Los hooks de M33/M41/M44 son eventos (sin acoplarse a cine/música).
5. No tocar M23 (secundarias) ni M26 (templo) — solo sus datos/hooks.
6. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 22 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 25/25 puntos de la sección 21 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: requiere M21 (misiones) y M28 (caminos) para implementar; los sellos de M26 y los templos M24/M25/M26 son sus recursos.
- Clave: grafo de escenas validado + 7 sellos como gating real + anti-exposición medible.
- Al implementar, actualizar fila 22 del CHECKLIST-GLOBAL y crear el Log correspondiente.