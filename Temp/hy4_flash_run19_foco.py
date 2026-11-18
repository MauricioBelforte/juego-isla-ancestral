"""Busqueda focal de contradicciones numericas por grupo. Solo lectura."""
from pathlib import Path
import re

D = Path('DOCUMENTACION')
GRUPOS = {
1:(['08','09','10','167','168'], ['radio','1024','256','64 m','chunk','LOD','1800','3000']),
2:(['11','12','16','07','04'], ['zoom','2.5 m','5 m','8 m','4.0','20.0','niveles']),
3:(['29','30','31','32','09'], ['DURACION_DIA','DURACION_NOCHE','560 min','28 d','1440','480','336','horas']),
4:(['33','34','35','15','16'], ['muerte estacional','dormante','invierno','tier','Madera','Cobre','hierro','oro']),
5:(['38','39','74','71','17'], ['precio','stock','festival','hito','recompensa','bono','d[íi]a']),
6:(['108','169','68','27','28'], ['ruta','pasajero','crucero','islas','barco','capacidad']),
7:(['112','111','101','102','154'], ['checks','suites','cobertura','EXIT','gate','tests']),
8:(['03','06','21','22','23'], ['cap[ií]tulo','final','DLC','cadenas','versi[oó]n','semver']),
9:(['106','100','121','120','99'], ['DLC','soporte','meses','privacidad','menores','clasificaci[oó]n']),
10:(['90','91','88','47','52'], ['FPS','bus','font','fuente','textura','MB','ms','memoria']),
}
for g,(ids,keys) in GRUPOS.items():
    print('='*88); print('GRUPO',g,'claves:',','.join(keys))
    pat = re.compile('|'.join(keys), re.I)
    for mid in ids:
        ds=[d for d in D.iterdir() if d.is_dir() and d.name.startswith(mid+'-')]
        if not ds: continue
        d=ds[0]; n=0
        for doc in sorted((d/'plan-actual').glob('0[1-5]-*.md')):
            for i,l in enumerate(doc.read_text(encoding='utf-8',errors='replace').splitlines(),1):
                if not pat.search(l) or not re.search(r'\d',l): continue
                t=re.sub(r'\s+',' ',l.strip())[:135]
                print(' M%s %s:%d %s'%(mid,doc.name,i,t))
                n+=1
                if n>=6: break
            if n>=6: break
