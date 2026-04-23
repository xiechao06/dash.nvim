local M = {}

local function finder_fn(current_file_type, bang)
  return function(_, ctx)
    local search_text = ctx.filter.search
    if not search_text or #search_text == 0 then
      return {}
    end

    local results = require('libdash_nvim').query({
      search_text = search_text,
      buffer_type = current_file_type,
      ignore_keywords = bang,
    })

    local items = {}
    for _, item in ipairs(results) do
      table.insert(items, {
        text = item.display,
        dash_item = item,
      })
    end
    return items
  end
end

local function handle_selected(picker, item)
  if not item or not item.dash_item then
    return
  end

  picker:close()

  local selected_item = item.dash_item
  local libdash = require('libdash_nvim')
  if selected_item.is_fallback then
    libdash.open_url(selected_item.value)
  else
    libdash.open_item(selected_item)
  end
end

function M.dash(opts)
  opts = opts or {}
  local current_file_type = vim.bo.filetype
  return require('snacks').picker.pick({
    source = 'dash',
    title = require('dash.providers').build_picker_title(opts.bang or false),
    prompt = 'Dash> ',
    live = true,
    search = opts.initial_text or '',
    finder = finder_fn(current_file_type, opts.bang or false),
    format = 'text',
    confirm = handle_selected,
  })
end

return M
