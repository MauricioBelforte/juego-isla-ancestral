**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Arquitectura de Menús (`menu-architecture`) — Módulo 145

> **División de responsabilidades (AGENTS.md §9):** este documento define las **reglas de experiencia** de los menús. El diseño de las 21 pantallas del shell, perfiles y ajustes es de **M89 (Diseño de Menús)**; la infraestructura runtime es de **M53 (UI/UX, en curso)**. Aquí no se duplica su contenido.

## 1. Reglas de experiencia (transversales)

1. **Máximo 3 niveles de profundidad** en cualquier flujo de menús (Regla: 1 menú → 2 sección → 3 detalle; el detalle nunca abre otro submenú).
2. **Botón "Volver"** siempre presente y consistente: `Esc`/`B` retrocede un nivel; en nivel 1, `Esc` abre la confirmación de salida (nunca cierra el juego directamente).
3. **Foco visible siempre** (M53 MenuNavigator con wrap-around); el estado del foco se conserva al volver.
4. **Transiciones** de ≤ 200 ms con fade suave (cozy); prohibidos los cortes secos o zooms bruscos.
5. **La pausa congela el mundo** (decisión de M89) y nunca abre durante cutscenes críticas.
6. **Sin dead-ends:** todo flujo tiene salida visible (Volver/Guardar/Continuar).
7. **Búsqueda/filtrado** en listas largas (catálogo M159, diario M55, colecciones M37): filtro por categoría + orden alfabético/reciente; sin paginación infinita.

## 2. Estructura esperada (resumen; detalle en M89)

### Menú principal (5 opciones)
```
[ Continuar ]  (solo si hay partida activa)
[ Nueva partida ]  → selección perfil 1-3 × slot 3-6 (M89)
[ Cargar ]
[ Opciones ]
[ Salir ]
```

### Menú in-game (8 opciones)
```
[ Reanudar ]
[ Diario ]         (M55)
[ Mapa ]           (M54)
[ Inventario ]     (M14)
[ Colecciones ]    (M37)
[ Opciones ]
[ Guardar/Salir ]  (guardado visible, M59)
[ Créditos/Ayuda ]
```

### Configuración (4 categorías, M89/M90/M91/M58)
```
[ Gráficos ] [ Audio ] [ Controles ] [ Accesibilidad y Jugabilidad ]
```

## 3. Mapa de navegación (flujo entre menús)

```
Principal ⇄ Cargar ⇄ Perfiles
Principal → Opciones ⇄ (4 categorías) ⇄ detalle
Principal → Nueva partida → Perfiles → (juego)
Juego (Esc) ⇄ In-game ⇄ Diario/Mapa/Inventario/Colecciones (overlays, no reemplazan escena)
In-game → Opciones (mismo árbol que Principal, con "Reanudar" primero)
```

## 4. Atajos de teclado frecuentes (base; remapeo en M57)

| Acción | Atajo | Nota |
|---|---|---|
| Menú in-game | `Esc` | Retrocede nivel a nivel |
| Diario | `J` | Overlay |
| Mapa | `M` | Overlay |
| Inventario | `I` / `Tab` | Overlay |
| Interacción | `F` | Contextual (M70) |
| Hotbar | `1-9` + rueda | M13 |
| Captura/brújula rápida | `Tab` doble (gamepad: view) | referencia rápida |

Regla: todo atajo es remapeable (M57) y se muestra en prompts dinámicos por dispositivo (teclado/gamepad, M57).

## 5. Flujo de guardado/carga (experiencia)

1. Guardar: siempre explícito o por hitos (autosave M59); indicador de "Guardando…" **no bloqueante** (regla §8 AGENTS).
2. Cargar: lista de slots con fecha/hora, estación y mini-resumen (día 12 · Primavera · 4 h jugadas).
3. Nunca se sobrescribe un slot sin confirmación si la partida destino fue jugada < 24 h.
4. Sin miedo: guardar siempre es posible (M152, guardados confiables).

## 6. Accesibilidad en menús

- Entrada de accesibilidad **primera clase** en Opciones (M58): tamaño de texto (6 tamaños, M53 ThemeUx), alto contraste, reducción de movimiento, remapeo.
- Navegación 100 % por teclado/gamepad y 100 % por puntero (equivalencia completa).
- Toda opción tiene tooltip explicativo (M53 TooltipService) y efecto inmediato visible.

## 7. Wireframes de referencia (2 pantallas críticas)

```
┌ PRINCIPAL ────────────────┐        ┌ IN-GAME (Esc) ─────────────┐
│      (arte de fondo)      │        │ ▸ Reanudar                 │
│                           │        │   Diario      Mapa         │
│ ▸ Continuar               │        │   Inventario  Colecciones  │
│   Nueva partida           │        │   Opciones    Guardar/Salir│
│   Cargar                  │        │   Créditos/Ayuda           │
│   Opciones                │        │ (mundo pausado y visible)  │
│   Salir                   │        └────────────────────────────┘
└───────────────────────────┘
```

Wireframes completos por pantalla: evolucionan en M89 (21 pantallas shell); este módulo define que **ningún wireframe nuevo puede romper las reglas §1**.

## 8. Testing de navegación

Con jugadores: sesiones de 10 min "encuentra X en los menús" (ver `plan-testing-experiencia.md`), objetivo: 100 % de tareas completadas sin ayuda. Iteración registrada en M89/M53.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
