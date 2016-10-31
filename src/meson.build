valagist_sources = [
    'ValaGist.vala',
    'Errors.vala',
    'Gist.vala',
    'GistFile.vala',
    'MyProfile.vala',
    'OtherProfile.vala',
    'Profile.vala'
]

valagist_lib = library('valagist-1.0', valagist_sources,
                  vala_args: ['--vapidir=' + meson.current_source_dir()],
                  c_args: ['-g', '-O0', '-Wno-unused'],
                  dependencies: [glib, gobject, json_glib, libsoup],
                  install: true)

valagist = declare_dependency(include_directories: include_directories('.'),
                              link_with: valagist_lib)

install_headers(meson.current_build_dir() +'/valagist-1.0.h')

install_data([meson.current_build_dir() + '/valagist-1.0.vapi'],
             install_dir: 'share/vala/vapi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(name: 'valagist-1.0',
                   description: 'Gist client library for Vala',
                   version: meson.project_version(),
                   requires: 'glib-2.0 gobject-2.0 json-glib-1.0 libsoup-2.4',
                   libraries: valagist_lib)

