# Options: windows, macos, linux, wasm
TARGET_OS ?= wasm 
# Options: folders in lib/
TARGET_PLATFORM ?= webassembly

build: build-$(TARGET_OS) 

build-windows:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	cl /O2 /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED raygui.c /LD /Febin/$(TARGET_PLATFORM)/raygui.dll /link /LIBPATH lib/$(TARGET_PLATFORM) msvcrt.lib winmm.lib gdi32.lib user32.lib shell32.lib /subsystem:windows
	mv bin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/rayguidll.lib

	# STATIC
	cl /c raygui.c /Fobin/$(TARGET_PLATFORM)/raygui.obj /LIBPATH lib/$(TARGET_PLATFORM) /DRAYGUI_IMPLEMENTATION
	lib /OUTbin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/raygui.obj msvcrt.lib winmm.lib gdi32.lib user32.lib shell32.lib /subsystem:windows
	rm bin/$(TARGET_PLATFORM)/raygui.obj
	
	mv raygui.c raygui.h

build-macos:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	gcc -O2 -dynamiclib -o bin/$(TARGET_PLATFORM)/libraygui.5.0.0.dylib raygui.c -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -framework OpenGL -framework CoreFoundation -framework CoreGraphics -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -lm -lpthread -ldl

	# STATIC
	clang -O2 -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -framework OpenGL -framework CoreFoundation -framework CoreGraphics -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -lm -lpthread -ldl
	ar rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv raygui.c raygui.h

build-linux:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
ifneq ($(TARGET_PLATFORM), linux_i386)
	gcc -o bin/$(TARGET_PLATFORM)/libraygui.so.5.0.0 raygui.c -shared -fpic -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
endif

	# STATIC
	gcc -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
	ar rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv raygui.c raygui.h

build-wasm:
	mv raygui.h raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# STATIC
	emcc -c raygui.c -o bin/$(TARGET_PLATFORM)/raygui.web.o -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib.web
	emar rcs bin/$(TARGET_PLATFORM)/libraygui.web.a bin/$(TARGET_PLATFORM)/raygui.web.o
	rm bin/$(TARGET_PLATFORM)/raygui.web.o
	
	mv raygui.c raygui.h

clean:
	rm -rf bin