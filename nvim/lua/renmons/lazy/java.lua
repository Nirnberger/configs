-- Java via nvim-jdtls (not vim.lsp.enable): jdtls needs a workspace dir per project,
-- lombok and the debug/test bundles, which plain lspconfig doesn't set up.
-- Mason installs jdtls, java-debug-adapter and java-test (mason.lua).
local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

-- brew JDKs (native arm64). jdtls itself needs a recent Java (25+ since late 2026),
-- so it runs on the latest openjdk; projects build against 21 unless their pom/gradle says otherwise.
local jdk_latest = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
local jdk21 = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"

local function bundles()
	local jars = vim.fn.glob(
		mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
		true,
		true
	)
	for _, jar in ipairs(vim.fn.glob(mason .. "/packages/java-test/extension/server/*.jar", true, true)) do
		local name = vim.fn.fnamemodify(jar, ":t")
		-- these two are not OSGi bundles, jdtls refuses to load them
		if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
			table.insert(jars, jar)
		end
	end
	return jars
end

-- testrunner repos ship run-policy-tests.sh (handles AWS login/credentials itself); output stays in a terminal split
local last_run

local function start_terminal(run)
	last_run = run
	vim.cmd("botright 20new")
	vim.fn.termopen({ "bash", "run-policy-tests.sh", run.target }, { cwd = run.root, env = run.env })
	vim.cmd("startinsert")
end

local function run_script(buf, with_method, env)
	local root = vim.fs.root(buf, { "run-policy-tests.sh" })
	if not root then
		vim.notify("run-policy-tests.sh not found in a parent directory", vim.log.levels.WARN)
		return
	end
	local target = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t:r")
	if with_method then
		local lines = vim.api.nvim_buf_get_lines(buf, 0, vim.api.nvim_win_get_cursor(0)[1], false)
		for i = #lines, 1, -1 do
			local name = lines[i]:match("void%s+([%w_]+)%s*%(")
			if name then
				target = target .. "#" .. name
				break
			end
		end
	end
	start_terminal({ root = root, target = target, env = env })
end

local function rerun_last()
	if last_run then
		start_terminal(last_run)
	else
		vim.notify("No testrunner run yet", vim.log.levels.INFO)
	end
end

-- failed tests of the last run (run.failures, written by the script) -> quickfix list
local function failures_to_quickfix()
	local root = (last_run and last_run.root) or vim.fs.root(0, { "run-policy-tests.sh" })
	local file = root and (root .. "/run.failures")
	if not file or vim.fn.filereadable(file) == 0 then
		vim.notify("No run.failures found, run the tests first", vim.log.levels.WARN)
		return
	end
	local items = {}
	for _, line in ipairs(vim.fn.readfile(file)) do
		local class, method, name = unpack(vim.split(line, "\t", { plain = true }))
		local path = root .. "/src/main/java/" .. class:gsub("%.", "/") .. ".java"
		local lnum = 1
		if vim.fn.filereadable(path) == 1 then
			for i, l in ipairs(vim.fn.readfile(path)) do
				if l:match("void%s+" .. method .. "%s*%(") then
					lnum = i
					break
				end
			end
		end
		table.insert(items, { filename = path, lnum = lnum, text = (name or method) })
	end
	if #items == 0 then
		vim.notify("Last run had no failures", vim.log.levels.INFO)
		return
	end
	vim.fn.setqflist({}, " ", { title = "Testrunner failures", items = items })
	vim.cmd("copen")
end

local function on_attach(_, buf)
	local jdtls = require("jdtls")
	local map = function(mode, keys, func, desc)
		vim.keymap.set(mode, keys, func, { buffer = buf, desc = "Java: " .. desc })
	end

	map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
	map({ "n", "v" }, "<leader>jv", function()
		jdtls.extract_variable(vim.fn.mode() ~= "n")
	end, "Extract variable")
	map({ "n", "v" }, "<leader>jc", function()
		jdtls.extract_constant(vim.fn.mode() ~= "n")
	end, "Extract constant")
	map("v", "<leader>jm", function()
		jdtls.extract_method(true)
	end, "Extract method")
	map("n", "<leader>jt", jdtls.test_nearest_method, "Test nearest method")
	map("n", "<leader>jT", jdtls.test_class, "Test class")
	map("n", "<leader>jr", function()
		run_script(buf, true)
	end, "Testrunner script: method (GIT)")
	map("n", "<leader>jR", function()
		run_script(buf, false)
	end, "Testrunner script: class (GIT)")
	map("n", "<leader>jl", function()
		run_script(buf, true, { POLICY_LOCAL = "1" })
	end, "Testrunner script: method (localhost)")
	map("n", "<leader>jL", function()
		run_script(buf, false, { POLICY_LOCAL = "1" })
	end, "Testrunner script: class (localhost)")
	map("n", "<leader>jj", rerun_last, "Testrunner script: repeat last run")
	map("n", "<leader>je", failures_to_quickfix, "Testrunner script: failed tests to quickfix")
	map("n", "<leader>ju", "<cmd>JdtUpdateConfig<cr>", "Reload pom.xml / build.gradle")
end

local function start()
	if vim.fn.executable(mason .. "/bin/jdtls") == 0 then
		-- first start on a new machine: mason-tool-installer is still downloading it
		vim.notify_once("jdtls not installed yet (see :Mason), reopen the file when it's done", vim.log.levels.WARN)
		return
	end
	local jdtls = require("jdtls")
	local root = vim.fs.root(0, { "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
		or vim.fn.getcwd()
	-- one workspace per project; jdtls stores its index there
	local workspace = vim.fn.stdpath("cache")
		.. "/jdtls/"
		.. vim.fn.fnamemodify(root, ":t")
		.. "-"
		.. vim.fn.sha256(root):sub(1, 8)

	local runtimes = {}
	if vim.uv.fs_stat(jdk21) then
		table.insert(runtimes, { name = "JavaSE-21", path = jdk21, default = true })
	end
	if vim.uv.fs_stat(jdk_latest) then
		local version = vim.fn.fnamemodify(vim.fn.resolve("/opt/homebrew/opt/openjdk"), ":t"):match("^(%d+)")
		if version then
			table.insert(runtimes, { name = "JavaSE-" .. version, path = jdk_latest })
		end
	end

	local extended = vim.deepcopy(jdtls.extendedClientCapabilities)
	extended.resolveAdditionalTextEditsSupport = true

	jdtls.start_or_attach({
		cmd = {
			mason .. "/bin/jdtls",
			"--jvm-arg=-javaagent:" .. mason .. "/packages/jdtls/lombok.jar",
			"-data",
			workspace,
		},
		cmd_env = vim.uv.fs_stat(jdk_latest) and { JAVA_HOME = jdk_latest } or nil,
		root_dir = root,
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
		init_options = { bundles = bundles(), extendedClientCapabilities = extended },
		settings = {
			java = {
				configuration = { runtimes = runtimes, updateBuildConfiguration = "interactive" },
				contentProvider = { preferred = "fernflower" }, -- decompile library classes on gd
				signatureHelp = { enabled = true },
				inlayHints = { parameterNames = { enabled = "literals" } },
				completion = {
					favoriteStaticMembers = {
						"org.junit.jupiter.api.Assertions.*",
						"org.mockito.Mockito.*",
						"org.mockito.ArgumentMatchers.*",
						"org.hamcrest.Matchers.*",
						"java.util.Objects.requireNonNull",
					},
				},
				sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
			},
		},
		on_attach = on_attach,
	})

	-- test runner and debugging go through nvim-dap
	if #bundles() > 0 then
		jdtls.setup_dap({ hotcodereplace = "auto" })
		-- for apps started outside nvim with -agentlib:jdwp on port 5005 (see KEYS.md)
		require("dap").configurations.java = {
			{ type = "java", request = "attach", name = "Attach to localhost:5005", hostName = "127.0.0.1", port = 5005 },
		}
	end
end

return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
	dependencies = {
		"mfussenegger/nvim-dap", -- <leader>jt / jT run tests through it
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserJdtls", { clear = true }),
			pattern = "java",
			callback = function(args)
				-- Java convention is 4 spaces (options.lua defaults to 2)
				vim.bo[args.buf].shiftwidth = 4
				vim.bo[args.buf].tabstop = 4
				vim.bo[args.buf].softtabstop = 4
				start()
			end,
		})
	end,
}
