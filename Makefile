# Options: windows, macos, linux, wasm
TARGET_OS ?= wasm 
# Options: folders in lib/
TARGET_PLATFORM ?= webassembly

build: build-$(TARGET_OS) 

build-windows:
	mv input/raygui.h input/raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	cl /O2 /MD /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED input/raygui.c /LD /Febin/$(TARGET_PLATFORM)/raygui.dll /link /LIBPATH lib/$(TARGET_PLATFORM)/raylibdll.lib winmm.lib gdi32.lib user32.lib shell32.lib /subsystem:windows
	mv bin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/rayguidll.lib

	# STATIC
	cl /c /MT input/raygui.c /Fobin/$(TARGET_PLATFORM)/raygui.obj /DRAYGUI_IMPLEMENTATION
	lib /OUT:bin/$(TARGET_PLATFORM)/raygui.lib bin/$(TARGET_PLATFORM)/raygui.obj
	rm bin/$(TARGET_PLATFORM)/raygui.obj
	
	mv input/raygui.c input/raygui.h

build-macos:
	mv input/raygui.h input/raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
	clang -O2 -dynamiclib -o bin/$(TARGET_PLATFORM)/libraygui.5.0.0.dylib input/raygui.c -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -framework OpenGL -framework CoreFoundation -framework CoreGraphics -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -lm -lpthread -ldl

	# STATIC
	clang -O2 -c input/raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION
	ar rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv input/raygui.c input/raygui.h

build-linux:
	mv input/raygui.h input/raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# SHARED
ifneq ($(TARGET_PLATFORM), linux_i386)
	gcc -o bin/$(TARGET_PLATFORM)/libraygui.so.5.0.0 input/raygui.c -shared -fpic -DRAYGUI_IMPLEMENTATION -L lib/$(TARGET_PLATFORM) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
endif

	# STATIC
	gcc -c input/raygui.c -o bin/$(TARGET_PLATFORM)/raygui.o -DRAYGUI_IMPLEMENTATION
	ar rcs bin/$(TARGET_PLATFORM)/libraygui.a bin/$(TARGET_PLATFORM)/raygui.o
	rm bin/$(TARGET_PLATFORM)/raygui.o
	
	mv input/raygui.c input/raygui.h

# CC: emcc, AR: emar
build-wasm:
	mv input/raygui.h input/raygui.c
	mkdir -p bin/$(TARGET_PLATFORM)/

	# STATIC
	emcc -c input/raygui.c -o bin/$(TARGET_PLATFORM)/raygui.web.o -DRAYGUI_IMPLEMENTATION
	emar rcs bin/$(TARGET_PLATFORM)/libraygui.web.a bin/$(TARGET_PLATFORM)/raygui.web.o
	rm bin/$(TARGET_PLATFORM)/raygui.web.o
	
	mv input/raygui.c input/raygui.h

clean:
	rm -rf bin