#!/usr/bin/env bash

set -eux

build_os="$(uname)"

if [ "${build_os}" == "Linux" ]; then
    # Instalar dependencias con yum
    yum -y install \
        gcc-c++ \
        cmake \
        pkgconfig \
        boost-devel \
        eigen3-devel \
        ode-devel \
        wget \
        yaml-cpp-devel \
        python3-devel \
        python3-pip \
        boost-python3-devel \
        boost-numpy3-devel \
        python3-numpy \
        pypy3

    # Instalar dependencias de la aplicación si se va a construir OMPL.app
    # Adaptar la condición según cómo se determine si se construye OMPL.app
    if [[ "${CIBW_BUILD}" == *"cp3"* ]]; then # Ejemplo de condición
      yum -y install \
          freeglut-devel \
          assimp-devel \
          python3-PyOpenGL \
          python3-flask \
          python3-celery \
          libccd-devel
    fi

    # manylinux ships with a pypy installation. Make it available on the $PATH
    # so the OMPL build process picks it up and can make use of it during the
    # Python binding generation stage.
    ln -s /opt/python/pp310-pypy310_pp73/bin/pypy /usr/bin
elif [ "${build_os}" == "Darwin" ]; then
    export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    brew install \
        cmake \
        pkg-config \
        boost \
        eigen \
        ode \
        wget \
        yaml-cpp \
        pypy3 \
        castxml \
        llvm@18 \
        boost-python3 \
        freeglut \
        assimp \
        libccd

    # Instalar la versión correcta de Python
    # Ajustar a la versión que necesites, por ejemplo, python@3.10, python@3.11, etc.
    brew install --overwrite "python@${python_version}"

    # Si construyes OMPL.app, instala PyQt5 con pip (no con brew)
    if [[ "${CIBW_BUILD}" == *"cp3"* ]]; then # Ejemplo de condición
      python3 -m pip install pyqt5
    fi
fi
