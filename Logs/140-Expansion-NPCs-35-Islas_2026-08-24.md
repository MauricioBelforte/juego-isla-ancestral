# Log 140: Expansión de NPCs a 35 (4 islas)

**Fecha:** 2026-08-24
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Se expandió la población del juego de 8 a **35 NPCs** distribuidos en 4 islas, satisfaciendo la solicitud del usuario de un pueblo lleno de gente que regale cosas, dinero, misiones y recompensas.

## Cambios Realizados

### M19 — NPC y Vecinos
- Población: 8 → **35 NPCs** (12 Raíz + 10 Ceniza + 8 Coral + 5 Aurora)
- 20 personalidades/profesiones definidas
- Tabla de regalos expandida a 35 NPCs
- Cada NPC tiene: regalo al jugador, misión temática, casa asignada
- Integración documentada con M161 (diseño visual), M162 (diálogos), M20 (amistad), M23 (misiones)

### Distribución por isla

| Isla | NPCs | Profesiones clave |
|------|------|-------------------|
| Raíz | 12 | Pintora, herrero, exploradora, cocinero, pescador, jardinera, bibliotecario, mercader, sanadora, carpintero, música, guardián |
| Ceniza | 10 | Minero, ermitaño, boticario, cocinero volcánico, explorador, minero-jefe, historiador, vendedor, guardián, músico |
| Coral | 8 | Pescador maestro, joyera, mercader, cultivador, guardián, astrónomo, constructor, músico |
| Aurora | 5 | Sabio anciano, astrónomo jefe, sanador, constructor de hielo, mensajero |

### NPCs que dan regalos, dinero y misiones
Todos los 35 NPCs tienen asignados:
- **Regalos al jugador:** items de su profesión (herramientas, recetas, muebles, etc.)
- **Misiones temáticas:** 1-2 misiones por NPC (explorar, cocinar, pescar, construir, etc.)
- **Recompensas:** monedas, items raros, recetas, muebles exclusivos

## Pendiente
- **M161 (Diseño Visual):** necesita actualización para incluir los 35 NPCs con diseño visual único
- **M162 (Diálogos):** necesita actualización para incluir diálogos de los 35 NPCs por capítulo

## Archivos Modificados
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/01-Requerimientos.md` — población expandida a 35
- `DOCUMENTACION/5-FUTURAS-MEJORAS.md` — item "cantidad de NPCs" marcado [x]
