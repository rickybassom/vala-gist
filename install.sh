#!/bin/sh

mkdir -p "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"
mkdir -p "${DESTDIR}${MESON_INSTALL_PREFIX}/share/gir-1.0"

echo "${DESTDIR}${MESON_INSTALL_PREFIX}"

install -m 0644                                         \
    "${MESON_BUILD_ROOT}/src/ValaGist.vapi" \
    "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"

install -m 0644                            \
    "${MESON_BUILD_ROOT}/src/ValaGist@sha/ValaGist-1.0.gir" \
    "${DESTDIR}${MESON_INSTALL_PREFIX}/share/gir-1.0"
