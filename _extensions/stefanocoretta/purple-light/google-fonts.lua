function Meta(meta)
  if meta.googlefonts then
    local fonts = meta.googlefonts

    local font_list = {}

    if type(fonts ) == "table" then
      for i, font in ipairs(fonts) do
        font_str = pandoc.utils.stringify(font)

        font_list[#font_list+1] = "family=" .. string.gsub(font_str, " ", "+")

      end
    end

    local font_url = "https://fonts.googleapis.com/css2?" .. table.concat(font_list, "&") .. "&display=swap"
    -- quarto.log.output(font_url)

    local meta_header_includes = meta["header-includes"]

    meta_header_includes[#meta_header_includes+1] = pandoc.RawBlock("html",
            '<link rel="stylesheet" href="' ..font_url .. '">')
  end
  return meta
end
