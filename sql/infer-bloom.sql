SPARQL
DEFINE input:inference <http://schema.ga-group.nl/symbology#>
DEFINE input:same-as "yes"
PREFIX gas: <http://schema.ga-group.nl/symbology#>
PREFIX bsym: <http://bsym.bloomberg.com/sym/>
PREFIX bps: <http://bsym.bloomberg.com/pricing_source/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/>
INSERT INTO GRAPH <http://data.ga-group.nl/bsym/> {
	?bsym skos:related ?wsym .
	?wsym gas:symbolOf <http://www.bloomberg.com/> .
} FROM <http://data.ga-group.nl/bsym/>
WHERE {
	?bsym a figi-gii:CompositeGlobalIdentifier ;
		gas:listedAs ?xsym ;
		gas:listedOn bps:GR .
	BIND(IRI(CONCAT('http://www.bloomberg.com/quote/', ?xsym, ':GR')) AS ?wsym) .
};
