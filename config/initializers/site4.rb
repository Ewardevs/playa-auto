# Site4 — la cuarta web pública, montada en /v4.
#
# Mismo interruptor único que Site2 y Site3: mientras `preview` esté en true,
# Site4 se sirve con `noindex` y no aparece en sitemap.xml ni en robots.txt,
# que siguen siendo del sitio principal. Se cambia a false el día que Site4
# pase a ser la web pública, y no hay que tocar nada más.
Rails.application.config.x.site4.preview = true
