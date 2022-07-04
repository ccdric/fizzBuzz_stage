# MakeFile Generique pour projet ou lib du socle pour codeBlock

#-------------------------------------------------------------------------------------------------------------------------
# recuperation de l'environnement
KERNTYP=$(shell uname -s | tr "A-Z" "a-z" | cut -c1-5 )
SERVNAME=$(shell uname -n)
ifeq ($(strip $(KERNTYP)),aix)
    PKGTARGET=${KERNTYP}"-"$(shell uname -v)"."$(shell uname -r)"-ppc_64"
else
    PKGTARGET=$(shell . /etc/os-release && echo $$ID)"-"$(shell . /etc/os-release && echo $$VERSION_ID)"-"$(shell arch)
endif

DATE=$(shell date +%Y%m%d_%H%M%S)

HASH_COMMIT=$(shell git log | head -n1 | cut -d' ' -f2)

# Config Make
NBR_CPUS=8
ifeq ($(strip $(KERNTYP)),linux)
NBR_CPUS=$(shell nproc)
endif
MAKE_PID := $(shell echo $$PPID)
JOB_FLAG := $(filter -j%, $(subst -j ,-j,$(shell ps -o"%p %a" | grep "^\s*$(MAKE_PID).*$(MAKE)")))
JOBS     := $(subst -j,,$(JOB_FLAG))
ifeq ($(strip $(JOBS)),)
MAKEFLAGS += --jobs=$(NBR_CPUS)
endif

# Listes des sources et utilitaires du projet a archiver
PROJNAME=$(notdir $(shell pwd | tr '\\\\' '/' ))
PROJFILE=$(PROJNAME).cbp
PROJMAKE=$(PROJNAME).mak
RESSOURCES=ressources
MAKCONF=sources.list
CUSTSRC=$(shell grep "^[a-z,A-Z,0-9,_]" $(MAKCONF) | tr "\n\r" " " )
SOURCES=$(PROJMAKE) $(PROJFILE) Makefile $(MAKCONF) $(CUSTSRC)
SRCINCLUDES=include

# repertoires
TMPMAK=tmp_prj.mak
LIBR=lib
EXTCLDIR=$(shell echo ${EXIT_CLIENTSDIR})
GALILEEROOT=/outils/socle
SOCLE_INC=$(GALILEEROOT)/include

FAKEROOT=fakeroot
FAKESOCLE=$(FAKEROOT)$(GALILEEROOT)
FAKEBINDIR=$(FAKEROOT)/$(SOCLE_BIN)
FAKELIBDIR=$(FAKEROOT)/$(SOCLE_LIB)
FAKEINCLUDEDIR=$(FAKEROOT)/$(SOCLE_INC)

# adaptation au projet (lib ou exec)
PROJTYPE=$(shell printf "$(PROJNAME)" | cut -d "_" -f 1)
PROJRACINE=$(shell printf "$(PROJNAME)" | cut -d "_" -f 2-)
ISLIB=$(shell if [ "$(PROJTYPE)" = "scllib" ] ; then echo 1; else echo 0;fi)
VERSION_FILE=$(shell if [ "$(ISLIB)" = "1" ] ; then echo "$(SRCINCLUDES)/version.h"; else echo "main.cpp"; fi)
INSTALLDIR=$(shell if [ "$(ISLIB)" = "1" ] ; then echo "$(SOCLE_LIB)"; else echo "$(SOCLE_BIN)"; fi)
# projets lib only
LIBRACINE=$(PROJRACINE)
MAINBASEINCLUDEFILE=$(shell if [ "$(ISLIB)" = "1" ] ; then printf "$(LIBRACINE).h";fi)
MAININCLUDEFILE=$(shell if [ "$(ISLIB)" = "1" ] ; then printf $(SRCINCLUDES)/$(MAINBASEINCLUDEFILE);fi)
LIBBINARISRC=$(shell if [ "$(KERNTYP)" = "aix" ] ; then echo "$(OUT_AIX)"; else echo "$(OUT_RELEASE)";fi)
LIBEXTENS=$(shell printf "$(LIBBINARISRC)" | sed 's/.*\.//g')
# projets exe only

#-------------------------------------------------------------------------------------------------------------------------
# configuration pour l'instalation riscdev4 ou riscdev6
#-------------------------------------------------------------------------------------------------------------------------
ifeq ($(strip $(SERVNAME)),riscdev4)
	REMOTSRV="riscdev4"
endif
ifeq ($(strip $(SERVNAME)),riscdev6)
	REMOTSRV="riscdev6"
endif

#-------------------------------------------------------------------------------------------------------------------------
# nom des commandes utilises
MAKEPKGEXE=tar -C "$(FAKEROOT)" --transform="s,^$(OUTILSREP),/$(OUTILSREP)," -czvf
ARCHEXE=tar --exclude=*.save --exclude=*~ -czvf
UNARCHEXE=tar -xPzvf
INSTALL=install -D --group=gsocle
PRINT="echo"
CBP2MAKE=cbp2make

#-------------------------------------------------------------------------------------------------------------------------

# recup version dns les sources
MAJOR_FILTER=const *int *.*MAJOR_VERS
MINOR_FILTER=const *int *.*MINOR_VERS
REVIS_FILTER=const *int *.*REVISION
BETA_FILTER=const *std::string *BETAVERS

MAJOR_NUM="$(shell cat "$(VERSION_FILE)" | grep "$(MAJOR_FILTER)" | tr -s " \t()" "\t" | cut -f4)"
MINOR_NUM="$(shell cat "$(VERSION_FILE)" | grep "$(MINOR_FILTER)" | tr -s " \t()" "\t" | cut -f4)"
REVIS_NUM="$(shell cat "$(VERSION_FILE)" | grep "$(REVIS_FILTER)"   | tr -s " \t()" "\t" | cut -f4)"
BETA_VAL="$(shell cat "$(VERSION_FILE)" | grep "$(BETA_FILTER)" | tr -s " \t()" "\t" | cut -f4)"

SRCVERSION="$(MAJOR_NUM).$(MINOR_NUM).$(REVIS_NUM)$(BETA_VAL)"

#-------------------------------------------------------------------------------------------------------------------------
ARCHFILE=$(PROJNAME)_$(SRCVERSION)_$(DATE).tgz
PACKAGEFILE=$(PROJNAME).$(SRCVERSION)-$(PKGTARGET).PKG

#-------------------------------------------------------------------------------------------------------------------------
# propre aux libs
CURRENTINCBASEDIR=$(LIBRACINE)_$(SRCVERSION)
LASTLIB=$(SOCLE_LIB)/lib$(CURRENTINCBASEDIR).$(LIBEXTENS)
LIBINCINSTALLDIR=$(SOCLE_INC)/$(CURRENTINCBASEDIR)
# propre aux exes
CURRENTEXEBASE=$(PROJNAME)_$(SRCVERSION)
LASTEXE=$(INSTALLDIR)/$(BIN_SOUSREP)/$(CURRENTEXEBASE)
DEVEXE=$(SOCLE_BIN)/$(BIN_SOUSREP)/$(PROJNAME)_dev
# commun aux exes et aux libs
SRCBIN=$(shell if [ "$(ISLIB)" = "1" ] ; then echo "$(LIBBINARISRC)"; else echo "$(OUT_RELEASE)"; fi)
LASTBIN=$(shell if [ "$(ISLIB)" = "1" ] ; then echo "$(LASTLIB)"; else echo "$(LASTEXE)"; fi)
DEVBIN=$(shell if [ "$(ISLIB)" = "1" ] ; then echo ""; else echo "$(DEVEXE)"; fi)
RESSOURCEINSTALLDIR="$(SOCLE_LIB)/$(CURRENTINCBASEDIR)"
# commande d'installation :
CMDINSTALL=$(UNARCHEXE) $(PACKAGEFILE) -p --same-owner --no-overwrite-dir -C $(GALILEEROOT) >/dev/null


#-------------------------------------------------------------------------------------------------------------------------

# Inclusion du fichier mak  du projet si il existe sinon creation vide
# ----------------------------------------------------------------------

ARFLAGS = $(shell if [ "$(KERNTYP)" = "aix" ] ; then echo " -X64"; else echo ""; fi)
CIBLE = $(shell if [ "$(KERNTYP)" = "aix" ] ; then echo "aix"; else echo "release"; fi)

CONFMAKE=CONFIG.mak
CONFIG_INCLUDE:=$(wildcard $(CONFMAKE))
ifneq ($(strip $(CONFIG_INCLUDE)),)
  contents :=  $(shell echo including extra rules $(CONFIG_INCLUDE))
  include $(CONFIG_INCLUDE)
else
  POUBELLE=$(shell touch $(CONFMAKE))
endif

EXTRA_INCLUDES:=$(wildcard $(PROJMAKE))
ifneq ($(strip $(EXTRA_INCLUDES)),)
  contents :=  $(shell echo including extra rules $(EXTRA_INCLUDES))
  include $(EXTRA_INCLUDES)
else
  POUBELLE=$(shell touch $(PROJMAKE))
endif

# cibles  generiqus
# ----------------------------------------------------------------------
package: cleanpkg
	@$(INSTALL) --mode=775 -d $(FAKEROOT);
	@$(INSTALL) --mode=775 -d $(FAKESOCLE);
	@$(INSTALL) --mode=775 -d $(FAKEBINDIR);
	@$(INSTALL) --mode=775 -d $(FAKELIBDIR);
	@if [ -d $(RESSOURCES) ] ; then \
		$(INSTALL) --mode=775 -d $(FAKEROOT)/$(RESSOURCEINSTALLDIR); \
		$(INSTALL) --mode=664 $(RESSOURCES)/* "$(FAKEROOT)/$(RESSOURCEINSTALLDIR)"; \
	fi; 
	@if [ $(ISLIB) = 1 ] ; then \
		$(INSTALL) --mode=775 -d "$(FAKEINCLUDEDIR)"; \
		$(INSTALL) --mode=775 -d "$(FAKEROOT)/$(LIBINCINSTALLDIR)"; \
		$(INSTALL) --mode=664 $(SRCINCLUDES)/*.h "$(FAKEROOT)/$(LIBINCINSTALLDIR)"; \
		sed 's@#include "@#include "'$(CURRENTINCBASEDIR)'/@g' $(MAININCLUDEFILE) > $(FAKEROOT)/$(LIBINCINSTALLDIR)/$(MAINBASEINCLUDEFILE); \
		chgrp gsocle $(FAKEROOT)/$(LIBINCINSTALLDIR)/$(MAINBASEINCLUDEFILE); \
	fi
	@$(INSTALL) --mode=775 "$(SRCBIN)" "$(FAKEROOT)/$(LASTBIN)";
	@$(ARCHEXE) "$(PACKAGEFILE)" -C "$(FAKESOCLE)" .

install: package
	@if  test -f $(LASTBIN); then \
		$(PRINT) " !!!! ERREURE : le binaire $(LASTBIN) est deja installe !!!!"; \
	elif [ $(ISLIB) = 1 ] && test -d $(LIBINCINSTALLDIR); then \
		$(PRINT) " !!!! ERREURE : le repertoire header $(LIBINCINSTALLDIR) est deja installe !!!!"; \
	else \
		$(CMDINSTALL); \
		if [ "$(KERNTYP)" = "aix" ] && [ "$(SERVNAME)" != "pser055" ] ; then \
			scp -p $(PACKAGEFILE) $(REMOTSRV):$(FAKESOCLE) \
			ssh $(REMOTSRV):$(FAKESOCLE) $(CMDINSTALL); \
		fi \
	fi

uninstall:
	@if [ -d $(RESSOURCES) ] ; then rm -Rf $(RESSOURCEINSTALLDIR); fi
	@if [ $(ISLIB) = 1 ]  ; then rm -Rf $(LIBINCINSTALLDIR); fi
	@rm -f $(LASTBIN)
	@if [ "$(KERNTYP)" = "aix" ] && [ "$(SERVNAME)" != "pser055" ] ; then \
		if [ -d $(RESSOURCES)  ] ; then ssh $(REMOTSRV) rm -Rf $(RESSOURCEINSTALLDIR); fi; \
		if [ $(ISLIB) = 1 ]  ; then ssh $(REMOTSRV) rm -Rf $(LIBINCINSTALLDIR); fi; \
		ssh $(REMOTSRV) rm -f $(REMOTSRV):$(LASTBIN); \
	fi

devinstall:
	@if [ $(ISLIB) != 1 ]; then \
		$(INSTALL)  --mode=755 $(OUT_RELEASE) $(DEVBIN); \
		if [ "$(KERNTYP)" = "aix" ] && [ "$(SERVNAME)" != "pser055" ] ; then \
			scp -p $(DEVBIN) $(REMOTSRV):$(DEVBIN); \
		fi;\
	fi
archive:
	@$(ARCHEXE) $(ARCHFILE) $(SOURCES)

cbp2make:
	@$(CBP2MAKE) -in $(PROJFILE) -out $(PROJMAKE) -unix
	@sed 's/\(^AR = ar.*\)/\1 $$(ARFLAGS)/' $(PROJMAKE)		\
		| sed 's/\(^all: \).*/\1$$(CIBLE)/'			\
		| sed 's/\\)/\)/g' 					\
		| sed 's/\\(/\(/g' 					\
		| sed 's/ = $$(LIB)\([^ ]\)/ = $$(LIB) \1/'		\
		| sed 's#\\\$$#$$#g'> $(TMPMAK)
	@mv $(TMPMAK) $(PROJMAKE)

cleanpkg:
	@rm -Rf $(FAKEROOT)
	@rm -f $(PACKAGEFILE)

mrpropre: clean cleanpkg
	@rm -f *.tgz

help:
	@$(PRINT) "Usage :"
	@$(PRINT) " "
	@$(PRINT) "	make             -> build par defaut (Debug et Release)"
	@$(PRINT) "	make package     -> creation du package d'instalation (tgz) pour prod et pre-prod "
	@$(PRINT) "	make install     -> install de le binaire Release renomee avec le numero de version "
	@$(PRINT) "	make devinstall  -> install de le binaire Release avec l'extention _dev (ecrase le prescedent)"
	@$(PRINT) "	make help        -> cet aide"
	@$(PRINT) "	make archive     -> cree une archive horodatee des sources "
	@$(PRINT) "	make cbp2make    -> converti le projet codeBlock en Makefile"
	@$(PRINT) "			 (necessite l'exe $(CBP2MAKE) dans le path)"
	@$(PRINT) " "
	@$(PRINT) "	make mrpropre    -> nettoyage complet  :  clean + package d'installation et repertoire associé "
	@$(PRINT) " "
	@$(PRINT) "	make testvar     -> pour le debug du Makefile"
	@$(PRINT) " "
	@$(PRINT) " options de compilation : export ENV_CFLAGS=xxxxxxxx; make ..."
	@$(PRINT) "      ex : DEBUG_XXXXXXXXX     -> affiche les infos de debug de XXXXXXXXX dans le log "
	@$(PRINT) " "
	@$(PRINT) " "

testvar:
	@$(PRINT) " SERVNAME=[$(SERVNAME)]"
	@$(PRINT) " LNXTARGET=[$(LNXTARGET)]"
	@$(PRINT) " AIXTARGET=[$(AIXTARGET)]"
	@$(PRINT) " PKGTARGET=[$(PKGTARGET)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " NBR_CPUS=[$(NBR_CPUS)]"
	@$(PRINT) " JOB_FLAG=[$(JOB_FLAG)]"
	@$(PRINT) " JOBS=[$(JOBS)]"
	@$(PRINT) " MAKEFLAGS=[$(MAKEFLAGS)]"
	@$(PRINT) " MAKE_PID=[$(MAKE_PID)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " OUT_RELEASE=[$(OUT_RELEASE)]"
	@$(PRINT) " OUT_AIX=[$(OUT_AIX)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " CIBLE=[$(CIBLE)]"
	@$(PRINT) " ARCHEXE=[$(ARCHEXE)]"
	@$(PRINT) " MAKEPKGEXE=[$(MAKEPKGEXE)]"
	@$(PRINT) " INSTALL=[$(INSTALL)]"
	@$(PRINT) " PRINT=[$(PRINT)]"
	@$(PRINT) " KERNTYP=[$(KERNTYP)]"
	@$(PRINT) " CBP2MAKE=[$(CBP2MAKE)]"
	@$(PRINT) " PROJNAME=[$(PROJNAME)]"
	@$(PRINT) " EXTCLDIR=[$(EXTCLDIR)]"
	@$(PRINT) " GALILEEROOT=[$(GALILEEROOT)]"
	@$(PRINT) " VERSION_FILE=[$(VERSION_FILE)]"
	@$(PRINT) " MAJOR_NUM=[$(MAJOR_NUM)]"
	@$(PRINT) " MINOR_NUM=[$(MINOR_NUM)]"
	@$(PRINT) " REVIS_NUM=[$(REVIS_NUM)]"
	@$(PRINT) " BETA_VAL=[$(BETA_VAL)]"
	@$(PRINT) " SRCVERSION=[$(SRCVERSION)]"
	@$(PRINT) " HASH_COMMIT=[$(HASH_COMMIT)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " ARCHFILE=[$(ARCHFILE)]"
	@$(PRINT) " PROJFILE=[$(PROJFILE)]"
	@$(PRINT) " PROJMAKE=[$(PROJMAKE)]"
	@$(PRINT) " CUSTSRC=[$(CUSTSRC)]"
	@$(PRINT) " SOURCES=[$(SOURCES)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " --> Propre aux libs"
	@$(PRINT) " LIBRACINE=[$(LIBRACINE)]"
	@$(PRINT) " MAINBASEINCLUDEFILE=[$(MAINBASEINCLUDEFILE)]"
	@$(PRINT) " MAININCLUDEFILE=[$(MAININCLUDEFILE)]"
	@$(PRINT) " LIBBINARISRC=[$(LIBBINARISRC)]"
	@$(PRINT) " LIBEXTENS=[$(LIBEXTENS)]"
	@$(PRINT) " CURRENTINCBASEDIR=[$(CURRENTINCBASEDIR)]"
	@$(PRINT) " LASTLIB=[$(LASTLIB)]"
	@$(PRINT) " LIBINCINSTALLDIR=[$(LIBINCINSTALLDIR)]"
	@$(PRINT) " --> Propre aux exes"
	@$(PRINT) " LASTEXE=[$(LASTEXE)]"
	@$(PRINT) " DEVEXE=[$(DEVEXE)]"
	@$(PRINT) " --> commun aux exes et libs"
	@$(PRINT) " SRCBIN=[$(SRCBIN)]"
	@$(PRINT) " LASTBIN=[$(LASTBIN)]"
	@$(PRINT) " DEVBIN=[$(DEVBIN)]"
	@$(PRINT) " RESSOURCEINSTALLDIR=[$(RESSOURCEINSTALLDIR)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " SRCINCLUDES=[$(SRCINCLUDES)]"
	@$(PRINT) " SOCLE_BIN=[$(SOCLE_BIN)]"
	@$(PRINT) " SOCLE_LIB=[$(SOCLE_LIB)]"
	@$(PRINT) " SOCLE_INC=[$(SOCLE_INC)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " ### partie installation jumelé dev4/dev6 ### "
	@$(PRINT) " REMOTSRV=[$(REMOTSRV)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " ### pour création du package ### "
	@$(PRINT) " FAKEROOT=[$(FAKEROOT)]"
	@$(PRINT) " FAKESOCLE=[$(FAKESOCLE)]"
	@$(PRINT) " FAKEBINDIR=[$(FAKEBINDIR)]"
	@$(PRINT) " FAKELIBDIR=[$(FAKELIBDIR)]"
	@$(PRINT) " FAKEINCLUDEDIR=[$(FAKEINCLUDEDIR)]"
	@$(PRINT) " PACKAGEFILE=[$(PACKAGEFILE)]"
	@$(PRINT) " =[$()]"
	@$(PRINT) " CMDINSTALL=[$(CMDINSTALL)]"
	@$(PRINT) " INSTALL=[$(INSTALL)]"

