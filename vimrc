" syntax highlighting for p/oxy code
" make sure the source is correct,
" copy poxy syntax to the correct location

au BufRead,BufNewFile *.p set filetype=poxy
au! Syntax poxy source /usr/share/vim/vim72/syntax/poxy.vim
