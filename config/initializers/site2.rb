# Site2 — la segunda web pública, montada en /v2.
#
# `preview` es el único interruptor del sitio. Mientras esté en true:
#
#   - todas las páginas de Site2 se sirven con `noindex`
#   - Site2 no aparece en sitemap.xml ni en robots.txt, que siguen siendo del
#     sitio principal
#
# El día que Site2 pase a ser la web pública, se cambia este valor a false y no
# hay que tocar nada más: los controladores y el layout lo leen desde acá.
Rails.application.config.x.site2.preview = true
