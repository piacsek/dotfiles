local colors = {
  bg = "#131314",
  fg = "#ebebeb",
  fg_dark = "#999999",
  blue = "#33ccff",
  cyan = "#37cccc",
  green = "#54b33e",
  orange = "#ed864a",
  purple = "#ed94ff",
  red = "#fa3232",
  yellow = "#ffcf40",
  teal = "#5be7f5",
  bg_highlight = "#000066",
  bg_visual = "#006280",
}

return {
  normal = {
    a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
    b = { bg = colors.bg_highlight, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
  insert = {
    a = { bg = colors.green, fg = colors.bg, gui = "bold" },
    b = { bg = colors.bg_highlight, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
  visual = {
    a = { bg = colors.purple, fg = colors.bg, gui = "bold" },
    b = { bg = colors.bg_highlight, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
  replace = {
    a = { bg = colors.red, fg = colors.bg, gui = "bold" },
    b = { bg = colors.bg_highlight, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
  command = {
    a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
    b = { bg = colors.bg_highlight, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
  inactive = {
    a = { bg = colors.bg, fg = colors.fg_dark },
    b = { bg = colors.bg, fg = colors.fg_dark },
    c = { bg = colors.bg, fg = colors.fg_dark },
  },
}