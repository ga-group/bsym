SPARQL
PREFIX gas: <http://schema.ga-group.nl/symbology#>
SELECT ?bsym ?isin FROM <http://data.ga-group.nl/bsym/> WHERE {
	?bsym gas:symbolOf <http://openfigi.com/> .
	?bsym skos:broader ?isin .
	?isin a gas:ISIN .
};
