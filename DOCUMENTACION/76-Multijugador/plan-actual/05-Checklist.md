**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 76: Multijugador (130 ítems)

## A. Decisión de Producto (RF1)

- [ ] Decidir si habrá multijugador (v1: NO, single-player cozy) [M]
- [ ] Documentar la decisión con argumentos de género (AC/Stardew/CozyGrove) [M]
- [ ] Documentar la decisión con argumentos de coste [M]
- [ ] Verificar que el postgame (M75) cubre la vida de la isla sin red [M]
- [ ] Registrar la decisión en el manifiesto mp_contract.json [S]

## B. Modo Local (RF2)

- [ ] Definir el modo local como primera forma de MP [M]
- [ ] Definir 2 jugadores en el mismo dispositivo [S]
- [ ] Definir split-screen como presentación local [M]
- [ ] Definir host autoritativo para el modo local [M]
- [ ] Definir frame budget 60 FPS antes de aprobar la feature (M61) [C]

## C. Modo Online (RF3)

- [ ] Diferir el online como extensión futura [S]
- [ ] Condicionar el online a hit de métricas (>10k descargas) [M]
- [ ] Exigir M77 (Online y Red) antes de cualquier online [S]
- [ ] Definir máximo de 4 jugadores online [S]
- [ ] Documentar presupuesto estimado de servidores [M]

## D. Cantidad de Jugadores (RF4)

- [ ] Definir 1 jugador en v1 (single) [S]
- [ ] Definir 2 jugadores para el modo local [S]
- [ ] Definir 4 jugadores máximo para online futuro [S]
- [ ] Documentar el impacto de rendimiento por jugador extra [M]
- [ ] Verificar que la cantidad no rompe el cozy (sin multitudes) [S]

## E. Anfitrión (RF5)

- [ ] Definir el anfitrión = jugador que crea la isla [S]
- [ ] Definir que el anfitrión posee el mundo [S]
- [ ] Definir invitado sin poder de host [S]
- [ ] Documentar migración de host (si se cierra sesión) [M]
- [ ] Registrar la autoridad en el manifiesto [S]

## F. Servidor (RF6)

- [ ] Definir P2P/split para el modo local (sin servidor) [S]
- [ ] Definir servidor dedicado SOLO para online futuro [M]
- [ ] Documentar $0 de servidores en v1 [S]
- [ ] Documentar la estimación mensual de servidor dedicado [M]
- [ ] Registrar servidores_v1=false en el manifiesto [S]

## G. Sincronización (RF7)

- [ ] Definir host autoritativo (simula mundo, recibe inputs) [M]
- [ ] Definir snapshot+reconciliación para online (M77) [M]
- [ ] Definir tick rate de referencia (10-20 Hz estado) [M]
- [ ] Documentar interpolar animaciones del invitado (M13) [M]
- [ ] Verificar determinismo local (split no red) [M]

## H. Autoridad (RF8)

- [ ] Definir autoridad del host en el mundo [S]
- [ ] Definir autoridad del invitado sobre su avatar [S]
- [ ] Definir autoridad del servidor para online (M77) [M]
- [ ] Documentar regla: el invitado no desbloquea logros en la isla ajena (M72) [M]
- [ ] Registrar authority=host en el manifiesto [S]

## I. Persistencia (RF9)

- [ ] Definir save individual sin cambio de formato (M59) [M]
- [ ] Definir invitado = perfil local (M92) [M]
- [ ] Definir que el invitado NO persiste en la isla del host [S]
- [ ] Documentar cero conflictos de escritura de saves [S]
- [ ] Verificar migración M60 intacta [S]

## J. Permisos (RF10)

- [ ] Definir invitado sin zona destructiva [S]
- [ ] Definir edición permitida en zona asignada [M]
- [ ] Definir casa del host protegida [S]
- [ ] Documentar permisos por diseño (anti-griefing) [S]
- [ ] Verificar permisos en el manifiesto [S]

## K. Invitaciones (RF11)

- [ ] Definir invitación local = segundo mando [S]
- [ ] Definir código de visita con expiración (online futuro) [M]
- [ ] Definir lista de amigos futura (M77) [M]
- [ ] Documentar flujo de invitación sin cuentas en v1 [S]
- [ ] Verificar que la invitación nunca expone datos [S]

## L. Cuentas (RF12)

- [ ] Definir sin cuentas en v1 [S]
- [ ] Definir perfiles locales (M92) [S]
- [ ] Definir cuenta opcional SOLO para online futuro [M]
- [ ] Documentar el servicio de cuenta como externo (M77) [M]
- [ ] Verificar privacidad del perfil local [S]

## M. Identidad (RF13)

- [ ] Definir avatar de perfil (M92) [S]
- [ ] Definir nombre de isla único en visitas [M]
- [ ] Definir nombre de jugador editable [S]
- [ ] Documentar identidad sin cuentas (local) [S]
- [ ] Verificar identidad en el manifiesto [S]

## N. Chat (RF14)

- [ ] Definir sin chat en v1 [S]
- [ ] Definir frases rápidas (T-chat moderado) [M]
- [ ] Definir sin texto libre en el cozy [S]
- [ ] Definir sistema de reporte si hay texto libre futuro [M]
- [ ] Registrar chat=frases rapidas en el manifiesto [S]

## O. Emotes (RF15)

- [ ] Definir rueda de emotes [S]
- [ ] Definir emotes como notificaciones express (M44) [M]
- [ ] Definir set base de emotes (hola, gracias, risa, enojo) [S]
- [ ] Documentar animaciones de emotes (M13) [M]
- [ ] Verificar que los emotes no requieren red en local [S]

## P. Intercambio (RF16)

- [ ] Definir sin intercambio en v1 [S]
- [ ] Definir trueque futuro solo decorativo (M38) [M]
- [ ] Prohibir transferencia de ítems de historia (M22/M23) [S]
- [ ] Prohibir transferencia de colecciones de avance (M73) [S]
- [ ] Verificar economía protegida en el manifiesto [S]

## Q. Construcción Cooperativa (RF17)

- [ ] Definir construcción cooperativa futura solo en zona permitida [M]
- [ ] Definir catálogo de muebles compartido de solo lectura [M]
- [ ] Definir undo/redo del invitado para evitar errores [M]
- [ ] Documentar sin tocar el sistema de construcción single (M15) [S]
- [ ] Verificar permisos de construcción en el manifiesto [S]

## R. Puzzles Cooperativos (RF18)

- [ ] Definir puzzles cooperativos SOLO opcionales (M24) [S]
- [ ] Prohibir puzzles que bloqueen historia (M22) [S]
- [ ] Definir solución compartida sin estado duplicado [M]
- [ ] Documentar puzzles con 1 solución (sin puzles rotos) [S]
- [ ] Verificar que el invitado no recibe logros de progreso (M72) [S]

## S. Progreso Compartido (RF19)

- [ ] Definir progreso NUNCA compartido [S]
- [ ] Documentar cada jugador con su isla [S]
- [ ] Verificar que el invitado no avanza la historia ajena (M22) [S]
- [ ] Documentar que los eventos (M74) se viven juntos pero cuentan individual [M]
- [ ] Registrar progreso individual en el manifiesto [S]

## T. Progreso Individual (RF20)

- [ ] Definir invitado con su avatar y progreso global [M]
- [ ] Definir perfil local del invitado (M92) [M]
- [ ] Documentar colecciones (M73) individuales [S]
- [ ] Documentar economía (M38) individual [S]
- [ ] Verificar sin contaminación de saves [S]

## U. Seguridad (RF21)

- [ ] Definir offline-first (M59) [S]
- [ ] Definir código de visita con expiración [M]
- [ ] Definir sin exposición de datos locales [M]
- [ ] Documentar cifrado de transporte futuro (M77) [M]
- [ ] Verificar que v1 no abre puertos de red [S]

## V. Anti-Griefing (RF22)

- [ ] Definir anti-griefing por diseño (permisos) [S]
- [ ] Definir invitado sin herramientas destructivas [S]
- [ ] Definir respaldo del mundo del host (M59) ante incidentes [M]
- [ ] Documentar rollback de cambios del invitado [M]
- [ ] Registrar permisos en el manifiesto [S]

## W. Moderación (RF23)

- [ ] Definir moderación por frases rápidas (sin texto libre) [S]
- [ ] Definir reporte de jugadores si hay texto futuro [M]
- [ ] Definir baneo de visitas para el host [M]
- [ ] Documentar política de privacidad de cuentas futuras (M77) [M]
- [ ] Verificar cero moderación en v1 (no hay red) [S]

## X. Costes de Servidores (RF24)

- [ ] Documentar $0 de servidores en v1 [S]
- [ ] Estimar servidor 8 vCPU/16 GB para ~200 CCU [M]
- [ ] Estimar $120-180/mes por servidor dedicado [M]
- [ ] Condicionar el online al hit de métricas (>10k descargas) [M]
- [ ] Registrar coste_estimado_mensual=0 en el manifiesto [S]

## Y. Cierre del Contrato (RF25)

- [ ] Definir los 25 puntos del plan maestro como contrato [M]
- [ ] Documentar el flujo de apertura de FASE LOCAL [M]
- [ ] Documentar el flujo de apertura de FASE ONLINE (M77) [M]
- [ ] Entregar validate_mp_contract.gd (grep + manifiesto) [M]
- [ ] Entregar mp_contract.json [S]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]