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
" The last Airline theme
let s:last_airline_theme = ''
" The last Vim colorscheme
let s:last_colorscheme = ''

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
    " Ensures the current palette has colors for the current mode
    if has_key(g:airline#themes#{g:airline_theme}#palette, s:airline_mode)
        " Fetch colors from the current theme palette
        let l:mode_fg = g:airline#themes#{g:airline_theme}#palette[s:airline_mode]['airline_z'][2]
        let l:mode_bg = g:airline#themes#{g:airline_theme}#palette[s:airline_mode]['airline_z'][3]
        return [l:mode_fg, l:mode_bg]
    endif
endfunction

" Set the color of the cursor line number
function! s:SetCursorLineNrColor()
    " Update cursor line number color
    let l:mode_colors = <SID>GetAirlineModeColors()
    if !empty(l:mode_colors)
        exec printf('highlight %s %s %s %s %s',
                \ 'CursorLineNr',
                \ 'guifg='.mode_colors[0],
                \ 'guibg='.mode_colors[1],
                \ 'ctermfg='.mode_colors[0],
                \ 'ctermbg='.mode_colors[1])
    endif
endfunction

" Determines when a redraw of the line number should occur:
"   ColorLineNr seems to only redraw on cursor moved events for visual mode?
"   Force a redraw when toggling Airline back on
"   Force a redraw when changing Airline theme
function! s:ShouldRedrawCursorLineNr()
    if s:airline_mode == 'visual' ||
       \ s:last_airline_mode == 'visual' ||
       \ s:last_airline_mode == 'toggledoff' ||
       \ g:airline_theme != s:last_airline_theme ||
       \ s:last_colorscheme != g:colors_name
        return 1
    endif
    return 0
endfunction

" Determines when the color of the line number should be updated:
"   When the mode has changed
"   When the Airline theme has changed
"   When th Vim colorscheme has changed
function! s:ShouldUpdateCursorLineNrColor()
    if s:airline_mode != s:last_airline_mode ||
       \ g:airline_theme != s:last_airline_theme ||
       \ s:last_colorscheme != g:colors_name
        return 1
    endif
    return 0
endfunction

" Sets the cursor line number to the color for the current mode from Airline
function! UpdateCursorLineNr()
    " Ensure Airline is still enabled. Stop highlight updates if not
    if !exists('#airline')
        call <SID>AirlineToggledOff()
    else
        call <SID>AirlineToggledOn()

        " Do nothing if plugin is disabled
        if g:airline_colornum_enabled == 1
            " Update the current mode
            call <SID>GetAirlineMode()

            " Update cursor line number color
            if <SID>ShouldUpdateCursorLineNrColor()
                call <SID>SetCursorLineNrColor()

                " Cause the cursor line num to be redrawn to update color
                if <SID>ShouldRedrawCursorLineNr()
                    call feedkeys("\<left>\<right>", 'n')
                endif

                " Save last mode
                let s:last_airline_mode = s:airline_mode
                " Save last theme
                let s:last_airline_theme = g:airline_theme
                " Save last colorscheme
                let s:last_colorscheme = g:colors_name
            endif
        endif
    endif
endfunction

" Ensure line number is update every time the status line is updated
function! s:LoadCursorLineNrUpdates()
    " Only add to statusline if Airline is loaded and it has not been added
    if g:loaded_airline == 1
        if exists('g:airline_section_z') && g:airline_section_z !~ 'UpdateCursorLineNr'
            let g:airline_section_z .= '%{UpdateCursorLineNr()}'
            " Force color to update now
            call UpdateCursorLineNr()
        endif
    endif
endfunction

" Unload the function for updating the line number
function! s:UnloadCursorLineNrUpdates()
    if exists('g:airline_section_z')
        let g:airline_section_z = substitute(g:airline_section_z, '%{UpdateCursorLineNr()}', "", "g")
    endif
endfunction

" Resets colors for the cursor line number to default
function! s:ResetCursorLineNrColor()
    " Restore original colors
    highlight CursorLineNr ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
    " Reset last mode
    let s:last_airline_mode = ''
endfunction

" When Airline is toggled off, restore status line and cursor line to original
" states
function! s:AirlineToggledOff()
    " Restore original statusline
    let &statusline = s:original_statusline
    " Restore cursor line color and redraw
    call <SID>ResetCursorLineNrColor()
    call feedkeys("\<left>\<right>", 'n')
    " Used to ensure this is re-enabled when Airline is toggled on
    let s:airline_toggled_off = 1
    " Ensures the cursor line number is redrawn correctly
    let s:last_airline_mode = 'toggledoff'
endfunction

" Saves the original status line and adds an update call to status line for
" when Airline is toggled off
function! s:AirlineToggledOn()
    if exists('#airline')
        " Only execute if this is the first time or if Airline was toggled off
        if !exists('s:airline_toggled_off') || s:airline_toggled_off == 1
            execute 'AirlineToggle'
            " Save original status line
            if !exists('s:original_statusline')
                let s:original_statusline = &statusline
            endif
            " Add call to status line to ensure an update when Airline is
            " toggled off
            if &statusline !~ 'UpdateCursorLineNr'
                set statusline+=%{UpdateCursorLineNr()}
            endif
            execute 'AirlineToggle'
            let s:airline_toggled_off = 0
        endif
    endif
endfunction

" Enables this plugin
function! s:EnableAirlineColorNum()
    let g:airline_colornum_enabled = 1
    " Setup autocommands
    augroup AirlineColorNum
        au!
        " Ensure function has been loaded into the status line whenever entering a buffer
        autocmd BufWinEnter * call <SID>LoadCursorLineNrUpdates()
    augroup END
    " Attempt to load immediately
    call <SID>LoadCursorLineNrUpdates()
endfunction

" Disables this plugin
function! s:DisableAirlineColorNum()
    let g:airline_colornum_enabled = 0
    " Delete autocommands
    augroup! AirlineColorNum
    call <SID>UnloadCursorLineNrUpdates()
    call <SID>ResetCursorLineNrColor()
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
