#Airline Color Num Plugin

Sets the cursor line number to the same color as the current mode in the
statusline set by the [Vim Airline](https://github.com/bling/vim-airline) plugin.

##Screenshots
![Normal Example](http://i.imgur.com/zU0MWWV.png)
![Insert Example](http://i.imgur.com/dxXZVLy.png)
![Visual Example](http://i.imgur.com/JqdpYFB.png)

##Installation
There are a few ways you can go about installing this plugin:

1.  If you have [Vundle](https://github.com/gmarik/Vundle.vim) you can simply add:
    ```
    Bundle 'ntpeters/vim-airline-colornum'
    ```
    to your `.vimrc` file then run:
    ```
    :BundleInstall
    ```
2.  If you are using [Pathogen](https://github.com/tpope/vim-pathogen), you can just run the following command:
    ```
    git clone git://github.com/ntpeters/vim-airline-colornum.git ~/.vim/bundle/vim-airline-colornum
    ```
3.  While this plugin can also be installed by copying its contents into your `~/.vim/` directory, I would highly recommend using one of the above methods as they make managing your Vim plugins painless.

##Usage
This plugin is enabled by default.

*  To disable this plugin in your `.vimrc`:
   ```
   let g:airline_colornum_enabled = 0
   ```
   
*  To disable this plugin temporarily:
   ```
   :DisableAirlineColorNum
   ```

*  To enable this plugin:
   ```
   :EnableAirlineColorNum
   ```
   
##Troubleshooting
If you are not seeing the highlight in certain modes, make sure your cursorline
is enabled by adding this to your `.vimrc`:
```
set cursorline
```
Depending on your theme, this may cause your cursorline to be highlighted.
If you do not like this behavior, then also add the following to your `.vimrc`:
```
hi clear CursorLine
```

##Promotion
If you like this plugin, please star it on Github and vote it up at Vim.org!

Repository exists at: http://github.com/ntpeters/vim-airline-colornum

Plugin also hosted at: http://www.vim.org/scripts/script.php?script_id=5219
