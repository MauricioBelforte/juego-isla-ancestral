**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 76: Multijugador (130 ítems)
**Estado:** 🔵 En curso — agente Step-5-WorkBuddy (reclamo sec. 21.4.7 del bloqueo, 2026-10-16; msg 54/55 del director GLM-5.3 Flash-Director)

## A. Decisión de Producto (RF1)

- [x] Decidir si habrá multijugador (v1: NO, single-player cozy) [M] — **Diseño: 02-Analisis.md 3.1**
- [x] Documentar la decisión con argumentos de género (AC/Stardew/CozyGrove) [M] — **Diseño: 02-Analisis.md 1**
- [x] Documentar la decisión con argumentos de coste [M] — **Diseño: 02-Analisis.md 2.4**
- [x] Verificar que el postgame (M75) cubre la vida de la isla sin red [M] — **Evidencia: M75 01-Requerimientos L14/L18 (isla con vida, eventos M74; sin red)**
- [x] Registrar la decisión en el manifiesto mp_contract.json [S]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)] — **CERRADO 2026-10-16 (Step-5-WorkBuddy): mp_contract.json entregado, mp_v1=single**

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
- [x] Verificar que la cantidad no rompe el cozy (sin multitudes) [S] — **Diseño: 02-Analisis.md 1 (cozy 1-2-4 jugadores)**

## E. Anfitrión (RF5)

- [x] Definir el anfitrión = jugador que crea la isla [S] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir que el anfitrión posee el mundo [S] — **Diseño: 03-Diseno.md 4**
- [x] Definir invitado sin poder de host [S] — **Diseño: 02-Analisis.md 3.2**
- [x] Documentar migración de host (si se cierra sesión) [M] — **Diseño: 03-Diseno.md 7.1**
- [x] Registrar la autoridad en el manifiesto [S] — **Evidencia: mp_contract.json authority=host**

## F. Servidor (RF6)

- [x] Definir P2P/split para el modo local (sin servidor) [S] — **Diseño: 01-Requerimientos.md 5 RF6**
- [x] Definir servidor dedicado SOLO para online futuro [M] — **Diseño: 01-Requerimientos.md 5 RF6**
- [x] Documentar $0 de servidores en v1 [S] — **Diseño: 02-Analisis.md 2.4 A1**
- [x] Documentar la estimación mensual de servidor dedicado [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [x] Registrar servidores_v1=false en el manifiesto [S] — **Evidencia: mp_contract.json servidores_v1=false**

## G. Sincronización (RF7)

- [x] Definir host autoritativo (simula mundo, recibe inputs) [M] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir snapshot+reconciliación para online (M77) [M] — **Diseño: 02-Analisis.md 2.3 A2**
- [x] Definir tick rate de referencia (10-20 Hz estado) [M] — **Diseño: 03-Diseno.md 7.2 (rango 10-20 Hz; M77 fija 10 Hz)**
- [x] Documentar interpolar animaciones del invitado (M13) [M] — **Diseño: 03-Diseno.md 7.3 (M77 L123 ya documentado)**
- [ ] Verificar determinismo local (split no red) [M] — **[ ] honesto: requiere FASE MP implementada (split no existe)**

## H. Autoridad (RF8)

- [x] Definir autoridad del host en el mundo [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir autoridad del invitado sobre su avatar [S] — **Diseño: 02-Analisis.md 2.3 A1**
- [x] Definir autoridad del servidor para online (M77) [M] — **Diseño: 03-Diseno.md 3.2**
- [x] Documentar regla: el invitado no desbloquea logros en la isla ajena (M72) [M] — **Diseño: 03-Diseno.md 7.4**
- [x] Registrar authority=host en el manifiesto [S] — **Evidencia: mp_contract.json authority=host**

## I. Persistencia (RF9)

- [x] Definir save individual sin cambio de formato (M59) [M] — **Diseño: 03-Diseno.md 4**
- [x] Definir invitado = perfil local (M92) [M] — **Diseño: 03-Diseno.md 4**
- [x] Definir que el invitado NO persiste en la isla del host [S] — **Diseño: 02-Analisis.md 2.2 A1**
- [x] Documentar cero conflictos de escritura de saves [S] — **Diseño: 02-Analisis.md 2.2 A1**
- [x] Verificar migración M60 intacta [S] — **Evidencia: M60 189/196 sin refs M76; validador core limpio**

## J. Permisos (RF10)

- [x] Definir invitado sin zona destructiva [S] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir edición permitida en zona asignada [M] — **Diseño: 01-Requerimientos.md 5 RF10**
- [x] Definir casa del host protegida [S] — **Diseño: 01-Requerimientos.md 5 RF10**
- [x] Documentar permisos por diseño (anti-griefing) [S] — **Diseño: 02-Analisis.md 3.2**
- [x] Verificar permisos en el manifiesto [S] — **Evidencia: mp_contract.json permisos**

## K. Invitaciones (RF11)

- [x] Definir invitación local = segundo mando [S] — **Diseño: 01-Requerimientos.md 5 RF11**
- [x] Definir código de visita con expiración (online futuro) [M] — **Diseño: 01-Requerimientos.md 5 RF11**
- [x] Definir lista de amigos futura (M77) [M] — **Diseño: 03-Diseno.md 7.5 (dueño M77)**
- [x] Documentar flujo de invitación sin cuentas en v1 [S] — **Diseño: 02-Analisis.md 3.5**
- [ ] Verificar que la invitación nunca expone datos [S] — **[ ] honesto: requiere implementación de invitación (FASE MP)**

## L. Cuentas (RF12)

- [x] Definir sin cuentas en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Definir perfiles locales (M92) [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Definir cuenta opcional SOLO para online futuro [M] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Documentar el servicio de cuenta como externo (M77) [M] — **Diseño: 01-Requerimientos.md 3.2**
- [x] Verificar privacidad del perfil local [S] — **Diseño: 03-Diseno.md 7.14 (sin red; user:// local)**

## M. Identidad (RF13)

- [x] Definir avatar de perfil (M92) [S] — **Diseño: 01-Requerimientos.md 5 RF13**
- [x] Definir nombre de isla único en visitas [M] — **Diseño: 01-Requerimientos.md 5 RF13**
- [x] Definir nombre de jugador editable [S] — **Diseño: 03-Diseno.md 7.6**
- [x] Documentar identidad sin cuentas (local) [S] — **Diseño: 01-Requerimientos.md 5 RF12**
- [x] Verificar identidad en el manifiesto [S] — **Evidencia: mp_contract.json identidad**

## N. Chat (RF14)

- [x] Definir sin chat en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF14**
- [x] Definir frases rápidas (T-chat moderado) [M] — **Diseño: 03-Diseno.md 3.1**
- [x] Definir sin texto libre en el cozy [S] — **Diseño: 03-Diseno.md 3.2**
- [x] Definir sistema de reporte si hay texto libre futuro [M]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)] — **CERRADO 2026-10-16: contrato 7.4/7.18 + moderacion.reporte_jugadores**
- [x] Registrar chat=frases rapidas en el manifiesto [S] — **Evidencia: mp_contract.json chat=frases rapidas**

## O. Emotes (RF15)

- [x] Definir rueda de emotes [S] — **Diseño: 01-Requerimientos.md 5 RF15**
- [x] Definir emotes como notificaciones express (M44) [M] — **Diseño: 03-Diseno.md 5**
- [x] Definir set base de emotes (hola, gracias, risa, enojo) [S] — **Diseño: 03-Diseno.md 7.7**
- [x] Documentar animaciones de emotes (M13) [M] — **Diseño: 03-Diseno.md 7.8**
- [x] Verificar que los emotes no requieren red en local [S] — **Evidencia: mp_contract.json emotes.requieren_red=false**

## P. Intercambio (RF16)

- [x] Definir sin intercambio en v1 [S] — **Diseño: 01-Requerimientos.md 5 RF16**
- [x] Definir trueque futuro solo decorativo (M38) [M] — **Diseño: 02-Analisis.md 3.6**
- [x] Prohibir transferencia de ítems de historia (M22/M23) [S] — **Diseño: 02-Analisis.md 3.6**
- [x] Prohibir transferencia de colecciones de avance (M73) [S] — **Diseño: 02-Analisis.md 3.6**
- [x] Verificar economía protegida en el manifiesto [S] — **Evidencia: mp_contract.json economia**

## Q. Construcción Cooperativa (RF17)

- [x] Definir construcción cooperativa futura solo en zona permitida [M] — **Diseño: 01-Requerimientos.md 5 RF17**
- [x] Definir catálogo de muebles compartido de solo lectura [M] — **Diseño: 03-Diseno.md 7.9**
- [x] Definir undo/redo del invitado para evitar errores [M] — **Diseño: 03-Diseno.md 7.10**
- [x] Documentar sin tocar el sistema de construcción single (M15) [S]
- [x] Verificar permisos de construcción en el manifiesto [S] — **Evidencia: mp_contract.json permisos.construccion_cooperativa**

## R. Puzzles Cooperativos (RF18)

- [x] Definir puzzles cooperativos SOLO opcionales (M24) [S] — **Diseño: 01-Requerimientos.md 5 RF18**
- [x] Prohibir puzzles que bloqueen historia (M22) [S] — **Diseño: 01-Requerimientos.md 5 RF18**
- [x] Definir solución compartida sin estado duplicado [M] — **Diseño: 03-Diseno.md 7.11**
- [x] Documentar puzzles con 1 solución (sin puzles rotos) [S] — **Diseño: 03-Diseno.md 7.12**
- [x] Verificar que el invitado no recibe logros de progreso (M72) [S] — **Diseño: 03-Diseno.md 7.4 + mp progreso.invitado_logros_isla_ajena=false**

## S. Progreso Compartido (RF19)

- [x] Definir progreso NUNCA compartido [S] — **Diseño: 01-Requerimientos.md 5 RF19**
- [x] Documentar cada jugador con su isla [S] — **Diseño: 01-Requerimientos.md 5 RF19**
- [x] Verificar que el invitado no avanza la historia ajena (M22) [S] — **Diseño: 03-Diseno.md 7.4 + mp progreso.invitado_avanza_historia_ajena=false**
- [x] Documentar que los eventos (M74) se viven juntos pero cuentan individual [M] — **Diseño: 03-Diseno.md 7.13**
- [x] Registrar progreso individual en el manifiesto [S] — **Evidencia: mp persistence=individual + progreso.compartido=nunca**

## T. Progreso Individual (RF20)

- [x] Definir invitado con su avatar y progreso global [M] — **Diseño: 01-Requerimientos.md 5 RF20**
- [x] Definir perfil local del invitado (M92) [M] — **Diseño: 03-Diseno.md 4**
- [x] Documentar colecciones (M73) individuales [S] — **Diseño: 03-Diseno.md 5**
- [x] Documentar economía (M38) individual [S] — **Diseño: 03-Diseno.md 5**
- [x] Verificar sin contaminación de saves [S] — **Diseño: 02-Analisis.md 2.2 A1 + mp persistence=individual**

## U. Seguridad (RF21)

- [x] Definir offline-first (M59) [S] — **Diseño: 01-Requerimientos.md 5 RF21**
- [x] Definir código de visita con expiración [M] — **Diseño: 01-Requerimientos.md 5 RF21**
- [x] Definir sin exposición de datos locales [M] — **Diseño: 03-Diseno.md 7.14**
- [x] Documentar cifrado de transporte futuro (M77) [M] — **Diseño: 03-Diseno.md 7.15 (dueño M77)**
- [x] Verificar que v1 no abre puertos de red [S] — **Evidencia: validador 0 refs de red en scripts v1 (36 checks)**

## V. Anti-Griefing (RF22)

- [x] Definir anti-griefing por diseño (permisos) [S] — **Diseño: 02-Analisis.md 3.2**
- [x] Definir invitado sin herramientas destructivas [S] — **Diseño: 01-Requerimientos.md 5 RF22**
- [x] Definir respaldo del mundo del host (M59) ante incidentes [M] — **Diseño: 03-Diseno.md 7.16**
- [x] Documentar rollback de cambios del invitado [M] — **Diseño: 03-Diseno.md 7.17**
- [x] Registrar permisos en el manifiesto [S] — **Evidencia: mp_contract.json permisos + moderacion**

## W. Moderación (RF23)

- [x] Definir moderación por frases rápidas (sin texto libre) [S] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir reporte de jugadores si hay texto futuro [M] — **Diseño: 02-Analisis.md 3.9**
- [x] Definir baneo de visitas para el host [M] — **Diseño: 03-Diseno.md 7.18**
- [x] Documentar política de privacidad de cuentas futuras (M77) [M] — **Diseño: 03-Diseno.md 7.19 (dueño M77)**
- [x] Verificar cero moderación en v1 (no hay red) [S] — **Evidencia: mp moderacion.cero_moderacion_v1=true + validador sin red**

## X. Costes de Servidores (RF24)

- [x] Documentar $0 de servidores en v1 [S] — **Diseño: 02-Analisis.md 2.4 A1**
- [x] Estimar servidor 8 vCPU/16 GB para ~200 CCU [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [x] Estimar $120-180/mes por servidor dedicado [M] — **Diseño: 02-Analisis.md 2.4 A2**
- [x] Condicionar el online al hit de métricas (>10k descargas) [M] — **Diseño: 02-Analisis.md 3.3**
- [x] Registrar coste_estimado_mensual=0 en el manifiesto [S] — **Evidencia: mp_contract.json coste_estimado_mensual=0**

## Y. Cierre del Contrato (RF25)

- [x] Definir los 25 puntos del plan maestro como contrato [M] — **Diseño: 01-Requerimientos.md 5**
- [x] Documentar el flujo de apertura de FASE LOCAL [M] — **Diseño: 03-Diseno.md 2.3 Flujo B**
- [x] Documentar el flujo de apertura de FASE ONLINE (M77) [M] — **Diseño: 03-Diseno.md 2.3 Flujo C**
- [x] Entregar validate_mp_contract.gd (grep + manifiesto) [M] — **Evidencia: scripts/multijugador/validate_mp_contract.gd 36/0 EXIT 0 x3; guardián en rojo OK**
- [x] Entregar mp_contract.json [S]  [Auditoria T-agnes blq8 2026-10-06: mp_contract.json AUSENTE + M76 bloqueado por producto (single-player v1, patron M77)] — **CERRADO 2026-10-16: res://data/multijugador/mp_contract.json (1555 B, ASCII)**

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S] — **Diseño: 04-Codigo.md Notas del Agente**
- [x] Firmar los documentos del módulo (modelo y plataforma) [S] — **Diseño: 04-Codigo.md Notas del Agente**
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S] — **ESTADO-PARALELO + Log actualizados; fila GLOBAL entregada al director (msg 55) — él aplica**
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S] — **Pendiente: fila GLOBAL a aplicar por el director**
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S] — **Evidencia: 130 exactos; enunciados base plan-inicial == plan-actual 130/130**
**Totales:** 130 ítems · Completados: 126 · Pendientes: 4 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 4 [x] / 126 [ ] / 0 [?].
> Las marcas no se tocaron.

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)
M76: 3 [x] degradados (bloqueado por producto). Evidencia: mp_contract.json AUSENTE = M76 bloqueado single-player v1 (patron M77): 3 [x] -> [?] (mp_contract.json x2 + reporte futuro). 1 [x] queda (documentar decision single-player). Reportado al director.
