" Author: Nate Peterson
" Repository: http://github.com/ntpeters/vim-airline-colornum

" Prevent loading the plugin multiple times
if exists('g:loaded_airline_colornum_plugin')
    finish
endif
let g:loaded_airline_colornum_plugin = 1

" The current Vim mode - Airline Key
let s:airline_mode = ''
" The previous mode
let s:last_airline_mode = ''

" Gets the current Vim mode as a key compatible with the Airline color map
function! s:GetAirlineMode()
    " Only set mode if airline is active
    if get(w:, 'airline_active', 1)
        let l:mode = mode()
        " Convert mode to a compatible value
        if l:mode ==# "i"
            let s:airline_mode = 'insert'
        elseif l:mode ==# "R"
            let s:airline_mode = 'replace'
        elseif l:mode =~# '\v(v|V||s|S|)'
            let s:airline_mode = 'visual'
        else
            let s:airline_mode = 'normal'
        endif
    else
        let s:airline_mode = 'inactive'
    endif
endfunction

" Gets the statusline colors for the current mode from Airline
function! s:GetAirlineModeColors()
    if has_key(g:airline#themes#{g:airline_theme}#palette, s:airline_mode)
        let l:mode_fg = g:airline#themes#{g:airline_theme}#palette[s:airline_mode]['airline_z'][2]
        let l:mode_bg = g:airline#themes#{g:airline_theme}#palette[s:airline_mode]['airline_z'][3]
        return [l:mode_fg, l:mode_bg]
    endif
endfunction

" Sets the cursor line number to the color for the current mode from Airline
function! SetCursorLineNrColor()
    call <SID>GetAirlineMode()
    " Only update if the mode has changed
    if s:airline_mode != s:last_airline_mode
        let s:last_airline_mode = s:airline_mode
        let l:mode_colors = <SID>GetAirlineModeColors()
        if !empty(l:mode_colors)
            exec printf('highlight %s %s %s %s %s',
                    \ 'CursorLineNr',
                    \ 'guifg='.mode_colors[0],
                    \ 'guibg='.mode_colors[1],
                    \ 'ctermfg='.mode_colors[0],
                    \ 'ctermbg='.mode_colors[1])
            " ColorLineNr seems to only redraw on cursor moved events...
            call feedkeys("\<left>\<right>", 'n')
        endif
    endif
endfunction

" Ensure line number is update every time the status line is updated
function! s:LoadLineNumberUpdates()
    " Only add to statusline if Airline is loaded and it has not been added
    if g:loaded_airline == 1 && g:airline_section_z !~ 'SetCursorLineNrColor'
        let g:airline_section_z .= '%{SetCursorLineNrColor()}'
    endif
endfunction

" Unload the function for updating the line number
function! s:UnloadLineNumberUpdates()
    let g:airline_section_z = substitute(g:airline_section_z, "%{SetCursorLineNrColor()}", "", "g")
endfunction

" Setup line number updates upon entering a buffer
autocmd BufWinEnter * call <SID>LoadLineNumberUpdates()

" Ensure the update function is unloaded from inactive buffers
autocmd BufWinLeave * call <SID>UnloadLineNumberUpdates()
