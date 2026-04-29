; extends

((template_string) @injection.content
 (#set! injection.language "sql")
 (#offset! @injection.content 0 1 0 -1))
