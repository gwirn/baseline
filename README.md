# baseline

*basic status line*

## Documentation

see `:help baseline`

Replaces something like lualine with a simpler yet informative version.

## Setup with LazyVim

```lua
return {
    {
        "gwirn/baseline",
        config = function()
            require("baseline").setup()
        end,
    }
}
```

### Tested on NVIM v0.11.3
