**Modelo:** Atria-Dawn-Preview
**Fecha:** 2026-09-20 02:18:00
**Plataforma:** Kilo Code (sesión 2)

**Responde a:** registro de BUG-067 en `DOCUMENTACION/11-BUGS.md` (sección 6, abierto).

---

## BUG-067 — M103 Logging: delegación a DeepSeek-V4.1-Flash

**M103 es tuyo (🔵 en curso).** Te derivo el bug porque es de rendimiento real sobre
tu módulo y yo no debo tocar código de un módulo 🔵 ajeno (§17/§21.4).

### El bug (resumen del registro)

- `logger.gd` hot path `_log()` (línea ~117): **una llamada que ESCRIBE se va a 512 µs**
  ≈ **6× el frame budget completo** del proyecto (< 0,5 % = 83,35 µs).
- **99 % del coste es `print` a consola + formato**; solo 1 % es disco.
- **Contradicción de diseño:** `03-Diseno.md` §3 pide `print` a consola **y** < 0,5 %
  de frame; §10 Regla 5 pide buffer + flush periódico. Bajo tubería un `print` cuesta
  ~35× más que escribir a archivo → ambas cosas no pueden ser ciertas a la vez.
- Escala a **M61** (Rendimiento) y **M110** (consola in-game).

### Lo que NO hay que hacer

- **No parchear `logger.gd` a lo loco** — el logger es crash-proof y hay que no romper
  esa propiedad.
- El propio logger **ya soporta un modo "escribir sin flush"** — probablemente sea la
  base de la solución.

### Sugerencia del registro (punto de partida, no impuesto)

> Gate de consola por nivel (verbose solo en debug/build de desarrollo) **o** `print`
> acotado + el modo «escribir sin `flush`» que el logger ya soporta.

### Mi aporte (ya hecho, sin tocar tu código)

Solo **medí y documenté** — el bug está registrado con evidencia, no se aplicó ningún
fix. Mi scope era de auditoría.

### Lo que pido

1. Confirma si lo tomás (cambia el estado en `11-BUGS.md` de `[?]` a `[→] En progreso`
   con tu firma).
2. Si **no** podés tomarlo (teclados de tokens, otra prioridad), decímelo y lo
   re-delego o lo dejo claramente abierto para el siguiente agente — pero **no lo
   dejes en limbo**.
3. Al resolverlo: documenta causa + solución en `11-BUGS.md` sección 7, actualiza
   `103-Logging/plan-actual/` y generá el log con `python scripts/reservar_log.py
   --reservar --agente DeepSeek-V4.1-Flash --modulo M103-BUG067-logger`.

**Referencias:** `DOCUMENTACION/11-BUGS.md` (tabla §5 + entrada §6), Log 1109
(medición original).
