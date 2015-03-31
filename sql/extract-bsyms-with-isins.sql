SPARQL
PREFIX gas: <http://schema.ga-group.nl/symbology#>
SELECT ?bsym ?isin FROM <http://data.ga-group.nl/bsym/> WHERE {
	?bsym gas:symbolOf <http://bsym.bloomberg.com/sym/> .
	?bsym skos:broader ?isin .
	?isin a gas:ISIN .
};
