# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6} )

inherit distutils-r1 bash-completion-r1

DESCRIPTION="Asynchronous task queue/job queue based on distributed message passing"
HOMEPAGE="http://celeryproject.org/ https://pypi.org/project/celery/"
SRC_URI="https://files.pythonhosted.org/packages/a2/4b/d020836f751617e907e84753a41c92231cd4b673ff991b8ee9da52361323/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
# There are a number of other optional 'extras' which overlap with those of kombu, however
# there has been no apparent expression of interest or demand by users for them. See requires.txt
IUSE="doc examples redis sqs test yaml"

RDEPEND="
	<=dev-python/kombu-4.4.0[${PYTHON_USEDEP}]
	>dev-python/kombu-4.2.1[${PYTHON_USEDEP}]
	>=dev-python/billiard-3.6.0[${PYTHON_USEDEP}]
	<dev-python/billiard-4.0.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/greenlet[${PYTHON_USEDEP}]
	dev-python/vine[${PYTHON_USEDEP}]
"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( ${RDEPEND}
		>=dev-python/case-1.3.1[${PYTHON_USEDEP}]
		dev-python/eventlet[${PYTHON_USEDEP}]
		dev-python/gevent[$(python_gen_usedep python2_7)]
		>=dev-python/pymongo-2.6.2[${PYTHON_USEDEP}]
		dev-python/pyopenssl[${PYTHON_USEDEP}]
		>=dev-python/pytest-3.0[${PYTHON_USEDEP}]
		>=dev-python/python-dateutil-2.1[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/redis-py[${PYTHON_USEDEP}]
		>=dev-db/redis-2.8.0
		>=dev-python/boto-2.13.3[${PYTHON_USEDEP}]
		>=dev-python/pyzmq-13.1.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-3.10[${PYTHON_USEDEP}]
		>=dev-python/unittest2-0.5.1[${PYTHON_USEDEP}]
	)
	doc? (
		dev-python/docutils[${PYTHON_USEDEP}]
		>=dev-python/sphinx_celery-1.3[${PYTHON_USEDEP}]
		dev-python/jinja[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/typing[${PYTHON_USEDEP}]' python2_7)
	)"

DISTUTILS_IN_SOURCE_BUILD=1

python_compile_all() {
	if use doc; then
		mkdir docs/.build || die
		emake -C docs html
	fi
}

python_test() {
	esetup.py test
}

python_install_all() {
	newinitd "extra/generic-init.d/celeryd" celeryd
	newinitd "extra/generic-init.d/celerybeat" celerybeat

	if use examples; then
		docompress -x "/usr/share/doc/${PF}/examples"
		docinto examples
		dodoc -r examples/.
	fi

	use doc && local HTML_DOCS=( docs/_build/html/. )

	newbashcomp extra/bash-completion/celery.bash ${PN}

	distutils-r1_python_install_all
}

pkg_postinst() {
	optfeature "zookeeper support" dev-python/kazoo
	optfeature "msgpack support" dev-python/msgpack
	optfeature "eventlet support" dev-python/eventlet
	optfeature "redis support" dev-db/redis dev-python/redis-py
	optfeature "gevent support" dev-python/gevent
	optfeature "auth support" dev-python/pyopenssl
	optfeature "pyro support" dev-python/pyro:4
	optfeature "yaml support" dev-python/pyyaml
	optfeature "memcache support" dev-python/pylibmc
	optfeature "mongodb support" dev-python/pymongo
	optfeature "sqlalchemy support" dev-python/sqlalchemy
	optfeature "sqs support" dev-python/boto
}
