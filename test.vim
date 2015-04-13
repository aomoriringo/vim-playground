source <sfile>:h/bigint.vim
let s:suite = themis#suite('Test for bigint.vim')
let s:assert = themis#helper('assert')

function! s:suite.of()
  call s:assert.equals(Of(123), {'num': [123], 'sign': 1})
  call s:assert.equals(Of("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(Of({'num': [123], 'sign': 1}), {'num': [123], 'sign': 1})
endfunction

function! s:suite.from_int()
  call s:assert.equals(FromInt(0), {'num': [0], 'sign': 1})
  call s:assert.equals(FromInt(123), {'num': [123], 'sign': 1})
  call s:assert.equals(FromInt(-789), {'num': [789], 'sign': -1})
endfunction

function! s:suite.from_string()
  call s:assert.equals(FromString("0"), {'num': [0], 'sign': 1})
  call s:assert.equals(FromString("123"), {'num': [123], 'sign': 1})
  call s:assert.equals(FromString("1234567890"), {'num': [12, 3456, 7890], 'sign': 1})
endfunction

function! s:suite.to_string()
  call s:assert.equals(ToString({'num': [0], 'sign': 1}), "0")
  call s:assert.equals(ToString({'num': [123], 'sign': 1}), "123")
  call s:assert.equals(ToString({'num': [12, 3456, 7890], 'sign': 1}), "1234567890")
endfunction

function! s:suite.big_compare()
  call s:assert.equals(BigCompare(0, 0), 0)
  call s:assert.equals(BigCompare(1, 1), 0)
  call s:assert.equals(BigCompare(-1, -1), 0)
  call s:assert.equals(BigCompare(2, 1), 1)
  call s:assert.equals(BigCompare(1, 2), -1)
  call s:assert.equals(BigCompare(1, -1), 1)
  call s:assert.equals(BigCompare(-1, 1), -1)
  call s:assert.equals(BigCompare("1234567890", 0), 1)
  call s:assert.equals(BigCompare("-1234567890", 0), -1)
  call s:assert.equals(BigCompare("1234567890", "1234567890"), 0)
endfunction

function! s:suite.big_add()
  call s:assert.equals(BigAdd(0, 0), FromInt(0))
  call s:assert.equals(BigAdd("9999999999999999", 1), FromString("10000000000000000"))
  call s:assert.equals(BigAdd(-1, 999), FromInt(998))
  call s:assert.equals(BigAdd(-1000, -1234), FromInt(-2234))
  call s:assert.equals(BigAdd("-123456789", 111111111), FromInt(-12345678))
endfunction

function! s:suite.big_sub()
  call s:assert.equals(BigSub(0, 0), FromInt(0))
  call s:assert.equals(BigSub(99999999, -1), FromInt(100000000))
  call s:assert.equals(BigSub(-1, -999), FromInt(998))
  call s:assert.equals(BigSub(-1000, 1234), FromInt(-2234))
  call s:assert.equals(BigSub(-123456789, -111111111), FromInt(-12345678))
  call s:assert.equals(BigSub("1122334455667788", "1111111111111111"), FromString("11223344556677"))
endfunction

function! s:suite.big_mul()
  call s:assert.equals(BigMul(0, 0), FromInt(0))
  call s:assert.equals(BigMul(1234567890, 1234567890), FromString("1524157875019052100"))
  call s:assert.equals(BigMul(12345678, 9), FromInt(111111102))
  call s:assert.equals(BigMul("1234567890123", 0), FromInt(0))
endfunction

function! s:suite.big_div()
  call s:assert.equals(BigDiv(123456780, 12345678), FromInt(10))
  call s:assert.equals(BigDiv(123, 123), FromInt(1))
  call s:assert.equals(BigDiv("11123456789", "11123456790"), FromInt(0))
  call s:assert.equals(BigDiv("519920419074760465703", "22801763489"), FromString("22801763527"))
endfunction

function! s:suite.big_mod()
  call s:assert.equals(BigMod(3, -2), FromInt(1))
  call s:assert.equals(BigMod(-3, 2), FromInt(-1))
  call s:assert.equals(BigMod(-3, -2), FromInt(-1))
  call s:assert.equals(BigMod(123456780, 12345678), FromInt(0))
  call s:assert.equals(BigMod(123, 123), FromInt(0))
  call s:assert.equals(BigMod("123456789", "123456790"), FromInt(123456789))
  call s:assert.equals(BigMod("519920419074760465703", "22801763489"), FromInt(0))
endfunction

function! s:suite.big_sign()
  call s:assert.equals(BigSign("1234567890123"), 1)
  call s:assert.equals(BigSign(0), 0)
  call s:assert.equals(BigSign(-3), -1)
endfunction

function! s:suite.big_neg()
  call s:assert.equals(BigNeg("-1111"), FromInt(1111))
endfunction
