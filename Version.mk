# Version number, which should match the official version of the tool we are building
include src/trace-decoder/version.mk

# Customization ID, which should identify the customization added to the original by SiFive
FREEDOM_TRACE_DECODER_ID := 2021.02.0

# Characteristic tags, which should be usable for matching up providers and consumers
FREEDOM_TRACE_DECODER_RISCV_TAGS = rv32i rv64i m a f d c v zfh zba zbb
FREEDOM_TRACE_DECODER_TOOLS_TAGS = trace-decoder
