--[[
  Shortcodes for the Journal of Data Science Quarto format.
  Provides cross-format support for common JDS markup.
]]--

-- Shortcode for nicely formatted 'LaTeX' string
function latex()
  if quarto.doc.isFormat("pdf") then
    return pandoc.RawInline('tex', '{\\LaTeX}')
  elseif quarto.doc.isFormat("html") then
    return pandoc.Math('InlineMath', "\\LaTeX")
  else
    return pandoc.Span('LaTeX')
  end
end

-- Shortcode for programming language names: {{< proglang R >}}
function proglang(args)
  local lang = pandoc.utils.stringify(args[1])
  if lang == nil or lang == "" then return pandoc.Str("") end
  if quarto.doc.isFormat("pdf") then
    return pandoc.RawInline('tex', '\\proglang{' .. lang .. '}')
  else
    return pandoc.Strong(pandoc.Str(lang))
  end
end

-- Shortcode for software package names: {{< pkg stats >}}
function pkg(args)
  local name = pandoc.utils.stringify(args[1])
  if name == nil or name == "" then return pandoc.Str("") end
  if quarto.doc.isFormat("pdf") then
    return pandoc.RawInline('tex', '\\pkg{' .. name .. '}')
  else
    return pandoc.Emph(pandoc.Str(name))
  end
end
