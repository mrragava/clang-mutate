LLVM_POSTFIX ?=
CXX := clang++$(LLVM_POSTFIX)
RTTIFLAG := -fno-rtti
PICOJSON_INCS := -I third-party/picojson-1.3.0
PICOJSON_DEFINES := -D PICOJSON_USE_INT64
LLVM_CONFIG := llvm-config$(LLVM_POSTFIX)
LLVM_DWARFDUMP := llvm-dwarfdump$(LLVM_POSTFIX)
CXXFLAGS := $(shell $(LLVM_CONFIG) --cxxflags) $(RTTIFLAG) $(PICOJSON_INCS) $(PICOJSON_DEFINES) -DLLVM_DWARFDUMP='"$(LLVM_DWARFDUMP)"'
LLVMLDFLAGS := $(shell $(LLVM_CONFIG) --ldflags --libs) -ldl

SOURCES = ASTMutate.cpp ASTLister.cpp ASTEntry.cpp ASTEntryList.cpp Bindings.cpp Renaming.cpp Scopes.cpp Macros.cpp TypeDBEntry.cpp BinaryAddressMap.cpp Json.cpp Utils.cpp clang-mutate.cpp
OBJECTS = $(SOURCES:.cpp=.o)
EXES = clang-mutate
CLANGLIBS = \
	-lpthread \
	-lz \
	-ltinfo \
	-lclangFrontend \
	-lclangSerialization \
	-lclangDriver \
	-lclangTooling \
	-lclangParse \
	-lclangSema \
	-lclangAnalysis \
	-lclangEdit \
	-lclangAST \
	-lclangLex \
	-lclangBasic \
	-lclangRewrite

all: $(EXES)
.PHONY: clean install

%: %.o
	$(CXX) -o $@ $<

clang-mutate: $(OBJECTS)
	$(CXX) -o $@ $^ $(CLANGLIBS) $(LLVMLDFLAGS)

clean:
	-rm -f $(EXES) $(OBJECTS) compile_commands.json a.out etc/hello etc/loop *~

install: clang-mutate
	cp $< $$(dirname $$(which clang$(LLVM_POSTFIX)))

# An alternative to giving compiler info after -- on the command line
compile_commands.json:
	echo -e "[\n\
	  {\n\
	    \"directory\": \"$$(pwd)\",\n\
	    \"command\": \"$$(which clang) $$(pwd)/etc/hello.c\",\n\
	    \"file\": \"$$(pwd)/etc/hello.c\"\n\
	  }\n\
	]\n" > $@


# Tests
TESTS =	hello-second-stmt-says-hello-get		\
	hello-second-stmt-says-hello-json		\
	hello-semi-colon-on-end-of-statement-get	\
	hello-semi-colon-on-end-of-statement-insert	\
	hello-semi-colon-on-end-of-statement-cut	\
	hello-semi-colon-on-end-of-statement-json

PASS=\e[1;1m\e[1;32mPASS\e[1;0m
FAIL=\e[1;1m\e[1;31mFAIL\e[1;0m
check/%: test/%
	@if ./$< >/dev/null 2>/dev/null;then \
	printf "$(PASS)\t"; \
	else \
	printf "$(FAIL)\t"; \
	fi
	@printf "\e[1;1m%s\n" $*

check: $(addprefix check/, $(TESTS))
