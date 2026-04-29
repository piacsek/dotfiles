; extends

((template_string) @injection.content
 (#lua-match? @injection.content "^`[%s\n]*%-?%-?[%s\n]*[Ss][Ee][Ll][Ee][Cc][Tt][%s\n]")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))

((template_string) @injection.content
 (#lua-match? @injection.content "^`[%s\n]*[Ww][Ii][Tt][Hh][%s\n]")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))

((template_string) @injection.content
 (#lua-match? @injection.content "^`[%s\n]*[Ii][Nn][Ss][Ee][Rr][Tt][%s\n]")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))

((template_string) @injection.content
 (#lua-match? @injection.content "^`[%s\n]*[Uu][Pp][Dd][Aa][Tt][Ee][%s\n]")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))

((template_string) @injection.content
 (#lua-match? @injection.content "^`[%s\n]*[Dd][Ee][Ll][Ee][Tt][Ee][%s\n]")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))
