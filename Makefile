# Options: windows, macos, linux, wasm
TARGET_OS ?= wasm 
# Options: folders in lib/
TARGET_PLATFORM ?= webassembly

CC ?= gcc
AR ?= ar

build: build-$(TARGET_OS) 

# CC: cl, AR: lib
build-windows:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	$(CC) /O2 /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED raygui.c /LD /Febin/$(TARGET_PLATFORM)/raygui.dll /link /LIBPATH lib/$(TARGET_PLATFORM)/raylibdll.lib msvcrt.lib winmm.lib gdi32.lib user32.lib shell32.lib /subsystem:windows
	mv bin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/rayguidll.lib

	# STATIC
	$(CC) /c raygui.c /Fobin/$(TARGET_PLATFORM)/raygui.obj /LIBPATH lib/$(TARGET_PLATFORM)/raylib.lib /DRAYGUI_IMPLEMENTATION
	$(AR) /OUTbin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/raygui.obj msvcrt.lib winmm.lib gdi32.lib user32.lib shell32.lib /subsystem:windows
	rm bin/$(TARGET_PLATFORM)/raygui.obj
	
	mv raygui.c raygui.h

# CC: clang, AR: ar
build-macos:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	$(CC) -O2 -dynamiclib -o bin/$(TARGET_PLATFORM)/libraygui.5.0.0.dylib raygui.c -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -framework OpenGL -framework CoreFoundation -framework CoreGraphics -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -lm -lpthread -ldl

	# STATIC
	$(CC) -O2 -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -framework OpenGL -framework CoreFoundation -framework CoreGraphics -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -lm -lpthread -ldl
	$(AR) rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv raygui.c raygui.h

# CC: gcc, AR: ar
build-linux:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
ifneq ($(TARGET_PLATFORM), linux_i386)
	$(CC) -o bin/$(TARGET_PLATFORM)/libraygui.so.5.0.0 raygui.c -shared -fpic -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
endif

	# STATIC
	$(CC) -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
	$(AR) rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv raygui.c raygui.h

# CC: emcc, AR: emar
build-wasm:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# STATIC
	$(CC) -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.web.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib.web
	$(AR) rcs bin/$(TARGET_PLATFORM)/libraygui.web.a bin/$(TARGET_PLATFORM)/raygui.web.o
	rm bin/$(TARGET_PLATFORM)/raygui.web.o
	
	mv raygui.c raygui.h

clean:
	rm -rf bin