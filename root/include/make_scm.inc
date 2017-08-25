# define SCM_ADMIN check
# SCM_ADMIN : SCM_MHOME = SCM_HOME or SCM_BHOME = SCM_HOME
# Check var is SCM_ADMIN
ifeq ($(SCM_HOME), $(SCM_MHOME))
	SCM_ADMIN=Y
else
	ifeq ($(SCM_HOME), $(SCM_BHOME))
	    SCM_ADMIN=Y
	endif
endif

# define vpath
VPATH=$(SCM_SRC_DIR) $(SCM_OUT_DIR) $(USER_VPATH) $(SCM_WDA_LIB) $(SCM_WDA_BIN)

# Lex libray
ifeq (-ll, $(filter -ll, $(LDLIBS)))
PRE_LDLIBS += -ll
endif

# Yacc libray
ifeq (-ly, $(filter -ly, $(LDLIBS)))
PRE_LDLIBS += -ly
endif

LDDIRS+=-L$(SCM_WDA_LIB)
LDLIBS:=$(PRE_LDLIBS) $(USER_LIBS) $(filter-out -ll -ly, $(LDLIBS))

# define objects
$(foreach bin, $(BINS), \
	$(eval \
		MAIN_OBJS += $($(bin)_MAIN_OBJ) \
	) \
)
$(foreach lib, $(LIBS), \
	$(eval \
		USER_LIB_OBJS+=$($(lib)_OBJS) \
	) \
)

$(LIB_NAME)_OBJS?=$(filter %.o, $(filter-out $(MAIN_OBJS) $(USER_LIB_OBJS) $(NOT_OBJS),$(OBJS)))
$(JAR_NAME)_OBJS?=$(filter %.class, $(filter-out $(NOT_OBJS),$(OBJS)))

# local library create rule generate
ifneq ($($(LIB_NAME)_OBJS),)
LIBS+=$(LIB_NAME)
else
ifneq ($(wildcard $(patsubst $(SCM_HOME)%,$(SCM_MHOME)%,$(SCM_WDA_LIB)/$(LIB_NAME))),)
LIBS+=$(LIB_NAME)
else
USER_LIBS:=$(filter-out $(patsubst lib%.a,-l%,$(LIB_NAME)),$(USER_LIBS))
AUSER_LIBS:=USER_LIBS
LDLIBS:=$(filter-out $(patsubst lib%.a,-l%,$(LIB_NAME)),$(LDLIBS))
endif
endif

AR_LIBS=$(filter %.a,$(LIBS))
SO_LIBS=$(filter %.so,$(LIBS))

$(foreach lib, $(AR_LIBS), \
	$(eval \
		$(call ARL_TEMPLATE,$(lib)) \
	) \
)

$(foreach lib, $(SO_LIBS), \
	$(eval \
		$(call CXXSOL_TEMPLATE,$(lib)) \
	) \
)

ifneq ($($(JAR_NAME)_OBJS),)
JARS  += $(JAR_NAME)
VPATH += $(SCM_OUT_DIR)/$(JAVAOUT_DIR)

$(JAR_NAME) : $($(JAR_NAME)_OBJS)
	$(JARL)
endif

POSTLIBS=$(SO_LIBS)

# Local library dependency
$(foreach bin, $(BINS), \
	$(foreach lib, $(LIBS), \
		$(eval \
			$(bin) : $(lib) \
		) \
	) \
)

# User library dependency
# local library의 -l 옵션은 lib%.a로 변경해야 clean build시 정상 작동
$(foreach bin, $(BINS), \
	$(foreach lib, $(USER_LIBS), \
		$(eval \
			$(bin) : $(patsubst -l%,lib%.a,$(lib)) \
		) \
	) \
)

#$(lib) : $(patsubst %,$(SCM_OUT_DIR)/%,$(filter $($(lib)_OBJS), $(LOCAL_OBJS))) \
# Local object dependency

ifneq ($(SCM_ADMIN),Y)
$(foreach lib, $(AR_LIBS), \
	$(eval \
		$(lib) : $($(lib)_OBJS) \
	) \
)
endif

# Shell copy rule generate
SHELL_FILES=$(filter-out $(MAIN_OBJS) $(NOT_SHELLS), $(notdir $(wildcard $(SCM_SRC_DIR)/*.sh)))
BINS+=$(addprefix $(SCM_WDA_BIN)/,$(SHELL_FILES) )
$(foreach sh, $(SHELL_FILES), \
	$(eval \
		$(call SHL_TEMPLATE,$(sh)) \
	) \
)

# CFG copy rule generate
CFG_FILES=$(filter-out $(MAIN_OBJS) $(NOT_CFGS), $(notdir $(wildcard $(SCM_SRC_DIR)/*.cfg) $(wildcard $(SCM_SRC_DIR)/*.CFG)))
BINS+=$(addprefix $(SCM_WDA_CFG)/,$(CFG_FILES) )
$(foreach cfg, $(CFG_FILES), \
	$(eval \
		$(call CFGL_TEMPLATE,$(cfg)) \
	) \
)


# if not SCM_ADMIN then expand INCDIRS, LDDIRS, VPATH
ifneq ($(SCM_ADMIN),Y)
define EXPAND_INCDIRS
	ifeq ($(findstring $(SCM_HOME), $(1)), $(SCM_HOME))
		LOCAL_INCDIRS+=$(1)
		LOCAL_INCDIRS+=$(patsubst -I$(SCM_HOME)%,-I$(SCM_MHOME)%,$(1))
	else
		LOCAL_INCDIRS+=$(1)
	endif
endef

LOCAL_INCDIRS:=
$(foreach val, $(INCDIRS), \
	$(eval \
		$(call EXPAND_INCDIRS,$(val)) \
	) \
)
INCDIRS:=$(LOCAL_INCDIRS)


define EXPAND_LDDIRS
	ifeq ($(findstring $(SCM_HOME), $(1)), $(SCM_HOME))
		LOCAL_LDDIRS+=$(1)
		LOCAL_LDDIRS+=$(patsubst -L$(SCM_HOME)%,-L$(SCM_MHOME)%,$(1))
	else
		LOCAL_LDDIRS+=$(1)
	endif
endef

LOCAL_LDDIRS:=
$(foreach val, $(LDDIRS), \
	$(eval \
		$(call EXPAND_LDDIRS,$(val)) \
	) \
)
LDDIRS:=$(LOCAL_LDDIRS)

# VPATH Expand 시 Master의 SCM_OUT 은 포함하지 않는다.
define EXPAND_VPATH
	ifeq ($(findstring $(SCM_HOME), $(1)), $(SCM_HOME))
		LOCAL_VPATH+=$(1)
		ifneq ($(1), $(SCM_OUT_DIR))
			LOCAL_VPATH+=$(patsubst $(SCM_HOME)%,$(SCM_MHOME)%,$(1))
		endif
	else
		LOCAL_VPATH+=$(1)
	endif
endef

LOCAL_VPATH:=
$(foreach val, $(VPATH), \
	$(eval \
		$(call EXPAND_VPATH,$(val)) \
	) \
)
VPATH:=$(LOCAL_VPATH)

endif

