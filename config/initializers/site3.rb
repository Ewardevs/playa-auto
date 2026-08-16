# Site3 — la tercera web pública, montada en /v3.
#
# Mismo interruptor único que Site2: mientras `preview` esté en true, Site3 se
# sirve con `noindex` y no aparece en sitemap.xml ni en robots.txt, que siguen
# siendo del sitio principal. Se cambia a false el día que Site3 pase a ser la
# web pública, y no hay que tocar nada más.
Rails.application.config.x.site3.preview = true
