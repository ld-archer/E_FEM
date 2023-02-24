SHELL           = /bin/sh
srcdir          = FEM_CPP
DEFS            = 
dCPPFLAGS        = -Wall -Werror -g -MMD
CPPFLAGS       = -Wall -O3 -MMD -ffast-math -msse2
LIBS            =  -lpthread

SOURCES := $(notdir $(wildcard $(srcdir)/*.cpp))
HEADERS := $(notdir $(wildcard $(srcdir)/*.h))
OBJS := $(patsubst %.cpp, $(srcdir)/optimized/%.o, $(SOURCES))
dOBJS := $(patsubst %.cpp, $(srcdir)/debug/%.o, $(SOURCES))

FEM_RUN_DIR = .
CXX         = mpicxx 
CXXFLAGS    = 
CXX_DEFS    =  -DHAVE_CXX_IOSTREAM -DHAVE_NAMESPACE_STD -D__FEM_UNIX__
CXX_COMPILE = $(CXX) $(DEFS) $(CXX_DEFS) $(INCLUDES) $(CXXFLAGS) $(CPPFLAGS)
dCXX_COMPILE = $(CXX) $(DEFS) $(CXX_DEFS) $(INCLUDES) $(CXXFLAG) $(dCPPFLAGS)
CXX_LINK    = $(CXX)
LDFLAGS     = 

VPATH = .
.SUFFIXES:
.SUFFIXES: .o .cpp .txt 

FEM: ${OBJS}
	$(CXX_COMPILE) $(LDFLAGS) -o ${FEM_RUN_DIR}/FEM ${OBJS}  ${LIBS}
dFEM: ${dOBJS}
	$(dCXX_COMPILE) $(LDFLAGS) -o ${FEM_RUN_DIR}/dFEM ${dOBJS} ${LIBS}
person_test: $(srcdir)/debug/Person.o $(srcdir)/debug/Vars.o $(srcdir)/debug/missing_var_exception.o $(srcdir)/debug/utility.o $(srcdir)/testing/person_main.o
	$(dCXX_COMPILE) $(LDFLAGS) -o ${FEM_RUN_DIR}/person_test $^ ${LIBS}

-include $(OBJS:.o=.d)
-include $(dOBJS:.o=.d)

$(srcdir)/optimized/%.o: $(srcdir)/%.cpp
	$(CXX_COMPILE) -c $< -o $(srcdir)/optimized/$(@F)
$(srcdir)/debug/%.o: $(srcdir)/%.cpp
	$(dCXX_COMPILE) -c $< -o $(srcdir)/debug/$(@F)
