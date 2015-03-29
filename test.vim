source <sfile>:h/bigint.vim
let s:suite = themis#suite('Test for bigint.vim')
let s:assert = themis#helper('assert')

function! s:suite.string_to_bigint()
  call s:assert.equals(StringToBigint("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(StringToBigint("1234567890"), {'num': [12, 34567890], 'sign': 1})
endfunction

function! s:suite.bigint_to_string()
  call s:assert.equals(BigintToString({'num': [123], 'sign': 1}), "123")
endfunction

function! s:suite.big_compare()
  call s:assert.equals(BigCompare(StringToBigint("0"), StringToBigint("0")), 0)
  call s:assert.equals(BigCompare(StringToBigint("123"), StringToBigint("123")), 0)
  call s:assert.equals(BigCompare(StringToBigint("1234567890"), StringToBigint("1")), 1)
  call s:assert.equals(BigCompare(StringToBigint("-1234567890"), StringToBigint("-1234567890")), 0)
  call s:assert.equals(BigCompare(StringToBigint("10000000000"), StringToBigint("100")), 1)
  call s:assert.equals(BigCompare(StringToBigint("-1"), StringToBigint("1")), -1)
endfunction

function! s:suite.big_abs_compare()
endfunction
