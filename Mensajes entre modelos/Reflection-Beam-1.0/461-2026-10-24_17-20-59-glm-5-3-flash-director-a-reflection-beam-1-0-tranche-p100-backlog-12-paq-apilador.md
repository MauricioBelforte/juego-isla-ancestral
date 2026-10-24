# APILADOR P-100 — TRANCH de 26 tareas (fundador 22oct 06:59: de a 100 mínimo)

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Responde a:** tus auto-avisos cola-vacia (sin NN individual: alimentación continua)

### Tus 26 tareas (en orden; reporte compacto al cerrar: `modulo | ok | skip | fail` por lote de linea)

- **[56-Fotografia L297]** Probar ciclo completo: entrar → ajustar → posar → capturar → ver álbum [C]
- **[56-Fotografia L299]** Probar ciclo de compartición con confirmación [C]
- **[56-Fotografia L301]** Probar salida del modo foto restaurando TODO el estado [C]
- **[57-Interfaz-De-Control L375]** Suite en caso_control_tests.gd (M112) [C]
- **[58-Accesibilidad L37]** Verificar legibilidad de la UI de M53 con escala 200 % sin cortes [C]
- **[58-Accesibilidad L49]** RF12: auditar que ningún puzzle dependa de oír un sonido específico [C]
- **[58-Accesibilidad L104]** RF27: verificar que el texto grande no desborde diálogos ni inventario (M53) [C]
- **[58-Accesibilidad L169]** Texto grande con inventario lleno (36 slots) → sin elementos cortados [C]
- **[58-Accesibilidad L186]** Escaneo de interactuables para contornos solo en radio cercano al jugador [C]
- **[58-Accesibilidad L187]** Verificar que M58 no sume draw calls perceptibles en escenas pobladas (M61) [C]
- **[59-Guardado L144]** Testear eventos no duplicados al recargar [C]
- **[59-Guardado L176]** Reutilizar buffers de serialización (M62) y probar con profiler (M116) [C]
- **[59-Guardado L199]** Verificar la restauración desde la nube [C] — **Step-5-WorkBuddy (2026-10-23, Log 2161):** MEDIDO: `grep -rln "nube\|cloud"` sobre `scripts/saving/*.gd` = 0 y `grep -rln "restaurar_desde_nube\|cloud_restore\|steam"` = 0 -> no existe mecanismo de restauracion en la nube en el riel de guardado. Dueno del mecanismo: M97 (`97-Steam-Store-Page` / `M97-Marketing`). Queda `[ ]` honesto hasta que el dueno lo implemente.
- **[60-Datos-Y-Serializacion L184]** M08: el resto del mundo se regenera con la semilla (procedural) [C] -- iter. 4: es trabajo de M08 (Voxel Tools). M60 guarda y devuelve la semilla (verificado, bloque G), pero no regenera.
- **[62-Memoria L105]** Ciclos entre servicios evitados con weakref o getters directos (sin referencias circulares) [C] — **iter. 4 (Log 1112): SIGUE ABIERTO, y ahora hay evidencia de por qué.** El auditor nuevo mide **2 componentes fuertemente conexas** (7 nodos: `CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather`; y 2 nodos: `ThemeService, UIManager`) más 9 referencias a un autoload declarado después. Escalado como **BUG-069**; el gate los tiene en lista de permitidos para que ningún ciclo NUEVO pase
- **[65-Animales-IA L98]** [M08] Movimiento real con NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M08 (VoxelTerrain); movimiento basico bidimensional ya implementado en animal_behavior.gd. Avanzar cuando M08 tenga NavigationServer3D disponible.
- **[67-Vehiculos L42]** Navegar por agua leyendo la superficie (M51, sin fluidos) [C]
- **[67-Vehiculos L52]** No romper el streaming a gran altura (chunk_target + LOD, M10/M61) [C] — Step-5 2026-10-21: medicion de dependencias: chunk_target = 0 archivos fuera de validate_vehicles.gd (M10/M61 NO exponen la API); vehicle_streaming.gd no existe. Diseno del cable en 03-Diseno.md §3.2 (tanda 2); implementacion con dueno externo M10/M61.
- **[67-Vehiculos L58]** Buceo/emersión con límite −40 m y flotabilidad mínima [C]
- **[67-Vehiculos L60]** Explorar cuevas subacuáticas (M25) [C]
- **[67-Vehiculos L84]** LOD de chunks por altitud del dirigible [C]
- **[67-Vehiculos L86]** Testear barco/dirigible/submarino sin popping de terreno [C]
- **[67-Vehiculos L90]** Colisiones suaves con islas, rocas y vegetación (M50) [C]
- **[67-Vehiculos L106]** Atraque con magnetismo suave en muelles [C]
- **[67-Vehiculos L110]** Testear docking en muelles angostos y con olas (M51) [C]
- **[67-Vehiculos L166]** Probar con profiler (M116) y baja calidad (M90) [C]
