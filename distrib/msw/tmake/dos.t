#!#############################################################################
#! File:    dos.t
#! Purpose: tmake template file from which makefile.dos is generated by running
#!          tmake -t dos wxwin.pro -o makefile.dos
#! Author:  Vadim Zeitlin
#! Created: 14.07.99
#! Version: $Id$
#!#############################################################################

#${
    #! include the code which parses filelist.txt file and initializes
    #! %wxCommon, %wxGeneric and %wxMSW hashes.
    IncludeTemplate("filelist.t");

    #! now transform these hashes into $project tags
    foreach $file (sort keys %wxGeneric) {
        if ( $wxGeneric{$file} =~ /\b(PS|G|U)\b/ ) {
            #! this file for some reason was compiled for VC++ 1.52
            next unless $file =~ /^prntdlgg\./;
        }

        $file =~ s/cp?p?$/obj/;
        $project{"WXGENERICOBJS"} .= "\$(GENDIR)\\" . $file . " "
    }

    foreach $file (sort keys %wxCommon) {
        #! socket files don't compile under Win16 currently
        next if $wxCommon{$file} =~ /\b(32|S)\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXCOMMONOBJS"} .= "\$(COMMDIR)\\" . $file . " "
    }

    foreach $file (sort keys %wxMSW) {
        #! don't take files not appropriate for 16-bit Windows
        next if $wxMSW{$file} =~ /\b(32|O)\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXMSWOBJS"} .= "\$(MSWDIR)\\" . $file . " "
    }
#$}

# This file was automatically generated by tmake at #$ Now()
# DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST! CHANGE DOS.T!

#
# File:     makefile.dos
# Author:   Julian Smart
# Created:  1997
# Updated:
# Copyright:(c) 1997, Julian Smart
#
# "%W% %G%"
#
# Makefile : Builds wxWindows library wx.lib for VC++ (16-bit)
# Arguments:
#
# FINAL=1 argument to nmake to build version with no debugging info.
#
!include <..\makemsc.env>

LIBTARGET=$(WXLIB)
DUMMYOBJ=dummy.obj

# Please set these according to the settings in wx_setup.h, so we can include
# the appropriate libraries in wx.lib

# This one overrides the others, to be consistent with the settings in wx_setup.h
MINIMAL_WXWINDOWS_SETUP=0

USE_XPM_IN_MSW=0
USE_CTL3D=1

!if "$(MINIMAL_WXWINDOWS_SETUP)" == "1"
USE_CTL3D=0
USE_XPM_IN_MSW=0
!endif

PERIPH_LIBS=
PERIPH_TARGET=
PERIPH_CLEAN_TARGET=

# !if "$(USE_CTL3D)" == "1"
# PERIPH_LIBS=d:\msdev\lib\ctl3d32.lib $(PERIPH_LIBS)
# !endif

!if "$(USE_XPM_IN_MSW)" == "1"
PERIPH_LIBS=$(WXDIR)\contrib\wxxpm\xpm.lib $(PERIPH_LIBS)
PERIPH_TARGET=xpm $(PERIPH_TARGET)
PERIPH_CLEAN_TARGET=clean_xpm $(PERIPH_CLEAN_TARGET)
!endif

# PNG and Zlib
PERIPH_TARGET=png zlib $(PERIPH_TARGET)
PERIPH_CLEAN_TARGET=clean_png clean_zlib $(PERIPH_CLEAN_TARGET)

GENDIR=..\generic
COMMDIR=..\common
OLEDIR=.\ole
MSWDIR=.

GENERICOBJS= #$ ExpandList("WXGENERICOBJS");

COMMONOBJS = \
		$(COMMDIR)\y_tab.obj \
		#$ ExpandList("WXCOMMONOBJS");

MSWOBJS = #$ ExpandList("WXMSWOBJS");

# TODO: Implement XPM and PNG targets in this makefile!
#  $(OLEDIR)\xpmhand \
#  $(OLEDIR)\pnghand \

OBJECTS = $(COMMONOBJS) $(GENERICOBJS) $(MSWOBJS)

# Normal, static library
all:    $(DUMMYOBJ) $(WXDIR)\lib\wx1.lib $(WXDIR)\lib\wx2.lib $(WXDIR)\lib\wx3.lib


# $(WXDIR)\lib\wx.lib:      dummy.obj $(OBJECTS) $(PERIPH_LIBS)
# 	-erase $(LIBTARGET)
# 	lib /PAGESIZE:128 @<<
# $(LIBTARGET)
# y
# $(OBJECTS) $(PERIPH_LIBS)
# nul
# ;
# <<

$(WXDIR)\lib\wx1.lib:      $(COMMONOBJS) $(PERIPH_LIBS)
	-erase $(WXDIR)\lib\wx1.lib
	lib /PAGESIZE:128 @<<
$(WXDIR)\lib\wx1.lib
y
$(COMMONOBJS) $(PERIPH_LIBS)
nul
;
<<

$(WXDIR)\lib\wx2.lib:      $(GENERICOBJS)
	-erase $(WXDIR)\lib\wx2.lib
	lib /PAGESIZE:128 @<<
$(WXDIR)\lib\wx2.lib
y
$(GENERICOBJS)
nul
;
<<

$(WXDIR)\lib\wx3.lib:      $(MSWOBJS)
	-erase $(WXDIR)\lib\wx3.lib
	lib /PAGESIZE:128 @<<
$(WXDIR)\lib\wx3.lib
y
$(MSWOBJS)
nul
;
<<

########################################################
# Windows-specific objects

dummy.obj: dummy.$(SRCSUFF) $(WXDIR)\include\wx\wx.h
        cl @<<
        cl $(CPPFLAGS) /YcWX/WXPREC.H $(DEBUG_FLAGS) /c /Tp $*.$(SRCSUFF)
<<

#dummy.obj: dummy.$(SRCSUFF) $(WXDIR)\include\wx\wx.h
#        cl $(CPPFLAGS) /YcWX/WXPREC.H $(DEBUG_FLAGS) /c /Tp $*.$(SRCSUFF)

dummydll.obj: dummydll.$(SRCSUFF) $(WXDIR)\include\wx\wx.h
        cl @<<
$(CPPFLAGS) /YcWX/WXPREC.H /c /Tp $*.$(SRCSUFF)
<<

#${
    $_ = $project{"WXMSWOBJS"} . $project{"WXCOMMONOBJS"} . $project{"WXGENERICOBJS"};
    my @objs = split;
    foreach (@objs) {
        s:\\:/:;
        $text .= $_ . ':     $*.$(SRCSUFF)' . "\n" .
                 '        cl @<<' . "\n" .
                 '$(CPPFLAGS) /Fo$@ /c /Tp $*.$(SRCSUFF)' . "\n" .
                 "<<\n\n";
    }
#$}

$(COMMDIR)/y_tab.obj:     $*.c $(COMMDIR)/lex_yy.c
        cl @<<
$(CPPFLAGS2) -DUSE_DEFINE -DYY_USE_PROTOS /Fo$@ /I ..\common /c $*.c
<<

$(COMMDIR)/y_tab.c:     $(COMMDIR)/dosyacc.c
        copy $(COMMDIR)\dosyacc.c $(COMMDIR)\y_tab.c

$(COMMDIR)/lex_yy.c:    $(COMMDIR)/doslex.c
    copy $(COMMDIR)\doslex.c $(COMMDIR)\lex_yy.c

$(OBJECTS):	$(WXDIR)/include/wx/setup.h

# Peripheral components

xpm:
    cd $(WXDIR)\src\xpm
    nmake -f makefile.dos FINAL=$(FINAL)
    cd $(WXDIR)\src\msw

clean_xpm:
    cd $(WXDIR)\src\xpm
    nmake -f makefile.dos clean
    cd $(WXDIR)\src\msw

zlib:
    cd $(WXDIR)\src\zlib
    nmake -f makefile.dos FINAL=$(FINAL)
    cd $(WXDIR)\src\msw

clean_zlib:
    cd $(WXDIR)\src\zlib
    nmake -f makefile.dos clean
    cd $(WXDIR)\src\msw

png:
    cd $(WXDIR)\src\png
    nmake -f makefile.dos FINAL=$(FINAL)
    cd $(WXDIR)\src\msw

clean_png:
    cd $(WXDIR)\src\png
    nmake -f makefile.dos clean
    cd $(WXDIR)\src\msw

clean: $(PERIPH_CLEAN_TARGET)
        -erase *.obj
        -erase ..\lib\*.lib
        -erase *.pdb
        -erase *.sbr
        -erase *.pch
        cd $(WXDIR)\src\generic
        -erase *.pdb
        -erase *.sbr
        -erase *.obj
        cd $(WXDIR)\src\common
        -erase *.pdb
        -erase *.sbr
        -erase *.obj
        cd $(WXDIR)\src\msw\ole
        -erase *.pdb
        -erase *.sbr
        -erase *.obj
        cd $(WXDIR)\src\msw

cleanall: clean


MFTYPE=dos
makefile.$(MFTYPE) : $(WXWIN)\distrib\msw\tmake\filelist.txt $(WXWIN)\distrib\msw\tmake\$(MFTYPE).t
	cd $(WXWIN)\distrib\msw\tmake
	tmake -t $(MFTYPE) wxwin.pro -o makefile.$(MFTYPE)
	copy makefile.$(MFTYPE) $(WXWIN)\src\msw
