source <sfile>:h/bigint.vim
let s:suite = themis#suite('Test for bigint.vim')
let s:assert = themis#helper('assert')

function! s:suite.string_to_bigint()
  call s:assert.equals(StringToBigint("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(StringToBigint("1234567890"), {'num': [12, 3456, 7890], 'sign': 1})
endfunction

function! s:suite.bigint_to_string()
  call s:assert.equals(BigintToString({'num': [123], 'sign': 1}), "123")
endfunction

function! s:suite.big_compare()
  call s:assert.equals(BigCompare(StringToBigint("0"), StringToBigint("0")), 0)
  call s:assert.equals(BigCompare(StringToBigint("1"), StringToBigint("1")), 0)
  call s:assert.equals(BigCompare(StringToBigint("-1"), StringToBigint("-1")), 0)
  call s:assert.equals(BigCompare(StringToBigint("1234567890"), StringToBigint("1")), 1)
  call s:assert.equals(BigCompare(StringToBigint("-1234567890"), StringToBigint("-1234567890")), 0)
  call s:assert.equals(BigCompare(StringToBigint("-1"), StringToBigint("-2")), 1)
  call s:assert.equals(BigCompare(StringToBigint("10000000000"), StringToBigint("100")), 1)
  call s:assert.equals(BigCompare(StringToBigint("-1"), StringToBigint("1")), -1)
endfunction

function! s:suite.big_add()
  call s:assert.equals(BigAdd(StringToBigint("0"), StringToBigint("0")), StringToBigint("0"))
  call s:assert.equals(BigAdd(StringToBigint("9999999999999999"), StringToBigint("1")), StringToBigint("10000000000000000"))
  call s:assert.equals(BigAdd(StringToBigint("-1"), StringToBigint("999")), StringToBigint("998"))
  call s:assert.equals(BigAdd(StringToBigint("-1000"), StringToBigint("-1234")), StringToBigint("-2234"))
  call s:assert.equals(BigAdd(StringToBigint("-123456789"), StringToBigint("111111111")), StringToBigint("-12345678"))
endfunction

function! s:suite.big_sub()
  call s:assert.equals(BigSub(StringToBigint("0"), StringToBigint("0")), StringToBigint("0"))
  call s:assert.equals(BigSub(StringToBigint("99999999"), StringToBigint("-1")), StringToBigint("100000000"))
  call s:assert.equals(BigSub(StringToBigint("-1"), StringToBigint("-999")), StringToBigint("998"))
  call s:assert.equals(BigSub(StringToBigint("-1000"), StringToBigint("1234")), StringToBigint("-2234"))
  call s:assert.equals(BigSub(StringToBigint("-123456789"), StringToBigint("-111111111")), StringToBigint("-12345678"))
endfunction

function! s:suite.big_mul()
  call s:assert.equals(BigMul(StringToBigint("0"), StringToBigint("0")), StringToBigint("0"))
  call s:assert.equals(BigMul(StringToBigint("1234567890"), StringToBigint("1234567890")), StringToBigint("1524157875019052100"))
endfunction
