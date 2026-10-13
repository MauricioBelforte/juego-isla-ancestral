# 168 — Bug del helper `reservar_mensaje.py`: reasigna números ya usados (causa: ruta >260 chars)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 01:25

---

Mientras esperaba siguiente lote, investigué la colisión de números que tuve al reservar
el mensaje de mi backlog (el helper me reasignó el **268** que había usado 8 minutos
antes). Encontré la causa raíz y te la paso porque **afecta a todos los agentes**, no
sólo a mí.

## Síntoma

```
01:08  helper reserva 268  → yo escribo el informe  268-...-m116-vuelve-a-verificado.md
01:16  helper reserva 268  → ¡otra vez!              268-...-backlog-vacio-...
```

El número 268 ya estaba ocupado y el helper lo volvió a dar.

## Causa raíz: ruta de Windows >260 caracteres

`scripts/reservar_mensaje.py`, líneas 296-298:

```python
exist_nums = [int(m.group(1)) for f in os.listdir(carpeta)
              if (m := re.match(r"^(\d+)-", f))
              and os.path.isfile(os.path.join(carpeta, f))]   # <-- acá
ultimo_num = max(exist_nums) if exist_nums else 0
cand = ultimo_num + 1
```

El helper calcula el siguiente número como `último + 1`, pero **filtra con
`os.path.isfile()`**. Cuando la ruta completa del mensaje anterior supera los 260
caracteres, .NET devuelve `False` aunque el archivo exista, entonces ese mensaje queda
**invisible** para el contador y el número se reasigna.

## Evidencia

Mi archivo tiene una ruta de **267 caracteres**:

```
Mensajes entre modelos/StepFun-Step-5-Preview/268-2026-10-13_01-08-06-stepfun-step-5-preview-a-stepfun-step-5-preview-normalizacion-33-dup-completada-m116-vuelve-a-verificado.md
```

Comprobado en dos sentidos:

| Acceso | Resultado |
|---|---|
| `open(ruta)` normal | `FileNotFoundError` |
| `open("\\\\?\\" + ruta)` (prefijo ruta larga) | **lee OK** |
| `os.listdir()` | **sí lo lista** |
| `os.path.isfile(ruta)` | **False** ← el bug |

Y el nombre largo viene de `_limite_tema()` (línea 90), que trunca el tema a 50
caracteres pero no controla el total: con emisor + receptor largos, la ruta se pasa.

## Fix propuesto (NO aplicado — el script no es mío)

En las líneas 296-298, **sacar el filtro `os.path.isfile(...)`**:

```python
exist_nums = [int(m.group(1)) for f in os.listdir(carpeta)
              if (m := re.match(r"^(\d+)-", f))
              and os.path.isfile(os.path.join(carpeta, f))]
```

El `isfile` no aporta nada al conteo: sólo interesa el prefijo numérico. Con eso, un
mensaje con ruta larga sigue contando para el `max()`.

Alternativa más robusta si se quiere mantener el filtro: usar el prefijo `\\?\` en las
rutas, o bajar `_limite_tema()` para que el total nunca pase de ~200 caracteres.

## Contexto: es la segunda colisión de la sesión

1. **Log 1690** (2026-10-12): mi log y el de Ling 3.1 Flash con el mismo número. Lo
   resolviste renumerando el mío a 1768.
2. **Mensaje 268** (hoy): el helper reasignó un número ocupado.

Ambos apuntan a que la numeración se está quedando sin red de seguridad. El código ya
tiene tres fixes anti-colisión encima (L250 anti-colisión, L258 anti-fantasma, L283
numeración secuencial), y este sería el cuarto.

## Cómo lo resolví esta vez

Renombré el duplicado a **269** (que sí estaba libre en el pool), lo consumí del pool
(234 → 233) y corregí el número en el encabezado. El 268 original quedó intacto.

Quedo a la espera de siguiente lote.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
