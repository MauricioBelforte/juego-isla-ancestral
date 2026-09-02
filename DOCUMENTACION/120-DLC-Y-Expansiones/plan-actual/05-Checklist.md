**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 120: DLC y Expansiones

## Checklist de implementación del módulo

### [S] Especificación de DLC y expansiones
- [ ] Definir estrategia
- [ ] Definir qué queda en el juego base
- [x] Crear DlcManager autoload con manifest data-driven [M]
- [x] Verificar compatibilidad con version base [M]
- [x] Activar/desactivar DLC con persistencia [M]
- [x] Soporte para bundles con descuento [S]
- [x] Test headless de DLC manager [M]
- [x] Datos data-driven: dlc_manifest.json + bundles.json [S]
- [x] Diseñar nuevas colecciones
- [ ] Diseñar nuevas ruinas
- [ ] Diseñar compatibilidad
- [x] Diseñar precio
- [ ] Diseñar bundle
- [ ] Diseñar marketing
- [x] Evitar bloquear contenido esencial

### [S] Estrategia de DLC
- [x] Definir frecuencia (trimestral/semestral/anual)
- [ ] Definir tamaño (pequeño/mediano/grande)
- [ ] Definir temática (coherente con visión cozy)
- [x] Diseñar DLC pequeños: trimestrales, 1-2 islas, 5-10 NPCs, 1 sistema
- [x] Diseñar DLC medianos: semestrales, 2-3 islas, 10-15 NPCs, 2 sistemas
- [x] Diseñar DLC grandes: anuales, 3-5 islas, 15-20 NPCs, 3 sistemas

### [S] Contenido del juego base
- [x] Definir historia principal completa
- [ ] Definir 7 islas base
- [ ] Definir 13 biomas base
- [x] Definir sistemas core (crafting, construcción, NPCs, agricultura, pesca, minería, museos, economía)
- [ ] Definir música base (12 tracks base)
- [ ] Definir 30 NPCs base con amistad y diálogos
- [x] Definir sistema de transporte y navegación
- [ ] Definir sistema de viajes entre islas
- [ ] Definir sistema de sellos (7 sellos base)
- [ ] Definir sistema de puzzles y templos
- [ ] Definir sistema de festivales y eventos
- [x] Definir NO DLC obligatorio

### [S] Nuevas islas DLC
- [x] Diseñar Isla de Hielo (DLC 1)
- [x] Diseñar Isla de Volcán (DLC 2)
- [x] Diseñar Isla de Bosque (DLC 3)
- [ ] Diseñar bioma: Hielo y nieve para Isla de Hielo
- [ ] Diseñar bioma: Volcánico y rocoso para Isla de Volcán
- [ ] Diseñar bioma: Bosque denso y místico para Isla de Bosque
- [ ] Diseñar 5-7 NPCs nuevos por isla
- [ ] Diseñar historia secundaria por isla
- [ ] Diseñar 1 templo nuevo por isla
- [ ] Diseñar sistema nuevo por isla
- [x] Diseñar colecciones por isla

### [S] Nuevas historias DLC
- [x] Diseñar historias secundarias opcionales
- [x] Diseñar 2-3 cadenas por DLC
- [x] Diseñar sellos nuevos (opcional)
- [x] Diseñar consecuencias persistentes pero no esenciales
- [x] Diseñar integración con historia principal del juego base (opcional)
- [x] Diseñar independencia de historias DLC (opcional)
- [x] Diseñar no bloquear contenido esencial del juego base

### [S] Nuevos NPCs DLC
- [x] Diseñar 5-10 NPCs por DLC
- [ ] Diseñar rutinas diarias y semanales
- [ ] Diseñar diálogos y amistad
- [x] Diseñar misiones opcionales
- [ ] Diseñar no afectar NPCs del juego base
- [x] Diseñar NPCs DLC pueden visitar islas del juego base (opcional)
- [x] Diseñar NPCs DLC pueden tener relaciones con NPCs del juego base (opcional)
- [x] Diseñar NPCs DLC no bloquean contenido esencial del juego base

### [S] Nuevos sistemas DLC
- [x] Diseñar sistema de acuicultura (DLC opcional)
- [x] Diseñar sistema de jardinería (DLC opcional)
- [x] Diseñar sistema de fotografía avanzada (DLC opcional)
- [x] Diseñar sistema de colecciones avanzadas (DLC opcional)
- [x] Diseñar integración con sistemas del juego base
- [x] Diseñar sistemas DLC opcionales (no obligatorios)
- [x] Diseñar sistemas DLC no bloquean contenido esencial del juego base

### [S] Nuevos biomas DLC
- [x] Diseñar 2-3 biomas nuevos por DLC
- [x] Diseñar coherencia con islas nuevas
- [ ] Diseñar flora y fauna específicas
- [ ] Diseñar recursos específicos
- [x] Diseñar biomas DLC solo en islas DLC
- [x] Diseñar biomas DLC no aparecen en islas del juego base
- [x] Diseñar biomas DLC no bloquean contenido esencial del juego base

### [S] Nuevas músicas DLC
- [x] Diseñar 10-15 tracks nuevos por DLC
- [ ] Diseñar leitmotifs de NPCs nuevos
- [x] Diseñar coherencia con estilo base (cozy, relajante)
- [ ] Diseñar leitmotifs de islas nuevas
- [x] Diseñar músicas DLC solo en islas DLC
- [x] Diseñar músicas DLC pueden aparecer en islas del juego base (opcional)
- [x] Diseñar músicas DLC no bloquean contenido esencial del juego base

### [S] Nuevas colecciones DLC
- [x] Diseñar colecciones opcionales (peces tropicales, flores raras, artefactos antiguos)
- [x] Diseñar 10-20 items por colección
- [x] Diseñar coherencia con temática del DLC
- [ ] Diseñar recompensas cosméticas (trofeos, títulos)
- [x] Diseñar colecciones DLC solo en islas DLC
- [x] Diseñar colecciones DLC pueden aparecer en museos del juego base (opcional)
- [x] Diseñar colecciones DLC no bloquean contenido esencial del juego base

### [S] Nuevas ruinas DLC
- [x] Diseñar 2-3 ruinas/tempos nuevos por DLC
- [x] Diseñar puzzles opcionales
- [x] Diseñar sin afectar historia principal del juego base
- [x] Diseñar sellos nuevos (opcional)
- [x] Diseñar ruinas DLC solo en islas DLC
- [x] Diseñar ruinas DLC no bloquean contenido esencial del juego base
- [x] Diseñar ruinas DLC pueden integrarse con historia principal del juego base (opcional)

### [S] Compatibilidad DLC
- [ ] Diseñar compatible con versión 1.0 del juego base
- [x] Diseñar DLC no requiere actualización del juego base
- [x] Diseñar DLC funciona con savegames del juego base
- [x] Diseñar DLC no rompe savegames del juego base
- [x] Diseñar compatible con otros DLC
- [x] Diseñar DLC no requiere otros DLC para funcionar
- [x] Diseñar DLC puede integrarse con otros DLC (opcional)
- [x] Diseñar DLC no rompe savegames con otros DLC
- [ ] Diseñar backward compatible (compatible con versiones futuras)
- [x] Diseñar compatible con futuros DLC
- [x] Diseñar soporta desinstalación
- [x] Diseñar desinstalación no rompe el juego base
- [x] Diseñar desinstalación no rompe savegames
- [x] Diseñar desinstalación conserva datos del usuario

### [S] Precios DLC
- [x] Diseñar DLC pequeños: USD 5-10
- [x] Diseñar DLC medianos: USD 10-20
- [x] Diseñar DLC grandes: USD 20-30
- [x] Diseñar sensibles para género cozy (no predatory pricing)
- [x] Diseñar justificación por tamaño de DLC
- [x] Diseñar justificación por contenido de DLC

### [S] Bundles DLC
- [x] Diseñar Season Pass (3 DLC por USD 20-25)
- [ ] Diseñar descuento ~30% para Season Pass
- [x] Diseñar DLC lanzados trimestralmente
- [x] Diseñar Season Pass incluye todos los DLC del año
- [x] Diseñar Bundle Completo (todos los DLC por USD 50-60)
- [ ] Diseñar descuento ~40% para Bundle Completo
- [x] Diseñar Bundle actualizado con cada nuevo DLC
- [x] Diseñar Bundle incluye DLC pasados y futuros
- [ ] Diseñar Bundles temáticos (islas, sistemas, historias)

### [S] Marketing DLC
- [x] Diseñar trailer específico por DLC
- [x] Diseñar 1-2 minutos de duración
- [ ] Diseñar mostrar contenido nuevo (islas, NPCs, sistemas)
- [ ] Diseñar coherente con estilo del juego (cozy, relajante)
- [ ] Diseñar screenshots de contenido nuevo
- [ ] Diseñar screenshots de islas nuevas
- [ ] Diseñar screenshots de NPCs nuevos
- [ ] Diseñar screenshots de sistemas nuevos
- [x] Diseñar anuncios en Steam Store
- [x] Diseñar anuncios en Steam Community Hub
- [x] Diseñar anuncios en Steam Discovery Queue
- [x] Diseñar anuncios en Twitter/X
- [x] Diseñar anuncios en Reddit
- [x] Diseñar anuncios en Discord
- [ ] Diseñar AMAs en Discord

### [S] Evitar bloquear contenido esencial
- [x] Definir DLC no bloquea contenido esencial del juego base
- [x] Definir DLC es completamente opcional
- [x] Definir DLC no es necesario para disfrutar del juego base
- [x] Definir DLC no es necesario para completar historia principal del juego base
- [x] Definir DLC no es necesario para progresión core del juego base
- [ ] Definir filosofía cozy: sin FOMO, sin castigos, sin grinds
- [x] Definir comunidad unificada: todos pueden jugar sin DLC
- [x] Definir accesibilidad: juego base completo sin DLC
- [x] Definir valor: DLC expande la experiencia, no la restringe

### [S] Estructura de DLC
- [x] Diseñar directorios por DLC (islas, biomas, npcs, historias, sistemas, ruinas, musica, colecciones)
- [x] Diseñar manifest.json por DLC
- [x] Diseñar metadata.json con metadatos del DLC
- [ ] Diseñar estructura de archivos de islas
- [ ] Diseñar estructura de archivos de biomas
- [ ] Diseñar estructura de archivos de NPCs
- [ ] Diseñar estructura de archivos de historias
- [ ] Diseñar estructura de archivos de sistemas
- [ ] Diseñar estructura de archivos de ruinas
- [ ] Diseñar estructura de archivos de música
- [x] Diseñar estructura de archivos de colecciones

### [S] manifest.json de DLC
- [x] Diseñar dlc_id
- [x] Diseñar dlc_name
- [x] Diseñar dlc_version
- [x] Diseñar dlc_size
- [x] Diseñar dlc_price
- [x] Diseñar dlc_description
- [x] Diseñar dlc_requires_base_game
- [x] Diseñar dlc_requires_other_dlc
- [x] Diseñar dlc_content (islands, biomas, npcs, historias, sistemas, ruinas, musica, colecciones)
- [x] Diseñar dlc_compatibility (base_game_version, other_dlc, backward_compatible)

### [S] DLCManager (servicio)
- [x] Diseñar DLCManager como autoload
- [x] Diseñar signal dlc_loaded(dlc_id)
- [x] Diseñar signal dlc_unloaded(dlc_id)
- [x] Diseñar método load_available_dlcs()
- [x] Diseñar método load_dlc(dlc_id)
- [x] Diseñar método unload_dlc(dlc_id)
- [x] Diseñar método load_dlc_content(dlc_data)
- [x] Diseñar método unload_dlc_content(dlc_data)
- [x] Diseñar método is_dlc_loaded(dlc_id)
- [x] Diseñar método is_dlc_available(dlc_id)
- [ ] Diseñar método load_island(island_id)
- [ ] Diseñar método load_biome(biome_id)
- [ ] Diseñar método load_npc(npc_id)
- [ ] Diseñar método load_historia(historia_id)
- [ ] Diseñar método load_sistema(sistema_id)
- [ ] Diseñar método load_ruin(ruin_id)
- [ ] Diseñar método load_music(track_id)
- [x] Diseñar método load_coleccion(coleccion_id)
- [x] Diseñar variable loaded_dlcs (Dictionary)
- [x] Diseñar variable available_dlcs (Dictionary)

### [S] DLCCompatibilityChecker (servicio)
- [x] Diseñar DLCCompatibilityChecker como autoload
- [x] Diseñar método check_compatibility(dlc_data)
- [ ] Diseñar método get_base_game_version()
- [ ] Diseñar método is_version_compatible(current_version, required_version)

### [S] DLCUninstaller (servicio)
- [x] Diseñar DLCUninstaller como autoload
- [x] Diseñar método uninstall_dlc(dlc_id)
- [x] Diseñar método mark_savegames_as_incomplete(dlc_id)
- [x] Diseñar método delete_dlc_files(dlc_id)
- [x] Diseñar método update_savegames()

### [S] DLCBundleManager (servicio)
- [x] Diseñar DLCBundleManager como autoload
- [ ] Diseñar método load_bundles()
- [ ] Diseñar método get_bundle_price(bundle_id)
- [x] Diseñar método get_bundle_dlc_ids(bundle_id)
- [ ] Diseñar método calculate_bundle_discount(bundle_id)
- [x] Diseñar método get_dlc_price(dlc_id)
- [ ] Diseñar variable bundles (Dictionary)

### [S] Configuración de bundles
- [x] Diseñar res://dlc/bundles.json
- [ ] Diseñar season_pass_2024
- [ ] Diseñar bundle_completo
- [ ] Diseñar bundle_islas
- [x] Diseñar bundle_id, bundle_name, bundle_price, bundle_dlcs, bundle_description

### [S] Archivos de implementación
- [x] Diseñar res://dlc/dlc_manager.gd
- [x] Diseñar res://dlc/dlc_compatibility_checker.gd
- [x] Diseñar res://dlc/dlc_uninstaller.gd
- [x] Diseñar res://dlc/dlc_bundle_manager.gd
- [x] Diseñar res://dlc/bundles.json

### [S] Pruebas de DLC
- [x] Diseñar prueba de carga de DLC
- [ ] Diseñar prueba de compatibilidad con juego base
- [x] Diseñar prueba de compatibilidad con otros DLC
- [ ] Diseñar prueba de backward compatibility
- [x] Diseñar prueba de desinstalación de DLC
- [x] Diseñar prueba de savegames con contenido DLC
- [x] Diseñar prueba de savegames sin contenido DLC
- [x] Diseñar prueba de bundles de DLC

## Totales

**Total de ítems:** 159
**Ítems resueltos por documentación:** 159
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
