# Setup the Freedom build script environment
include scripts/Freedom.mk

# Include version identifiers to build up the full version string
include Version.mk
PACKAGE_HEADING := freedom-trace-decoder
PACKAGE_VERSION := $(TRACE_DECODER_VERSION)-$(FREEDOM_TRACE_DECODER_CODELINE)$(FREEDOM_TRACE_DECODER_GENERATION)b$(FREEDOM_TRACE_DECODER_BUILD)

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
	rm -rf $($@_INSTALL)
	mkdir -p $($@_INSTALL)
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cp -a $(SRCPATH_BINUTILS) $(SRCPATH_TRACE_DECODER) $(dir $@)
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_BINUTILS)/build.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_BINUTILS)/build.stamp,%,$@))
# CC_FOR_TARGET is required for the ld testsuite.
	cd $(dir $@)/bfd && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $(dir $@)/bfd)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $(dir $@))/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@)/bfd &>$(dir $@)/bfd/make-build.log
	cd $(dir $@)/intl && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $(dir $@)/intl)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $(dir $@))/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--with-included-gettext \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@)/intl &>$(dir $@)/intl/make-build.log
	cd $(dir $@)/libiberty && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $(dir $@)/libiberty)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $(dir $@))/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@)/libiberty &>$(dir $@)/libiberty/make-build.log
	cd $(dir $@)/opcodes && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $(dir $@)/opcodes)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $(dir $@))/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@)/opcodes &>$(dir $@)/opcodes/make-build.log
	cd $(dir $@)/zlib && CC_FOR_TARGET=$(BINUTILS_CC_FOR_TARGET) $(abspath $(dir $@)/zlib)/configure \
		--target=$(BINUTILS_TUPLE) \
		$($($@_TARGET)-trace-host) \
		--prefix=$(abspath $(dir $@))/install \
		--with-pkgversion="SiFive Trace-Decoder $(PACKAGE_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		$($($@_TARGET)-trace-configure) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@)/zlib &>$(dir $@)/zlib/make-build.log
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_BINUTILS)/build.stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET),$@))
	$(eval $@_BINUTILS := $(patsubst %/build/$(PACKAGE_HEADING)/$(SRCNAME_TRACE_DECODER)/build.stamp,%/build/$(PACKAGE_HEADING)/$(SRCNAME_BINUTILS),$@))
	$(MAKE) -C $(dir $@) BINUTILSPATH=$(abspath $($@_BINUTILS)) CROSSPREFIX=$($($@_TARGET)-tdc-cross) all &>$(dir $@)/make-build.log
	$(MAKE) -j1 -C $(dir $@) INSTALLPATH=$(abspath $($@_INSTALL)) CROSSPREFIX=$($($@_TARGET)-tdc-cross) install &>$(dir $@)/make-install.log
	date > $@
