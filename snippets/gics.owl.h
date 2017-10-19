@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix figi-gii: <http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/> .
@prefix gas: <http://schema.ga-group.nl/symbology#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix gics: <http://schema.ga-group.nl/meta/classification/GICS/>  .

<http://schema.ga-group.nl/meta/classification/GICS/>
    dct:license """The MIT License:  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

      The copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.""", "http://opensource.org/licenses/mit-license.php"^^xsd:anyURI ;
    a owl:Ontology ;
    rdfs:label "Ontology for GICS" ;
    owl:imports <http://www.w3.org/2004/02/skos/core> ;
    owl:versionIRI <http://schema.ga-group.nl/meta/classification/GICS/201609/> .
