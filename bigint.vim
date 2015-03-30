let g:bigint = {'num': [], 'sign': 1}
let g:nodeMaxDigit = 4
let g:nodeMaxNum = 10000

function! Isdigit(str)
  return match(a:str, '^[+-]\?\d\+$') != -1
endfunction

function! StringToBigint(str)
  if Isdigit(a:str) != 1
    throw 'is not digit: '.a:str
  endif
  let bigint = deepcopy(g:bigint)
  let bigint.sign = (a:str[0] == "-") ? -1 : 1
  if match(a:str, '^[+-]') != -1
    let l:str = a:str[1:]
  else
    let l:str = a:str
  endif
  let l:strlen = len(l:str)
  let l:nodes = ((l:strlen-1)/g:nodeMaxDigit)+1
  let l:head_node_len = l:strlen % g:nodeMaxDigit

  if l:head_node_len != 0
    call add(bigint.num, l:str[: l:head_node_len-1])
  endif

  let l:tail_nodes = split(l:str[l:head_node_len :], '.\{' . g:nodeMaxDigit . '}\zs')
  let l:bigint.num = map(l:bigint.num + l:tail_nodes, 'str2nr(v:val)')
  return l:bigint
endfunction

function! BigintToString(bigint)
  let l:str = ''
  let l:str .= string(a:bigint.num[0])
  for node in a:bigint.num[1:]
    let l:str .= printf('%0'.g:nodeMaxDigit.'d', node)
  endfor
  if a:bigint.sign == -1
    let l:str = '-' .l:str
  endif
  return l:str
endfunction

" a > b: return 1
" a = b: return 0
" a < b: return -1
function! BigCompare(a,b)
  if a:a.sign != a:b.sign
    return (a:a.sign == 1) ? 1 : -1
  endif
  return BigAbscompare(a:a,a:b) * a:a.sign
endfunction

function! BigAbscompare(a,b)
  let l:len_a = len(a:a.num)
  let l:len_b = len(a:b.num)

  if len_a != len_b
    return (len_a > len_b) ? 1 : -1
  endif
  for i in range(len_a)
    if a:a.num[i] != a:b.num[i]
      return (a:a.num[i] > a:b.num[i]) ? 1 : -1
    endif
  endfor
  return 0
endfunction

function! BigAdd(a,b)
  if a:a.sign == a:b.sign
    let l:tmp = BigAbsadd(a:a,a:b)
    let l:tmp.sign = a:a.sign
    return l:tmp
  else
    let l:comp = BigAbscompare(a:a,a:b)
    if l:comp >= 0
      let l:tmp = BigAbssub(a:a,a:b)
      let l:tmp.sign = a:a.sign
      return l:tmp
    else
      let l:tmp = BigAbssub(a:b,a:a)
      let l:tmp.sign = a:b.sign
      return l:tmp
    endif
  endif
endfunction

function! BigSub(a,b)
  let l:b = deepcopy(a:b)
  let l:b.sign = l:b.sign*-1
  return BigAdd(a:a,l:b)
endfunction

function! BigAbsadd(a,b)
  if BigAbscompare(a:a,a:b) >= 0
    let l:res = deepcopy(a:a)
    let l:addend = a:b
  else
    let l:res = deepcopy(a:b)
    let l:addend = a:a
  endif

  let l:res_len = len(l:res.num)
  let l:addend_len = len(l:addend.num)
  let l:carry = 0

  for i in range(res_len)
    let l:res_idx = l:res_len-i-1
    let l:addend_idx = l:addend_len-i-1

    if l:addend_idx >= 0
      let l:tmp_add = l:addend.num[l:addend_idx]
    else
      let l:tmp_add = 0
    endif

    let l:tmp = l:res.num[l:res_idx] + l:tmp_add + l:carry
    let l:carry = l:tmp / g:nodeMaxNum
    let l:tmp = l:tmp % g:nodeMaxNum
    let l:res.num[l:res_idx] = l:tmp
  endfor

  if l:carry > 0
    call insert(l:res.num, l:carry, 0)
  endif
  return l:res
endfunction

function! BigAbssub(a,b)
  if BigAbscompare(a:a,a:b) >= 0
    let l:res = deepcopy(a:a)
    let l:subtrahend = a:b
  else
    let l:res = deepcopy(a:b)
    let l:subtrahend = a:a
  endif

  let l:res_len = len(l:res.num)
  let l:subtrahend_len = len(l:subtrahend.num)
  let l:borrow = 0

  for i in range(l:res_len)
    let l:res_idx = l:res_len-i-1
    let l:subtrahend_idx = l:subtrahend_len-i-1

    if l:subtrahend_idx >= 0
      let l:tmp_sub = l:subtrahend.num[l:subtrahend_idx]
    else
      let l:tmp_sub = 0
    endif
    let l:tmp = l:res.num[l:res_idx] - l:tmp_sub - l:borrow

    if l:tmp < 0
      let l:borrow = 1
      let l:tmp += g:nodeMaxNum
    else
      let l:borrow = 0
    endif
    let l:res.num[l:res_idx] = l:tmp
  endfor

  while len(l:res.num) > 1
    if l:res.num[0] == 0
      call remove(l:res.num, 0)
    else
      break
    endif
  endwhile
  return l:res
endfunction

function! BigMul(a,b)
  let l:res = deepcopy(g:bigint)
  if BigAbscompare(a:a,a:b) >= 0
    let l:multiplicand = a:a
    let l:multiplier = a:b
  else
    let l:multiplicand = a:b
    let l:multiplier = a:a
  endif

  let l:multiplier_len = len(l:multiplier.num)
  for i in range(l:multiplier_len)
    let l:multiplier_idx = l:multiplier_len-i-1
    let l:multiplier_int = l:multiplier.num[l:multiplier_idx]

    let l:tmp = BigAbsmulShortInt(l:multiplicand, l:multiplier_int)
    for j in range(i)
      call add(l:tmp.num, 0)
    endfor
    let l:res = BigAbsadd(l:res, l:tmp)
  endfor

  let l:res.sign = a:a.sign * a:b.sign
  return l:res
endfunction

function! BigAbsmulShortInt(a,n)
  " n < 10000
  if a:n >= g:nodeMaxNum
    throw 'too large: '.a:n
  endif

  let l:res = deepcopy(a:a)
  let l:res_len = len(l:res.num)
  let l:carry = 0

  for i in range(res_len)
    let l:res_idx = l:res_len-i-1
    let l:tmp = l:res.num[l:res_idx] * a:n + l:carry
    let l:carry = l:tmp / g:nodeMaxNum
    let l:tmp = l:tmp % g:nodeMaxNum
    let l:res.num[l:res_idx] = l:tmp
  endfor

  if l:carry > 0
    call insert(l:res.num, l:carry, 0)
  endif
  return l:res

endfunction

function! BigDiv(a,b)
endfunction

function! BigMod(a,b)
endfunction
