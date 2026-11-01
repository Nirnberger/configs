-- Java via nvim-jdtls (not vim.lsp.enable): jdtls needs a workspace dir per project,
-- lombok and the debug/test bundles, which plain lspconfig doesn't set up.
-- Mason installs jdtls, java-debug-adapter and java-test (mason.lua).
local mason = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

-- brew JDKs (native arm64). jdtls itself needs a recent Java (25+ since late 2026),
-- so it runs on the latest openjdk; projects build against 21 unless their pom/gradle says otherwise.
local jdk_latest = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
local jdk21 = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"

local function bundles()
  local jars = vim.fn.glob(mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
  for _, jar in ipairs(vim.fn.glob(mason .. "/packages/java-test/extension/server/*.jar", true, true)) do
    local name = vim.fn.fnamemodify(jar, ":t")
    -- these two are not OSGi bundles, jdtls refuses to load them
    if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
      table.insert(jars, jar)
    end
  end
  return jars
end

local function on_attach(_, buf)
  local jdtls = require("jdtls")
  local map = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = buf, desc = "Java: " .. desc })
  end

  map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
  map({ "n", "v" }, "<leader>jv", function() jdtls.extract_variable(vim.fn.mode() ~= "n") end, "Extract variable")
  map({ "n", "v" }, "<leader>jc", function() jdtls.extract_constant(vim.fn.mode() ~= "n") end, "Extract constant")
  map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Extract method")
  map("n", "<leader>jt", jdtls.test_nearest_method, "Test nearest method")
  map("n", "<leader>jT", jdtls.test_class, "Test class")
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
  local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 8)

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
