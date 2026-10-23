# Log 2147 - Hy3 - Runtime test M28/M27-Viajes (IslandTravelGuard gating)
# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-22 22:39
# Modulo: M28 (viaje) / M27 (islas) - IslandTravelGuard
# Backlog: item 62 (COLAS ACTIVA) "Runtime test de M28-Viajes: ruta/fast-travel gating"
# Rama: RAMA-2 (director 329 consumido; cola V2 fuente)
#
# CONTEXTO / INDEPENDENCIA (sec.21.23)
#   Autor de IslandTravelGuard: DeepSeek-V4.1-Flash.
#   Verificador: Hunyuan (Hy3). Autor != verificador -> cumple sec.21.23.
#   La clase es RefCounted pura, sin escena, sin disco, sin autoloads:
#   verificable headless instanciandola directo y alimentando una "vista" manual.
#
# ENTORNO (ejecucion real, no simulada)
#   Godot 4.7.2-stable (win64 console) --headless
#   --path game/isla-ancestral
#   --script res://scripts/islas/test_island_travel_guard_hy3.gd
#   La cola (IslandOps, tambien RefCounted pura) se conduce en seco:
#   encolar() + iniciar() para simular carga/descarga en curso.
#
# COBERTURA (edge cases K1-K9 del checklist de M27)
#   K1  debe_precargar: vecino al borde se precarga; presupuesto 0 = nada;
#       isla ya cargada no es candidata.
#   K2  evaluar_viaje: ya_estas_ahi / secreta(no viajable) / ancla(esperar) /
#       ops=null(encolar) / descarga_en_curso(otro) / destino_descargandose /
#       carga_ya_en_curso(esperar) / cola_ocupada(encolar).
#   K3  evaluar_naufrago: en_tierra / a_bordo / en_agua_cerca(salvavidas) /
#       oceano_abierto(respawn_cozy).
#   K4  estado_destino: isla_desconocida / secreta_no_descubierta /
#       ancla_pendiente / bloqueada_por_progreso / ok.
#   K5  punto_seguro: punto firme (ajustado=false) / fuera de disco se proyecta
#       al interior (ajustado=true, sin flotante fuera) / isla_desconocida (no fiable).
#   K6  cancelar_viaje: cancela la op viva y queda limpio; ops=null no rompe.
#   K7  evaluar_guardado: libre / carga_en_curso(esperar) / cola_pendiente(esperar).
#   K8  respawn_cozy: siempre tierra firme dentro del disco; sin islas -> ok=false.
#   K9  descarga_forzada: LRU sobre islas cargadas no-intocables; preserva
#       descubierta/visitada (estado_preservado=true); principal y actual intactas.
#       descarga_agresiva_viajeros(preset baja): descarga las viajeras, no la
#       principal ni la actual; estado_preservado=true.
#
# GUARDA ANTI-FALSO-VERDE (3 capas)
#   1) _fin(bloque) por cada bloque de test (10 bloques).
#   2) CHECKS_MINIMOS MEDIDO en verde = 59.
#   3) _summary() en call_deferred SEPARADO: si _run aborta por SCRIPT ERROR,
#      detecta bloques faltantes y fuerza EXIT 1 (no cuelga).
#   SONDA ROJA: con env HY3_PROBE_ROJO=1 se fuerza un check falso al inicio
#   para probar que el suite REALMENTE falla (EXIT 1).
#
# EVIDENCIA MEDIDA (bytes, ejecucion real)
#   CORRIDA VERDE : 59 checks, 0 fallos, EXIT 0.
#   SONDA ROJA    : 60 checks, 1 fallo,  EXIT 1  (prueba de test-vivo).
#   Archivo de test: game/isla-ancestral/scripts/islas/test_island_travel_guard_hy3.gd
#   Binario: D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe
#
# CONCLUSION
#   sec.21.8 PASS. IslandTravelGuard (M28/M27-Viajes gating) verificado por
#   runtime headless real con guarda anti-falso-verde. 0 fallos en 59 checks.
#   Sin GO extra del director: item tomado de la cola V2 (item 62), fuera de
#   NO TOCAR, no en vuelo de otro modelo.
#   Cifras modulo M28 (segun backlog del director, item 62): pendiente de
#   cierre oficial del modulo; este log cierra solo la verificacion runtime.
