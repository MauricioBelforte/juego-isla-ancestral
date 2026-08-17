**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 16: Crafting

## ID del Módulo
- **Código:** M16 (plan maestro: sección 15 — CRAFTING)
- **Carpeta:** `DOCUMENTACION/16-Crafting/`
- **Dependencias:** M14 (Inventario), M15 (Recursos), M13 (Herramientas), M17 (Construcción). Relaciones: M11 (interacciones/objetos interactuables), M20 (diálogos y NPCs), M37 (economía), M38 (tiendas), M29 (tiempo/clima/estaciones), M73 (festivales y eventos)
- **Stack:** Godot 4.x (≥4.4.1) + Voxel Tools (GDExtension) + GDScript
- **Naturaleza del juego:** cozy sin combate obligatorio; cero frustración; ritmo pausado

## 1. Problema

El jugador necesita transformar los recursos que recolecta (M15) en objetos útiles: herramientas (M13), mobiliario y decoración (M17), ropa/textiles, comida y objetos de progreso. Sin un sistema de crafting coherente, la isla no progresa: no hay formas de mejorar la casa, reparar herramientas ni encargar objetos a las deidades.

Los problemas a resolver son:

1. **Cómo definir recetas:** qué materiales, en qué cantidades, en qué estación se fabrica cada objeto.
2. **Cómo se desbloquean:** el jugador no debe saber todas las recetas desde el inicio; debe haber descubrimiento por experimentación y compra de recetas a NPCs (M20).
3. **Dónde se fabrica:** las recetas pertenecen a estaciones (mesa de trabajo, fogata, telar), no a un menú abstracto global.
4. **Cómo mantenerlo cozy:** sin tiempos de espera frustrantes ni intentos fallidos castigadores; el material consumido solo se gasta cuando la receta tiene éxito.
5. **Cómo evitar la redundancia:** cientos de recetas que no aportan nada rompen la sensación cozy y el balance (punto del plan maestro).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Banco de trabajo y estaciones | Estaciones de crafting físicas en el mundo voxel: mesa de trabajo, fogata (banco de trabajo avanzado) y telar. Cada una habilita un grupo de recetas |
| RF2 | Recetas | Definibles por datos (Resource): materiales, cantidades, resultado, estación requerida, nivel, categoría, origen de desbloqueo |
| RF3 | Categorías y niveles | Categorías: herramientas, estructura/mobiliario, textiles, cocina, decoración, ancestral, ocultas. Niveles de receta que escalan el progreso |
| RF4 | Desbloqueo por conocimiento | El jugador conoce recetas: por experimentación en estación (descubiertas) o compradas a NPCs (M20/M38). Persistente entre sesiones |
| RF5 | Recetas secretas, ancestrales, estacionales y regionales | Subgrupos con desbloqueo especial: experimentación avanzada, ofrendas a deidades, eventos de estación (M29/M73), regiones de la isla |
| RF6 | Crafting instantáneo | Sin barra de espera ni temporizadores: al confirmar, el resultado se entrega al instante (cozy, sin frustración) |
| RF7 | Creación individual | Crear 1 unidad de una receta por acción |
| RF8 | Creación múltiple | Botón de creación múltiple respetando el máximo posible con los materiales disponibles |
| RF9 | Preview | Vista previa del resultado (modelo 3D o icono) y del estado visual del objeto al construirlo |
| RF10 | Lista de materiales faltantes | La UI muestra en rojo lo que falta y los lugares de obtención (origen M15) |
| RF11 | Validación de materiales | Solo se consumen materiales si la receta completa está disponible; nunca se pierde material en un fallo |
| RF12 | Feedback sonoro y visual | Sonidos y efectos SFX/VFX de éxito y de material insuficiente; animación breve de creación (no bloqueante) |
| RF13 | Almacenamiento e integración | El resultado va al inventario (M14) o directamente al almacenamiento doméstico (M13/M14) si el inventario está lleno según política definida |
| RF14 | Economía alrededor del crafting | Recetas comprables como ítems (pergamino de receta); balance de costo de materiales (M37) |
| RF15 | Utilidad real por objeto | Todo objeto crafteable debe tener un uso real en el juego (herramienta, mobiliario, ingrediente, ofrenda, venta) sin recetas redundantes |
| RF16 | Interfaz de crafting | Panel con lista de recetas filtrada por estación, detalle de materiales, botones crear 1x / crear múltiple, cerrar panel |
| RF17 | Persistencia | Conocimiento de recetas, progresión y configuración guardados con el guardado del juego |
| RF18 | Sin combate | Cero requisitos de combate o daño; las herramientas se usan para recolectar, no para atacar |

## 3. Requisitos No Funcionales

- **Cozy:** sin tiempos de espera frustrantes; sin fallos destructivos; mensajes amables; cero presión de tiempo; el jugador puede pausar o irse en cualquier momento de la estación sin consecuencias.
- **Rendimiento (M61):** búsqueda de recetas por estación ≤ 1 ms con cache; cero picos de frame al abrir/cerrar la UI; la UI de crafting no consume recursos cuando está cerrada (pool de nodos en UI, cerrado por defecto).
- **Usabilidad:** la lista de materiales faltantes es clara; tooltips con origen de obtención; navegación 100 % con gamepad y teclado/mouse; fuente legible, sin ocultar información relevante.
- **Accesibilidad:** tamaño de textos ajustable (si el proyecto lo incorpora), contraste suficiente para materiales faltantes (rojo + icono, no solo color).
- **Determinismo suave:** resultados y descubrimientos por PRNG de partida (M29) para coherencia entre guardados.
- **Modularidad:** ningún script de gameplay dependiente de la capa de UI; CraftingService expone API y señales; la UI solo consume.
- **Compatibilidad:** Godot 4.x (≥4.4.1), sin Plugins de terceros para el sistema de crafting (solo GDScript + Resources); funciona offline.

## 4. Criterios de Aceptación

1. Los 25 puntos de la sección 15 del plan maestro quedan resueltos y documentados.
2. Tres estaciones funcionales (mesa de trabajo, fogata, telar) con sus grupos de recetas.
3. El crafting es instantáneo al confirmar; el material solo se consume en éxito.
4. El desbloqueo funciona por experimentación y por compra a NPCs; las recetas conocidas persisten entre sesiones.
5. Sin recetas redundantes: cada objeto crafteable justifica su existencia.
6. La interfaz muestra preview, materiales faltantes y creación individual/múltiple.
7. Los ítems del checklist (mínimo 110) están completados y con su marcador de esfuerzo.

## 5. Alcance

**Dentro del alcance:** diseño y especificación del sistema (documentación); definición de datos de recetas (estructura y catálogo inicial); integración con M13/M14/M15/M17; interfaz de crafting; feedback; persistencia del conocimiento.

**Fuera del alcance (se delega a otros módulos):** obtención de recursos y respawn (M15), sistema de inventario (M14), compraventa y precios finales (M37/M38), diálogos de NPCs (M20), construcción/demolición (M17), los assets artísticos (modelos voxel, sonidos) aunque se definen las firmas de assets necesarios.

## 6. Restricciones

- Stack fijo: Godot 4.x (≥4.4.1) + Voxel Tools + GDScript. No se permite C# ni plugins externos.
- Idioma de la UI: español (textos del juego en español).
- Sin temporizadores de crafting: se descarta cualquier sistema de cola con barra de progreso real.
- Sin degradación en experiencia si el jugador no recuerda una receta: la UI debe indicar que existe algo por descubrir, pero nunca bloquear la progresión principal.
- Los materiales se definen en M15; Crafting solo referencia IDs, no los define.
- El conocimiento de recetas no puede comprarse con moneda real; solo con moneda del juego.