-- Java: jdtls (from the lang.java extra) needs a JDK >= 21 to *run*, while your
-- projects can still target 8/11/17/21/25. We start jdtls with the newest JDK found
-- and register every installed JDK as a runtime so Maven/Gradle projects compile
-- with the version they declare.

local function jdk_version(home)
  local f = io.open(home .. "/release", "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local v = content:match('JAVA_VERSION="([%d%.]+)')
  if not v then
    return nil
  end
  local major = tonumber(v:match("^1%.(%d+)") or v:match("^(%d+)"))
  return major
end

local function find_jdks()
  local candidates = {}
  for _, prefix in ipairs({ "/opt/homebrew/opt", "/usr/local/opt" }) do
    for _, v in ipairs({ "8", "11", "17", "21", "25", "" }) do
      local name = v == "" and "openjdk" or ("openjdk@" .. v)
      table.insert(candidates, prefix .. "/" .. name .. "/libexec/openjdk.jdk/Contents/Home")
    end
  end
  vim.list_extend(candidates, vim.fn.glob("/Library/Java/JavaVirtualMachines/*/Contents/Home", false, true))
  vim.list_extend(candidates, vim.fn.glob(vim.env.HOME .. "/Library/Java/JavaVirtualMachines/*/Contents/Home", false, true))
  vim.list_extend(candidates, vim.fn.glob(vim.env.HOME .. "/.sdkman/candidates/java/*", false, true))

  local by_major = {} ---@type table<integer, string>
  for _, home in ipairs(candidates) do
    local major = vim.uv.fs_stat(home) and jdk_version(home)
    if major and not by_major[major] then
      by_major[major] = vim.uv.fs_realpath(home) or home
    end
  end
  return by_major
end

return {
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      local jdks = find_jdks()
      local runtimes, newest = {}, nil
      for major, home in pairs(jdks) do
        local name = major <= 8 and ("JavaSE-1." .. major) or ("JavaSE-" .. major)
        table.insert(runtimes, { name = name, path = home })
        if not newest or major > newest then
          newest = major
        end
      end

      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          configuration = { runtimes = runtimes, updateBuildConfiguration = "interactive" },
          eclipse = { downloadSources = true },
          maven = { downloadSources = true },
          references = { includeDecompiledSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
        },
      })

      if newest and newest >= 21 then
        opts.jdtls = vim.tbl_deep_extend("force", opts.jdtls or {}, {
          cmd_env = { JAVA_HOME = jdks[newest] },
        })
      else
        vim.schedule(function()
          vim.notify("jdtls requires JDK >= 21 (brew install openjdk@21)", vim.log.levels.WARN)
        end)
      end
    end,
  },
}
