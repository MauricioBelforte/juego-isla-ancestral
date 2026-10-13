**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 76: Multijugador (130 ítems)

## A. Decisión de Producto (RF1)

- [x] Decidir si habrá multijugador (v1: NO, single-player cozy) [M] — **Diseño: 02-Analisis.md 3.1**
- [x] Documentar la decisión con argumentos de género (AC/Stardew/CozyGrove) [M] — **Diseño: 02-Analisis.md 1**
- [x] Documentar la decisión con argumentos de coste [M] — **Diseño: 02-Analisis.md 2.4**
- [ ] Verificar que el postgame (M75) cubre la vida de la isla sin red [M]
- [?] Registrar la decisión en el manifiesto mp_contract.json [S]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)]

## B. Modo Local (RF2)

- [x] Definir el modo local como primera forma de MP [M] — **Diseño: 02-Analisis.md 2.1 A1**
- [x] Definir 2 jugadores en el mismo dispositivo [S] — **Diseño: 03-Diseno.md 2**
- [x] Definir split-screen como presentación local [M] — **Diseño: 03-Diseno.md 2**
- [x] Definir host autoritativo para el modo local [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir frame budget 60 FPS antes de aprobar la feature (M61) [C] — **Diseño: 03-Diseno.md 2.3 Flujo B**

## C. Modo Online (RF3)

- [x] Diferir el online como extensión futura [S] — **Diseño: 02-Analisis.md 2.1 A2**
- [x] Condicionar el online a hit de métricas (>10k descargas) [M] — **Diseño: 02-Analisis.md 2.4**
- [x] Exigir M77 (Online y Red) antes de cualquier online [S] — **Diseño: 03-Diseno.md 5**
- [x] Definir máximo de 4 jugadores online [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Documentar presupuesto estimado de servidores [M] — **Diseño: 02-Analisis.md 2.4 A2**

## D. Cantidad de Jugadores (RF4)

- [x] Definir 1 jugador en v1 (single) [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir 2 jugadores para el modo local [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir 4 jugadores máximo para online futuro [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Documentar el impacto de rendimiento por jugador extra [M] — **Diseño: 03-Diseno.md 6**
- [ ] Verificar que la cantidad no rompe el cozy (sin multitudes) [S]

## E. Anfitrión (RF5)

- [x] Definir el anfitrión = jugador que crea la isla [S] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir que el anfitrión posee el mundo [S] — **Diseño: 03-Diseno.md 4**
- [x] Definir invitado sin poder de host [S] — **Diseño: 02-Analisis.md 3.2**
- [ ] Documentar migración de host (si se cierra sesión) [M]
- [ ] Registrar la autoridad en el manifiesto [S]

## F. Servidor (RF6)

- [x] Definir P2P/split para el modo local (sin servidor) [S] — **Diseño: 01-Requerimientos.md 5 RF6**
- [x] Definir servidor dedicado SOLO para online futuro [M] — **Diseño: 01-Requerimientos.md 5 RF6**
- [x] Documentar $0 de servidores en v1 [S] — **Diseño: 02-Analisis.md 2.4 A1**
- [x] Documentar la estimación mensual de servidor dedicado [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [ ] Registrar servidores_v1=false en el manifiesto [S]

## G. Sincronización (RF7)

- [x] Definir host autoritativo (simula mundo, recibe inputs) [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir snapshot+reconciliación para online (M77) [M] — **Diseño: 02-Analisis.md 2.3 A2**
- [ ] Definir tick rate de referencia (10-20 Hz estado) [M]
- [ ] Documentar interpolar animaciones del invitado (M13) [M]
- [ ] Verificar determinismo local (split no red) [M]

## H. Autoridad (RF8)

- [x] Definir autoridad del host en el mundo [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir autoridad del invitado sobre su avatar [S] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir autoridad del servidor para online (M77) [M] — **Diseño: 03-Diseno.md 3.2**
- [ ] Documentar regla: el invitado no desbloquea logros en la isla ajena (M72) [M]
- [ ] Registrar authority=host en el manifiesto [S]

## I. Persistencia (RF9)

- [x] Definir save individual sin cambio de formato (M59) [M] — **Diseño: 03-Diseno.md 4**
- [x] Definir invitado = perfil local (M92) [M] — **Diseño: 03-Diseno.md 4**
- [x] Definir que el invitado NO persiste en la isla del host [S] — **Diseño: 02-Analisis.md 2.2 A1**
- [x] Documentar cero conflictos de escritura de saves [S] — **Diseño: 02-Analisis.md 2.2 A1**
- [ ] Verificar migración M60 intacta [S]

## J. Permisos (RF10)

- [x] Definir invitado sin zona destructiva [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir edición permitida en zona asignada [M] — **Diseño: 01-Requerimientos.md 5 RF10**
- [x] Definir casa del host protegida [S] — **Diseño: 01-Requerimientos.md 5 RF10**
- [x] Documentar permisos por diseño (anti-griefing) [S] — **Diseño: 02-Analisis.md 3.2**
- [ ] Verificar permisos en el manifiesto [S]

## K. Invitaciones (RF11)

- [x] Definir invitación local = segundo mando [S] — **Diseño: 01-Requerimientos.md 5 RF11**
- [x] Definir código de visita con expiración (online futuro) [M] — **Diseño: 01-Requerimientos.md 5 RF11**
- [ ] Definir lista de amigos futura (M77) [M]
- [x] Documentar flujo de invitación sin cuentas en v1 [S] — **Diseño: 02-Analisis.md 3.5**
- [ ] Verificar que la invitación nunca expone datos [S]

## L. Cuentas (RF12)

- [x] Definir sin cuentas en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Definir perfiles locales (M92) [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Definir cuenta opcional SOLO para online futuro [M] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Documentar el servicio de cuenta como externo (M77) [M] — **Diseño: 01-Requerimientos.md 3.2**
- [ ] Verificar privacidad del perfil local [S]

## M. Identidad (RF13)

- [x] Definir avatar de perfil (M92) [S] — **Diseño: 01-Requerimientos.md 5 RF13**
- [x] Definir nombre de isla único en visitas [M] — **Diseño: 01-Requerimientos.md 5 RF13**
- [ ] Definir nombre de jugador editable [S]
- [x] Documentar identidad sin cuentas (local) [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [ ] Verificar identidad en el manifiesto [S]

## N. Chat (RF14)

- [x] Definir sin chat en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF14**
- [x] Definir frases rápidas (T-chat moderado) [M] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir sin texto libre en el cozy [S] — **Diseño: 03-Diseno.md 3.2**
- [?] Definir sistema de reporte si hay texto libre futuro [M]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)]
- [ ] Registrar chat=frases rapidas en el manifiesto [S]

## O. Emotes (RF15)

- [x] Definir rueda de emotes [S] — **Diseño: 01-Requerimientos.md 5 RF15**
- [x] Definir emotes como notificaciones express (M44) [M] — **Diseño: 03-Diseno.md 5**
- [ ] Definir set base de emotes (hola, gracias, risa, enojo) [S]
- [ ] Documentar animaciones de emotes (M13) [M]
- [ ] Verificar que los emotes no requieren red en local [S]

## P. Intercambio (RF16)

- [x] Definir sin intercambio en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF16**
- [x] Definir trueque futuro solo decorativo (M38) [M] — **Diseño: 02-Analisis.md 3.6**
- [x] Prohibir transferencia de ítems de historia (M22/M23) [S] — **Diseño: 02-Analisis.md 3.6**
- [x] Prohibir transferencia de colecciones de avance (M73) [S] — **Diseño: 02-Analisis.md 3.6**
- [ ] Verificar economía protegida en el manifiesto [S]

## Q. Construcción Cooperativa (RF17)

- [x] Definir construcción cooperativa futura solo en zona permitida [M] — **Diseño: 01-Requerimientos.md 5 RF17**
- [ ] Definir catálogo de muebles compartido de solo lectura [M]
- [ ] Definir undo/redo del invitado para evitar errores [M]
- [x] Documentar sin tocar el sistema de construcción single (M15) [S]
- [ ] Verificar permisos de construcción en el manifiesto [S]

## R. Puzzles Cooperativos (RF18)

- [x] Definir puzzles cooperativos SOLO opcionales (M24) [S] — **Diseño: 01-Requerimientos.md 5 RF18**
- [x] Prohibir puzzles que bloqueen historia (M22) [S] — **Diseño: 01-Requerimientos.md 5 RF18**
- [ ] Definir solución compartida sin estado duplicado [M]
- [ ] Documentar puzzles con 1 solución (sin puzles rotos) [S]
- [ ] Verificar que el invitado no recibe logros de progreso (M72) [S]

## S. Progreso Compartido (RF19)

- [x] Definir progreso NUNCA compartido [S] — **Diseño: 01-Requerimientos.md 5 RF19**
- [x] Documentar cada jugador con su isla [S] — **Diseño: 01-Requerimientos.md 5 RF19**
- [ ] Verificar que el invitado no avanza la historia ajena (M22) [S]
- [ ] Documentar que los eventos (M74) se viven juntos pero cuentan individual [M]
- [ ] Registrar progreso individual en el manifiesto [S]

## T. Progreso Individual (RF20)

- [x] Definir invitado con su avatar y progreso global [M] — **Diseño: 01-Requerimientos.md 5 RF20**
- [x] Definir perfil local del invitado (M92) [M] — **Diseño: 03-Diseno.md 4**
- [x] Documentar colecciones (M73) individuales [S] — **Diseño: 03-Diseno.md 5**
- [x] Documentar economía (M38) individual [S] — **Diseño: 03-Diseno.md 5**
- [ ] Verificar sin contaminación de saves [S]

## U. Seguridad (RF21)

- [x] Definir offline-first (M59) [S] — **Diseño: 01-Requerimientos.md 5 RF21**
- [x] Definir código de visita con expiración [M] — **Diseño: 01-Requerimientos.md 5 RF21**
- [ ] Definir sin exposición de datos locales [M]
- [ ] Documentar cifrado de transporte futuro (M77) [M]
- [ ] Verificar que v1 no abre puertos de red [S]

## V. Anti-Griefing (RF22)

- [x] Definir anti-griefing por diseño (permisos) [S] — **Diseño: 02-Analisis.md 3.2**
- [x] Definir invitado sin herramientas destructivas [S] — **Diseño: 01-Requerimientos.md 5 RF22**
- [ ] Definir respaldo del mundo del host (M59) ante incidentes [M]
- [ ] Documentar rollback de cambios del invitado [M]
- [ ] Registrar permisos en el manifiesto [S]

## W. Moderación (RF23)

- [x] Definir moderación por frases rápidas (sin texto libre) [S] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir reporte de jugadores si hay texto futuro [M] — **Diseño: 02-Analisis.md 3.9**
- [ ] Definir baneo de visitas para el host [M]
- [ ] Documentar política de privacidad de cuentas futuras (M77) [M]
- [ ] Verificar cero moderación en v1 (no hay red) [S]

## X. Costes de Servidores (RF24)

- [x] Documentar $0 de servidores en v1 [S] — **Diseño: 02-Analisis.md 2.4 A1**
- [x] Estimar servidor 8 vCPU/16 GB para ~200 CCU [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [x] Estimar $120-180/mes por servidor dedicado [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [x] Condicionar el online al hit de métricas (>10k descargas) [M] — **Diseño: 02-Analisis.md 3.3**
- [ ] Registrar coste_estimado_mensual=0 en el manifiesto [S]

## Y. Cierre del Contrato (RF25)

- [x] Definir los 25 puntos del plan maestro como contrato [M] — **Diseño: 01-Requerimientos.md 5**
- [x] Documentar el flujo de apertura de FASE LOCAL [M] — **Diseño: 03-Diseno.md 2.3 Flujo B**
- [x] Documentar el flujo de apertura de FASE ONLINE (M77) [M] — **Diseño: 03-Diseno.md 2.3 Flujo C**
- [ ] Entregar validate_mp_contract.gd (grep + manifiesto) [M]
- [?] Entregar mp_contract.json [S]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S] — **Diseño: 04-Codigo.md Notas del Agente**
- [x] Firmar los documentos del módulo (modelo y plataforma) [S] — **Diseño: 04-Codigo.md Notas del Agente**
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]
**Totales:** 130 ítems · Completados: 81 · Pendientes: 46 · No resueltos: 3.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 4 [x] / 126 [ ] / 0 [?].
> Las marcas no se tocaron.

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)
M76: 3 [x] degradados (bloqueado por producto). Evidencia: mp_contract.json AUSENTE = M76 bloqueado single-player v1 (patron M77): 3 [x] -> [?] (mp_contract.json x2 + reporte futuro). 1 [x] queda (documentar decision single-player). Reportado al director.
