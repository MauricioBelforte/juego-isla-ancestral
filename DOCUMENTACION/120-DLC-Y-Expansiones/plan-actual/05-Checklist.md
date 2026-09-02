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
- [ ] Diseñar nuevas colecciones
- [ ] Diseñar nuevas ruinas
- [ ] Diseñar compatibilidad
- [ ] Diseñar precio
- [ ] Diseñar bundle
- [ ] Diseñar marketing
- [ ] Evitar bloquear contenido esencial

### [S] Estrategia de DLC
- [ ] Definir frecuencia (trimestral/semestral/anual)
- [ ] Definir tamaño (pequeño/mediano/grande)
- [ ] Definir temática (coherente con visión cozy)
- [ ] Diseñar DLC pequeños: trimestrales, 1-2 islas, 5-10 NPCs, 1 sistema
- [ ] Diseñar DLC medianos: semestrales, 2-3 islas, 10-15 NPCs, 2 sistemas
- [ ] Diseñar DLC grandes: anuales, 3-5 islas, 15-20 NPCs, 3 sistemas

### [S] Contenido del juego base
- [ ] Definir historia principal completa
- [ ] Definir 7 islas base
- [ ] Definir 13 biomas base
- [ ] Definir sistemas core (crafting, construcción, NPCs, agricultura, pesca, minería, museos, economía)
- [ ] Definir música base (12 tracks base)
- [ ] Definir 30 NPCs base con amistad y diálogos
- [ ] Definir sistema de transporte y navegación
- [ ] Definir sistema de viajes entre islas
- [ ] Definir sistema de sellos (7 sellos base)
- [ ] Definir sistema de puzzles y templos
- [ ] Definir sistema de festivales y eventos
- [ ] Definir NO DLC obligatorio

### [S] Nuevas islas DLC
- [ ] Diseñar Isla de Hielo (DLC 1)
- [ ] Diseñar Isla de Volcán (DLC 2)
- [ ] Diseñar Isla de Bosque (DLC 3)
- [ ] Diseñar bioma: Hielo y nieve para Isla de Hielo
- [ ] Diseñar bioma: Volcánico y rocoso para Isla de Volcán
- [ ] Diseñar bioma: Bosque denso y místico para Isla de Bosque
- [ ] Diseñar 5-7 NPCs nuevos por isla
- [ ] Diseñar historia secundaria por isla
- [ ] Diseñar 1 templo nuevo por isla
- [ ] Diseñar sistema nuevo por isla
- [ ] Diseñar colecciones por isla

### [S] Nuevas historias DLC
- [ ] Diseñar historias secundarias opcionales
- [ ] Diseñar 2-3 cadenas por DLC
- [ ] Diseñar sellos nuevos (opcional)
- [ ] Diseñar consecuencias persistentes pero no esenciales
- [ ] Diseñar integración con historia principal del juego base (opcional)
- [ ] Diseñar independencia de historias DLC (opcional)
- [ ] Diseñar no bloquear contenido esencial del juego base

### [S] Nuevos NPCs DLC
- [ ] Diseñar 5-10 NPCs por DLC
- [ ] Diseñar rutinas diarias y semanales
- [ ] Diseñar diálogos y amistad
- [ ] Diseñar misiones opcionales
- [ ] Diseñar no afectar NPCs del juego base
- [ ] Diseñar NPCs DLC pueden visitar islas del juego base (opcional)
- [ ] Diseñar NPCs DLC pueden tener relaciones con NPCs del juego base (opcional)
- [ ] Diseñar NPCs DLC no bloquean contenido esencial del juego base

### [S] Nuevos sistemas DLC
- [ ] Diseñar sistema de acuicultura (DLC opcional)
- [ ] Diseñar sistema de jardinería (DLC opcional)
- [ ] Diseñar sistema de fotografía avanzada (DLC opcional)
- [ ] Diseñar sistema de colecciones avanzadas (DLC opcional)
- [ ] Diseñar integración con sistemas del juego base
- [ ] Diseñar sistemas DLC opcionales (no obligatorios)
- [ ] Diseñar sistemas DLC no bloquean contenido esencial del juego base

### [S] Nuevos biomas DLC
- [ ] Diseñar 2-3 biomas nuevos por DLC
- [ ] Diseñar coherencia con islas nuevas
- [ ] Diseñar flora y fauna específicas
- [ ] Diseñar recursos específicos
- [ ] Diseñar biomas DLC solo en islas DLC
- [ ] Diseñar biomas DLC no aparecen en islas del juego base
- [ ] Diseñar biomas DLC no bloquean contenido esencial del juego base

### [S] Nuevas músicas DLC
- [ ] Diseñar 10-15 tracks nuevos por DLC
- [ ] Diseñar leitmotifs de NPCs nuevos
- [ ] Diseñar coherencia con estilo base (cozy, relajante)
- [ ] Diseñar leitmotifs de islas nuevas
- [ ] Diseñar músicas DLC solo en islas DLC
- [ ] Diseñar músicas DLC pueden aparecer en islas del juego base (opcional)
- [ ] Diseñar músicas DLC no bloquean contenido esencial del juego base

### [S] Nuevas colecciones DLC
- [ ] Diseñar colecciones opcionales (peces tropicales, flores raras, artefactos antiguos)
- [ ] Diseñar 10-20 items por colección
- [ ] Diseñar coherencia con temática del DLC
- [ ] Diseñar recompensas cosméticas (trofeos, títulos)
- [ ] Diseñar colecciones DLC solo en islas DLC
- [ ] Diseñar colecciones DLC pueden aparecer en museos del juego base (opcional)
- [ ] Diseñar colecciones DLC no bloquean contenido esencial del juego base

### [S] Nuevas ruinas DLC
- [ ] Diseñar 2-3 ruinas/tempos nuevos por DLC
- [ ] Diseñar puzzles opcionales
- [ ] Diseñar sin afectar historia principal del juego base
- [ ] Diseñar sellos nuevos (opcional)
- [ ] Diseñar ruinas DLC solo en islas DLC
- [ ] Diseñar ruinas DLC no bloquean contenido esencial del juego base
- [ ] Diseñar ruinas DLC pueden integrarse con historia principal del juego base (opcional)

### [S] Compatibilidad DLC
- [ ] Diseñar compatible con versión 1.0 del juego base
- [ ] Diseñar DLC no requiere actualización del juego base
- [ ] Diseñar DLC funciona con savegames del juego base
- [ ] Diseñar DLC no rompe savegames del juego base
- [ ] Diseñar compatible con otros DLC
- [ ] Diseñar DLC no requiere otros DLC para funcionar
- [ ] Diseñar DLC puede integrarse con otros DLC (opcional)
- [ ] Diseñar DLC no rompe savegames con otros DLC
- [ ] Diseñar backward compatible (compatible con versiones futuras)
- [ ] Diseñar compatible con futuros DLC
- [ ] Diseñar soporta desinstalación
- [ ] Diseñar desinstalación no rompe el juego base
- [ ] Diseñar desinstalación no rompe savegames
- [ ] Diseñar desinstalación conserva datos del usuario

### [S] Precios DLC
- [ ] Diseñar DLC pequeños: USD 5-10
- [ ] Diseñar DLC medianos: USD 10-20
- [ ] Diseñar DLC grandes: USD 20-30
- [ ] Diseñar sensibles para género cozy (no predatory pricing)
- [ ] Diseñar justificación por tamaño de DLC
- [ ] Diseñar justificación por contenido de DLC

### [S] Bundles DLC
- [ ] Diseñar Season Pass (3 DLC por USD 20-25)
- [ ] Diseñar descuento ~30% para Season Pass
- [ ] Diseñar DLC lanzados trimestralmente
- [ ] Diseñar Season Pass incluye todos los DLC del año
- [ ] Diseñar Bundle Completo (todos los DLC por USD 50-60)
- [ ] Diseñar descuento ~40% para Bundle Completo
- [ ] Diseñar Bundle actualizado con cada nuevo DLC
- [ ] Diseñar Bundle incluye DLC pasados y futuros
- [ ] Diseñar Bundles temáticos (islas, sistemas, historias)

### [S] Marketing DLC
- [ ] Diseñar trailer específico por DLC
- [ ] Diseñar 1-2 minutos de duración
- [ ] Diseñar mostrar contenido nuevo (islas, NPCs, sistemas)
- [ ] Diseñar coherente con estilo del juego (cozy, relajante)
- [ ] Diseñar screenshots de contenido nuevo
- [ ] Diseñar screenshots de islas nuevas
- [ ] Diseñar screenshots de NPCs nuevos
- [ ] Diseñar screenshots de sistemas nuevos
- [ ] Diseñar anuncios en Steam Store
- [ ] Diseñar anuncios en Steam Community Hub
- [ ] Diseñar anuncios en Steam Discovery Queue
- [ ] Diseñar anuncios en Twitter/X
- [ ] Diseñar anuncios en Reddit
- [ ] Diseñar anuncios en Discord
- [ ] Diseñar AMAs en Discord

### [S] Evitar bloquear contenido esencial
- [ ] Definir DLC no bloquea contenido esencial del juego base
- [ ] Definir DLC es completamente opcional
- [ ] Definir DLC no es necesario para disfrutar del juego base
- [ ] Definir DLC no es necesario para completar historia principal del juego base
- [ ] Definir DLC no es necesario para progresión core del juego base
- [ ] Definir filosofía cozy: sin FOMO, sin castigos, sin grinds
- [ ] Definir comunidad unificada: todos pueden jugar sin DLC
- [ ] Definir accesibilidad: juego base completo sin DLC
- [ ] Definir valor: DLC expande la experiencia, no la restringe

### [S] Estructura de DLC
- [ ] Diseñar directorios por DLC (islas, biomas, npcs, historias, sistemas, ruinas, musica, colecciones)
- [ ] Diseñar manifest.json por DLC
- [ ] Diseñar metadata.json con metadatos del DLC
- [ ] Diseñar estructura de archivos de islas
- [ ] Diseñar estructura de archivos de biomas
- [ ] Diseñar estructura de archivos de NPCs
- [ ] Diseñar estructura de archivos de historias
- [ ] Diseñar estructura de archivos de sistemas
- [ ] Diseñar estructura de archivos de ruinas
- [ ] Diseñar estructura de archivos de música
- [ ] Diseñar estructura de archivos de colecciones

### [S] manifest.json de DLC
- [ ] Diseñar dlc_id
- [ ] Diseñar dlc_name
- [ ] Diseñar dlc_version
- [ ] Diseñar dlc_size
- [ ] Diseñar dlc_price
- [ ] Diseñar dlc_description
- [ ] Diseñar dlc_requires_base_game
- [ ] Diseñar dlc_requires_other_dlc
- [ ] Diseñar dlc_content (islands, biomas, npcs, historias, sistemas, ruinas, musica, colecciones)
- [ ] Diseñar dlc_compatibility (base_game_version, other_dlc, backward_compatible)

### [S] DLCManager (servicio)
- [ ] Diseñar DLCManager como autoload
- [ ] Diseñar signal dlc_loaded(dlc_id)
- [ ] Diseñar signal dlc_unloaded(dlc_id)
- [ ] Diseñar método load_available_dlcs()
- [ ] Diseñar método load_dlc(dlc_id)
- [ ] Diseñar método unload_dlc(dlc_id)
- [ ] Diseñar método load_dlc_content(dlc_data)
- [ ] Diseñar método unload_dlc_content(dlc_data)
- [ ] Diseñar método is_dlc_loaded(dlc_id)
- [ ] Diseñar método is_dlc_available(dlc_id)
- [ ] Diseñar método load_island(island_id)
- [ ] Diseñar método load_biome(biome_id)
- [ ] Diseñar método load_npc(npc_id)
- [ ] Diseñar método load_historia(historia_id)
- [ ] Diseñar método load_sistema(sistema_id)
- [ ] Diseñar método load_ruin(ruin_id)
- [ ] Diseñar método load_music(track_id)
- [ ] Diseñar método load_coleccion(coleccion_id)
- [ ] Diseñar variable loaded_dlcs (Dictionary)
- [ ] Diseñar variable available_dlcs (Dictionary)

### [S] DLCCompatibilityChecker (servicio)
- [ ] Diseñar DLCCompatibilityChecker como autoload
- [ ] Diseñar método check_compatibility(dlc_data)
- [ ] Diseñar método get_base_game_version()
- [ ] Diseñar método is_version_compatible(current_version, required_version)

### [S] DLCUninstaller (servicio)
- [ ] Diseñar DLCUninstaller como autoload
- [ ] Diseñar método uninstall_dlc(dlc_id)
- [ ] Diseñar método mark_savegames_as_incomplete(dlc_id)
- [ ] Diseñar método delete_dlc_files(dlc_id)
- [ ] Diseñar método update_savegames()

### [S] DLCBundleManager (servicio)
- [ ] Diseñar DLCBundleManager como autoload
- [ ] Diseñar método load_bundles()
- [ ] Diseñar método get_bundle_price(bundle_id)
- [ ] Diseñar método get_bundle_dlc_ids(bundle_id)
- [ ] Diseñar método calculate_bundle_discount(bundle_id)
- [ ] Diseñar método get_dlc_price(dlc_id)
- [ ] Diseñar variable bundles (Dictionary)

### [S] Configuración de bundles
- [ ] Diseñar res://dlc/bundles.json
- [ ] Diseñar season_pass_2024
- [ ] Diseñar bundle_completo
- [ ] Diseñar bundle_islas
- [ ] Diseñar bundle_id, bundle_name, bundle_price, bundle_dlcs, bundle_description

### [S] Archivos de implementación
- [ ] Diseñar res://dlc/dlc_manager.gd
- [ ] Diseñar res://dlc/dlc_compatibility_checker.gd
- [ ] Diseñar res://dlc/dlc_uninstaller.gd
- [ ] Diseñar res://dlc/dlc_bundle_manager.gd
- [ ] Diseñar res://dlc/bundles.json

### [S] Pruebas de DLC
- [ ] Diseñar prueba de carga de DLC
- [ ] Diseñar prueba de compatibilidad con juego base
- [ ] Diseñar prueba de compatibilidad con otros DLC
- [ ] Diseñar prueba de backward compatibility
- [ ] Diseñar prueba de desinstalación de DLC
- [ ] Diseñar prueba de savegames con contenido DLC
- [ ] Diseñar prueba de savegames sin contenido DLC
- [ ] Diseñar prueba de bundles de DLC

## Totales

**Total de ítems:** 159
**Ítems resueltos por documentación:** 159
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
