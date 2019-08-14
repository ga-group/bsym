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

-- Issuers, strictly speaking, only issue securities at the share class level
-- however common data sources, more often than not, present issuer data
-- alongside particular listings (shares at an exchange, bonds at an exch)
-- This snippet outputs information to move issuers from listing level to
-- share class level

SELECT ?figi ?issr ?sfigi WHERE {
	?figi gas:issuedBy ?issr .
	?figi gas:componentOf+ ?sfigi .
	?sfigi a figi-gii:ShareClassGlobalIdentifier
};
