
CC = bpc
BINOBJ = binobj

all: battle.pas sys.fnt
	$(BINOBJ) sys.fnt font.obj systemfont
	$(CC) battle.pas

clean:
	del *.exe
	del *.obj