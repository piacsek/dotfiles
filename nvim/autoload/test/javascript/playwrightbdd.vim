" Custom vim-test runner for playwright-bdd (Gherkin .feature files).
"
" playwright-bdd compiles .feature files into playwright specs via `bddgen`
" (default output: .features-gen/<path-relative-to-config>.feature.spec.js),
" so running a feature means regenerating and pointing playwright at the
" generated spec. Registered via g:test#custom_runners in core/plugins.lua.
"
" Per-project knobs (g: vars, set from a project's .nvim.lua):
"   test#javascript#playwrightbdd#features_root  repo root the generated tree
"                                                mirrors (default: cwd)
"   test#javascript#playwrightbdd#output_dir     bddgen outputDir
"                                                (default: .features-gen)

if !exists('g:test#javascript#playwrightbdd#file_pattern')
  let g:test#javascript#playwrightbdd#file_pattern = '\v\.feature$'
endif

function! test#javascript#playwrightbdd#test_file(file) abort
  return a:file =~# g:test#javascript#playwrightbdd#file_pattern
endfunction

function! test#javascript#playwrightbdd#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_scenario(a:position)
    let args = empty(name) ? [] : ['-g '.shellescape(name, 1)]
    return args + [s:generated_spec(a:position['file'])]
  elseif a:type ==# 'file'
    return [s:generated_spec(a:position['file'])]
  else
    return []
  endif
endfunction

function! test#javascript#playwrightbdd#build_args(args) abort
  return a:args
endfunction

function! test#javascript#playwrightbdd#executable() abort
  return 'npx bddgen && npx playwright test'
endfunction

" Playwright greps against the space-joined title chain, so
" 'Feature title Scenario title' pins down one scenario.
if !exists('g:test#playwrightbdd#patterns')
  let g:test#playwrightbdd#patterns = {
    \ 'test': ['\v^\s*%(Scenario Outline|Scenario|Example)\s*:\s*(.*)$'],
    \ 'namespace': ['\v^\s*Feature\s*:\s*(.*)$'],
  \}
endif

function! s:nearest_scenario(position) abort
  let name = test#base#nearest_test(a:position, g:test#playwrightbdd#patterns)
  return test#base#escape_regex(join(name['namespace'] + name['test']))
endfunction

function! s:generated_spec(file) abort
  let root = fnamemodify(get(g:, 'test#javascript#playwrightbdd#features_root', getcwd()), ':p:h')
  let output_dir = get(g:, 'test#javascript#playwrightbdd#output_dir', '.features-gen')
  let rel = substitute(fnamemodify(a:file, ':p'), '\V\^'.escape(root, '\').'/', '', '')
  return output_dir.'/'.rel.'.spec.js'
endfunction
