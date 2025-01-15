This plugin counts how many lines every function in your .c file has by tracking lines with `{` and `}`. 

![screenshot](screenshot.png "Screenshot")

NOTE: as of now the following style is expected:
* identifier and arguments of the function on one line
* curly braces always on their own lines and the type
```
void func(int param)
{
    if (!condition)
    {
        function_body();
        return (1);
    }
    return (0);
}
```

## Install with Lazy:
in ~/.config/nvim/init.lua add
```
require("nvim-function-linecount")
```

and in your ~.config/nvim/lua/plugins/ folder add
```
{
  "EyzeCOLD/nvim-function-linecount"
}
```
