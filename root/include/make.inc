.SUFFIXES:
.SUFFIXES: .cpp .c .pc .lpp .ypp .y .l .java .class .o

# make configuration
include $(SCM_ROOT)/include/make_config.inc

ifdef DEBUG_FLAGS
CFLAGS+=$(DEBUG_FLAGS)
endif

#############################################################
# command define section
#############################################################
CP    = cp
CHMOD = chmod
LEX   = lex
YACC  = yacc
MV    = mv
JAVAC = javac
JAR   = jar
MKDIR = mkdir

EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)
COMMA:= ,

#############################################################
# Compile section
#############################################################

# C compile
CINCS=$(INCDIRS)


define CC_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(CC) -o $@ -c $(CFLAGS) $(CINCS) $<
endef

# C++ compile
define CXX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(CXX) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $<
endef

# oracle proc compile
PROC=$(ORACLE_HOME)/bin/proc
#PROCFLAGS   += unsafe_null=yes mode=oracle dbms=v8 sqlcheck=syntax ltype=none
PROCFLAGS   += unsafe_null=yes mode=oracle dbms=v8 ltype=none
PROCXXFLAGS += code=cpp cpp_suffix=cpp
INCDIRS+=-I$(ORACLE_HOME)/precomp/public
PROCINCS=$(patsubst -I%,include=%,$(INCDIRS))
ifeq ($(ARCH),32)
LDDIRS+=-L$(ORACLE_HOME)/lib32
else
LDDIRS+=-L$(ORACLE_HOME)/lib
endif

ifneq ($(PROC_LDLIBS),none)
ifndef PROC_LDLIBS
PROC_LDLIBS = -lclntsh
endif
LDLIBS+=$(PROC_LDLIBS)
endif

define PROC_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(PROC) $(PROCFLAGS) $(PROCINCS) iname=$< oname=$*.c
$(CC) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.c
endef

# oracle proc++ compile
define PROCXX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(PROC) $(PROCXXFLAGS) $(PROCFLAGS) $(PROCINCS) iname=$< oname=$*.cpp
$(CXX) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.cpp
endef

ifeq ($(PROC_DEFAULT_CODE),cpp)
PROC_DEF_CMD=$(PROCXX_CMD)
else
PROC_DEF_CMD=$(PROC_CMD)
endif

# altibase C compile
SESC=$(ALTIBASE_HOME)/bin/apre -o ./ -parse none
SESCFLAGS   = -unsafe_null
SESCXXFLAGS = -t cpp
INCDIRS+=-I$(ALTIBASE_HOME)/include

ifndef SESCINCS
ifeq ($(SESC_VERSION),3)
SESCINCS= -include $(subst $(SPACE),$(COMMA),$(patsubst -I%,%,$(INCDIRS)))
#SESCINCS:=$(subst $(SCM_OUT_DIR),\.,$(SECINCS))
else
SESCINCS=$(patsubst -I%, -include %,$(INCDIRS))
endif
endif

ifneq ($(SESC_LDLIBS),none)
ifndef SESC_LDLIBS
SESC_LDLIBS = -lapre -lodbccli
endif

ifneq ($(ARCH),32)
LDDIRS+=-L$(ALTIBASE_HOME)/lib
LDLIBS+=$(SESC_LDLIBS)
endif
endif

define SESC_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(SESC) $(SESCFLAGS) $(SESCINCS) $<
$(CC) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.c
endef

# altibase C++ compile
define SESCXX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(SESC) $(SESCFLAGS) $(SESCXXFLAGS) $(SESCINCS) $<
$(CXX) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.cpp
endef

ifeq ($(SESC_DEFAULT_CODE),cpp)
SESC_DEF_CMD=$(SESCXX_CMD)
else
SESC_DEF_CMD=$(SESC_CMD)
endif

# YACC compile
define YACC_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(YACC) $(YFLAGS) $<
$(MV) -f y.tab.c $*.c
# $(MV) -f y.tab.h $*.h
$(CC) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.c
endef

define YACCXX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
$(YACC) $(YFLAGS) $<
$(MV) -f y.tab.c $*.cpp
# $(MV) -f y.tab.h $*.h
$(CXX) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.cpp
endef

# LEX compile
define LEX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
@$(RM) $@
$(LEX) $(LFLAGS) -t $< > $*.c
$(CC) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.c
endef

define LEXXX_CMD
@echo -----------------------------------
@echo Compile $<
@echo -----------------------------------
@$(RM) $@
$(LEX) $(LFLAGS) -t $< > $*.cpp
$(CXX) -o $@ -c $(CXXFLAGS) $(CFLAGS) $(CINCS) $*.cpp
endef

# JAVA compile
JAVACFLAGS = -deprecation
JARFLAGS   = cvf
JAVAOUT_DIR = __classes
define JAVAC_CMD
@$(MKDIR) -p $(dir $(JAVAOUT_DIR)/$@)
$(JAVAC) $(JAVACFLAGS) -d $(dir $(JAVAOUT_DIR)/$@) -sourcepath $(SCM_SRC_DIR) $<
endef

#############################################################
# Link section
#############################################################
define CXXL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CXX) -o $(SCM_WDA_BIN)/$@ $< $(CXXFLAGS) $(CFLAGS) $(LDFLAGS) $(LDDIRS) $(LDLIBS)
endef

define CCL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CC) -o $(SCM_WDA_BIN)/$@ $< $(CFLAGS) $(LDFLAGS) $(LDDIRS) $(LDLIBS)
endef

define CXXSOL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CXX) -b -o $(SCM_WDA_LIB)/$@ $^ $(CXXFLAGS) $(CFLAGS) $(LDFLAGS) $(LDDIRS) $(LDLIBS)
endef

define CCSOL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CC) -b -o $(SCM_WDA_LIB)/$@ $^ $(CFLAGS) $(LDFLAGS) $(LDDIRS) $(LDLIBS)
endef

define SHL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CP) $< $(SCM_WDA_BIN)/$@
$(CHMOD) 755 $(SCM_WDA_BIN)/$@
endef

define CPL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(CP) $< $(SCM_WDA_BIN)/$@
endef

define JARL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(JAR) $(JARFLAGS) $(SCM_WDA_LIB)/$@ -C $(JAVAOUT_DIR) .
endef

define ARL
@echo -----------------------------------
@echo Create $@
@echo -----------------------------------
$(AR) $(ARFLAGS) $(SCM_WDA_LIB)/$@ $^
ranlib $(SCM_WDA_LIB)/$@
endef

define ARL_TEMPLATE
$(1) : $($(1)_OBJS)
	$$(ARL)
endef

define CXXSOL_TEMPLATE
$(1) : $($(1)_OBJS)
	$$(CXXSOL)
endef


define SHL_TEMPLATE
$(SCM_WDA_BIN)/$(1) : $(SCM_SRC_DIR)/$(1)
	@echo -----------------------------------
	@echo Create $(1)
	@echo -----------------------------------
	$(CP) $(SCM_SRC_DIR)/$(1) $(SCM_WDA_BIN)/$(1)
	$(CHMOD) 755 $(SCM_WDA_BIN)/$(1)
endef

define CPL_TEMPLATE
$(SCM_WDA_BIN)/$(1) : $(SCM_SRC_DIR)/$(1)
	@echo -----------------------------------
	@echo Create $(1)
	@echo -----------------------------------
	$(CP) $(SCM_SRC_DIR)/$(1) $(SCM_WDA_BIN)/$(1)
	$(CHMOD) 755 $(SCM_WDA_BIN)/$(1)
endef

define CFGL_TEMPLATE
$(SCM_WDA_CFG)/$(1) : $(SCM_SRC_DIR)/$(1)
	@echo -----------------------------------
	@echo Create $(1)
	@echo -----------------------------------
	$(CP) $(SCM_SRC_DIR)/$(1) $(SCM_WDA_CFG)/$(1)
endef


#############################################################
# Normal suffix rule section ( 수정시 Local suffix rule 수정필요)
#############################################################
%.o : %.pc
	$(PROC_DEF_CMD)

%.o : %.sc
	$(SESC_DEF_CMD)

%.o : %.y
	$(YACC_CMD)

%.o : %.ypp
	$(YACCXX_CMD)

%.o : %.l
	$(LEX_CMD)

%.o : %.lpp
	$(LEXXX_CMD)

%.o : %.cpp
	$(CXX_CMD)

%.o : %.c
	$(CC_CMD)

%.class : %.java
	$(JAVAC_CMD)

#############################################################
# Local suffix rule section ( 수정시 Normal suffix rule 수정필요)
#############################################################
$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.pc
	$(PROC_DEF_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.sc
	$(SESC_DEF_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.y
	$(YACC_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.ypp
	$(YACCXX_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.l
	$(LEX_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.lpp
	$(LEXXX_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.cpp
	$(CXX_CMD)

$(SCM_OUT_DIR)/%.o : $(SCM_SRC_DIR)/%.c
	$(CC_CMD)

$(SCM_OUT_DIR)/%.class : $(SCM_SRC_DIR)/%.java
	$(JAVAC_CMD)

define DEBUG_PRINT
	$(warning ####################################################)
	$(warning + make debug DEBUG_VALUES=<name1> <name2> ...      +)
	$(warning ----------------------------------------------------)
	$(foreach val,$(DEBUG_VALUES),$(warning  # $(val) = $($(val))))
	$(warning ####################################################)
endef

