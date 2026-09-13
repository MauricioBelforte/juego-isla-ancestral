# Encuesta Post-Sesión — Isla Ancestral
Fecha límite: dentro de las 2 horas posteriores a la sesión.

## A. Datos de sesión
- Código de tester: {alias} | Fecha: {AAAA-MM-DD} | Build: {hash}
- Edad: {rango} | Experiencia previa en juegos cozy: {nunca / poca / mucha} | Horas de juego semanales: {n}

## B. Tono emocional (1 = nada, 5 = muchísimo)
1. Durante la sesión me sentí estresado/a: [1-5]
2. Me sentí abrumado/a por la cantidad de cosas por hacer: [1-5]
3. Me sentí aburrido/a en algún momento: [1-5]
4. Me sentí tranquilo/a y relajado/a: [1-5]
5. Disfruté mi tiempo en la isla: [1-5]
6. Sentí que yo controlaba mi experiencia: [1-5]
7. Me dieron ganas de seguir jugando: [1-5]

## C. Comprensión (1 = nada, 5 = totalmente)
8. Supe qué hacer en todo momento: [1-5]
9. Entendí a dónde ir al despertar: [1-5]
10. Los avisos de la UI me ayudaron: [1-5]

## D. Cuantitativo de juego (auto-reporte)
11. Objetivos cumplidos: {n}
12. Reinicios de día / muertes: {n}
13. Items obtenidos: {n}
14. Tiempo total jugado: {minutos}

## E. Cualitativo
15. Lo que MÁS me gustó: {texto}
16. Lo que MENOS me gustó: {texto}
17. El momento más estresante: {texto}
18. El momento más lindo: {texto}
19. Si pudiera cambiar UNA cosa sería: {texto}

## F. Perfil emocional
20. ¿En qué momento quisiste dejar de jugar? {nunca / momento específico / texto}
21. ¿Jugarías 30 minutos más ahora mismo? {sí / no / quizás}

---
## Índice de tono cozy (Google Sheets)
TonoCozy = (Q4 + Q5 + Q6)/3 - (Q1 + Q2 + Q3)/3
Rango: -4 a +4 | Meta prototipo: >= +0.5 | Meta pre-alpha: >= +1.0