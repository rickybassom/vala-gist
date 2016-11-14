project('Vala Gist', ['vala', 'c'],
        version: '1.0.0-dev',
        license: 'GNU',
        meson_version: '>=0.35')

api_version = '1.0'

glib = dependency('glib-2.0', version: '>=2.32')
gobject = dependency('gobject-2.0', version: '>=2.32')
gmodule = dependency('gmodule-2.0', version: '>=2.32')
gio = dependency('gio-2.0', version: '>=2.32')
gio_unix = dependency('gio-unix-2.0', version: '>=2.40')
json_glib = dependency('json-glib-1.0', version: '>=1.0')
libsoup = dependency('libsoup-2.4', version: '>=2.4')

meson.add_install_script('_install.sh')

subdir('src')
subdir('tests')
