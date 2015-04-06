let s:bigint = {'num': [0], 'sign': 1}
let s:nodeMaxDigit = 4
let s:nodeMaxNum = 10000

function! Isdigit(str)
  return match(a:str, '^[+-]\?\d\+$') != -1
endfunction

function! FromInt(n)
  " TODO: do not use FromString
  return FromString(string(a:n))
endfunction

function! FromString(str)
  if Isdigit(a:str) != 1
    throw 'is not digit: '.a:str
  endif
  let bigint = deepcopy(s:bigint)
  let bigint.sign = (a:str[0] == "-") ? -1 : 1
  if match(a:str, '^[+-]') != -1
    let l:str = a:str[1:]
  else
    let l:str = a:str
  endif
  let l:strlen = len(l:str)
  let l:nodes = ((l:strlen-1)/s:nodeMaxDigit)+1
  let l:head_node_len = l:strlen % s:nodeMaxDigit

  if l:head_node_len != 0
    call add(bigint.num, l:str[: l:head_node_len-1])
  endif

  let l:tail_nodes = split(l:str[l:head_node_len :], '.\{' . s:nodeMaxDigit . '}\zs')
  let l:bigint.num = map(l:bigint.num + l:tail_nodes, 'str2nr(v:val)')
  return BigFixForm(l:bigint)
endfunction

function! ToString(bigint)
  let l:str = ''
  let l:str .= string(a:bigint.num[0])
  for node in a:bigint.num[1:]
    let l:str .= printf('%0'.s:nodeMaxDigit.'d', node)
  endfor
  if a:bigint.sign == -1
    let l:str = '-' .l:str
  endif
  return l:str
endfunction

function! Of(n)
  " n: Number or String or Bigint
  let l:t = type(a:n)
  if l:t == 4 " Dictionary
    return a:n
  elseif l:t == 0 " Number
    return FromString(string(a:n))
  elseif l:t == 1 " String
    return FromString(a:n)
  else
    throw 'type error'
  endif
endfunction

" a > b: return 1
" a = b: return 0
" a < b: return -1
function! BigCompare(a,b)
  let l:a = Of(a:a)
  let l:b = Of(a:b)

  if l:a.sign != l:b.sign
    return (l:a.sign == 1) ? 1 : -1
  endif
  return _BigAbscompare(l:a,l:b) * l:a.sign
endfunction

function! _BigAbscompare(a,b)
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
  let l:a = Of(a:a)
  let l:b = Of(a:b)

  if l:a.sign == l:b.sign
    let l:tmp = _BigAbsadd(l:a,l:b)
    let l:tmp.sign = l:a.sign
    return l:tmp
  else
    let l:comp = _BigAbscompare(l:a,l:b)
    if l:comp >= 0
      let l:tmp = _BigAbssub(l:a,l:b)
      let l:tmp.sign = l:a.sign
      return l:tmp
    else
      let l:tmp = _BigAbssub(l:b,l:a)
      let l:tmp.sign = l:b.sign
      return l:tmp
    endif
  endif
endfunction

function! BigSub(a,b)
  let l:a = Of(a:a)
  let l:b = Of(a:b)

  let l:b = deepcopy(l:b)
  let l:b.sign = l:b.sign*(-1)
  return BigAdd(l:a,l:b)
endfunction

function! _BigAbsadd(a,b)
  if _BigAbscompare(a:a,a:b) >= 0
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
    let l:carry = l:tmp / s:nodeMaxNum
    let l:tmp = l:tmp % s:nodeMaxNum
    let l:res.num[l:res_idx] = l:tmp
  endfor

  if l:carry > 0
    call insert(l:res.num, l:carry, 0)
  endif
  return BigFixForm(l:res)
endfunction

function! _BigAbssub(a,b)
  if _BigAbscompare(a:a,a:b) >= 0
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
      let l:tmp += s:nodeMaxNum
    else
      let l:borrow = 0
    endif
    let l:res.num[l:res_idx] = l:tmp
  endfor

  return BigFixForm(l:res)
endfunction

function! BigMul(a,b)
  let l:a = Of(a:a)
  let l:b = Of(a:b)

  let l:res = deepcopy(s:bigint)
  if _BigAbscompare(l:a,l:b) >= 0
    let l:multiplicand = l:a
    let l:multiplier = l:b
  else
    let l:multiplicand = l:b
    let l:multiplier = l:a
  endif

  let l:multiplier_len = len(l:multiplier.num)
  for i in range(l:multiplier_len)
    let l:multiplier_idx = l:multiplier_len-i-1
    let l:multiplier_int = l:multiplier.num[l:multiplier_idx]

    let l:tmp = _BigAbsmulShortInt(l:multiplicand, l:multiplier_int)
    for j in range(i)
      call add(l:tmp.num, 0)
    endfor
    let l:res = _BigAbsadd(l:res, l:tmp)
  endfor

  let l:res.sign = l:a.sign * l:b.sign
  return BigFixForm(l:res)
endfunction

function! BigDivMod(a,b)
  let l:a = Of(a:a)
  let l:b = Of(a:b)
  if BigCompare(l:b, s:bigint) == 0
    if BigCompare(l:a, s:bigint) == 0
      throw 'indeterminate'
    else
      throw 'incompatible'
    endif
  endif

  let l:res = deepcopy(s:bigint)
  let l:dividend = deepcopy(l:a)
  let l:divisor = deepcopy(l:b)
  if _BigAbscompare(l:a,l:b) < 0
    return [l:res, l:a]
  endif

  let l:dividend_len = len(l:dividend.num)
  let l:divisor_len = len(l:divisor.num)
  let l:extend_nodes_len = l:dividend_len - l:divisor_len

  " 0, 1, 2
  " # 0
  " 1 234 567 890
  " 1 111
  " # 1
  " 1 234 567 890
  "     1 111
  " # 2
  " 1 234 567 890
  "         1 111
  "
  let l:part_divisor = l:divisor.num[0] + 1
  for i in range(l:extend_nodes_len+1)
    let l:part_dividend_idx = len(l:dividend.num) - l:divisor_len - l:extend_nodes_len + i
    if l:part_dividend_idx == 0
      let l:part_dividend = l:dividend.num[0]
    else " l:part_dividend_idx == 1
      let l:part_dividend = l:dividend.num[0] * s:nodeMaxNum + l:dividend.num[1]
    endif

    let l:part_div = FromString(string(l:part_dividend / l:part_divisor))
    let l:extend_divisor = deepcopy(l:divisor)
    for j in range(l:extend_nodes_len - i)
      call add(l:extend_divisor.num, 0)
    endfor

    let l:tmp = BigMul(l:extend_divisor, l:part_div)
    let l:dividend = _BigAbssub(l:dividend, l:tmp)

    while _BigAbscompare(l:dividend, l:extend_divisor) >= 0
      let l:dividend = _BigAbssub(l:dividend, l:extend_divisor)
      let l:part_div = BigAdd(l:part_div, FromString("1"))
    endwhile

    for j in range(l:extend_nodes_len - i)
      call add(l:part_div.num, 0)
    endfor
    let l:res = BigAdd(l:res, l:part_div)
  endfor

  let l:res.sign = l:a.sign * l:b.sign
  return [BigFixForm(l:res), BigFixForm(l:dividend)]
endfunction

function! BigDiv(a,b)
  return BigDivMod(a:a,a:b)[0]
endfunction

function! BigMod(a,b)
  return BigDivMod(a:a,a:b)[1]
endfunction

function! _BigAbsmulShortInt(a,n)
  " n < 10000
  if a:n >= s:nodeMaxNum
    throw 'too large: '.a:n
  endif

  let l:res = deepcopy(a:a)
  let l:res_len = len(l:res.num)
  let l:carry = 0

  for i in range(res_len)
    let l:res_idx = l:res_len-i-1
    let l:tmp = l:res.num[l:res_idx] * a:n + l:carry
    let l:carry = l:tmp / s:nodeMaxNum
    let l:tmp = l:tmp % s:nodeMaxNum
    let l:res.num[l:res_idx] = l:tmp
  endfor

  if l:carry > 0
    call insert(l:res.num, l:carry, 0)
  endif
  return l:res
endfunction

function! BigSignum(a)
  let l:a = Of(a:a)
  if l:a.num == [0]
    return 0
  else
    return l:a.sign
  endif
endfunction

function! BigNegate(a)
  let l:a = Of(a:a)
  let l:res = deepcopy(l:a)
  let l:res.sign = l:res.sign*(-1)
  return l:res
endfunction

function! BigFixForm(a)
  let l:res = a:a
  while len(l:res.num) > 1
    if l:res.num[0] == 0
      call remove(l:res.num, 0)
    else
      break
    endif
  endwhile
  return l:res
endfunction

