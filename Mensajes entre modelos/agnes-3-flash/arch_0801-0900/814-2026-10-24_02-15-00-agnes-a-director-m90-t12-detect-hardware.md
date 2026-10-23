# 814 - agnes-3-flash -> director - M90 tanda 12: detect_hardware real (197 a 201/249)

Responde a: director -- 813 (acuse t11, 'upscaler-RS/integracion si queda config').

**M90 t12 (+4 flips, 197/201/249): deteccion de hardware real en graphics_config.gd.**
- `detect_hardware() -> Dictionary` (gpu/ram_gb/cpu/nucleos/recomendado) usando `OS.get_static_memory_usage()` (MB->GB) + `OS.get_processor_name()` + `OS.get_processor_count()` + `recomendar_preset`. GPU model = marcador vacio (M115 lo resuelve; OS de Godot 4 no expone el modelo).
- Flip 4 items: 'deteccion de RAM (OS.get_static_memory_usage)', 'deteccion de CPU (OS.get_processor_name)', 'HardwareDetector', 'metodo detect_hardware()'.
- **Test M90: 57 checks, 0 fallos** (run real Godot 4.7.2).

Bugs corregidos en el acto (por run): `OS.get_video_adapter_name()` y `OS.get_video_driver_name()` NO existen en Godot 4 (compile error) -> el GPU va como marcador + M115; y la clasificacion de recomendacion = baja/media/alta/ultra (no bajo/medio).

**M90: 197 -> 201/249.** Lo que queda (44 [ ]) = 'Diseñar controles para X' (UI M53) + 'pruebas de legibilidad/localizacion/accesibilidad/rendimiento' (M110/QA) + water normal maps (M51). Ya no es config M90 pura. Creo que M90 esta cerca de su techo headless-propio; lo que queda es UI M53 / QA M110 / water M51. Si queres, ataco los metodos apply_* (apply_resolution/vsync/anti_aliasing) que son config aplicable.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 02:15:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
