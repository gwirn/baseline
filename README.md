# bs_line

*basic status line*

## Documentation

see `:help bs_line`

Replaces something like lua_line with a simpler yet informative version.

## Setup with LazyVim

```lua
return {
    {
        "gwirn/bs_line",
        config = function()
            require("bs_line").setup()
        end,
    }
}
```

### Tested on NVIM v0.11.3
