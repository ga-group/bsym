SPARQL
DEFINE input:inference <http://schema.ga-group.nl/symbology#>
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
-- This snippet detects issuer assignment differences between listing leve and
-- and composites

SELECT ?figi ?issr ?sfigi ?sissr WHERE {
	?figi gas:componentOf+ ?sfigi .
	?figi gas:issuedBy ?issr .
	?sfigi gas:issuedBy ?sissr .
	## only inconsistent ones
	FILTER (?issr != ?sissr)
	## same symbologies
	?figi gas:symbolOf ?symb .
	?sfigi gas:symbolOf ?symb .
	?issr gas:symbolOf ?isymb .
	?sissr gas:symbolOf ?isymb .
	## make sure they are not just renamed
	FILTER NOT EXISTS { ?figi gas:issuedBy ?sissr }
	FILTER NOT EXISTS { ?sfigi gas:issuedBy ?issr }
};
