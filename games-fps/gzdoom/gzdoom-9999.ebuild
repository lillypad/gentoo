# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit games cmake-utils git-2 eutils

DESCRIPTION="Enhanced OpenGL port of the official DOOM source code"
HOMEPAGE="http://www.osnanet.de/c.oelckers/gzdoom/index.html"
EGIT_REPO_URI="https://github.com/coelckers/gzdoom.git"

LICENSE="DOOMLIC BUILDLIC BSD"
SLOT="0"
KEYWORDS=""
IUSE="cpu_flags_x86_mmx +gtk +fluidsynth +soundfont"

DEPEND="
		soundfont? (
				fluidsynth? ( media-sound/fluidsynth )
				media-sound/fluid-soundfont
		)

		gtk? ( x11-libs/gtk+:2 )
		media-libs/flac
		media-libs/openal
		virtual/glu
		virtual/jpeg
		virtual/opengl
		media-libs/libsdl2

		cpu_flags_x86_mmx? ( || ( dev-lang/nasm dev-lang/yasm ) )"
RDEPEND="${DEPEND}"

src_prepare() {
	# Use default game data path
	sed -i \
		-e "s:/usr/local/share/:${GAMES_DATADIR}/doom-data/:" \
		src/posix/i_system.h || die
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_no cpu_flags_x86_mmx ASM)
		$(cmake-utils_use_no gtk GTK)
		$(cmake-utils_use_use fluidsynth FLUIDSYNTH)
		-DNO_FMOD=ON
	)

	cmake-utils_src_configure
}

src_install() {
	dodoc docs/*.{txt,TXT}
	dohtml docs/console*.{css,html}

	cd "${CMAKE_BUILD_DIR}" || die
	dogamesbin ${PN} || die

	insinto "${GAMES_DATADIR}/doom-data"
	doins ${PN}.pk3

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	elog "Copy or link wad files into ${GAMES_DATADIR}/doom-data/"
	elog "(the files must be readable by the 'games' group)."
	elog
	elog "To play, simply run:"
	elog "   gzdoom"
	elog "See /usr/share/doc/${P}/zdoom.txt.* for more info"
}
