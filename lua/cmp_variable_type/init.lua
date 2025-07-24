local cmp = require('cmp')
local ts_utils = require('nvim-treesitter.ts_utils')

-- For creating a custom nvim-cmp completion source see :help cmp-develop.
local source = {}

---Invoke completion.
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  callback(source:_get_completion_response())
end

---@return string
function source:get_debug_name()
  return 'variable_type'
end

---@return lsp.CompletionResponse
function source:_get_completion_response()
  local type_identifier_text = source:_get_type_identifier_text_at_cursor()
  if type_identifier_text ~= nil then
    return source:_get_completion_items(type_identifier_text)
  else
    return {}
  end
end

---@return string|nil type_identifier_text Example: 'LinkedHashSet'
function source:_get_type_identifier_text_at_cursor()
  local local_variable_declaration_node = source:_get_local_variable_declaration_node_at_cursor()
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

---@return TSNode|nil
function source:_get_local_variable_declaration_node_at_cursor()
  local node = ts_utils.get_node_at_cursor()
  if node == nil then
    return
  end
  local start_row = node:start()
  while (node ~= nil and node:type() ~= 'local_variable_declaration' and node:start() == start_row) do
    node = node:parent()
  end
  return node
end

---@param type_identifier_text string Example: 'LinkedHashSet'
---@return lsp.CompletionItem[]
function source:_get_completion_items(type_identifier_text)
  local completions = {}
  for label in source:_suggestion(type_identifier_text) do
    table.insert(completions, {
      label = label,
      kind = cmp.lsp.CompletionItemKind.Variable,
      data = {
        -- Useful for displaying type as a source in completion menu.
        type = type_identifier_text
      }
    })
  end
  return completions
end

---@param type_identifier_text string
---@return function
---@usage source:_suggestion('LinkedHashSet') -- { 'linkedHashSet', 'hashSet', 'set' }
function source:_suggestion(type_identifier_text)
  local words = source:_split_pascal_case(type_identifier_text)
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

---@param str string
---@return table words A table containing elements for each uppercase word.
---@usage source:_split_pascal_case('LinkedHashSet') -- { 'Linked', 'Hash', 'Set' }
function source:_split_pascal_case(str)
  -- Insert a space before each uppercase letter (except the first)
  local spaced_str = str:gsub("(%l)(%u)", "%1 %2")
  -- Split the string by spaces
  local components = {}
  for word in spaced_str:gmatch("%S+") do -- Use %S+ to match one or more non-whitespace characters
    table.insert(components, word)
  end
  return components
end

return source
