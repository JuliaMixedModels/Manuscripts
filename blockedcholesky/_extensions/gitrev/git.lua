-- from https://quarto.org/docs/extensions/shortcodes.html
function git(command)
  local p = io.popen("git " .. command)
  local output = p:read('*all')
  p:close()
  return output
end

-- return a table containing shortcode definitions
-- defining shortcodes this way allows us to create helper
-- functions that are not themselves considered shortcodes
return {
  ["git-rev"] = function(args, kwargs)
    -- command line args
    local cmdArgs = ""
    local short = pandoc.utils.stringify(kwargs["short"])
    if short == "true" then
      cmdArgs = cmdArgs .. "--short "
    end

    -- run the command
    local cmd = "rev-parse " .. cmdArgs .. "HEAD"
    local rev = git(cmd)

    -- return as string
    return pandoc.Str(string.gsub(rev, '%s+$', ''))
  end
}
