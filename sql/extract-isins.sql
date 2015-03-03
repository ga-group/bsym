SPARQL
PREFIX gas: <http://schema.ga-group.nl/symbology#>
SELECT ?sym FROM <http://data.ga-group.nl/bsym/> WHERE {
	?sym a gas:ISIN .
};
