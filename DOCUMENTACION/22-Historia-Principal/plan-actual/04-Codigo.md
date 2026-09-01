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

---

## Notas del Agente — Iteración 1 núcleo data (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 22:20:00
**Estado:** Parcial (núcleo data-driven implementado y verificado; módulo liberado 🟡)

### Lo que hice
- Grafo de historia data-driven `data/historia/historia_principal.json` v1: 12 nodos (prólogo + C1-C7 + 4 finales), campos Escena {id, capitulo, titulo, tipo, resumen, requisitos[], siguiente[]}, catálogo de 7 sellos, finales [principal, regresar, guardian, secreto] según 03-Diseno §Arcos/§Secuencia.
- HistoriaService autoload (`scripts/historia/story_manager.gd`, sección "historia" en M59): puede_entrar con requisitos verificables (capítulo previo / sellos / flag WorldState M21 / objeto M14), completar_nodo con re-validación (M66), marcar_sello → EventBus.quest.prereq_met (contrato M07), siguientes_disponibles, finales_alcanzables, capitulo_actual.
- Validador de grafo `scripts/historia/validar_historia.gd` (patrón DialogGraphValidator M21): sin huérfanos, sin retroceso de capítulo (DAG), 4 finales alcanzables desde prólogo, requisitos bien formados, catálogo sellos = declarado → **0 fallos**.
- Test headless `scripts/historia/test_historia.gd`: **0 fallos** (carga, progresión lineal, gating sellos con motivos, flags WorldState, 4 finales, round-trip persistencia).
- Regresión M21 (test_condiciones_mundo): 0 fallos.
- Checklist relevado: 37/100 [x].

### Lo que NO pude hacer (honestidad obligatoria)
- Contenido narrativo real (diálogos por escena, 30 pistas, 10 foreshadows como datos jugables): el JSON lleva títulos/resúmenes mínimos; la escritura es iteración con dueño (recomiendo DeepSeek/escritura + QA de guion).
- Cutscenes (M33), música (M41/M44), eclipse (M31), caminos M28: flags preparados pero sin hooks.
- El flag "templo_brisa_abierto" y "pistas_secreto_completas" esperan que M26/M25/M147 los activen vía WorldState.set_flag.

### Recomendaciones para el próximo agente
- Escribir escenas completas extendiendo el JSON (requisito "resumen" ≤ 140 palabras, regla anti-exposición 03-Diseno).
- M26 debe llamar HistoriaService.marcar_sello(id) al validar cada sala (y set_flag templo_brisa_abierto en la apertura del templo).
- M23 (secundarias) puede leer capitulo_actual() para los comentarios-hook sin bloquear el grafo.
