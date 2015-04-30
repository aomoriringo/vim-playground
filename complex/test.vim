source <sfile>:h/complex.vim
let s:suite = themis#suite('Test for complex.vim')
let s:assert = themis#helper('assert')

function! s:suite.from_string()
endfunction

function! s:suite.from_float()
  call s:assert.equals(FromFloat(0, 0), {'real': 0.0, 'imag': 0.0})
  call s:assert.equals(FromFloat(1, 2), {'real': 1.0, 'imag': 2.0})
endfunction


function! s:suite.add()
  call s:assert.equals(Add(FromFloat(3, 1), FromFloat(2, -4)), FromFloat(5, -3))
endfunction

function! s:suite.sub()
  call s:assert.equals(Sub(FromFloat(3, 1), FromFloat(2, -4)), FromFloat(1, 5))
endfunction

function! s:suite.mul()
  call s:assert.equals(Mul(FromFloat(3, 1), FromFloat(2, -4)), FromFloat(10, -10))
endfunction

function! s:suite.div()
  call s:assert.equals(Div(FromFloat(3, 1), FromFloat(2, -4)), FromFloat(0.1, 0.7))
endfunction

function! s:suite.conjugate()
  call s:assert.equals(Conjugate(FromFloat(3, 1)), FromFloat(3, -1))
endfunction
