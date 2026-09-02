# 36-Fauna — Checklist (plan-actual)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02
**Reserva log:** 414 (QA cruzado)

> Estado verificado en QA cruzado (Log 414): núcleo coherente, tests 59/0,
> contrato M36↔M65 válido, fix deriva constantes aplicado. Los `[?]` restantes
> son trabajo con dueño en otros módulos (M09, M32, M45, M55/M37).

## A. Catálogo y datos (FaunaSpecies / FaunaCatalog)
- [x] FaunaSpecies define enum Comportamiento completo (6 valores) [S]
- [x] FaunaSpecies define enum Clase (4 valores) [S]
- [x] FaunaSpecies define enum Rareza (4 valores) [S]
- [x] FaunaSpecies define enum VentanaHoraria (5 valores) [S]
- [x] Campos @export presentes (id, display_name, bioma, rareza, etc.) [S]
- [x] es_valido() valida id no vacío [S]
- [x] es_valido() valida display_name no vacío [S]
- [x] es_valido() valida bioma_principal no vacío [S]
- [x] activa_en_hora(0-23) implementada para TODA_HORA [S]
- [x] activa_en_hora implementada para DIURNA (6-19) [S]
- [x] activa_en_hora implementada para NOCTURNA (<6 o >=19) [S]
- [x] activa_en_hora implementada para CREPUSCULAR (5-8 / 17-20) [S]
- [x] activa_en_hora implementada para ALBA (5-8) [S]
- [x] bioma_compatible compara bioma origen == bioma principal [S]
- [x] generar_factor_miedo_individual usa PRNG ±10% [S]
- [x] FaunaCatalog carga desde res://data/fauna/catalog.json [S]
- [x] FaunaCatalog usa fallback in-code si JSON no existe [S]
- [x] FaunaCatalog usa fallback si JSON vacío [S]
- [x] FaunaCatalog descarta JSON no-array con warning [S]
- [x] _especie_desde_dict mapea id/display_name/nombre_cientifico [S]
- [x] _especie_desde_dict mapea bioma/rareza/ventana/comportamiento/clase [S]
- [x] _especie_desde_dict mapea gregaria y manada min/max [S]
- [x] _especie_desde_dict mapea escala_min/max [S]
- [x] _especie_desde_dict mapea color_variantes (Color/Array/String) [S]
- [x] _especie_desde_dict mapea velocidades y radios [S]
- [x] manada_max >= manada_min garantizado (maxi) [S]
- [x] escala_max >= escala_min garantizado (maxi) [S]
- [x] obtener(id) devuelve Resource o null [S]
- [x] obtener_todas() devuelve Array [S]
- [x] cantidad() devuelve tamaño [S]
- [x] especies_por_bioma filtra por bioma [S]
- [x] candidatas_para filtra bioma + hora [S]
- [x] peso_por_rareza: COMUN=1.0 [S]
- [x] peso_por_rareza: POCO_COMUN=0.5 [S]
- [x] peso_por_rareza: RARA=0.25 [S]
- [x] peso_por_rareza: MUY_RARA=0.1 [S]
- [x] peso_por_rareza: default 0.5 [S]
- [x] _parsear_enum robusto ante nombre inválido [S]
- [x] _parse_color acepta Color directo [S]
- [x] _parse_color acepta Array RGB/A [S]
- [x] _parse_color acepta String [S]
- [x] _parse_color fallback Color.WHITE [S]

## B. Registro de descubrimiento (FaunaRegistry)
- [x] Autoload "fauna_registry" registrado en project.godot [S]
- [x] Sin class_name (autoload, §9.17) [S]
- [x] señal especie_avistada emitida [S]
- [x] señal especie_fotografiada emitida [S]
- [x] señal diario_cambio emitida [S]
- [x] enum EstadoEspecie (3 estados) [S]
- [x] registrar_avistamiento ignora id vacío [S]
- [x] Dedupe por instancia_id con has() explícito (fix Log 406) [S]
- [x] Dedupe ventana 30s (DEDUPE_TIEMPO_S) [S]
- [x] Tolerancia pantalla 0.5s mínima [S]
- [x] Distancia máxima 24m (DISTANCIA_AVISTAMIENTO_M) [S]
- [x] Estado NO_AVISTADA → AVISTADA en primer avistamiento [S]
- [x] Historial acumula contextos [S]
- [x] Contador de avistamientos por especie [S]
- [x] registrar_foto pasa a FOTOGRAFIADA [S]
- [x] estado_especie devuelve int [S]
- [x] porcentaje_descubierto = descubiertas/total [S]
- [x] encontrar_registrados filtra != NO_AVISTADA [S]
- [x] obtener_contexto_especie devuelve último [S]
- [x] total_avistamientos devuelve contador [S]
- [x] Registro en SaveManager vía register_provider (duck-typed) [S]
- [x] Reset dedupe en dia_cambio (M29) [S]
- [x] get_section_name devuelve SECCION_SAVE [S]
- [x] get_save_data serializa StringName→String [S]
- [x] get_save_data incluye version/estados/contador [S]
- [x] restore_save_data ignora version < VERSION [S]
- [x] restore_save_data reconstruye StringName [S]
- [x] guardar_local escribe JSON user:// [S]
- [x] cargar_local lee JSON si existe [S]
- [x] cargar_local valida tipo dict [S]
- [x] _tiempo_actual_s usa Time.get_ticks_msec (no reloj SO) [S]
- [x] Tolerancia/distancia usan constantes compartidas (fix Log 414) [S]

## C. Comportamiento (FaunaBehavior)
- [x] class_name FaunaBehavior (Node3D) [S]
- [x] enum Estado de 8 estados [S]
- [x] señal estado_cambiado [S]
- [x] señal solicitar_avistamiento [S]
- [x] señal solicitar_movimiento(destino, velocidad) [S]
- [x] _ready auto-registra en animal_ai si existe [S]
- [x] _exit_tree desregistra de animal_ai [S]
- [x] inicializar asigna especie y genera instancia_id [S]
- [x] inicializar genera factor_miedo individual [S]
- [x] inicializar arranca en DEAMBULAR [S]
- [x] set_pausa congela tick [S]
- [x] tick dispatchea por estado [S]
- [x] _tick_deambular: radio alarma → HUIDA (HUIDA_INSTINTIVA) [S]
- [x] _tick_deambular: radio alarma → ALERTA (otros) [S]
- [x] _tick_deambular: curiosidad → CURIOSA_ACERCARSE [S]
- [x] _tick_deambular emite solicitar_movimiento stub [S]
- [x] _tick_alimentarse vuelve a DEAMBULAR tras 5s [S]
- [x] _tick_descansar vuelve a DEAMBULAR tras 10s [S]
- [x] _tick_alerta → HUIDA si muy cerca [S]
- [x] _tick_alerta → DEAMBULAR si se aleja [S]
- [x] _tick_huida huye en dirección opuesta [S]
- [x] _tick_huida velocidad = velocidad_huida * factor_miedo [S]
- [x] _tick_huida vuelve a DEAMBULAR a distancia segura [S]
- [x] _tick_curiosa se acerca al jugador [S]
- [x] _tick_curiosa → OBSERVANDO_JUGADOR si muy cerca [S]
- [x] _tick_observando vuelve a DEAMBULAR tras 3s [S]
- [x] _procesar_avistamiento respeta tolerancia pantalla [S]
- [x] _procesar_avistamiento respeta distancia máx [S]
- [x] _procesar_avistamiento emite contexto [S]
- [x] cambiar_estado evita transición a sí mismo [S]
- [x] cambiar_estado emite estado_cambiado [S]
- [x] _on_dia_cambio ajusta estado según hora [S]
- [x] Connect dia_cambio con duck-typing [S]
- [x] Constantes de avistamiento referencian RegistryRef (fix Log 414) [S]

## D. Orquestación (FaunaManager)
- [x] Autoload "fauna" registrado en project.godot [S]
- [x] cargar catálogo en _ready [S]
- [x] rng randomizado [S]
- [x] set_process(true) para tick M65 [S]
- [x] cantidad_especies delega a catalog [S]
- [x] obtener_especie delega a catalog [S]
- [x] candidatas_para delega a catalog [S]
- [x] especie_aleatoria_para: muestreo ponderado por rareza [S]
- [x] especie_aleatoria_para: total<=0 → candidata[0] [S]
- [x] especie_aleatoria_para: null si sin candidatas [S]
- [x] porcentaje_descubierto delega a registry [S]
- [x] registrar_avistamiento_test util para tests [S]
- [x] total_avistamientos delega a registry [S]
- [x] candidatos_de_especie respeta gregaria [S]
- [x] candidatos_de_especie genera instancia_id única [S]
- [x] persistir llama guardar_local si existe [S]
- [x] _process llama animal_ai.tick con has_method [S]
- [x] _get_registry vía root.get_node_or_null [S]
- [x] _get_animal_ai vía root.get_node_or_null [S]

## E. Integración multi-módulo (validación cruzada Hy3)
- [x] M36→M65: registrar(self) coherente con m65_animal_ai.registrar(nodo) [S]
- [x] M36→M65: desregistrar(self) coherente [S]
- [x] M36→M65: solicitar_movimiento(destino,velocidad) coherente con _on_solicitar_movimiento [S]
- [x] M36→M65: FaunaManager._process llama animal_ai.tick(delta) [S]
- [x] M36←M29: dia_cambio conectado en registry y behavior [S]
- [x] M36←M59: register_provider duck-typed [S]
- [x] M36→M65: bind(instancia_id) en conexión de señal [S]
- [x] Sin acoplamiento duro a M65 (get_node_or_null) [S]

## F. Tests (test_fauna.gd)
- [x] Autoloads fauna/fauna_registry presentes en test [S]
- [x] _test_catalogo_basico >=5 especies [S]
- [x] _test_catalogo_json == 7 especies exactas [S]
- [x] _test_catalogo_json salamandra_ancestral existe [S]
- [x] _test_catalogo_json halcon_montana existe [S]
- [x] _test_especie_validacion conejo válido [S]
- [x] _test_especie_validacion conejo gregario [S]
- [x] _test_especie_validacion manada min=2 [S]
- [x] _test_especie_validacion huida>deambular [S]
- [x] _test_especie_validacion color_variantes>=1 [S]
- [x] _test_especie_validacion especie vacía inválida [S]
- [x] _test_especie_validacion factor miedo ±10% [S]
- [x] _test_ventana_horaria diurno/nocturno [S]
- [x] _test_ventana_horaria crepuscular salamandra [S]
- [x] _test_ventana_horaria toda_hora cangrejo [S]
- [x] _test_bioma_y_candidatas pradera mediodía=1 [S]
- [x] _test_bioma_y_candidatas pradera noche=0 [S]
- [x] _test_bioma_y_candidatas bosque_ancestral=1 [S]
- [x] _test_bioma_y_candidatas bioma inexistente=0 [S]
- [x] _test_pesos_por_rareza comun>rara>muy_rara [S]
- [x] _test_registry_avistamiento transición AVISTADA [S]
- [x] _test_registry_avistamiento dedupe <30s [S]
- [x] _test_registry_avistamiento distancia>24 ignorado [S]
- [x] _test_registry_avistamiento FOTOGRAFIADA [S]
- [x] _test_registry_dedupe tolerancia 0.1s ignorado [S]
- [x] _test_registry_dedupe válido aceptado [S]
- [x] _test_registry_persistencia version>=1 [S]
- [x] _test_registry_persistencia restore aplica [S]
- [x] _test_registry_persistencia version 0 ignorada [S]
- [x] _test_behavior_inicializacion especie asignada [S]
- [x] _test_behavior_inicializacion factor miedo ±10% [S]
- [x] _test_behavior_inicializacion estado DEAMBULAR [S]
- [x] _test_behavior_transiciones HUIDA_INSTINTIVA→HUIDA [S]
- [x] _test_behavior_transiciones vuelta a DEAMBULAR [S]
- [x] _test_behavior_transiciones CURIOSA→CURIOSA_ACERCARSE [S]
- [x] _test_behavior_factor_miedo 20/20 en rango [S]
- [x] _test_manager_aleatoria pradera mediodía=conejo [S]
- [x] _test_manager_aleatoria pradera noche=null [S]
- [x] _test_manager_aleatoria porcentaje 0 inicio [S]
- [x] _test_manager_aleatoria avistamientos incrementan [S]

## G. Edge cases / robustez
- [x] Catalogo corrupto no rompe arranque (fallback) [M]
- [x] Registry sin SaveManager no rompe [S]
- [x] Behavior sin animal_ai corre en stub [S]
- [x] Registry sin TimeCalendar no rompe [S]
- [x] dedup de avistamiento no bloquea primer avistamiento (fix Log 406) [S]
- [x] Restore de save con version antigua no sobreescribe [S]
- [ ] [M09] Spawner real con burbuja 72m y filtros bioma/hora [C] — dueño M09
- [ ] [M09] Caches de spawn por bioma [M] — dueño M09
- [ ] [M65] Movimiento real vía NavigationServer3D evitando voxels [C] — dueño M65
- [ ] [M32] Reacción de fauna a clima (lluvia/tormenta) [M] — dueño M32
- [ ] [M45] Modelos/meshes de animales [C] — dueño M45
- [ ] [M55/M37] UI de diario de fauna y museo [C] — dueño M55/M37
- [ ] [M65] Anti-stuck de manada/banco coordinado [M] — dueño M65

## H. Optimización
- [x] Muestreo ponderado O(n) lineal (aceptable para catálogo pequeño) [S]
- [x] duck-typing evita dependencias innecesarias [S]
- [ ] [M61] Presupuesto de simulación de individuos (M65 ya define 40) [M] — dueño M61/M65
- [ ] [M61] Pool de nodos para evitar alloc/free por frame [C] — dueño M61

## I. Documentación / polish
- [x] Comentarios de modelo/plataforma/fecha en cada archivo [S]
- [x] DOCUMENTACION/36-Fauna/plan-actual creada en QA (Log 414) [S]
- [x] 05-Checklist >= 100 ítems [S]
- [x] Log 414 de QA cruzado firmado [S]
- [ ] Crear plan-inicial/ como reversa histórica [M]
- [ ] Viñeta/tooltip de avistamiento en HUD (M53) [M] — dueño M53
- [ ] Sonidos de fauna contextuales (M43) [M] — dueño M43

## J. QA cruzado (Log 414 — Hy3 / Kilo Code)
- [x] Verificación estática de los 6 archivos [S]
- [x] Integridad de data/fauna/catalog.json (7 especies) [S]
- [x] Autoloads fauna/fauna_registry/animal_ai en project.godot [S]
- [x] Contrato API M36↔M65 validado [S]
- [x] Fix deriva constantes en fauna_behavior.gd [S]
- [x] Veredicto: mantiene 🟡 (resto con dueño externo) [S]

**Total:** 100+ ítems (x marcados; pendientes `[ ]` son trabajo con dueño en
otros módulos, verificados como legítimos en QA cruzado).
## Verificación + dados (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] test_fauna.gd oficial: 0 fallos (FaunaManager + FaunaRegistry autoloads, 7 especies)
- [x] `scripts/fauna/fauna_schema.gd` — FaunaSchema (validación de especie: id, bioma, rareza COMUN..MUY_RARA, clase enum real AEREA/ACUATICA/TERRESTRE/ANFIBIA, manada min<=max, escala, velocidades>0, radio_alarma<=radio_curiosidad, 2-3 colores)
- [x] `scripts/fauna/fauna_auditor.gd` — auditoría data-driven del catálogo → reporte tools/reportes/fauna_audit.txt, exit 0/1
- [x] **3 datos del catálogo corregidos** (detectados por la auditoría): conejo_pradera radio_curiosidad 3.0→6.0 (alarma>curiosidad era inconsistente); nutria_ribera y lechuza_bosque con 1 solo color → 2 variantes añadidas (2-3 requeridos)
- [x] Verificación VISUAL del catálogo (swatch analizado con visión): paleta coherente por especie/biotopo (gaviota blanca, conejo camuflaje, nutria chocolate, lechuza crema+beige, cangrejo barro, halcón gris-marrón, salamandra ancestral roja = rareza destacada), 2-3 variantes cada una, contraste entre especies suficiente, estética cozy
- [?] Verificación de criaturas IN-GAME (aparición/behavior en el mundo) — requiere M64 IA de NPC (dueño: agnes; iter con IA completa)
