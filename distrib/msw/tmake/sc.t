#!#############################################################################
#! File:    sc.t
#! Purpose: tmake template file from which makefile.sc is generated by running
#!          tmake -t sc wxwin.pro -o makefile.sc
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
        my $tag = "";
        if ( $wxGeneric{$file} =~ /\b(PS|G|16|U)\b/ ) {
            $tag = "WXNONESSENTIALOBJS";
        }
        else {
            $tag = "WXGENERICOBJS";
        }

        $file =~ s/cp?p?$/obj/;
        $project{$tag} .= '$(GENDIR)\\' . $file . " "
    }

    foreach $file (sort keys %wxCommon) {
        $file =~ s/cp?p?$/obj/;
        $project{"WXCOMMONOBJS"} .= '$(COMMDIR)\\' . $file . " "
    }

    foreach $file (sort keys %wxMSW) {
        #! these files don't compile with SC++ 6
        next if $file =~ /^(joystick|pnghand)\./;

        next if $wxGeneric{$file} =~ /\b16\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXMSWOBJS"} .= '$(MSWDIR)\\' . $file . " "
    }
#$}

# This file was automatically generated by tmake at #$ Now()
# DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST! CHANGE SC.T!

# Symantec C++ makefile for the msw objects
# called from src\makefile.sc

# configuration section (see src\makefile.sc) ###########################

WXDIR = $(WXWIN)

include ..\makesc.env

DEBUG=0

LIBTARGET = $(LIBDIR)\wx.lib

OPTIONS=

# end of configuration section ##########################################

GENDIR=$(WXDIR)\src\generic
COMMDIR=$(WXDIR)\src\common
XPMDIR=$(WXDIR)\src\xpm
OLEDIR=ole
MSWDIR=$(WXDIR)\src\msw

GENERICOBJS= #$ ExpandList("WXGENERICOBJS");

COMMONOBJS = \
		$(COMMDIR)\y_tab.obj \
		#$ ExpandList("WXCOMMONOBJS");

MSWOBJS = #$ ExpandList("WXMSWOBJS");

XPMOBJECTS = 	$(XPMDIR)\crbuffri.obj\
		$(XPMDIR)\crdatfri.obj\
		$(XPMDIR)\create.obj $(XPMDIR)\crifrbuf.obj\
		$(XPMDIR)\crifrdat.obj\
		$(XPMDIR)\data.obj\
		$(XPMDIR)\hashtab.obj $(XPMDIR)\misc.obj\
		$(XPMDIR)\parse.obj $(XPMDIR)\rdftodat.obj\
		$(XPMDIR)\rdftoi.obj\
		$(XPMDIR)\rgb.obj $(XPMDIR)\scan.obj\
		$(XPMDIR)\simx.obj $(XPMDIR)\wrffrdat.obj\
		$(XPMDIR)\wrffrp.obj $(XPMDIR)\wrffri.obj

# Add $(NONESSENTIALOBJS) if wanting generic dialogs, PostScript etc.
OBJECTS = $(COMMONOBJS) $(GENERICOBJS) $(MSWOBJS) # $(XPMOBJECTS)

all: $(LIBTARGET)

$(LIBTARGET): $(OBJECTS)
	-del $(LIBTARGET)
	*lib /PAGESIZE:512 $(LIBTARGET) y $(OBJECTS), nul;

clean:
	-del *.obj
    -del $(LIBTARGET)

$(COMMDIR)\y_tab.obj:     $(COMMDIR)\y_tab.c $(COMMDIR)\lex_yy.c

$(COMMDIR)\y_tab.c:     $(COMMDIR)\dosyacc.c
        copy $(COMMDIR)\dosyacc.c $(COMMDIR)\y_tab.c

$(COMMDIR)\lex_yy.c:    $(COMMDIR)\doslex.c
    copy $(COMMDIR)\doslex.c $(COMMDIR)\lex_yy.c

# $(COMMDIR)\cmndata.obj:     $(COMMDIR)\cmndata.cpp
#	*$(CC) -c $(CFLAGS) -I$(INCLUDE) $(OPTIONS) $(COMMDIR)\cmndata.cpp -o$(COMMDIR)\cmndata.obj

MFTYPE=sc
makefile.$(MFTYPE) : $(WXWIN)\distrib\msw\tmake\filelist.txt $(WXWIN)\distrib\msw\tmake\$(MFTYPE).t
	cd $(WXWIN)\distrib\msw\tmake
	tmake -t $(MFTYPE) wxwin.pro -o makefile.$(MFTYPE)
	copy makefile.$(MFTYPE) $(WXWIN)\src\msw
