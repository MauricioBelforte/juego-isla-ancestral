# Prompt genérico — Actualización de documentación pendiente

---

## INSTRUCCIONES PARA TODOS LOS MODELOS

Este prompt es para **todos los modelos que trabajaron hoy** en el proyecto.

### El problema

Trabajaron en módulos pero **no actualizaron la documentación correspondiente**:
- No generaron `Logs/` con el formato AGENTS.md §6
- No actualizaron `plan-actual/04-Codigo.md` de su módulo
- No actualizaron `plan-actual/05-Checklist.md` de su módulo
- No contribuyeron a `DOCUMENTACION/07-GUIA-GODOT.md` si descubrieron algo nuevo

### Lo que tenés que hacer

1. **Leé TODO el chat de hoy** (2026-09-01) para entender qué hiciste
2. **Identificá tu módulo** en la tabla de abajo
3. **Completá CADA paso** que te corresponda

---

## Tabla de pendientes por modelo

| Modelo | Módulo(s) | ¿Qué falta? |
|---|---|---|
| **agnes-2.5-flash** | M64 IA de NPC + M74 Eventos | Log en `Logs/`, actualizar `plan-actual/04-Codigo.md` y `05-Checklist.md` de ambos módulos, contribuir a `07-GUIA-GODOT.md` si descubriste algo |
| **DeepSeek V4 Flash** | M17 Construcción | Log en `Logs/`, actualizar `plan-actual/` de M17, contribuir a `07-GUIA-GODOT.md` si descubriste algo |
| **minimax-m3-free** | M115 Hardware | Log en `Logs/`, actualizar `plan-actual/04-Codigo.md` y `05-Checklist.md` de M115 |

> **Nota:** ox-alpha ya no está disponible. M107, M159 y M20 quedan pendientes de reasignación.

---

## Formato de Log (AGENTS.md §6)

Crear archivo en `Logs/` con nombre: `NN-DESCRIPCION_BREVE_AAAA-MM-DD_HH-MM-SS.md`

Contenido mínimo:
```markdown
# Log NN: Descripción breve

**Fecha:** 2026-09-01
**Hora:** HH:MM (hora real de creación)
**Modelo:** [tu nombre]
**Plataforma:** [tu plataforma]

## Resumen
[Qué hiciste]

## Cambios Realizados
[Detalle de archivos creados/modificados]

## Archivos Modificados/Creados
[Lista]
```

**Paso 1:** Leer `Logs/ULTIMO_NUMERO.txt` → obtener número actual (N)
**Paso 2:** Crear archivo con N+1
**Paso 3:** Actualizar `ULTIMO_NUMERO.txt` con el nuevo número

---

## Formato de plan-actual/04-Codigo.md

Actualizar al inicio del archivo:
```
**Modelo:** [tu nombre]
**Plataforma:** [tu plataforma]
**Última actualización:** 2026-09-01
```

Agregar sección `## 5. Notas del Agente` al final si no existe:
```markdown
## 5. Notas del Agente

**Modelo:** [tu nombre]
**Plataforma:** [tu plataforma]
**Fecha:** 2026-09-01 HH:MM
**Estado:** [completado/parcial]

### Lo que hice
- [lista de archivos creados/modificados]

### Lo que NO pude hacer
- [lista honesta de pendientes]

### Recomendaciones para el próximo agente
- [cosas a tener en cuenta]
```

---

## Formato de plan-actual/05-Checklist.md

Actualizar al inicio del archivo:
```
**Modelo:** [tu nombre]
**Plataforma:** [tu plataforma]
**Fecha:** 2026-09-01
```

Marcar con `[x]` los ítems que completaste realmente (no "por hacer").

---

## 07-GUIA-GODOT.md — Contribución

Si durante tu trabajo descubriste:
- Un error de Godot que no estaba documentado
- Una buena práctica nueva
- Un truco o patrón útil
- Una limitación del motor

Agregalo como nueva §9.X al final de la sección correspondiente, con este formato:
```markdown
### §9.X [Título del descubrimiento]

[Descripción detallada del problema/descubrimiento]

**Solución:** [cómo se resuelve]

**Archivos relacionados:** `ruta/al/archivo.gd`

**Fecha:** 2026-09-01 · **Agente:** [tu nombre] ([plataforma])
```

Actualizar la firma al inicio de `07-GUIA-GODOT.md` con tu nombre y fecha.

---

## Reglas importantes

1. **Firmá SIEMPRE** con tu nombre y plataforma real
2. **Sé honesto** — si no pudiste hacer algo, poné `[?]` con explicación
3. **No inventes** — solo documentá lo que realmente hiciste
4. **Hora real** — usá la hora actual del sistema en el campo `Hora:` del log
5. **Numeración** — verificá que el número de log no exista antes de crearlo
