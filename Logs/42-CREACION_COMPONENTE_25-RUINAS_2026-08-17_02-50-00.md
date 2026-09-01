# Log 42 — Creación del Componente 25: Ruinas (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Hora:** 02:50

## Descripción breve

Se documentó el **Módulo 25 — Ruinas** en `DOCUMENTACION/25-Ruinas/` como módulo **delegable**. Resuelve los 25 puntos de la sección 24: kit modular de ≤ 40 piezas reutilizables con validación automática, 13 tipos de ruinas (chozas, templos, ciudades antiguas, observatorios, faros, puentes, jardines, bibliotecas, talleres, etc.), cámaras secretas y pasajes ocultos, 12 murales, 30-60 glifos, 25 objetos arqueológicos, 8 sistemas de activación reutilizables y progresión de descubrimiento en 4 estados.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | Problema, objetivos, alcance, restricciones |
| `plan-inicial/02-Analisis.md` | 25/25 puntos resueltos; 4 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | Kit, 13 tipos, murales/glifos/objetos, activadores, progresión, conexiones |
| `plan-inicial/04-Codigo.md` | Archivos propuestos, API, validación en Editor + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **100 ítems**, 100 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M25 → 🟢 Disponible, 100/100, **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 25 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 42.

## Decisiones

- **Kit modular ≤ 40 piezas** con pivote/snaps validados en Editor (fallo ⇒ no build); los 13 tipos se arman por combinación.
- **Progresión de descubrimiento en 4 estados** persistidos con guardado atómico y eventos (diario, mapa, museo M36).
- **Sin interiores innecesarios** (solo donde la exploración los amerita) y **sin geometría por región** (3 paletas de época cubren la variedad visual).
- **Cámaras secretas con 2+ caminos** y pistas ambientales (anti-arbitrariedad M24, cofre M66).
- **8 sistemas de activación reutilizables** anclados al framework emisor→receptor de M24 (las reglas viven en datos).
- Conexiones entre ruinas por **caminos de 2-4 tramos** validados con NavigationServer3D (M28/M08).