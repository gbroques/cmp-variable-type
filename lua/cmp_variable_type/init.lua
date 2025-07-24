local ts_utils = require('nvim-treesitter.ts_utils')
local cmp = require('cmp')
local source = {}

-- References:
-- * Let's create a Neovim plugin using Treesitter and Lua https://www.youtube.com/watch?v=dPQfsASHNkg
-- * How to create a custom completion source https://www.youtube.com/watch?v=sr8XZ3AsSAM

--- Returns { 'Linked', 'Hash', 'Set' } for 'LinkedHashSet'.
---@param str string
---@return table
local function split_pascal_case(str)
  -- Insert a space before each uppercase letter (except the first)
  local spaced_str = str:gsub("(%l)(%u)", "%1 %2")
  -- Split the string by spaces
  local components = {}
  for word in spaced_str:gmatch("%S+") do -- Use %S+ to match one or more non-whitespace characters
    table.insert(components, word)
  end
  return components
end

---@return TSNode|nil
local function get_local_variable_declaration_node_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if node == nil then
    error('No treesitter parser found.')
    return
  end
  local start_row = node:start()
  while (node ~= nil and node:type() ~= 'local_variable_declaration' and node:start() == start_row) do
    node = node:parent()
  end
  return node
end

---@return string|nil type_identifier_text
local function get_type_identifier_text_at_cursor()
  local local_variable_declaration_node = get_local_variable_declaration_node_at_cursor()
  if local_variable_declaration_node == nil then
    return nil
  end
  -- Assume first child of local_variable_declaration is type_identifer
  local first_child = local_variable_declaration_node:child(0)
  if first_child == nil then
    return nil
  end
  local bufnr = vim.api.nvim_get_current_buf()
  return vim.treesitter.get_node_text(first_child, bufnr)
end

--- Returns { 'linkedHashSet', 'hashSet', 'set' } for 'LinkedHashSet'
---@param type_identifier_text string
---@return function
local function suggestion(type_identifier_text)
  local words = split_pascal_case(type_identifier_text)
  local i = 0
  return function()
    i = i + 1
    if i <= #words then
      local label = string.lower(words[i])
      local j = i + 1
      while j <= #words do
        label = label .. words[j]
        j = j + 1
      end
      return label
    end
  end
end

---@param type_identifier_text string
---@return lsp.CompletionItem[]
local function get_completion_items(type_identifier_text)
  local completions = {}
  for label in suggestion(type_identifier_text) do
    table.insert(completions, {
      label = label,
      kind = cmp.lsp.CompletionItemKind.Variable
    })
  end
  return completions
end

---@return lsp.CompletionResponse
local function get_completion_response()
  local type_identifier_text = get_type_identifier_text_at_cursor()
  if type_identifier_text ~= nil then
    return get_completion_items(type_identifier_text)
  else
    return {}
  end
end

---Return the debug name of this source.
---@return string
function source:get_debug_name()
  return 'variable_type'
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  callback(get_completion_response())
end

cmp.register_source('variable_type', source)
