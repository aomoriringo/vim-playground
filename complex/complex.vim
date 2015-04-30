let s:zero = {'real': 0, 'imag': 0}

function! FromString(str)
endfunction

" Number or Float
function! FromFloat(real, imag)
  return {'real': a:real + 0.0, 'imag': a:imag + 0.0}
endfunction

function! Add(c1, c2)
  return {'real': a:c1.real + a:c2.real,
         \'imag': a:c1.imag + a:c2.imag}
endfunction

function! Sub(c1, c2)
  return {'real': a:c1.real - a:c2.real,
         \'imag': a:c1.imag - a:c2.imag}
endfunction

function! Mul(c1, c2)
  return {'real': a:c1.real * a:c2.real - a:c1.imag * a:c2.imag,
         \'imag': a:c1.real * a:c2.imag + a:c2.real * a:c1.imag}
endfunction

function! Div(c1, c2)
  let denominator = a:c2.real * a:c2.real + a:c2.imag * a:c2.imag
  return {'real': (a:c1.real * a:c2.real + a:c1.imag * a:c2.imag) / denominator,
         \'imag': (a:c1.imag * a:c2.real - a:c1.real * a:c2.imag) / denominator}
endfunction

function! Conjugate(c)
  return {'real': a:c.real,
         \'imag': a:c.imag * (-1)}
endfunction
