# cmp-variable-type

> [!WARNING]
> Currently experimental until v1.0.0 release.

[Tree-sitter](https://github.com/tree-sitter/tree-sitter) based [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for lowerCamelCase variable names based on type.

## Motivation

It's common to name variables after their type in strongly-typed languages such as Java.

For example, a variable name with the type `LinkedHashSet` could be `linkedHashSet`, `hashSet`, or `set`:

```java
LinkedHashSet l // suggest linkedHashSet
LinkedHashSet h // suggest hashSet
LinkedHashSet s // suggest set
```

Other editors such as VS Code also provide these completion suggestions.

## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim) as your plugin manager:
```lua
{
  'gbroques/cmp-variable-type',
  dependencies = {
    'hrsh7th/nvim-cmp',
    'nvim-treesitter/nvim-treesitter'
  },
  ft = 'java'
}
```

## Setup

```lua
require('cmp').setup({
  sources = {
    { name = 'variable_type' },
  },
})
```

## Configuration

The `type` is returned within the `data` element of the `completion_item` for each `entry`.

If you want to [customize the menu appearance](https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#basic-customisations) to show the type as the source:

```lua
local cmp = require('cmp')
cmp.setup {
  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      -- Source
      vim_item.menu = ({
        -- Show type (e.g. LinkedHashSet) as source in completion menu.
        variable_type = entry.completion_item.data ~= nil and entry.completion_item.data.type or 'Var'
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end
  },
}
```

## Supported Languages

Currently only supports Java. See [test/Test.java](./test/Test.java) for testing.

It should complete variables in the following places.

1. For fields declarations in class bodies:
   ```java
   class Example {

       private final CompletableFuture f
                                       ^ suggest future
   }
   ```

2. For parameter names in constructors:
   ```java
   class Example {

       Example(CompletableFuture f)
                                 ^ suggest future

   }
   ```

3. For parameter names in method declarations:
   ```java
   class Example {

       private String getValue(CompletableFuture f)
                                                 ^ suggest future

   }
   ```

4. And for local variable names in method bodies:
   ```java
   class Example {

       private String getValue() {
           CompletableFuture f
                             ^ suggest future
       }

   }
   ```

Pull requests are welcome for other languages like C#, Kotlin, and Scala.

## Limitations
1. Doesn't work for Java generic types. For example:
   ```java
   LinkedHashSet<String> l
                         ^ doesn't suggest linkedHashSet
   ```

   This is because the Java tree-sitter grammar parses incomplete generic type declarations as binary expressions.

   Changes to the [Java tree-sitter grammar](https://github.com/tree-sitter/tree-sitter-java) should be made before attempting to work around that.

2. Currently doesn't work for constants. For example:
   ```java
   class Example {
       private static final Logger L
                                   ^ doesn't suggest LOGGER
   }
   ```

