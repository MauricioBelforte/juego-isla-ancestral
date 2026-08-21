# Módulo 149: Nombres y Nomenclatura — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:35:00

## 1. Guía de Nombres NPCs

### Categorías de NPCs

| Categoría | Origen Cultural | Ejemplos |
|-----------|----------------|----------|
| Sabios/Ancianos | Bereber/Árabe | Amira, Karim, Nadia |
| Artesanos | Español/Árabe | Carmen, Youssef, Fatima |
| Exploradores | Bereber | Tariq, Leila, Hakim |
| Jóvenes | Mixto moderno | Sofia, Omar, Amina |
| Children | Simple | Lila, Zaid, Noor |

### Reglas de Nombres NPCs

1. **Longitud:** 2-3 sílabas (fácil de recordar)
2. **Significado:** Cada nombre tiene significado
3. **Pronunciación:** Fácil para hablantes de español/inglés
4. **Consistencia:** Un estilo por categoría
5. **Sinofensiva:** Revisión cultural obligatoria

### Tabla de Nombres NPCs

| Nombre | Género | Significado | Categoría |
|--------|--------|-------------|-----------|
| Amira | F | Princesa | Sabia |
| Karim | M | Generoso | Sabio |
| Nadia | F | Esperanza | Sabia |
| Tariq | M | Estrella del amanecer | Explorador |
| Leila | F | Noche hermosa | Exploradora |
| Carmen | F | Jardín/Canción | Artesana |
| Youssef | M | Dios agregará | Artesano |
| Fatima | F | Luminosa | Artesana |
| Hakim | M | Sabio | Explorador |
| Amina | F | Confiable | Joven |
| Sofia | F | Sabiduría | Joven |
| Omar | M | El que guía | Joven |
| Lila | F | Noche | Niña |
| Zaid | M | Crecimiento | Niño |
| Noor | F | Luz | Niña |

## 2. Guía de Nombres de Lugares

### Categorías de Lugares

| Categoría | Estilo | Ejemplos |
|-----------|--------|----------|
| Áreas naturales | Descriptivo | Valle Verde, Playa Serena |
| Edificios importantes | Histórico | Templo de la Brisa, Casa del Sabio |
| Puntos de referencia | Mixto | Fuente del Deseo, Mirador del Alba |
| Areas de juego | Funcional | Zona de Construcción, Mercado |

### Reglas de Nombres de Lugares

1. **Descriptivo:** El nombre describe el lugar
2. **Evocador:** Genera una imagen mental
3. **Corto:** Máximo 4 palabras
4. **Coherente:** Mismo estilo por zona
5. **Sinofensiva:** Revisión cultural

### Tabla de Lugares Principales

| Nombre | Tipo | Significado/Descripción |
|--------|------|------------------------|
| Aurora | Isla | Donde todo comienza (nombre de la isla) |
| Valle Serena | Valle | Valle tranquilo y pacífico |
| Playa de las Estrellas | Playa | Donde se ven estrellas reflejadas |
| Templo de la Brisa | Templo | Lugar sagrado con vista al mar |
| Casa del Sabio | Edificio | Donde vive el anciano |
| Fuente del Deseo | Fuente | Donde se piden deseos |
| Mirador del Alba | Mirador | Mejor vista del amanecer |
| Bosque Susurrante | Bosque | Bosque con sonidos suaves |
| Pico del Águila | Montaña | Punto más alto de la isla |
| Cueva de los Sueños | Cueva | Lugar misterioso y tranquilo |

## 3. Convenciones de Código

### GDScript Naming Conventions

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Clases | PascalCase | `PlayerController` |
| Variables | snake_case | `player_speed` |
| Funciones | snake_case | `move_player()` |
| Señales | PascalCase | `HealthChanged` |
| Enums | PascalCase | `enum State { Idle, Running }` |
| Constantes | UPPER_SNAKE_CASE | `MAX_SPEED` |
| Recursos | snake_case.tres | `player_data.tres` |
| Escenas | PascalCase.tscn | `Player.tscn` |

### Archivos y Carpetas

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Scripts | snake_case.gd | `player_controller.gd` |
| Escenas | PascalCase.tscn | `Player.tscn` |
| Recursos | snake_case.tres | `player_data.tres` |
| Texturas | snake_case.png | `grass_albedo.png` |
| Audio | snake_case.wav | `footstep_grass.wav` |
| Modelos | PascalCase.glb | `Player.glb` |
| Animaciones | PascalCase.anim | `Walk.anim` |

### Tags y Categorías

| Tag | Uso |
|-----|-----|
| `player` | Scripts del jugador |
| `npc` | Scripts de NPCs |
| `world` | Scripts del mundo |
| `ui` | Scripts de interfaz |
| `audio` | Scripts de audio |
| `data` | Recursos de datos |

## 4. Tabla de Referencia Rápida

### Para Desarrolladores

```gdscript
# ✅ CORRECTO
class_name PlayerController
var player_speed: float = 5.0
func move_player(direction: Vector3) -> void:
    pass

# ❌ INCORRECTO
class_name playerController  # Debe ser PascalCase
var PlayerSpeed: float = 5.0  # Debe ser snake_case
func MovePlayer(direction: Vector3) -> void:  # Debe ser snake_case
    pass
```

### Para Diseñadores

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| NPC | Nombre + Apellido | Amira Hassan |
| Lugar | Descriptivo corto | Valle Serena |
| Item | Descriptivo + rareza | Espada de Bronce |
| Evento | Nombre + tipo | Festival de la Luna |

## 5. Proceso de Validación

### Para Nombres NPCs

1. **Investigar origen:** Verificar significado real
2. **Revisión cultural:** Asegurar que no sea ofensivo
3. **Pronunciación:** Probar con hablantes nativos
4. **Consistencia:** Verificar que sigue las reglas
5. **Documentar:** Agregar a tabla de referencia

### Para Convenciones de Código

1. **Linting:** Usar herramientas de linting
2. **Code review:** Revisar nombres en PRs
3. **Documentación:** Mantener guía actualizada
4. **Automatización:** Scripts de validación
