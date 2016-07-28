vala_sources = [
    'ValaGist.vala',
    'Errors.vala',
    'Gist.vala',
    'GistFile.vala',
    'MyProfile.vala',
    'OtherProfile.vala',
    'Profile.vala'
]

vala_args = [
    '--disable-warnings',
    '--gir=ValaGist-1.0.gir'
    #'-X', '-fPIC', '-X', '-shared -o valagist.so', '--library=ValaGist'
]

valagist_lib = library('ValaGist', vala_sources,
                  dependencies: [glib, gobject, json_glib, libsoup],
                  vala_args: vala_args,
                  install: true)

g_ir_compiler = find_program('g-ir-compiler')
custom_target('valagist-typelib',
               command: [g_ir_compiler, '--shared-library=libValaGist.so', '--output', '@OUTPUT@', meson.current_build_dir() + '/ValaGist@sha/ValaGist-1.0.gir'],
               output: 'ValaGist-1.0.typelib',
               depends: valagist_lib,
               install: true,
               install_dir: get_option('libdir') + '/girepository-1.0')

valagist = declare_dependency(include_directories: include_directories('.'),
                           link_with: valagist_lib)

install_headers(meson.current_build_dir() + '/ValaGist.h')

pkgconfig = import('pkgconfig')
pkgconfig.generate(requires: 'glib-2.0 gobject-2.0 json-glib-1.0 libsoup-2.4',
                   libraries: valagist_lib,
                   version: meson.project_version(),
                   name: 'Vala Gist',
                   filebase: 'valagist',
                   description: 'Vala gist api.',
                   subdirs: 'valagist')

