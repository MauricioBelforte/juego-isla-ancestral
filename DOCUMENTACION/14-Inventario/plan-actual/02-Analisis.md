**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo Code

# 02-Analisis.md — Módulo 14: Inventario

## 1. Resolución de los 24 puntos del plan maestro (sección 13)

| # | Punto | Resolución |
|---|---|---|
| 1 | Diseñar inventario | Bolsillo grid 4x6 (24 slots) estilo Animal Crossing + almacenamiento doméstico separado; gestión por contenedores y no por peso |
| 2 | Cantidad de slots | Bolsillo 24 iniciales; mochila +16 (40); almacenamiento doméstico 60 ampliable a 120; cofres colocables 16-40; almacén del pueblo 240 |
| 3 | Peso o ausencia de peso | Sin peso (decisión cozy): el límite lo dan slots + stack máx. Unificar con RF8 para no frustrar la recolección |
| 4 | Stack máximo | 99 recursos base, 10 medianos, 1 únicos (herramientas, muebles, objetos clave, regalos empaquetados); espóras de luz 999 |
| 5 | Categorías | 9 categorías con pestañas y contadores; la categoría nace del ItemData (campo `category`) |
| 6 | Ordenamiento | Sort por categoría, rareza, nombre (localizado) o fecha de obtención; favoritos quedan al frente y fijos |
| 7 | Filtros | Filtro por pestaña de categoría + búsqueda por texto + visto solo favoritos |
| 8 | Favoritos | Toggle por slot (tecla rápida + pin visual); los favoritos nunca se mueven al ordenar ni se apilan encima |
| 9 | Tooltip | Hover con delay 0.5 s: nombre, rareza, descripción, precio base, recetas del ítem (M16) y cantidad global poseída |
| 10 | Selección rápida | Atajos 1-6 para hotbar + rueda del mouse para ciclar; asignación por arrastre o por hover + tecla |
| 11 | Hotbar | Barra fija de 6 slots en la parte inferior, siempre visible, con contador de cantidad y durabilidad restante de herramientas (M13) |
| 12 | Almacenamiento doméstico | Cofre principal de la casa (M18): 60 slots, se amplía con cada expansión; accesible desde el interior de la casa |
| 13 | Cofres | Cofres colocables (M17) de 16/28/40 slots según material; id único persistente en el mundo |
| 14 | Almacenes | Almacén comunitario del pueblo: 240 slots compartidos, desbloqueable temprano, pensado para regalar/exponer colecciones |
| 15 | Mochila | Mejora simple: +16 slots; se compra u obtiene como regalo al progresar la amistad (M20); sin múltiples tallas confusas |
| 16 | Mejoras de capacidad | Ruta corta y rara: casa (60→120) y mochila (24→40); sin decenas de compras incrementales |
| 17 | Iconos | Atlas de iconos por categoría (una hoja 256) para un único draw call; borde de color por rareza |
| 18 | Estados bloqueados | Slots con candado hasta desbloquear la mecaánica: crafteo, comercio, colecciones; tooltip explica cómo desbloquear |
| 19 | Feedback de inventario lleno | Aviso al 80%; al 100% el botín queda en el mundo con marca visual; notificación amable con sugerencia de guardar en casa |
| 20 | Transferencia rápida | Un botón/tecla mueve el stack completo entre paneles (bolsillo ↔ contenedor) |
| 21 | Transferencia múltiple | Mover cantidad personalizada con spinner o mantener-click + rueda; también "mover todo lo de esta categoría" |
| 22 | Separación de stacks | Dividir un stack en cantidad exacta (tecla + prompt rápido con prefill de la mitad) |
| 23 | Sistema de descarte | Arrastrar fuera del inventario o tecla de soltar; ítems caen al suelo como pickup (se pueden recuperar) |
| 24 | Confirmación de objetos importantes | Diálogo de confirmación con mínimo 2 clicks para herramientas, regalos, espóras de luz y objetos de misión; sin "descartar sin querer" posible |

## 2. Decisiones clave

1. **Bolsillo + almacenamiento en casa (modelo Animal Crossing), no mochila infinita**: la gestión entre bolsillo y casa es el ciclo cozy por excelencia y da ritmo de juego; el almacenamiento crece con la casa (progresión tangible).
2. **Grid de slots en vez de lista**: el grid con espacios fijos permite estados visuales (favorito, bloqueado), drag & drop directo y hotbar natural. Las listas se reservan para casos puntuales como la bandeja de correo.
3. **Sin peso, con límites de slots y stack**: el peso (como en Stardew) penaliza y obliga a calcular; para un cozy sin combate el límite por slots es más simple de entender y nunca requiere matemáticas.
4. **Ítems como datos, no como nodos**: un ItemData (Resource) + cantidad por slot; cero instanciación de escenas por ítem. Es lo que permite abrir el inventario en milisegundos y guardar/restaurar sin fricción (M59).
5. **Regla de oro anti-frustración**: un ítem jamás se pierde. Lleno → queda en el mundo, va a la bandeja, o se devuelve al origen; siempre recuperable.
6. **Favoritos anclados**: el sort nunca desordena lo que el jugador marcó; evita la pérdida de contexto al ordenar.
7. **Espóras de luz como ítem de colección global**: contador en diario (M55), vinculadas a las deidades y recetas ancestrales (M16); su rareza y el bloqueo de descarte la posicionan como ítem "preciado" del juego.

## 3. Alternativas descartadas

- **Inventario por lista simple (tipo Zelda clásico)**: no escala bien a cientos de ítems recolectables ni permite drag & drop visual; descartado a favor del grid.
- **Inventario con peso (modelo Stardew/Minecraft)**: obliga a gestión aritmética y frustra la recolección; contradice el principio cozy del proyecto; descartado.
- **Inventario único global (todos los ítems en un solo contenedor virtual con búsqueda)**: elimina el ciclo bolsillo/casa, una de las fantasías centrales de Animal Crossing, y hace irrelevante la mochila y los cofres; descartado.
- **Un contenedor por categoría (pescas, recursos, herramientas separados)**: agrega fricción (hay que saber dónde está todo) y complica el crafting y las transferencias; descartado: un inventario único con pestañas de filtro logra el mismo orden sin la fricción.
- **Ítems como escenas instanciadas en runtime**: costo alto de instanciación y de guardado; descartado (ver decisión 4).