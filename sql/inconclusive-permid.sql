SPARQL
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?f ?p1 ?p2 WHERE {
	?f skos:related ?p1 , ?p2 
	FILTER(?p1!=?p2)
	FILTER(STRSTARTS(STR(?p1), 'https://permid.org/'))
	FILTER(STRSTARTS(STR(?p2), 'https://permid.org/'))
};
