Experiments with Regular Expression Derivatives.

See [regex.coffee](regex.coffee) for the interesting parts.

Run `node build/dotFA '(a+b+c+)+' | dot -Tsvg | display` to display the DFA graph of a regex.

### References

	* [Regular-expression derivatives reexamined](http://www.ccs.neu.edu/home/turon/re-deriv.pdf)

	* [Derivatives of regular expressions](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.98.4378)
	
	* [Redgrep](https://code.google.com/p/redgrep/source/browse/regexp.cc)
