FROM alpine:3.23 AS base


FROM base AS pico-sdk-no-picotool
ARG PICO_SDK_RELEASE=2.3.0
RUN apk add --no-cache \
  cmake \
  g++ \
  g++-arm-none-eabi \
  gcc \
  gcc-arm-none-eabi \
  linux-headers \
  make \
  musl-dev \
  ninja \
  python3
ENV PICO_SDK_PATH=/opt/pico-sdk
ADD https://github.com/raspberrypi/pico-sdk.git#${PICO_SDK_RELEASE} ${PICO_SDK_PATH}
WORKDIR /work


FROM pico-sdk-no-picotool AS build-picotool
ARG PICOTOOL_RELEASE=2.3.0
ADD https://github.com/raspberrypi/picotool.git#${PICOTOOL_RELEASE} src
RUN \
  cmake \
    -G Ninja \
    -S src \
    -B build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D PICOTOOL_NO_LIBUSB=ON \
    -D USE_PRECOMPILED=OFF && \
  cmake --build build && \
  DESTDIR=/work/install cmake --install build


FROM pico-sdk-no-picotool AS pico-sdk
COPY --from=build-picotool /work/install /


FROM pico-sdk AS build-debugprobe
RUN --mount=type=bind,target=/work/src \
  cmake \
    -G Ninja \
    -S src \
    -B build \
    -D CMAKE_BUILD_TYPE=Release && \
  cmake --build build
RUN ls -l build


FROM scratch AS debugprobe
COPY --from=build-debugprobe /work/build/debugprobe.uf2 /
