; extends

((template_string) @injection.content
 (#lua-match? @injection.content "SELECT")
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))
