source ./bigint.vim

function! Fib(n) abort
  "let l:start = reltime()
  let [a,b,i] = [FromString("0"),FromString("1"),0]
  while i < a:n
    let [a,b,i] = [b,BigAdd(a,b),i+1]
  endwhile
  "echo reltimestr(reltime(l:start))
  return ToString(a)
endfunction
