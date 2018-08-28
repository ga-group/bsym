SPARQL
DEFINE input:inference <http://schema.ga-group.nl/symbology#>
DEFINE input:same-as "yes"
PREFIX gas: <http://schema.ga-group.nl/symbology#>
PREFIX figi: <http://openfigi.com/id/>
PREFIX bps: <http://bsym.bloomberg.com/pricing_source/>
PREFIX figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT ?figi ?bps1 ?prov1 ?cfigi ?bps2 ?prov2 WHERE {
	?figi gas:symbolOf <http://openfigi.com/> .
	?figi gas:sector figi-gii:EquityMarketSector .
	?figi gas:componentOf ?cfigi .

	?figi gas:listedOn ?bps1 .
	?figi gas:listedOn ?bps2 .
	?cfigi gas:listedOn ?bps2 .
	## only inconsistent ones
	FILTER (?bps1 != ?bps2)
	## check provenance
	OPTIONAL {
		?prov1 rdf:subject ?figi ; rdf:object ?bps1
	}
	OPTIONAL {
		?prov2 rdf:subject ?figi ; rdf:object ?bps2
	}
	FILTER NOT EXISTS { ?prov1 prov:wasInvalidatedBy ?inv1 }
	FILTER NOT EXISTS { ?prov2 prov:wasInvalidatedBy ?inv2 }
};
