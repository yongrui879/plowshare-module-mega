##
# mega.co.nz plugin for Plowshare
# Usage:
# - make PREFIX=/usr install
# - make PREFIX=/usr DESTDIR=/tmp/packaging install
##

# TODO:
# - check for openssl dev files (openssl/aes.h)
# - check for openssl libs (libcrypto.so)

# Paths you can override
PREFIX  ?= /usr/local
PLOWDIR ?= $(DESTDIR)$(PREFIX)/share/plowshare4

# Compiler and tools
CC = gcc
CFLAGS = -Wall -O3
STRIP = strip
INSTALL = install
RM = rm -f

# Files
SRC = src/crypto.c
OUT = mega

# Rules
$(OUT): $(SRC)
	$(CC) $(CFLAGS) $< -o $@ -lcrypto
	$(STRIP) $@

install: $(OUT)
	$(INSTALL) -d $(PLOWDIR)/modules
	$(INSTALL) -d $(PLOWDIR)/plugins
	$(INSTALL) -m 755 $(OUT) $(PLOWDIR)/plugins/mega
	$(INSTALL) -m 644 module/mega.sh $(PLOWDIR)/modules

uninstall:
	$(RM) $(PLOWDIR)/plugins/mega
	$(RM) $(PLOWDIR)/modules/mega.sh

clean:
	@$(RM) $(OUT)

check_plowdir:
	@test -f $(PLOWDIR)/core.sh || \
		{ echo 'Invalid PLOWDIR, this is not a plowshare directory! Can'\''t find core.sh. Abort.'; false; }

patch_config: $(PLOWDIR)/modules/config
	@grep -q '^mega[[:space:]]' $< || { \
		echo 'patching modules/config file' && \
		echo 'mega            | download | upload |        |      | probe |' >> $<; }

# Note: sed -i is not BSD friendly!
unpatch_config: $(PLOWDIR)/modules/config
	@grep -q '^mega[[:space:]]' $< && \
		echo 'unpatching modules/config file' && \
		sed -i -e '/^mega[[:space:]]/d' $< || true

name:
	@echo "git$$(date +%Y%m%d).$$(git log --pretty=format:%h -1 master)"

.PHONY: install uninstall check_plowdir clean
