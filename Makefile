# Setup the Freedom build script environment
include scripts/Freedom.mk

# Include version identifiers to build up the full version string
include Version.mk
PACKAGE_HEADING := freedom-trace-decoder
PACKAGE_VERSION := $(TRACE_DECODER_VERSION)-$(FREEDOM_TRACE_DECODER_ID)

# Source code directory references
SRCNAME_TRACE_DECODER := trace-decoder
SRCPATH_TRACE_DECODER := $(SRCDIR)/$(SRCNAME_TRACE_DECODER)
SRCNAME_BINUTILS := riscv-binutils
SRCPATH_BINUTILS := $(SRCDIR)/$(SRCNAME_BINUTILS)
BINUTILS_TUPLE := riscv64-unknown-elf
BINUTILS_CC_FOR_TARGET ?= $(BINUTILS_TUPLE)-gcc

# Some special package configure flags for specific targets
$(WIN64)-trace-host          := --host=$(WIN64)
$(WIN64)-tdc-cross           := x86_64-w64-mingw32-
$(WIN64)-tdc-binext          := .exe
$(UBUNTU64)-trace-host       := --host=x86_64-linux-gnu
$(UBUNTU64)-trace-configure  := --enable-shared --enable-static
$(REDHAT)-trace-configure    := --enable-shared --enable-static

# Setup the package targets and switch into secondary makefile targets
# Targets $(PACKAGE_HEADING)/install.stamp and $(PACKAGE_HEADING)/libs.stamp
include scripts/Package.mk

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/install.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp
	mkdir -p $(dir $@)
	date > $@

# We might need some extra target libraries for this package
$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/libs.stamp: \
		$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/install.stamp
	date > $@

$(OBJ_WIN64)/build/$(PACKAGE_HEADING)/libs.stamp: \
		$(OBJ_WIN64)/build/$(PACKAGE_HEADING)/install.stamp
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp:
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/$(PACKAGE_HEADING)/source.stamp,%/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET),$@))
	$(eval $@_REC := $(abspath $(patsubst %/build/$(PACKAGE_HEADING)/source.stamp,%/rec/$(PACKAGE_HEADING),$@)))
	rm -rf $($@_INSTALL)
	mkdir -p $($@_INSTALL)
	rm -rf $($@_REC)
	mkdir -p $($@_REC)
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cp -a $(SRCPATH_BINUTILS) $(SRCPATH_TRACE_DECODER) $(dir $@)
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/build-binutils/build.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/build-binutils/build.stamp,%,$@))
	$(eval $@_BUILD := $(patsubst %/build/$(PACKAGE_HEADING)/build-binutils/build.stamp,%/build/$(PACKAGE_HEADING),$@))
	$(eval $@_REC := $(abspath $(patsubst %/build/$(PACKAGE_HEADING)/build-binutils/build.stamp,%/rec/$(PACKAGE_HEADING),$@)))
# CC_FOR_TARGET is required for the ld testsuite.
	cd $(dir $@) && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $($@_BUILD))/$(SRCNAME_BINUTILS)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $($@_BUILD))/$(SRCNAME_BINUTILS)/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-werror \
		--with-expat=no --with-mpc=no --with-mpfr=no --with-gmp=no \
		--disable-gdb \
		--disable-sim \
		--disable-libdecnumber \
		--disable-libreadline \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>$($@_REC)/$(SRCNAME_BINUTILS)-make-configure.log
	$(MAKE) -C $(dir $@) &>$($@_REC)/$(SRCNAME_BINUTILS)-make-build.log
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/build-binutils/build.stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET),$@))
	$(eval $@_BINUTILS := $(patsubst %/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%/build/$(PACKAGE_HEADING)/build-binutils,$@))
	$(eval $@_REC := $(abspath $(patsubst %/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%/rec/$(PACKAGE_HEADING),$@)))
	$(MAKE) -C $(dir $@) BINUTILSPATH=$(abspath $($@_BINUTILS)) CROSSPREFIX=$($($@_TARGET)-tdc-cross) all &>$($@_REC)/$(SRCNAME_TRACE_DECODER)-make-build.log
	$(MAKE) -j1 -C $(dir $@) INSTALLPATH=$(abspath $($@_INSTALL)) CROSSPREFIX=$($($@_TARGET)-tdc-cross) install &>$($@_REC)/$(SRCNAME_TRACE_DECODER)-make-install.log
	date > $@

#regress: \
#		$(OBJDIR)/native/$(PACKAGE_HEADING).native
#	mkdir -p $(dir $@)
#	PATH=$(abspath $(OBJDIR)/native/$(PACKAGE_TARNAME)/bin):$(PATH) dqr -v
#	date > $@
