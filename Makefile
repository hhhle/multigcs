
INCDIR=-I./ -I./Common -I$(SDKSTAGE)/opt/vc/include -I$(SDKSTAGE)/opt/vc/include/interface/vcos/pthreads -I/usr/include/libxml2 -Iscreens -Imavlink -Igps -Imwi21 -Ijeti -Iopenpilot -Ifrsky
LIBS=-lGLESv2 -lEGL -lm -lbcm_host -lpng -L$(SDKSTAGE)/opt/vc/lib -lcurl -lSDL -ludev -lSDL_image -lxml2
CFLAGS+= -DRPI_NO_X -Ofast -pipe -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard
#CFLAGS+= -flto -ffast-math -fno-math-errno -funsafe-math-optimizations -ffinite-math-only -fno-signed-zeros -fno-trapping-math -frounding-math


## ldd gcs  | grep -v /opt | awk '{print $1}' | xargs -r -l dpkg -S  | cut -d":" -f1 | sort -u | tr  "\n" "," ##

COMMONSRC=./Common/esShader.c ./Common/esTransform.c ./Common/esShapes.c ./Common/esUtil.c
COMMONHRD=esUtil.h

GCS=main.o screens/screen_rcflow.o screens/screen_model.o serial.o i2c.o gles_draw.o draw.o screens/screen_keyboard.o screens/screen_filesystem.o screens/screen_device.o screens/screen_baud.o screens/screen_background.o screens/screen_wpedit.o screens/screen_hud.o screens/screen_map.o screens/screen_calibration.o screens/screen_nd.o screens/screen_fms.o screens/screen_system.o screens/screen_tcl.o screens/screen_mavlink_menu.o screens/screen_mwi_menu.o screens/screen_openpilot_menu.o screens/screen_videolist.o screens/screen_graph.o \
	mavlink/my_mavlink.o gps/my_gps.o mwi21/mwi21.o jeti/jeti.o openpilot/openpilot.o frsky/frsky.o

default: all

all: gcs

clean:
	rm -f gcs *.o screens/*.o mavlink/*.o gps/*.o mwi21/*.o jeti/*.o openpilot/*.o frsky/*.o


install:
	mkdir -p /usr/share/gl-gcs/MAPS
	mkdir -p /usr/share/gl-gcs/textures
	mkdir -p /usr/share/gl-gcs/fonts
	mkdir -p /usr/share/gl-gcs/rcflow_presets
	mkdir -p /usr/bin
	cp -a textures/* /usr/share/gl-gcs/textures/
	cp -a fonts/* /usr/share/gl-gcs/fonts/
	cp -a rcflow_presets/* /usr/share/gl-gcs/rcflow_presets/
	cp -a gcs /usr/bin/gl-gcs
	cp -a gcs.sh /usr/bin/gcs
	cp -a clean-badmaps.sh /usr/share/gl-gcs/clean-badmaps.sh
	touch /usr/share/gl-gcs/setup.cfg
	chmod 0755 /usr/bin/gl-gcs
	chmod 0755 /usr/bin/gcs
	chmod 0777 /usr/share/gl-gcs/setup.cfg
	chmod 0777 /usr/share/gl-gcs/clean-badmaps.sh

deb: gcs
	rm -rf package/
	mkdir -p package/usr/share/gl-gcs/MAPS
	mkdir -p package/usr/share/gl-gcs/textures
	mkdir -p package/usr/share/gl-gcs/fonts
	mkdir -p package/usr/bin
	mkdir -p package/DEBIAN
	cp -a textures/* package/usr/share/gl-gcs/textures/
	cp -a fonts/* package/usr/share/gl-gcs/fonts/
	cp -a gcs package/usr/bin/gl-gcs
	cp -a gcs.sh package/usr/bin/gcs
	cp -a clean-badmaps.sh package/usr/share/gl-gcs/clean-badmaps.sh
	cp -a screens/screen_tcl.tcl package/usr/share/gl-gcs/scripts/screens/screen_tcl.tcl
	cp -a WMM2010.COF package/usr/share/gl-gcs/MAPS
	touch package/usr/share/gl-gcs/setup.cfg
	chmod 0755 package/usr/bin/gl-gcs
	chmod 0755 package/usr/bin/gcs
	chmod 0777 package/usr/share/gl-gcs/setup.cfg
	echo "Package: gl-gcs" > package/DEBIAN/control
	echo "Source: gl-gcs" >> package/DEBIAN/control
	echo "Version: 0.9-`date +%s`" >> package/DEBIAN/control
	echo "Architecture: `dpkg --print-architecture`" >> package/DEBIAN/control
	echo "Maintainer: Oliver Dippel <oliver@multixmedia.org>" >> package/DEBIAN/control
	echo "Depends: espeak, coreutils, imagemagick, bluez, input-utils, gcc-4.6,libasound2,libasyncns0,libattr1,libc6,libcaca0,libcap2,libcomerr2,libcurl3,libdbus-1-3,libdirectfb-1.2-9,libflac8,libgcc1,libgcrypt11,libgnutls26,libgpg-error0,libgssapi-krb5-2,libice6,libidn11,libjson0,libk5crypto3,libkeyutils1,libkrb5-3,libkrb5support0,libldap-2.4-2,libncursesw5,libogg0,libp11-kit0,libpng12-0,libpulse0,librtmp0,libsasl2-2,libsdl1.2debian,libslang2,libsm6,libsndfile1,libssh2-1,libssl1.0.0,libtasn1-3,libtinfo5,libts-0.0-0,libuuid1,libvorbis0a,libvorbisenc2,libwrap0,libx11-6,libx11-xcb1,libxau6,libxcb1,libxdmcp6,libxext6,libxi6,libxtst6,raspi-copies-and-fills,zlib1g,libxml2" >> package/DEBIAN/control
	echo "Section: media" >> package/DEBIAN/control
	echo "Priority: optional" >> package/DEBIAN/control
	echo "Description: Ground-Control-Station based on OpenGL-ES" >> package/DEBIAN/control
	echo " Ground-Control-Station based on OpenGL-ES" >> package/DEBIAN/control
	echo "/usr/share/gl-gcs/setup.cfg" > package/DEBIAN/conffiles
	chmod -R -s package/ -R
	chmod  0755 package/DEBIAN/ -R
	dpkg-deb --build package
	mv package.deb gl-gcs-rpi_0.9-`date +%s`_`dpkg --print-architecture`.deb

%.o: %.c
	gcc -c $(CFLAGS) $< -o $@ ${INCDIR} ${LIBS}

gcs: ${COMMONSRC} ${COMMONHDR} ${GCS}
	gcc $(CFLAGS) ${COMMONSRC} ${GCS} -o $@ ${INCDIR} ${LIBS}
