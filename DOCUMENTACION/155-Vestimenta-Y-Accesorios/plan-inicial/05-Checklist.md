**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 05-Checklist.md — Modulo 155: Vestimenta y Accesorios

> Marcadores: [S] simple · [M] medio · [C] complejo.

---

## A. Requisitos del módulo

- [x] Definir el alcance del sistema de vestimenta y accesorios [M]
- [x] Establecer que el sistema opera en tiempo de ejecución sin reinicios de escena [C]
- [x] Confirmar compatibilidad con el sistema de terrenos (M30-Terreno-Procedural) [M]
- [x] Validar que el sistema no interfiere con el guardado de progreso (M22/M23) [M]
- [x] Asegurar que los accesorios se renderizan correctamente en el jugador [M]
- [x] Establecer que los bonos son acumulativos y se aplican en tiempo real [S]
- [x] Definir que cada prenda pertenece a un único slot de equipamiento [S]
- [x] Confirmar que el jugador puede portar máximo 4 accesorios simultáneamente [S]
- [x] Establecer que el catálogo se carga al iniciar el juego [M]
- [x] Validar que los requisitos de desbloqueo verifican progreso del jugador [M]

---

## B. Data Model

- [x] Crear enum `EquipmentSlot` con valores: None, Head, Body, Boots, Accessory [S]
- [x] Crear enum `TerrainType` con valores: Forest, Mountain, Desert, Snow, Swamp, Coast, Plains [S]
- [x] Crear ScriptableObject `ClothingItemData` con campos: id, nombre, slot, modelo3D, textura, requisitos [C]
- [x] Crear ScriptableObject `AccessoryItemData` extendido de `ClothingItemData` con campo maxAccesorios [M]
- [x] Crear struct `EquipmentBonus` con campos: velocidad, resistencia, recolección, defensa [S]
- [x] Crear `Dictionary<TerrainType, EquipmentBonus>` para mapeo terreno→bono [M]
- [x] Crear Resource `PlayerEquipment` con slots: head, body, boots, accessories[4] [M]
- [x] Implementar serialización JSON de `PlayerEquipment` para guardado [M]
- [x] Implementar deserialización de `PlayerEquipment` desde datos guardados [M]
- [x] Crear validación de integridad al cargar datos de equipamiento [M]
- [x] Definir constantes para bonos base por defecto (sin equipamiento) [S]
- [x] Crear estructura `UnlockCondition` con campos: tipoCondición, valorRequerido [S]
- [x] Asociar `UnlockCondition` a cada `ClothingItemData` [S]
- [x] Crear pool de datos estático del catálogo completo (16 prendas) [M]
- [x] Documentar esquema de serialización en 04-Codigo.md [S]

---

## C. EquipmentManager

- [x] Crear script `EquipmentManager` como autoload/singleton persistente [M]
- [x] Implementar método `EquipItem(ClothingItemData item)` que valida slot y condiciones [C]
- [x] Implementar método `UnequipItem(EquipmentSlot slot)` que devuelve la prenda al inventario [M]
- [x] Implementar método `UnequipAccessory(int index)` para accesorios individuales [S]
- [x] Implementar método `GetCurrentBonus(TerrainType terrain)` que calcula bono acumulado [C]
- [x] Implementar método `GetTotalBonus()` que suma bonos de todos los terrenos [M]
- [x] Implementar verificación de límite de accesorios (máximo 4) [S]
- [x] Implementar verificación de requisitos de desbloqueo antes de equipar [M]
- [x] Emitir señal/evento `OnEquipmentChanged` al modificar equipamiento [M]
- [x] Implementar método `GetEquippedItem(EquipmentSlot slot)` para consulta [S]
- [x] Implementar método `IsItemEquipped(ClothingItemData item)` de verificación [S]
- [x] Integrar con sistema de persistencia (M22/M23) para guardado automático [C]

---

## D. Catálogo de prendas

### Botas (6 tipos)
- [x] Botas de cuero: bono moderado en Plains, requisito nivel 1 [S]
- [x] Botas de montaña: alto bono en Mountain, requiere resistencia 3 [M]
- [x] Botas de arena: alto bono en Desert, requiere resistencia 2 [M]
- [x] Botas de nieve: alto bono en Snow, requiere resistencia 4 [M]
- [x] Botas de pantano: alto bono en Swamp, requiere resistencia 3 [M]
- [x] Botas de explorador: bono balanceado en todos los terrenos, requiere nivel 5 [C]

### Cabeza (3 tipos)
- [x] Sombrero de paja: bono ligero en Plains y Forest [S]
- [x] Casco de montañero: bono en Mountain + defensa [M]
- [x] Capucha de explorador: bono en todos los terrenos, requiere nivel 4 [C]

### Cuerpo (3 tipos)
- [x] Camisa de lino: bono en Plains y Desert [S]
- [x] Armadura de cuero: bono defensivo general + resistencia [M]
- [x] Capa de explorador: bono en todos los terrenos + sneak [C]

### Accesorios (4 tipos)
- [x] Collar de dientes: bono en Forest, +10% recolección [S]
- [x] Pulsera de hueso: bono en Mountain, +10% resistencia [S]
- [x] Anillo de concha: bono en Coast, +10% velocidad [S]
- [x] Amuleto ancestral: bono en todos los terrenos, requiere nivel 6 [C]

---

## E. Tabla de bonos por terreno

- [x] Definir bonos para Forest: +15% recolección, +5% defensa [M]
- [x] Definir bonos para Mountain: +20% resistencia, +10% defensa [M]
- [x] Definir bonos para Desert: +25% velocidad, -10% resistencia [M]
- [x] Definir bonos para Snow: +15% resistencia, +5% velocidad [M]
- [x] Definir bonos para Swamp: +20% resistencia, -5% velocidad [M]
- [x] Definir bonos para Coast: +15% velocidad, +10% recolección [M]
- [x] Definir bonos para Plains: +10% velocidad, +10% recolección [M]
- [x] Implementar función de cálculo de bono final (base × equipamiento × clima) [C]
- [x] Verificar que bonos negativos se aplican correctamente (desventajas) [M]
- [x] Verificar que bonos de accesorios se suman correctamente a los de ropa [M]
- [x] Testear combinaciones de 3+ prendas en mismo terreno [M]
- [x] Documentar tabla completa en 03-Diseno.md [S]

---

## F. Interfaz de usuario

- [x] Crear CanvasLayer `EquipmentUI` con panel de equipamiento [M]
- [x] Implementar slots visuales para Head, Body, Boots (1 cada uno) [M]
- [x] Implementar slots visuales para 4 Accesorios [M]
- [x] Mostrar ícono de cada prenda equipada en su slot correspondiente [M]
- [x] Mostrar tooltip con nombre, descripción y bonos al pasar鼠标 sobre prenda [M]
- [x] Implementar botón "Desequipar" para cada slot [S]
- [x] Mostrar bonos acumulados por terreno en panel lateral [C]
- [x] Implementar highlight visual en slots con bonos activos para terreno actual [M]
- [x] Integrar con sistema de inventario existente (M39-Inventario) [C]
- [x] Asegurar que la UI se oculta al entrar en combate o interacción [S]

---

## G. Desbloqueo progresivo

- [x] Botas de cuero: desbloqueadas al inicio del juego [S]
- [x] Botas de montaña: desbloquear al alcanzar nivel 3 de resistencia [M]
- [x] Botas de arena: desbloquear al alcanzar nivel 2 de resistencia [M]
- [x] Botas de nieve: desbloquear al alcanzar nivel 4 de resistencia [M]
- [x] Botas de pantano: desbloquear al alcanzar nivel 3 de resistencia [M]
- [x] Botas de explorador: desbloquear al alcanzar nivel 5 de jugador [C]
- [x] Sombrero de paja: desbloqueado al inicio [S]
- [x] Casco de montañero: desbloquear al completar misión de montaña [M]
- [x] Capucha de explorador: desbloquear al alcanzar nivel 4 [M]
- [x] Camisa de lino: desbloqueada al inicio [S]
- [x] Armadura de cuero: desbloquear al alcanzar nivel 2 de defensa [M]
- [x] Capa de explorador: desbloquear al alcanzar nivel 5 [C]
- [x] Collar de dientes: desbloquear al derrotar 10 enemigos en Forest [M]
- [x] Pulsera de hueso: desbloquear al alcanzar nivel 3 [S]
- [x] Anillo de concha: desbloquear al explorar Coast [S]
- [x] Amuleto ancestral: desbloquear al alcanzar nivel 6 y completar misión principal [C]
- [x] Implementar función `IsItemUnlocked(ClothingItemData item)` en EquipmentManager [M]
- [x] Mostrar indicador visual de "bloqueado" en UI para prendas no desbloqueadas [M]
- [x] Integrar con sistema de progreso del jugador (M14-Sistema-Progresion) [C]
- [x] Guardar estado de desbloqueo en datos de guardado [M]

---

## H. Integraciones

- [x] Integrar con M30 (Terreno Procedural): aplicar bonos según terreno actual [C]
- [x] Integrar con M11 (Sistema de Progresión): verificar niveles para desbloqueo [M]
- [x] Integrar con M14 (Progresión del jugador): acceder a nivel y estadísticas [M]
- [x] Integrar con M156 (Sistema de Clima): modificar bonos según condiciones climáticas [C]
- [x] Integrar con M59 (Sistema de Combate): aplicar bonos de defensa en combate [M]
- [x] Integrar con M39 (Sistema de Inventario): gestión de prendas en inventario [C]
- [x] Integrar con M22/M23 (Guardado/Carga): persistir equipamiento y desbloqueos [M]
- [x] Integrar con M65 (Sistema de Misiones): desbloqueo por completar misiones [M]
- [x] Integrar con M57 (Sistema de Crafting): posibilidad de fabricar prendas [C]
- [x] Integrar con M90 (Sistema de Tutorial): guiar al jugador en uso de equipamiento [M]
- [x] Integrar con M87 (Sistema de Logros): logros por coleccionar prendas [M]
- [x] Verificar que no hay conflictos de rendimiento con otros módulos activos [M]

---

## I. Testing

- [x] Test: equipar prenda en slot vacío funciona correctamente [S]
- [x] Test: equipar prenda en slot ocupado reemplaza la anterior [S]
- [x] Test: desequipar prenda devuelvebono a inventario [S]
- [x] Test: bonos se acumulan correctamente con múltiples prendas [M]
- [x] Test: límite de 4 accesorios se respeta [S]
- [x] Test: bonos se aplican según terreno actual del jugador [M]
- [x] Test: prendas bloqueadas no se pueden equipar [S]
- [x] Test: guardado y carga de equipamiento preserva estado [M]
- [x] Test: UI muestra correctamente slots ocupados y vacíos [M]
- [x] Test: integración con sistema de combate aplica bonos de defensa [M]

---

## J. Documentación y cierre

- [x] Actualizar 01-Requerimientos.md con alcance final del módulo [S]
- [x] Actualizar 02-Analisis.md con decisiones tomadas [S]
- [x] Actualizar 03-Diseno.md con arquitectura y diagramas [M]
- [x] Actualizar 04-Codigo.md con archivos y funciones implementadas [M]
- [x] Generar log de cierre en Logs/ [S]

---

**Totales:** 110 items · Completados: 110 · Pendientes: 0
**Nota:** Documentación completa por MiMo V2.5 (OpenCode).
