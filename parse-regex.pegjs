{
	Bitset = require('./bitset')
	ast = require('./regex')
}

start = disjunction

// escaped [\^$.|?*+()
reserved = [\[\\\^\$\.\|\?\*\+\(\)]

charLiteral = ("\\" / !reserved) c:.
	{return ast.literal(Bitset.fromRange(c.charCodeAt(0)))}

anyChar = "."
	{return ast.literal(Bitset.fromRange(0, 255))}

charClass = "[" inverted:("^")?  body:(classRange / classLiteral)* "]"
	{
		var set = Bitset.empty
		for (var i=0; i<body.length; i++){
			set = set.union(body[i])
		}
		return ast.literal(set)
	}

	classChar =  ("\\" / ![-\]\\]) c:.
		{return c.charCodeAt(0)}

	classLiteral = c:classChar
		{return Bitset.fromRange(c)}

	classRange = start:classChar "-" end:classChar
		{return Bitset.fromRange(start, end)}


disjunction = a:concatenation "|" b:disjunction
	{return ast.disjunction([a, b])}
	/ concatenation

concatenation = a:kleene b:concatenation
	{return ast.concatenation(a, b)}
	/ kleene

kleene
	= a:atom "*" {return ast.repeat(a)}
	/ a:atom "+" {return ast.concatenation(a, ast.repeat(a))}
	/ atom

atom = anyChar / charLiteral / charClass / "(" s:start ")" {return s}

