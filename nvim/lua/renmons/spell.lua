-- <leader>zz: walk through spelling mistakes one by one and pick a fix from a list
local M = {}

local function replace_current_word(new_word)
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local cursor = col + 1 -- string positions are 1-based

	-- find the occurrence of <cword> that contains (or follows) the cursor
	local start = 1
	while true do
		local s, e = line:find(word, start, true) -- plain find, no patterns
		if not s then
			return
		end
		if e >= cursor then
			vim.api.nvim_buf_set_text(0, row - 1, s - 1, row - 1, e, { new_word })
			return
		end
		start = e + 1
	end
end

local function get_spelling_context(radius)
	radius = radius or 50

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local col = cursor[2]

	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	-- col ist 0-basiert, string.sub dagegen 1-basiert
	local cursor_col = col + 1

	local start_col = math.max(1, cursor_col - radius)
	local end_col = math.min(#line, cursor_col + radius)

	local context = line:sub(start_col, end_col)

	if start_col > 1 then
		context = "…" .. context
	end

	if end_col < #line then
		context = context .. "…"
	end

	return context
end

local function fix_next_spelling_mistake()
	local before = vim.api.nvim_win_get_cursor(0)

	vim.cmd("silent! normal! ]s")

	local after = vim.api.nvim_win_get_cursor(0)

	if before[1] == after[1] and before[2] == after[2] then
		vim.notify("No more spelling mistakes")
		return
	end

	local word = vim.fn.expand("<cword>")
	local bad = vim.fn.spellbadword(word)

	if bad[1] == "" then
		vim.notify("No spelling mistake under cursor")
		return
	end

	local suggestions = vim.fn.spellsuggest(word, 10)

	table.insert(suggestions, "✍ Custom correction...")
	table.insert(suggestions, "✓ Add word as correct")
	table.insert(suggestions, "⏭ Skip word")

	local context = get_spelling_context(20)

	vim.ui.select(suggestions, {
		prompt = string.format("Context: %s\n", context),
	}, function(choice)
		if not choice then
			return
		end

		if choice == "✍ Custom correction..." then
			vim.ui.input({
				prompt = "Correction for '" .. word .. "': ",
				default = word,
			}, function(input)
				if not input or input == "" then
					return
				end

				replace_current_word(input)
				vim.schedule(fix_next_spelling_mistake)
			end)

			return
		end

		if choice == "✓ Add word as correct" then
			vim.cmd("normal! zg")
			vim.schedule(fix_next_spelling_mistake)
			return
		end

		if choice == "⏭ Skip word" then
			vim.schedule(fix_next_spelling_mistake)
			return
		end

		replace_current_word(choice)
		vim.schedule(fix_next_spelling_mistake)
	end)
end

M.fix_next = fix_next_spelling_mistake

return M
