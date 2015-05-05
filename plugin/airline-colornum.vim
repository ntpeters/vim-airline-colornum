" Author: Nate Peterson
" Repository: http://github.com/ntpeters/vim-airline-colornum
"
" Syncs the color of the cursor line number with the current mode color used by
" Airline.

" Prevent loading the plugin multiple times
if exists('g:loaded_airline_colornum_plugin')
    finish
endif
let g:loaded_airline_colornum_plugin = 1

" Init 'enabled' var if not set by user
if !exists('g:airline_colornum_enabled')
    let g:airline_colornum_enabled = 1
endif

" The current Vim mode - Airline Key
let s:airline_mode = ''
" The previous mode
let s:last_airline_mode = ''

" Gets the current Vim mode as a key compatible with the Airline color map
function! s:GetAirlineMode()
    " Only set mode if airline is active
    " Note: Do not set mode to 'inactive'. This causes an infinite loop when
    " opening a split.
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
    " Do nothing if plugin is disabled
    if g:airline_colornum_enabled == 1
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
                " Not needed when entering or leaving insert mode
                if s:airline_mode != 'insert' && s:airline_mode != 'insert'
                    call feedkeys("\<left>\<right>", 'n')
                endif
            endif
        endif
    endif
endfunction

" Ensure line number is update every time the status line is updated
function! s:LoadCursorLineNumberUpdates()
    " Only add to statusline if Airline is loaded and it has not been added
    if g:loaded_airline == 1
        if exists('g:airline_section_z') && g:airline_section_z !~ 'SetCursorLineNrColor'
            let g:airline_section_z .= '%{SetCursorLineNrColor()}'
            " Force color to update now
            call SetCursorLineNrColor()
        endif
    endif
endfunction

" Unload the function for updating the line number
function! s:UnloadCursorLineNumberUpdates()
    if exists('g:airline_section_z')
        let g:airline_section_z = substitute(g:airline_section_z, '%{SetCursorLineNrColor()}', "", "g")
    endif
endfunction

" Enables this plugin
function! s:EnableAirlineColorNum()
    let g:airline_colornum_enabled = 1
    " Ensure function has been loaded into the status line whenever entering a buffer
    autocmd BufWinEnter * call <SID>LoadCursorLineNumberUpdates()
    " Attempt to load immediately
    call <SID>LoadCursorLineNumberUpdates()
endfunction

" Disables this plugin
function! s:DisableAirlineColorNum()
    let g:airline_colornum_enabled = 0
    call <SID>UnloadCursorLineNumberUpdates()
    " Restore original colors
    highlight CursorLineNr ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
    " Reset last mode
    let s:last_airline_mode = ''
endfunction

" Initial plugin setup
function! s:SetupAirlineColorNum()
    " Setup plugin commands
    command! EnableAirlineColorNum call <SID>EnableAirlineColorNum()
    command! DisableAirlineColorNum call <SID>DisableAirlineColorNum()

    " Enable plugin if not disabled by user
    if g:airline_colornum_enabled == 1
        call <SID>EnableAirlineColorNum()
    endif
endfunction

" Perform plugin init
call <SID>SetupAirlineColorNum()
