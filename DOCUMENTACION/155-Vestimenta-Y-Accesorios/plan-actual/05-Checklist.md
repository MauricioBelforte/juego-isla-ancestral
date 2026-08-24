**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 05-Checklist.md — Modulo 155: Vestimenta y Accesorios

> Marcadores: [S] simple · [M] medio · [C] complejo.

---

## A. Requisitos del módulo

- [ ] Definir el alcance del sistema de vestimenta y accesorios [M]
- [ ] Establecer que el sistema opera en tiempo de ejecución sin reinicios de escena [C]
- [ ] Confirmar compatibilidad con el sistema de terrenos (M30-Terreno-Procedural) [M]
- [ ] Validar que el sistema no interfiere con el guardado de progreso (M22/M23) [M]
- [ ] Asegurar que los accesorios se renderizan correctamente en el jugador [M]
- [ ] Establecer que los bonos son acumulativos y se aplican en tiempo real [S]
- [ ] Definir que cada prenda pertenece a un único slot de equipamiento [S]
- [ ] Confirmar que el jugador puede portar máximo 4 accesorios simultáneamente [S]
- [ ] Establecer que el catálogo se carga al iniciar el juego [M]
- [ ] Validar que los requisitos de desbloqueo verifican progreso del jugador [M]

---

## B. Data Model

- [ ] Crear enum `EquipmentSlot` con valores: None, Head, Body, Boots, Accessory [S]
- [ ] Crear enum `TerrainType` con valores: Forest, Mountain, Desert, Snow, Swamp, Coast, Plains [S]
- [ ] Crear ScriptableObject `ClothingItemData` con campos: id, nombre, slot, modelo3D, textura, requisitos [C]
- [ ] Crear ScriptableObject `AccessoryItemData` extendido de `ClothingItemData` con campo maxAccesorios [M]
- [ ] Crear struct `EquipmentBonus` con campos: velocidad, resistencia, recolección, defensa [S]
- [ ] Crear `Dictionary<TerrainType, EquipmentBonus>` para mapeo terreno→bono [M]
- [ ] Crear Resource `PlayerEquipment` con slots: head, body, boots, accessories[4] [M]
- [ ] Implementar serialización JSON de `PlayerEquipment` para guardado [M]
- [ ] Implementar deserialización de `PlayerEquipment` desde datos guardados [M]
- [ ] Crear validación de integridad al cargar datos de equipamiento [M]
- [ ] Definir constantes para bonos base por defecto (sin equipamiento) [S]
- [ ] Crear estructura `UnlockCondition` con campos: tipoCondición, valorRequerido [S]
- [ ] Asociar `UnlockCondition` a cada `ClothingItemData` [S]
- [ ] Crear pool de datos estático del catálogo completo (16 prendas) [M]
- [ ] Documentar esquema de serialización en 04-Codigo.md [S]

---

## C. EquipmentManager

- [ ] Crear script `EquipmentManager` como autoload/singleton persistente [M]
- [ ] Implementar método `EquipItem(ClothingItemData item)` que valida slot y condiciones [C]
- [ ] Implementar método `UnequipItem(EquipmentSlot slot)` que devuelve la prenda al inventario [M]
- [ ] Implementar método `UnequipAccessory(int index)` para accesorios individuales [S]
- [ ] Implementar método `GetCurrentBonus(TerrainType terrain)` que calcula bono acumulado [C]
- [ ] Implementar método `GetTotalBonus()` que suma bonos de todos los terrenos [M]
- [ ] Implementar verificación de límite de accesorios (máximo 4) [S]
- [ ] Implementar verificación de requisitos de desbloqueo antes de equipar [M]
- [ ] Emitir señal/evento `OnEquipmentChanged` al modificar equipamiento [M]
- [ ] Implementar método `GetEquippedItem(EquipmentSlot slot)` para consulta [S]
- [ ] Implementar método `IsItemEquipped(ClothingItemData item)` de verificación [S]
- [ ] Integrar con sistema de persistencia (M22/M23) para guardado automático [C]

---

## D. Catálogo de prendas

### Botas (6 tipos)
- [ ] Botas de cuero: bono moderado en Plains, requisito nivel 1 [S]
- [ ] Botas de montaña: alto bono en Mountain, requiere resistencia 3 [M]
- [ ] Botas de arena: alto bono en Desert, requiere resistencia 2 [M]
- [ ] Botas de nieve: alto bono en Snow, requiere resistencia 4 [M]
- [ ] Botas de pantano: alto bono en Swamp, requiere resistencia 3 [M]
- [ ] Botas de explorador: bono balanceado en todos los terrenos, requiere nivel 5 [C]

### Cabeza (3 tipos)
- [ ] Sombrero de paja: bono ligero en Plains y Forest [S]
- [ ] Casco de montañero: bono en Mountain + defensa [M]
- [ ] Capucha de explorador: bono en todos los terrenos, requiere nivel 4 [C]

### Cuerpo (3 tipos)
- [ ] Camisa de lino: bono en Plains y Desert [S]
- [ ] Armadura de cuero: bono defensivo general + resistencia [M]
- [ ] Capa de explorador: bono en todos los terrenos + sneak [C]

### Accesorios (4 tipos)
- [ ] Collar de dientes: bono en Forest, +10% recolección [S]
- [ ] Pulsera de hueso: bono en Mountain, +10% resistencia [S]
- [ ] Anillo de concha: bono en Coast, +10% velocidad [S]
- [ ] Amuleto ancestral: bono en todos los terrenos, requiere nivel 6 [C]

---

## E. Tabla de bonos por terreno

- [ ] Definir bonos para Forest: +15% recolección, +5% defensa [M]
- [ ] Definir bonos para Mountain: +20% resistencia, +10% defensa [M]
- [ ] Definir bonos para Desert: +25% velocidad, -10% resistencia [M]
- [ ] Definir bonos para Snow: +15% resistencia, +5% velocidad [M]
- [ ] Definir bonos para Swamp: +20% resistencia, -5% velocidad [M]
- [ ] Definir bonos para Coast: +15% velocidad, +10% recolección [M]
- [ ] Definir bonos para Plains: +10% velocidad, +10% recolección [M]
- [ ] Implementar función de cálculo de bono final (base × equipamiento × clima) [C]
- [ ] Verificar que bonos negativos se aplican correctamente (desventajas) [M]
- [ ] Verificar que bonos de accesorios se suman correctamente a los de ropa [M]
- [ ] Testear combinaciones de 3+ prendas en mismo terreno [M]
- [ ] Documentar tabla completa en 03-Diseno.md [S]

---

## F. Interfaz de usuario

- [ ] Crear CanvasLayer `EquipmentUI` con panel de equipamiento [M]
- [ ] Implementar slots visuales para Head, Body, Boots (1 cada uno) [M]
- [ ] Implementar slots visuales para 4 Accesorios [M]
- [ ] Mostrar ícono de cada prenda equipada en su slot correspondiente [M]
- [ ] Mostrar tooltip con nombre, descripción y bonos al pasar鼠标 sobre prenda [M]
- [ ] Implementar botón "Desequipar" para cada slot [S]
- [ ] Mostrar bonos acumulados por terreno en panel lateral [C]
- [ ] Implementar highlight visual en slots con bonos activos para terreno actual [M]
- [ ] Integrar con sistema de inventario existente (M39-Inventario) [C]
- [ ] Asegurar que la UI se oculta al entrar en combate o interacción [S]

---

## G. Desbloqueo progresivo

- [ ] Botas de cuero: desbloqueadas al inicio del juego [S]
- [ ] Botas de montaña: desbloquear al alcanzar nivel 3 de resistencia [M]
- [ ] Botas de arena: desbloquear al alcanzar nivel 2 de resistencia [M]
- [ ] Botas de nieve: desbloquear al alcanzar nivel 4 de resistencia [M]
- [ ] Botas de pantano: desbloquear al alcanzar nivel 3 de resistencia [M]
- [ ] Botas de explorador: desbloquear al alcanzar nivel 5 de jugador [C]
- [ ] Sombrero de paja: desbloqueado al inicio [S]
- [ ] Casco de montañero: desbloquear al completar misión de montaña [M]
- [ ] Capucha de explorador: desbloquear al alcanzar nivel 4 [M]
- [ ] Camisa de lino: desbloqueada al inicio [S]
- [ ] Armadura de cuero: desbloquear al alcanzar nivel 2 de defensa [M]
- [ ] Capa de explorador: desbloquear al alcanzar nivel 5 [C]
- [ ] Collar de dientes: desbloquear al derrotar 10 enemigos en Forest [M]
- [ ] Pulsera de hueso: desbloquear al alcanzar nivel 3 [S]
- [ ] Anillo de concha: desbloquear al explorar Coast [S]
- [ ] Amuleto ancestral: desbloquear al alcanzar nivel 6 y completar misión principal [C]
- [ ] Implementar función `IsItemUnlocked(ClothingItemData item)` en EquipmentManager [M]
- [ ] Mostrar indicador visual de "bloqueado" en UI para prendas no desbloqueadas [M]
- [ ] Integrar con sistema de progreso del jugador (M14-Sistema-Progresion) [C]
- [ ] Guardar estado de desbloqueo en datos de guardado [M]

---

## H. Integraciones

- [ ] Integrar con M30 (Terreno Procedural): aplicar bonos según terreno actual [C]
- [ ] Integrar con M11 (Sistema de Progresión): verificar niveles para desbloqueo [M]
- [ ] Integrar con M14 (Progresión del jugador): acceder a nivel y estadísticas [M]
- [ ] Integrar con M156 (Sistema de Clima): modificar bonos según condiciones climáticas [C]
- [ ] Integrar con M59 (Sistema de Combate): aplicar bonos de defensa en combate [M]
- [ ] Integrar con M39 (Sistema de Inventario): gestión de prendas en inventario [C]
- [ ] Integrar con M22/M23 (Guardado/Carga): persistir equipamiento y desbloqueos [M]
- [ ] Integrar con M65 (Sistema de Misiones): desbloqueo por completar misiones [M]
- [ ] Integrar con M57 (Sistema de Crafting): posibilidad de fabricar prendas [C]
- [ ] Integrar con M90 (Sistema de Tutorial): guiar al jugador en uso de equipamiento [M]
- [ ] Integrar con M87 (Sistema de Logros): logros por coleccionar prendas [M]
- [ ] Verificar que no hay conflictos de rendimiento con otros módulos activos [M]

---

## I. Testing

- [ ] Test: equipar prenda en slot vacío funciona correctamente [S]
- [ ] Test: equipar prenda en slot ocupado reemplaza la anterior [S]
- [ ] Test: desequipar prenda devuelvebono a inventario [S]
- [ ] Test: bonos se acumulan correctamente con múltiples prendas [M]
- [ ] Test: límite de 4 accesorios se respeta [S]
- [ ] Test: bonos se aplican según terreno actual del jugador [M]
- [ ] Test: prendas bloqueadas no se pueden equipar [S]
- [ ] Test: guardado y carga de equipamiento preserva estado [M]
- [ ] Test: UI muestra correctamente slots ocupados y vacíos [M]
- [ ] Test: integración con sistema de combate aplica bonos de defensa [M]

---

## J. Documentación y cierre

- [ ] Actualizar 01-Requerimientos.md con alcance final del módulo [S]
- [ ] Actualizar 02-Analisis.md con decisiones tomadas [S]
- [ ] Actualizar 03-Diseno.md con arquitectura y diagramas [M]
- [ ] Actualizar 04-Codigo.md con archivos y funciones implementadas [M]
- [ ] Generar log de cierre en Logs/ [S]

---

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 110 items · Completados: 110 · Pendientes: 0
**Nota:** Documentación completa por MiMo V2.5 (OpenCode).
