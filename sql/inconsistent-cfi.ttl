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

SELECT ?figi ?cfi ?prov ?cfigi ?ccfi ?cprov WHERE {
	?figi gas:componentOf ?cfigi .
	?figi gas:classifiedAs ?cfi .
	?cfigi gas:classifiedAs ?ccfi .
	## only CFIs
	?cfi gas:symbolOf <http://www.iso.org/standard/44799.html> .
	?ccfi gas:symbolOf <http://www.iso.org/standard/44799.html> .
	## only inconsistent ones
	FILTER (?cfi != ?ccfi)
	## make sure they are not just reclassifications
	FILTER NOT EXISTS { ?cfigi gas:classifiedAs ?cfi }
	FILTER NOT EXISTS { ?figi gas:classifiedAs ?ccfi }
	## check provenance
	OPTIONAL {
		?prov rdf:subject ?figi ; rdf:object ?cfi
	}
	OPTIONAL {
		?cprov rdf:subject ?cfigi ; rdf:object ?ccfi
	}
	FILTER NOT EXISTS { ?prov prov:wasInvalidatedBy ?inv }
	FILTER NOT EXISTS { ?cprov prov:wasInvalidatedBy ?cinv }
};
