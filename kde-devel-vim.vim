" To use this file, add this line to your ~/.vimrc:, w/o the dquote
" source /path/to/kde/sources/kdesdk/scripts/kde-devel-vim.vim
"
" For CreateChangeLogEntry() : If you don't want to re-enter your
" Name/Email in each vim session then make sure to have the viminfo
" option enabled in your ~/.vimrc, with the '!' flag, enabling persistent
" storage of global variables. Something along the line of
" set   viminfo=%,!,'50,\"100,:100,n~/.viminfo
" should do the trick.
"
" To make use of the ,ll and ,lg shortcuts you need to have the files
" GPLHEADER and LGPLHEADER in your home directory. Their content will be
" copied as license header then.

" Don't include these in filename completions
set suffixes+=.lo,.o,.moc,.la,.closure,.loT

" Search for headers here
set path=.,/usr/include,/usr/local/include,
if $QTDIR != ''
    let &path = &path . $QTDIR . '/include/,'
    let &path = &path . $QTDIR . '/include/Qt/,'
    let &path = &path . $QTDIR . '/include/QtCore/,'
    let &path = &path . $QTDIR . '/include/Qt3Support/,'
    let &path = &path . $QTDIR . '/include/QtAssistant/,'
    let &path = &path . $QTDIR . '/include/QtDBus/,'
    let &path = &path . $QTDIR . '/include/QtDesigner/,'
    let &path = &path . $QTDIR . '/include/QtGui/,'
    let &path = &path . $QTDIR . '/include/QtNetwork/,'
    let &path = &path . $QTDIR . '/include/QtOpenGL/,'
    let &path = &path . $QTDIR . '/include/QtSql/,'
    let &path = &path . $QTDIR . '/include/QtSvg/,'
    let &path = &path . $QTDIR . '/include/QtTest/,'
    let &path = &path . $QTDIR . '/include/QtUiTools/,'
    let &path = &path . $QTDIR . '/include/QtXml/,'
endif
if $KDEDIR != ''
    let &path = &path . $KDEDIR . '/include/,'
endif
if $KDEDIRS != ''
    let &path = &path . substitute( $KDEDIRS, '\(:\|$\)', '/include,', 'g' )
endif
set path+=,

" Use makeobj to build
set mp=makeobj

" If TagList is Loaded then get a funny statusline
" Only works if kde-devel-vim.vim is loaded after taglist.
" Droping this script in ~/.vim/plugin works fine
if exists('loaded_taglist')
    let Tlist_Process_File_Always=1
    set statusline=%<%f:[\ %{Tlist_Get_Tag_Prototype_By_Line()}\ ]\ %h%m%r%=%-14.(%l,%c%V%)\ %P
endif

" Insert tab character in whitespace-only lines, complete otherwise
inoremap <Tab> <C-R>=SmartTab()<CR>

if !exists("DisableSmartParens")
" Insert a space after ( or [ and before ] or ) unless preceded by a matching
" paren/bracket or space or inside a string or comment. Comments are only
" recognized as such if they start on the current line :-(
inoremap ( <C-R>=SmartParens( '(' )<CR>
inoremap [ <C-R>=SmartParens( '[' )<CR>
inoremap ] <C-R>=SmartParens( ']', '[' )<CR>
inoremap ) <C-R>=SmartParens( ')', '(' )<CR>
endif

" Insert an #include statement for the current/last symbol
inoremap <F5> <C-O>:call AddHeader()<CR>

" Insert a forward declaration for the current/last symbol
inoremap <S-F5> <C-O>:call AddForward()<CR>

" Switch between header and implementation files on ,h
nmap <silent> ,h :call SwitchHeaderImpl()<CR>
nmap <silent> ,p :call SwitchPrivateHeaderImpl()<CR>

" Comment selected lines on ,c in visual mode
vmap ,c :s,^,//X ,<CR>:noh<CR>
" Uncomment selected lines on ,u in visual mode
vmap ,u :s,^//X ,,<CR>

" Insert an include guard based on the file name on ,i
nmap ,i :call IncludeGuard()<CR>

" Insert license headers at the top of the file
nmap ,lg :call LicenseHeader( "GPL" )<CR>
nmap ,ll :call LicenseHeader( "LGPL" )<CR>

" Insert simple debug statements into each method
nmap ,d :call InsertMethodTracer()<CR>

" Expand #i to #include <.h> or #include ".h". The latter is chosen
" if the character typed after #i is a dquote
" If the character is > #include <> is inserted (standard C++ headers w/o .h)
iab #i <C-R>=SmartInclude()<CR>

" Insert a stripped down CVS diff
iab DIFF <Esc>:call RunDiff()<CR>

" mark 'misplaced' tab characters
set listchars=tab:�\ ,trail:�
set list

set incsearch

function! SetCodingStyle()
    "the path for the file
    let pathfn = expand( '%:p:h' )
    if pathfn =~ 'phonon'
        if strlen(mapcheck('(','i')) > 0
            iunmap (
        endif
        let g:DisableSpaceBeforeParen = 'x'
        call SmartParensOn()
        if ( &syntax =~ '^\(c\|cpp\|java\)$' )
            inoremap <CR> <ESC>:call SmartLineBreak2()<CR>a<CR>
        endif
        set sw=4
        set ts=4
        set noet
        set tw=80
        "set foldmethod=indent
        "set foldcolumn=3
        "map <TAB> za
    else "if pathfn =~ '\(kdelibs\|qt-copy\)'
        call SmartParensOff()
        inoremap ( <C-R>=SpaceBetweenKeywordAndParens()<CR>
        if ( &syntax =~ '^\(c\|cpp\|java\)$' )
            inoremap <CR> <ESC>:call SmartLineBreak()<CR>a<CR>
        endif
        set sw=4
        set sts=4
        set et
        set tw=80
    endif
endfunction

function! CreateMatchLine()
    let linenum = line( '.' )
    let current_line = getline( linenum )
    " don't do magic if the cursor isn't at the end of the line or if it's
    " inside a // comment
    if col( '.' ) != len( current_line ) || match( current_line, '//' ) >= 0
        return ''
    endif
    " remove whitespace at the end
    if match( current_line, '\s\+$' ) >= 0
        :execute ':s/\s*$//'
    endif
    let current_line = getline( linenum )
    " remove all /* */ comments
    let current_line = substitute( current_line, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
    " prepend earlier lines until we find a ;
    while linenum > 1 && match( current_line, ';' ) < 0
        let linenum = linenum - 1
        " remove all // comments
        let prev_line = substitute( getline( linenum ), '//.*$', '', '' )
        let current_line = prev_line . current_line
        " remove all /* */ comments
        let current_line = substitute( current_line, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
    endwhile
    " remove everything until the last ;
    let current_line = substitute( current_line, '^.*;', '', 'g' )
    " remove all strings
    let current_line = substitute( current_line, "'[^']*'", '', 'g' )
    let current_line = substitute( current_line, '"\(\\"\|[^"]\)*"', '', 'g' )
    " remove all ( )
    while match( current_line, '(.*)' ) >= 0
        let current_line = substitute( current_line, '([^()]*)', '', 'g' )
    endwhile
    " remove all [ ]
    while match( current_line, '\[.*\]' ) >= 0
        let current_line = substitute( current_line, '\[[^\[\]]*\]', '', 'g' )
    endwhile
    " if <CR> was pressed inside ( ) or [ ] don't add braces
    if match( current_line, '[(\[]' ) >= 0 || match( current_line, '/\*' ) >= 0
        return ''
    endif
    return current_line
endfunction

function! SmartLineBreak2()
    let current_line = CreateMatchLine()
    if current_line == ''
        return
    endif
    let need_brace_on_next_line = '\<\(class\|namespace\|struct\|if\|else\|while\|switch\|do\|foreach\|forever\|enum\|for\)\>'
    if match( current_line, need_brace_on_next_line ) >= 0
        let brace_at_end = '{$'
        if match( current_line, brace_at_end ) > 0
            :execute ':s/\s*{$//'
        endif
        :execute "normal o{"
        if match( current_line, '\<namespace\>' ) >= 0
            let namespace = substitute( current_line, '^.*namespace\s\+', '', '' )
            let namespace = substitute( namespace, '\s.*$', '', '' )
            :execute "normal o} // namespace " . namespace . "\<ESC>k"
        elseif match( current_line, '\<enum\|class\|struct\>' ) >= 0
            :execute "normal o};\<ESC>k"
        else
            :execute "normal o}\<ESC>k"
        endif
    elseif match( current_line, '^\s*{$' ) == 0
        :execute "normal o}\<ESC>k"
    endif
    :execute "normal $"
endfunction

function! SmartLineBreak()
    let current_line = CreateMatchLine()
    if current_line == ''
        return
    endif
    let need_brace_on_same_line = '\<\(if\|else\|while\|switch\|do\|foreach\|forever\|enum\|for\)\>'
    if match( current_line, need_brace_on_same_line ) >= 0
        let brace_at_end = '{$'
        if match( current_line, brace_at_end ) > 0
            if match( current_line, '[^ ]{$' ) > 0
                :execute ':s/{$/ {/'
            endif
        else
            :execute ':s/$/ {/'
        endif
        if match( current_line, '\<enum\>' ) >= 0
            :execute "normal o};\<ESC>k"
        else
            :execute "normal o}\<ESC>k"
        endif
    else
        let need_brace_on_next_line = '\<\(class\|namespace\|struct\)\>'
        if match( current_line, need_brace_on_next_line ) >= 0
            let brace_at_end = '{$'
            if match( current_line, brace_at_end ) > 0
                :execute ':s/\s*{$//'
            endif
            :execute "normal o{"
            if match( current_line, '\<namespace\>' ) >= 0
                let namespace = substitute( current_line, '^.*namespace\s\+', '', '' )
                let namespace = substitute( namespace, '\s.*$', '', '' )
                :execute "normal o} // namespace " . namespace . "\<ESC>k"
            else
                :execute "normal o};\<ESC>k"
            endif
        elseif match( current_line, '^\s*{$' ) == 0
            :execute "normal o}\<ESC>k"
        endif
    endif
    :execute "normal $"
endfunction

function! SmartParensOn()
    inoremap ( <C-R>=SmartParens( '(' )<CR>
    inoremap [ <C-R>=SmartParens( '[' )<CR>
    inoremap ] <C-R>=SmartParens( ']', '[' )<CR>
    inoremap ) <C-R>=SmartParens( ')', '(' )<CR>
endfunction

function! SmartParensOff()
    if strlen(mapcheck('[','i')) > 0
        iunmap (
        iunmap [
        iunmap ]
        iunmap )
    endif
endfunction

function! SmartTab()
    let col = col('.') - 1
    if !col || getline('.')[col-1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-P>"
    endif
endfunction

function! SmartParens( char, ... )
    if ! ( &syntax =~ '^\(c\|cpp\|java\)$' )
        return a:char
    endif
    let s = strpart( getline( '.' ), 0, col( '.' ) - 1 )
    if s =~ '//'
        return a:char
    endif
    let s = substitute( s, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
    let s = substitute( s, "'[^']*'", '', 'g' )
    let s = substitute( s, '"\(\\"\|[^"]\)*"', '', 'g' )
    if s =~ "\\([\"']\\|/\\*\\)"
        return a:char
    endif
    if a:0 > 0
        if strpart( getline( '.' ), col( '.' ) - 3, 2 ) == a:1 . ' '
            return "\<BS>" . a:char
        endif
        if strpart( getline( '.' ), col( '.' ) - 2, 1 ) == ' '
            return a:char
        endif
        return ' ' . a:char
    endif
    if !exists("g:DisableSpaceBeforeParen")
        if a:char == '('
            if strpart( getline( '.' ), col( '.' ) - 3, 2 ) == 'if' ||
              \strpart( getline( '.' ), col( '.' ) - 4, 3 ) == 'for' ||
              \strpart( getline( '.' ), col( '.' ) - 6, 5 ) == 'while' ||
              \strpart( getline( '.' ), col( '.' ) - 7, 6 ) == 'switch'
                return ' ( '
            endif
        endif
    endif
    return a:char . ' '
endfunction

function! SpaceBetweenKeywordAndParens()
    if ! ( &syntax =~ '^\(c\|cpp\|java\)$' )
        return '('
    endif
    let s = strpart( getline( '.' ), 0, col( '.' ) - 1 )
    if s =~ '//'
        " text inside a comment
        return '('
    endif
    let s = substitute( s, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
    let s = substitute( s, "'[^']*'", '', 'g' )
    let s = substitute( s, '"\(\\"\|[^"]\)*"', '', 'g' )
    if s =~ "\\([\"']\\|/\\*\\)"
        " text inside a string
        return '('
    endif
    if a:0 > 0
        if strpart( getline( '.' ), col( '.' ) - 3, 2 ) == a:1 . ' '
            return "\<BS>" . a:char
        endif
        if strpart( getline( '.' ), col( '.' ) - 2, 1 ) == ' '
            return a:char
        endif
        return ' ' . a:char
    endif
    if strpart( getline( '.' ), col( '.' ) - 3, 2 ) == 'if' ||
        \strpart( getline( '.' ), col( '.' ) - 4, 3 ) == 'for' ||
        \strpart( getline( '.' ), col( '.' ) - 6, 5 ) == 'while' ||
        \strpart( getline( '.' ), col( '.' ) - 7, 6 ) == 'switch' ||
        \strpart( getline( '.' ), col( '.' ) - 8, 7 ) == 'foreach' ||
        \strpart( getline( '.' ), col( '.' ) - 8, 7 ) == 'forever'
        return ' ('
    endif
    return '('
endfunction

function! SwitchHeaderImpl()
    let privateheaders = '_p\.\([hH]\|hpp\|hxx\)$'
    let headers = '\.\([hH]\|hpp\|hxx\)$'
    let impl = '\.\([cC]\|cpp\|cc\|cxx\)$'
    let fn = expand( '%' )
    if fn =~ privateheaders
        let list = glob( substitute( fn, privateheaders, '.*', '' ) )
    elseif fn =~ headers
        let list = glob( substitute( fn, headers, '.*', '' ) )
    elseif fn =~ impl
        let list = glob( substitute( fn, impl, '.*', '' ) )
    endif
    while strlen( list ) > 0
        let file = substitute( list, "\n.*", '', '' )
        let list = substitute( list, "[^\n]*", '', '' )
        let list = substitute( list, "^\n", '', '' )
        if ( ( fn =~ headers || fn =~ privateheaders ) && file =~ impl ) || ( fn =~ impl && file =~ headers )
            call AskToSave()
            execute( "edit " . file )
            return
        endif
    endwhile
    if ( fn =~ headers )
        call AskToSave()
        if exists( "$implextension" )
            let file = substitute( fn, headers, '.' . $implextension, '' )
        else
            let file = substitute( fn, headers, '.cpp', '' )
        endif
        " check for modified state of current buffer and if modified ask:
        " save, discard, cancel
        execute( 'edit '.file )
        call append( 0, "#include \"".fn."\"" )
        call append( 2, "// vim: sw=4 ts=4 noet" )
        execute( "set sw=4" )
        execute( "set ts=4" )
    elseif fn =~ impl
        call AskToSave()
        let file = substitute( fn, impl, '.h', '' )
        execute( "edit ".file )
    endif
endfunction

function! SwitchPrivateHeaderImpl()
    let privateheaders = '_p\.\([hH]\|hpp\|hxx\)$'
    let headers = '\.\([hH]\|hpp\|hxx\)$'
    let impl = '\.\([cC]\|cpp\|cc\|cxx\)$'
    let fn = expand( '%' )
    if fn =~ privateheaders
        let list = glob( substitute( fn, privateheaders, '.*', '' ) )
    elseif fn =~ headers
        let list = glob( substitute( fn, headers, '_p.*', '' ) )
    elseif fn =~ impl
        let list = glob( substitute( fn, impl, '_p.*', '' ) )
    endif
    while strlen( list ) > 0
        let file = substitute( list, "\n.*", '', '' )
        let list = substitute( list, "[^\n]*", '', '' )
        let list = substitute( list, "^\n", '', '' )
        if ( fn =~ privateheaders && file =~ impl ) || ( fn =~ impl && file =~ privateheaders ) || ( fn =~ headers && file =~ privateheaders )
            call AskToSave()
            execute( "edit " . file )
            return
        endif
    endwhile
    if ( fn =~ privateheaders )
        call AskToSave()
        if exists( "$implextension" )
            let file = substitute( fn, privateheaders, '.' . $implextension, '' )
        else
            let file = substitute( fn, privateheaders, '.cpp', '' )
        endif
        " check for modified state of current buffer and if modified ask:
        " save, discard, cancel
        execute( 'edit '.file )
        call append( 0, "#include \"".fn."\"" )
        call append( 2, "// vim: sw=4 ts=4 noet" )
        execute( "set sw=4" )
        execute( "set ts=4" )
    elseif fn =~ impl
        let file = substitute( fn, impl, '_p.h', '' )
        call CreatePrivateHeader( file )
    elseif fn =~ headers
        let file = substitute( fn, headers, '_p.h', '' )
        call CreatePrivateHeader( file )
    endif
endfunction

function! AskToSave()
    if &modified
        let yesorno = input("Save changes before switching file? [Y/n]")
        if yesorno == 'y' || yesorno == '' || yesorno == 'Y'
            :execute 'w'
            return 1
        else
            return 0
        endif
    endif
    return 1
endfunction

function! CreatePrivateHeader( privateHeader )
    let privateheaders = '_p\.\([hH]\|hpp\|hxx\)$'
    let headers = '\.\([hH]\|hpp\|hxx\)$'
    let impl = '\.\([cC]\|cpp\|cc\|cxx\)$'
    let fn = expand( '%' )
    if fn =~ headers
        let className = ClassNameFromHeader()
    elseif fn =~ impl
        let className = ClassNameFromImpl()
    endif

    if AskToSave() && fn =~ headers
        :normal gg
        " check whether a Q_DECLARE_PRIVATE is needed
        let dp = search( '\(^\|\s\+\)Q_DECLARE_PRIVATE\s*(\s*'.className.'\s*)' )
        if dp == 0 "nothing found
            call search( '^\s*class\s\+\([A-Za-z0-9]\+_EXPORT\s\+\)[A-Za-z_]\+\s*\(:\s*[,\t A-Za-z_]\+\)\?\s*\n\?\s*{' )
            call search( '{' )
            let @c = className
            if match(getline(line('.')+1), 'Q_OBJECT')
                :normal joQ_DECLARE_PRIVATE(c)
            else
                :normal oQ_DECLARE_PRIVATE(c)
            endif
            :execute 'w'
        endif
    endif
    execute( "edit ".a:privateHeader )
    let privateClassName = className . 'Private'
    let header = substitute( a:privateHeader, privateheaders, '.h', '' )

    call IncludeGuard()
    " FIXME: find out what license to use
    call LicenseHeader( "LGPL" )
    :set sw=4
    :set ts=4
    :set tw=80
    :normal Go// vim: sw=4 ts=4 tw=80
    let @h = header
    let @p = privateClassName
    let @c = className
    :normal kkko#include "h"class p{Q_DECLARE_PUBLIC(c)protected:c* q_ptr;};
endfunction

function! ClassNameFromHeader()
    :normal gg
    call search( '^\s*class\s\+\([A-Za-z0-9]\+_EXPORT\s\+\)\?[A-Za-z_]\+\s*\(:\s*[,\t A-Za-z_]\+\)\?\s*\n\?\s*{' )
    "\zs and \ze mark start and end of the matching
    return matchstr( getline('.'), '\s\+\zs\w\+\ze\s*\(:\|{\|$\)' )
endfunction

function! ClassNameFromImpl()
    :normal gg
    call search( '\s*\([A-Za-z_]\+\)::\1\s*(' )
    :normal "cye
    return @c
endfunction

function! IncludeGuard()
    let guard = toupper( substitute( substitute( expand( '%' ), '\([^.]*\)\.h', '\1_h', '' ), '/', '_', '' ) )
    call append( '^', '#define ' . guard )
    +
    call append( '^', '#ifndef ' . guard )
    call append( '$', '#endif // ' . guard )
    +
endfunction

function! LicenseHeader( license )
    let filename = $HOME . "/" . a:license . "HEADER"
    execute ":0r " . filename
"   call append( 0, system( "cat " . filename ) )
endfunction

function! SmartInclude()
    let next = nr2char( getchar( 0 ) )
    if next == '"'
        return "#include \".h\"\<Left>\<Left>\<Left>"
    endif
    if next == '>'
        return "#include <>\<Left>"
    endif
    return "#include <.h>\<Left>\<Left>\<Left>"
endfunction

function! MapIdentHeader( ident )
    " Qt stuff
    if a:ident =~ '^Q[A-Z]'
        return '<' . a:ident . '>'
    elseif a:ident == 'qDebug' ||
          \a:ident == 'qWarning' ||
          \a:ident == 'qCritical' ||
          \a:ident == 'qFatal'
        return '<QtDebug>'

    " KDE stuff
    elseif a:ident == 'K\(Double\|Int\)\(NumInput\|SpinBox\)'
        return '<knuminput.h>'
    elseif a:ident == 'KConfigGroup'
        return '<kconfigbase.h>'
    elseif a:ident == 'KListViewItem'
        return '<klistview.h>'
    elseif a:ident =~ 'kd\(Debug\|Warning\|Error\|Fatal\|Backtrace\)'
        return '<kdebug.h>'
    elseif a:ident == 'kapp'
        return '<kapplication.h>'
    elseif a:ident == 'i18n' ||
          \a:ident == 'I18N_NOOP'
        return '<klocale.h>'
    elseif a:ident == 'locate' ||
          \a:ident == 'locateLocal'
        return '<kstandarddirs.h>'
    elseif a:ident =~ '\(Small\|Desktop\|Bar\|MainBar\|User\)Icon\(Set\)\?' ||
          \a:ident == 'IconSize'
        return '<kiconloader.h>'

    " aRts stuff
    elseif a:ident =~ '\arts_\(debug\|info\|warning\|fatal\)'
        return '<debug.h>'

    " Standard Library stuff
    elseif a:ident =~ '\(std::\)\?\(cout\|cerr\|endl\)'
        return '<iostream>'
    elseif a:ident =~ '\(std::\)\?is\(alnum\|alpha\|ascii\|blank\|graph\|lower\|print\|punct\|space\|upper\|xdigit\)'
        return '<cctype>'
    elseif a:ident == 'printf'
        return '<cstdio>'
    endif

    " Private headers
    let header = tolower( substitute( a:ident, '::', '/', 'g' ) ) . '.h'
    if a:ident =~ 'Private$'
        let header = substitute( header, 'private', '_p', '' )
    endif
    let check = header
    while 1 
        if filereadable( check )
            return '"' . check . '"'
        endif
        let slash = match( check, '/' )
        if slash == -1
            return '<' . header . '>'
        endif
        let check = strpart( check, slash + 1 )
    endwhile
endfunction

" This is a rather dirty hack, but seems to work somehow :-) (malte)
function! AddHeader()
    let s = getline( '.' )
    let i = col( '.' ) - 1
    while i > 0 && strpart( s, i, 1 ) !~ '[A-Za-z0-9_:]'
        let i = i - 1
    endwhile
    while i > 0 && strpart( s, i, 1 ) =~ '[A-Za-z0-9_:]'
        let i = i - 1
    endwhile
    let start = match( s, '[A-Za-z0-9_]\+\(::[A-Za-z0-9_]\+\)*', i )
    let end = matchend( s, '[A-Za-z0-9_]\+\(::[A-Za-z0-9_]\+\)*', i )
    if end > col( '.' )
        let end = matchend( s, '[A-Za-z0-9_]\+', i )
    endif
    let ident = strpart( s, start, end - start )
    let include = '#include ' . MapIdentHeader( ident )

    let line = 1
    let incomment = 0
    let appendpos = 0
    let codestart = 0
    while line <= line( '$' )
        let s = getline( line )
        if incomment == 1
            let end = matchend( s, '\*/' )
            if end == -1
                let line = line + 1
                continue
            else
                let s = strpart( s, end )
                let incomment = 0
            endif
        endif
        let s = substitute( s, '//.*', '', '' )
        let s = substitute( s, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
        if s =~ '/\*'
            let incomment = 1
        elseif s =~ '^' . include
            break
        elseif s =~ '^#include' && s !~ '\.moc"'
            let appendpos = line
        elseif codestart == 0 && s !~ '^$'
            let codestart = line
        endif
        let line = line + 1
    endwhile
    if line == line( '$' ) + 1
        if appendpos == 0
            call append( codestart - 1, include )
            call append( codestart, '' )
        else
            call append( appendpos, include )
        endif
    endif
endfunction

function! AddForward()
    let s = getline( '.' )
    let i = col( '.' ) - 1
    while i > 0 && strpart( s, i, 1 ) !~ '[A-Za-z0-9_:]'
        let i = i - 1
    endwhile
    while i > 0 && strpart( s, i, 1 ) =~ '[A-Za-z0-9_:]'
        let i = i - 1
    endwhile
    let start = match( s, '[A-Za-z0-9_]\+\(::[A-Za-z0-9_]\+\)*', i )
    let end = matchend( s, '[A-Za-z0-9_]\+\(::[A-Za-z0-9_]\+\)*', i )
    if end > col( '.' )
        let end = matchend( s, '[A-Za-z0-9_]\+', i )
    endif
    let ident = strpart( s, start, end - start )
    let forward = 'class ' . ident . ';'

    let line = 1
    let incomment = 0
    let appendpos = 0
    let codestart = 0
    while line <= line( '$' )
        let s = getline( line )
        if incomment == 1
            let end = matchend( s, '\*/' )
            if end == -1
                let line = line + 1
                continue
            else
                let s = strpart( s, end )
                let incomment = 0
            endif
        endif
        let s = substitute( s, '//.*', '', '' )
        let s = substitute( s, '/\*\([^*]\|\*\@!/\)*\*/', '', 'g' )
        if s =~ '/\*'
            let incomment = 1
        elseif s =~ '^' . forward
            break
        elseif s =~ '^\s*class [A-za-z0-9_]\+;' || (s =~ '^#include' && s !~ '\.moc"')
            let appendpos = line
        elseif codestart == 0 && s !~ '^$'
            let codestart = line
        endif
        let line = line + 1
    endwhile
    if line == line( '$' ) + 1
        if appendpos == 0
            call append( codestart - 1, forward )
            call append( codestart, '' )
        else
            call append( appendpos, forward )
        endif
    endif
endfunction

function! RunDiff()
    echo 'Diffing....'
    read! cvs diff -bB -I \\\#include | egrep -v '(^Index:|^=+$|^RCS file:|^retrieving revision|^diff -u|^[+-]{3})'
endfunction

function! CreateChangeLogEntry()
    let currentBuffer = expand( "%" )

    if exists( "g:EMAIL" )
        let mail = g:EMAIL
    elseif exists( "$EMAIL" )
        let mail = $EMAIL
    else
        let mail = inputdialog( "Enter Name/Email for Changelog entry: " ) 
    if mail == ""
        echo "Aborted ChangeLog edit..."
        return
    endif
    let g:EMAIL = mail
    endif

    if bufname( "ChangeLog" ) != "" && bufwinnr( bufname( "ChangeLog" ) ) != -1
    execute bufwinnr( bufname( "ChangeLog" ) ) . " wincmd w"
    else
        execute "split ChangeLog"
    endif

    let lastEntry = getline( nextnonblank( 1 ) )
    let newEntry = strftime("%Y-%m-%d") . "  " . mail

    if lastEntry != newEntry 
        call append( 0, "" )
        call append( 0, "" )
        call append( 0, newEntry )
    endif

    " like emacs, prepend the current buffer name to the entry. but unlike
    " emacs I have no idea how to figure out the current function name :(
    " (Simon)
    if currentBuffer != ""
        let newLine = "\t* " . currentBuffer . ": "
    else
        let newLine = "\t* "
    endif

    call append( 2, newLine )

    execute "normal 3G$"
endfunction

function! AddQtSyntax()
    if expand( "<amatch>" ) == "cpp"
        syn keyword qtKeywords     signals slots emit Q_SLOTS Q_SIGNALS
        syn keyword qtMacros       Q_OBJECT Q_WIDGET Q_PROPERTY Q_ENUMS Q_OVERRIDE Q_CLASSINFO Q_SETS SIGNAL SLOT Q_DECLARE_PUBLIC Q_DECLARE_PRIVATE Q_D Q_Q Q_DISABLE_COPY Q_DECLARE_METATYPE Q_PRIVATE_SLOT Q_FLAGS Q_INTERFACES Q_DECLARE_INTERFACE Q_EXPORT_PLUGIN2
        syn keyword qtCast         qt_cast qobject_cast qvariant_cast qstyleoption_cast
        syn keyword qtTypedef      uchar uint ushort ulong Q_INT8 Q_UINT8 Q_INT16 Q_UINT16 Q_INT32 Q_UINT32 Q_LONG Q_ULONG Q_INT64 Q_UINT64 Q_LLONG Q_ULLONG pchar puchar pcchar qint8 quint8 qint16 quint16 qint32 quint32 qint64 quint64 qlonglong qulonglong qreal
        syn keyword kdeKeywords    k_dcop k_dcop_signals
        syn keyword kdeMacros      K_DCOP ASYNC PHONON_ABSTRACTBASE PHONON_OBJECT PHONON_HEIR PHONON_ABSTRACTBASE_IMPL PHONON_OBJECT_IMPL PHONON_HEIR_IMPL PHONON_PRIVATECLASS PHONON_PRIVATEABSTRACTCLASS
        syn keyword cRepeat        foreach
        syn keyword cRepeat        forever

        hi def link qtKeywords          Statement
        hi def link qtMacros            Type
        hi def link qtCast              Statement
        hi def link qtTypedef           Type
        hi def link kdeKeywords         Statement
        hi def link kdeMacros           Type
    endif
endfunction

function! InsertMethodTracer()
    :normal [[kf(yBjokDebug() << ""()" << endl;
endfunction

function! UpdateMocFiles()
    if &syntax == "cpp"
        let i = 1
        while i < 80
            let s = getline( i )
            if s =~ '^#include ".*\.moc"'
                let s = substitute( s, '.*"\(.*\)\.moc"', '\1.h', '' )
                if stridx( &complete, s ) == -1
                    let &complete = &complete . ',k' . s
                endif
                break
            endif
            let i = i + 1
        endwhile
    endif
endfunction

autocmd Syntax * call AddQtSyntax()
autocmd CursorHold * call UpdateMocFiles()
autocmd BufNewFile,BufRead * call SetCodingStyle()

" vim: sw=4 sts=4 et
