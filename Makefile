TARGETS = poxy.vim
INSTALL_PATH = /usr/share/vim/vim72/syntax

.PHONY: install default

default:
	@echo make install is the only option

install:
	install -m644 $(TARGETS) $(INSTALL_PATH)
