Experiments with Regular Expression Derivatives.

See [regex.coffee](regex.coffee) for the interesting parts.

Run `make && node build/dotFA '(a+b+c+)+' | dot -Tsvg | display` to display the DFA graph of a regex.

Run `make && node build/llvm 'a*b*'` for LLVM IR; pipe it to `opt -O3 | llc` for ASM.

Run `make && node build/llvm '.*foo.*' 'abcfooxyz' to test a string with the llvm-compiled regex.

### References

  * [Regular-expression derivatives reexamined](http://www.ccs.neu.edu/home/turon/re-deriv.pdf)
  * [Derivatives of regular expressions](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.98.4378)
  * [Redgrep](https://code.google.com/p/redgrep/source/browse/regexp.cc)
