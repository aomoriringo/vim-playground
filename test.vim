source <sfile>:h/bigint.vim
let s:suite = themis#suite('Test for bigint.vim')
let s:assert = themis#helper('assert')

function! s:suite.to_bigint()
  call s:assert.equals(ToBigint(123), {'num': [123], 'sign': 1})
  call s:assert.equals(ToBigint("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(ToBigint({'num': [123], 'sign': 1}), {'num': [123], 'sign': 1})
endfunction

function! s:suite.string_to_bigint()
  call s:assert.equals(StringToBigint("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(StringToBigint("1234567890"), {'num': [12, 3456, 7890], 'sign': 1})
endfunction

function! s:suite.bigint_to_string()
  call s:assert.equals(BigintToString({'num': [123], 'sign': 1}), "123")
endfunction

function! s:suite.big_compare()
  call s:assert.equals(BigCompare(0, 0), 0)
  call s:assert.equals(BigCompare(1, 1), 0)
  call s:assert.equals(BigCompare(-1, -1), 0)
  call s:assert.equals(BigCompare("1234567890", 1), 1)
  call s:assert.equals(BigCompare("-1234567890", "-1234567890"), 0)
  call s:assert.equals(BigCompare(-1, -2), 1)
  call s:assert.equals(BigCompare("10000000000", 100), 1)
  call s:assert.equals(BigCompare(-1, 1), -1)
endfunction

function! s:suite.big_add()
  call s:assert.equals(BigAdd(0, 0), StringToBigint("0"))
  call s:assert.equals(BigAdd("9999999999999999", 1), ToBigint("10000000000000000"))
  call s:assert.equals(BigAdd(-1, 999), ToBigint("998"))
  call s:assert.equals(BigAdd(-1000, -1234), ToBigint("-2234"))
  call s:assert.equals(BigAdd("-123456789", 111111111), ToBigint("-12345678"))
endfunction

function! s:suite.big_sub()
  call s:assert.equals(BigSub(0, 0), ToBigint("0"))
  call s:assert.equals(BigSub(99999999, -1), ToBigint("100000000"))
  call s:assert.equals(BigSub(-1, -999), ToBigint("998"))
  call s:assert.equals(BigSub(-1000, 1234), ToBigint("-2234"))
  call s:assert.equals(BigSub(-123456789, -111111111), ToBigint("-12345678"))
  call s:assert.equals(BigSub("1122334455667788", "1111111111111111"), ToBigint("11223344556677"))
endfunction

function! s:suite.big_mul()
  call s:assert.equals(BigMul(0, 0), ToBigint("0"))
  call s:assert.equals(BigMul(1234567890, 1234567890), ToBigint("1524157875019052100"))
  call s:assert.equals(BigMul(12345678, 9), ToBigint("111111102"))
  call s:assert.equals(BigMul("1234567890123", 0), ToBigint("0"))
endfunction

function! s:suite.big_div()
  call s:assert.equals(BigDiv(123456780, 12345678), ToBigint("10"))
  call s:assert.equals(BigDiv(123, 123), ToBigint("1"))
  call s:assert.equals(BigDiv("11123456789", "11123456790"), ToBigint("0"))
  call s:assert.equals(BigDiv("519920419074760465703", "22801763489"), ToBigint("22801763527"))
endfunction

function! s:suite.big_mod()
  call s:assert.equals(BigMod(123456780, 12345678), ToBigint("0"))
  call s:assert.equals(BigMod(123, 123), ToBigint("0"))
  call s:assert.equals(BigMod("123456789", "123456790"), ToBigint("123456789"))
  call s:assert.equals(BigMod("519920419074760465703", "22801763489"), StringToBigint("0"))
endfunction
