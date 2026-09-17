Aquí tienes el **resumen final de lo que nos queda por hacer**, organizado por prioridad y fase del proyecto. **Todo lo anterior ya está implementado en los scripts proporcionados** (generación de NPCs, LODs, rig deformable, animaciones básicas y controladores de Godot).

---

---

---

## 📌 **🔴 FASE CRÍTICA (MVP: Juego funcional)**
*Objetivo: Tener los 35 NPCs integrados en Godot con animaciones básicas, LODs y sin errores visuales graves.*

---

### **1️⃣ Revisión y aprobación visual de modelos (URGENTE)**
**📍 Qué falta:**
- **Revisar manualmente en Blender** cada uno de los 35 NPCs (usando las capturas generadas en `REVISION_02/`).
- Corregir problemas específicos:
  - **Intersecciones**: Herramientas que atraviesan el cuerpo (ej: caña de Fin, hacha de Rocky).
  - **Agarres**: Manos que no sujetan bien objetos (ej: pincel de Luna, martillo de Nácar).
  - **Sombreros/peinados**: Que no floten o se deformen (ej: capucha de Estrella Fugaz, moño de Nana).
  - **Faldas/túnicas**: Que no se claven en las piernas al caminar.
  - **Pies**: Que toquen el suelo en pose neutra (verificar `Z=0` en Blender).

**🛠️ Herramientas:**
- Usa el script `revision_artistica_restantes.py` para regenerar capturas si modificas algo.
- **Checklist visual**:
  - [ ] Silueta reconocible desde 3/4.
  - [ ] Accesorios visibles y en su lugar.
  - [ ] Sin piezas flotantes o superpuestas.
  - [ ] Colores de vértice correctos (piel, ropa, herramientas).

**✅ Criterio de aceptación:**
- Todos los NPCs pasan el checklist sin errores críticos.
- **Entregable:** Lista de NPCs aprobados y lista de correcciones pendientes.

---

### **2️⃣ Pruebas de importación en Godot 4.7.2**
**📍 Qué falta:**
- Importar **todos los `SM_NPC_*_RIG.glb`** en Godot.
- Verificar:
  - **Escala**: 1.8 m de altura (usar `REFERENCIA_1_8M`).
  - **Orientación**: Mirando hacia `-Z` (forward en Godot).
  - **Colores**: Que los `COLOR_0` se visualicen (activar *Vertex Color → Use as Albedo*).
  - **Animaciones**: Que `IDLE` y `SALUDO` funcionen (configurar `source_idle` y `source_greeting` en `NPCAnimado.gd`).
  - **LODs**: Que el cambio entre ALTA/MEDIA/BAJA sea fluido (usar `NPCVisualLOD.gd`).

**🛠️ Herramientas:**
- Escena de prueba con `NPCAnimado` + `NPCVisualLOD`.
- **Checklist técnico**:
  - [ ] Altura correcta en todos los LODs.
  - [ ] Sin saltos al cambiar de LOD.
  - [ ] Animaciones se reproducen sin errores.
  - [ ] Materiales se ven como en Blender.

**✅ Criterio de aceptación:**
- Todos los NPCs se importan sin errores de escala, orientación o colores.
- **Entregable:** Informe de pruebas con capturas de pantalla en Godot.

---

### **3️⃣ Ajustes de skinning (pesos de deformación)**
**📍 Qué falta:**
- Revisar **deformaciones no naturales** en:
  - **Codos/rodillas**: Que no se doblen en ángulos imposibles.
  - **Hombros/caderas**: Que no se hundan al caminar.
  - **Faldas/capas**: Que no se claven en el cuerpo.
- **Corregir manualmente** los pesos en Blender para los NPCs con problemas (ej: Sage, Obsidiana, Vulcania).

**🛠️ Herramientas:**
- Usar el modo **Weight Paint** en Blender para ajustar pesos.
- **Script de ayuda**: Ejecutar `rig_deformable_npcs.py` con `SOLO_NOMBRES = {"SAGE"}` para regenerar el rig de un NPC específico.

**✅ Criterio de aceptación:**
- Las animaciones `IDLE` y `CAMINAR` se ven naturales en todos los NPCs.
- **Entregable:** Lista de NPCs con skinning corregido.

---

### **4️⃣ Animaciones específicas por profesión**
**📍 Qué falta:**
- **Animaciones adicionales** para NPCs con herramientas grandes o posturas especiales:
  - **Fin (Pescador)**: Animación de "lanzar caña" (en lugar de SALUDO genérico).
  - **Roca (Guardián)**: Animación de "vigilar" (mirar a los lados).
  - **Sage (Bibliotecario)**: Animación de "leer libro" (manos sosteniendo el libro).
  - **Hielo (Sabio)**: Animación de "apoyarse en báculo".
  - **Estrella Fugaz (Mensajero)**: Animación de "señalar con farol".

**🛠️ Herramientas:**
- Modificar el script `rig_deformable_npcs.py` para añadir estas animaciones.
- **Ejemplo para Fin**:
  ```python
  if nombre == "FIN":
      def lanzar_cana(frame):
          # Animación personalizada para el brazo izquierdo (donde lleva la caña)
          ...
      resultados.append(crear_clip(arm, "LANZAR_CANA", range(1, 46), lanzar_cana))
  ```

**✅ Criterio de aceptación:**
- Cada NPC tiene al menos **1 animación única** que refleje su profesión.
- **Entregable:** Clips de animación nuevos en `RIG_DEFORMABLE/`.

---

---

---

## 📌 **🟡 FASE SECUNDARIA (Mejora de calidad)**
*Objetivo: Pulir detalles para una experiencia más inmersiva.*

---

### **5️⃣ Lógica de comportamiento en Godot**
**📍 Qué falta:**
- **Sistema de navegación**:
  - Usar `NavigationServer3D` para que los NPCs caminen por el mapa.
  - Configurar **áreas de navegación** (ej: senderos, interiores).
- **Comportamientos básicos**:
  - **Deambular**: NPCs caminan aleatoriamente en su zona.
  - **Perseguir**: NPCs se acercan al jugador si está cerca (ej: Merc, Chef).
  - **Interactuar**: NPCs se detienen y miran al jugador al hablar.
- **Detectar jugador**:
  - Usar `Area3D` para detectar proximidad.
  - Activar animación `SALUDO` o diálogo al detectar al jugador.

**🛠️ Herramientas:**
- **Nodo `NPCBehavior.gd`** (nuevo script):
  ```gdscript
  extends NPCAnimado

  @export var navigation_path: NavigationPath3D
  @export var detection_radius: float = 5.0
  @export var walk_speed: float = 1.2
  @export var idle_time: float = 3.0

  var _target_position: Vector3
  var _is_walking: bool = false
  var _idle_timer: float = 0.0

  func _process(delta: float) -> void:
      if get_current_lod() != Level.HIGH:
          return

      if _is_player_near():
          saludar()
      else:
          _idle_timer += delta
          if _idle_timer >= idle_time:
              _idle_timer = 0.0
              _find_new_target()

          if _is_walking:
              _walk_towards_target(delta)

  func _is_player_near() -> bool:
      var player = get_tree().get_first_node_in_group("player")
      if player:
          return global_position.distance_to(player.global_position) <= detection_radius
      return false

  func _find_new_target() -> void:
      _target_position = get_random_point_in_area()
      _is_walking = true
      _animation_player.play("CAMINAR")

  func _walk_towards_target(delta: float) -> void:
      var direction = (_target_position - global_position).normalized()
      global_position += direction * walk_speed * delta
      look_at(_target_position, Vector3.UP)

      if global_position.distance_to(_target_position) < 0.1:
          _is_walking = false
          _animation_player.play("IDLE")
  ```

**✅ Criterio de aceptación:**
- NPCs caminan por el mapa sin atrapamientos.
- Reaccionan al jugador (saludo, diálogo).
- **Entregable:** Script `NPCBehavior.gd` + pruebas en escena.

---

### **6️⃣ Sistema de diálogo**
**📍 Qué falta:**
- **Estructura de diálogos**:
  - Crear un `JSON` con diálogos para cada NPC (ej: `dialogos.json`).
  - Ejemplo:
    ```json
    {
      "LUNA": [
        {"texto": "¡Hola, viajero! ¿Te gustan mis pinturas?", "respuestas": ["Sí", "No"]},
        {"texto": "Puedes comprar una por 10 monedas.", "accion": "abrir_tienda"}
      ],
      "ROCKY": [
        {"texto": "¡Necesito mineral de hierro para forjar!", "respuestas": ["Aquí tienes", "Lo siento"]}
      ]
    }
    ```
- **UI de diálogo**:
  - Ventana emergente con texto y opciones.
  - Botones para avanzar o seleccionar respuestas.
- **Integración con NPCs**:
  - Conectar el sistema de diálogo con `NPCBehavior.gd`.

**🛠️ Herramientas:**
- **Nodo `DialogoManager.gd`**:
  ```gdscript
  extends Control

  @export var npc: NPCAnimado
  @export var dialogo_label: Label
  @export var boton_siguiente: Button
  @export var botones_respuestas: VBoxContainer

  var _dialogo_actual: Array = []
  var _indice: int = 0

  func mostrar_dialogo(npc_name: String) -> void:
      var dialogos = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogos.json"))
      _dialogo_actual = dialogos[npc_name]
      _indice = 0
      _actualizar_ui()

  func _actualizar_ui() -> void:
      if _indice >= _dialogo_actual.size():
          queue_free()
          return

      var dialogo = _dialogo_actual[_indice]
      dialogo_label.text = dialogo["texto"]

      # Limpiar botones de respuestas
      for child in botones_respuestas.get_children():
          child.queue_free()

      if "respuestas" in dialogo:
          for respuesta in dialogo["respuestas"]:
              var boton = Button.new()
              boton.text = respuesta
              boton.pressed.connect(_on_respuesta_seleccionada.bind(respuesta))
              botones_respuestas.add_child(boton)
      else:
          boton_siguiente.visible = true

  func _on_respuesta_seleccionada(respuesta: String) -> void:
      _indice += 1
      _actualizar_ui()
  ```

**✅ Criterio de aceptación:**
- Diálogos funcionales para al menos 5 NPCs de prueba.
- **Entregable:** `dialogos.json` + `DialogoManager.gd`.

---

### **7️⃣ Sistema de tareas/interacciones**
**📍 Qué falta:**
- **Acciones específicas**:
  - **Pintora (Luna)**: Abrir tienda de cuadros.
  - **Herrero (Rocky)**: Forjar objetos (animación de martillar).
  - **Pescador (Fin)**: Pescar (animación de lanzar caña + espera).
  - **Jardinera (Flora)**: Plantar semillas (animación de agacharse).
- **Sistema de misiones**:
  - NPCs dan misiones al jugador (ej: "Trae 5 manzanas").
  - Recompensas al completar misiones.

**🛠️ Herramientas:**
- **Nodo `Tarea.gd`**:
  ```gdscript
  class_name Tarea
  extends RefCounted

  var npc: NPCAnimado
  var tipo: String
  var descripcion: String
  var recompensa: Dictionary
  var completada: bool = false

  func completar() -> void:
      completada = true
      npc.on_tarea_completada(recompensa)
  ```

**✅ Criterio de aceptación:**
- Al menos 3 NPCs con interacciones únicas funcionales.
- **Entregable:** Sistema de tareas integrado en `NPCBehavior.gd`.

---

### **8️⃣ Optimización de rendimiento**
**📍 Qué falta:**
- **Pruebas de FPS**:
  - Medir rendimiento con **20-30 NPCs en pantalla** (ALTA + MEDIA + BAJA).
  - Identificar cuellos de botella (ej: skinning, sombras, materiales).
- **Optimizaciones**:
  - **Occlusion Culling**: Usar `VisibilityNotifier3D` para ocultar NPCs fuera de cámara.
  - **Batch Rendering**: Agrupar materiales similares.
  - **LOD dinámico**: Ajustar distancias de cambio según hardware.

**🛠️ Herramientas:**
- **Script de prueba de rendimiento**:
  ```gdscript
  extends Node

  @export var npc_scene: PackedScene
  @export var count: int = 30
  @export var radius: float = 20.0

  func _ready() -> void:
      for i in range(count):
          var npc = npc_scene.instantiate()
          var angle = randf() * TAU
          var distance = randf() * radius
          npc.position = Vector3(cos(angle), 0, sin(angle)) * distance
          add_child(npc)
  ```

**✅ Criterio de aceptación:**
- FPS ≥ 60 con 30 NPCs en pantalla (en hardware medio).
- **Entregable:** Informe de optimización con capturas de FPS.

---

---

---

## 📌 **🟢 FASE TERCIARIA (Pulido final)**
*Objetivo: Detalles que mejoran la experiencia pero no son críticos para el MVP.*

---

### **9️⃣ Animaciones avanzadas**
**📍 Qué falta:**
- **Animaciones de transición**:
  - De `IDLE` a `CAMINAR` (y viceversa).
  - De `CAMINAR` a `SALUDO`.
- **Animaciones contextuales**:
  - **Sentarse**: Para NPCs en bancos (ej: Sage, Nana).
  - **Comer/beber**: Para Chef, Horno.
  - **Dormir**: Para NPCs nocturnos (ej: Obsidiana).
- **Animaciones faciales**:
  - Parpadeo, sonrisas (usando **shape keys** en Blender).

**🛠️ Herramientas:**
- **Shape Keys** en Blender para expresiones faciales.
- **Transiciones en Godot**:
  ```gdscript
  _animation_player.play("TRANSITION_IDLE_TO_WALK")
  await _animation_player.animation_finished
  _animation_player.play("CAMINAR")
  ```

**✅ Criterio de aceptación:**
- Al menos 2 animaciones avanzadas por NPC (ej: sentarse + parpadeo).
- **Entregable:** Clips de animación nuevos.

---

### **10️⃣ Efectos visuales**
**📍 Qué falta:**
- **Partículas**:
  - Polvo al caminar (para NPCs en tierra).
  - Burbujas para NPCs acuáticos (ej: Coral, Ola).
  - Chispas para herreros (Rocky, Caldera).
- **Sombras**:
  - Ajustar sombras dinámicas para NPCs.
- **Iluminación**:
  - Farol de Estrella Fugaz emite luz tenue.
  - Linterna de Brasa/Pedro emite luz.

**🛠️ Herramientas:**
- **GPUParticles3D** en Godot para efectos.
- **Light3D** para fuentes de luz dinámicas.

**✅ Criterio de aceptación:**
- Efectos visuales coherentes con el estilo cozy.
- **Entregable:** Escenas con partículas y luces integradas.

---

### **11️⃣ Sonidos**
**📍 Qué falta:**
- **Sonidos ambientales**:
  - Pasos (diferentes para tierra, madera, agua).
  - Herramientas (martillo, pincel, caña de pescar).
  - Voces (saludos, diálogos).
- **Música**:
  - Tema por isla (Raíz, Ceniza, Coral, Aurora).

**🛠️ Herramientas:**
- **AudioStreamPlayer3D** para sonidos espaciales.
- **Banco de sonidos** en `res://audio/`.

**✅ Criterio de aceptación:**
- Sonidos sincronizados con animaciones (ej: paso al caminar).
- **Entregable:** Banco de sonidos + integración en NPCs.

---

### **12️⃣ Localización (opcional)**
**📍 Qué falta:**
- Traducción de diálogos a otros idiomas (ej: inglés, francés).
- Sistema de selección de idioma.

**🛠️ Herramientas:**
- **JSON de localización**:
  ```json
  {
    "es": {"LUNA_0": "¡Hola, viajero!"},
    "en": {"LUNA_0": "Hello, traveler!"}
  }
  ```

**✅ Criterio de aceptación:**
- Diálogos traducidos para al menos 2 idiomas.
- **Entregable:** Sistema de localización integrado.

---

---

---
---

## 📌 **📋 RESUMEN DE ENTREGABLES FINALES**
| **Fase** | **Entregable** | **Prioridad** | **Estado** |
|----------|----------------|---------------|------------|
| **MVP** | 35 NPCs aprobados visualmente | ⭐⭐⭐⭐⭐ | ❌ Pendiente |
| **MVP** | Pruebas de importación en Godot | ⭐⭐⭐⭐⭐ | ❌ Pendiente |
| **MVP** | Skinning corregido | ⭐⭐⭐⭐ | ❌ Pendiente |
| **MVP** | Animaciones específicas por profesión | ⭐⭐⭐⭐ | ❌ Pendiente |
| **Secundaria** | Lógica de navegación y comportamiento | ⭐⭐⭐ | ❌ Pendiente |
| **Secundaria** | Sistema de diálogo | ⭐⭐⭐ | ❌ Pendiente |
| **Secundaria** | Sistema de tareas | ⭐⭐ | ❌ Pendiente |
| **Secundaria** | Optimización de rendimiento | ⭐⭐ | ❌ Pendiente |
| **Terciaria** | Animaciones avanzadas | ⭐ | ❌ Pendiente |
| **Terciaria** | Efectos visuales (partículas, luces) | ⭐ | ❌ Pendiente |
| **Terciaria** | Sonidos ambientales | ⭐ | ❌ Pendiente |
| **Terciaria** | Localización | ⭐ | ❌ Pendiente |

---

---
---

## 📌 **🎯 ORDEN RECOMENDADO DE TRABAJO**
1. **Revisión visual en Blender** (1-2 días).
2. **Pruebas de importación en Godot** (1 día).
3. **Ajustes de skinning** (1-2 días).
4. **Animaciones específicas por profesión** (2-3 días).
5. **Lógica de navegación y comportamiento** (2 días).
6. **Sistema de diálogo** (1 día).
7. **Sistema de tareas** (1 día).
8. **Optimización de rendimiento** (1 día).
9. **Animaciones avanzadas** (2 días).
10. **Efectos visuales y sonidos** (2 días).

**Tiempo estimado total:** ~2-3 semanas (dependiendo del equipo).

---
---
---

## 📌 **🔚 ¿QUÉ QUEDA PARA EL FINAL?**
- **Retocar detalles visuales** (texturas, materiales, bordados).
- **Pulir animaciones** (transiciones, sincronización con sonidos).
- **Pruebas finales** (bug fixing, balanceo de juego).
- **Documentación** (guía de estilo, pipeline de creación de NPCs).

---
---
---
## 📌 **💡 CONSEJOS FINALES**
1. **Empieza por el MVP**: Enfócate en los 4 primeros puntos de la fase crítica. Sin ellos, el juego no será jugable.
2. **Prueba en Godot temprano**: No esperes a tener todos los NPCs perfectos para integrarlos. Empieza con 5-10.
3. **Usa versionado**: Guarda copias de seguridad de los `.blend` y `.glb` antes de modificarlos.
4. **Prioriza el contenido visible**: Los NPCs son el corazón del juego. Invierte tiempo en que se vean bien.
5. **Optimiza al final**: No pierdas tiempo optimizando antes de tener el contenido funcional.

---
---
**¿Qué necesitas que desarrolle en detalle a continuación?** 😊
Por ejemplo:
- El script de **navegación y comportamiento** (`NPCBehavior.gd`).
- El sistema de **diálogos** (`DialogoManager.gd`).
- Las **animaciones específicas** para Fin o Roca.
- La **optimización de rendimiento**.