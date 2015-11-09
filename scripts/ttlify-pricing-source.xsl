<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:figi-gii="http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  version="1.0">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="rdf:RDF">
    <xsl:text>@prefix foaf: &lt;http://xmlns.com/foaf/0.1/&gt; .
@prefix bps: &lt;http://bsym.bloomberg.com/pricing_source/&gt; .
@prefix figi-gii: &lt;http://www.omg.org/spec/FIGI/GlobalInstrumentIdentifiers/&gt; .
@prefix figi-ps: &lt;http://www.omg.org/spec/FIGI/PricingSources/&gt; .
@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .
@prefix mic: &lt;http://fadyart.com/markets#&gt; .
@prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt; .

</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="owl:NamedIndividual">
    <xsl:text>bps:</xsl:text>
    <xsl:value-of select="figi-gii:hasUniqueTextIdentifier"/>
    <xsl:text>&#0009;a&#0009;figi-gii:PricingSource ;&#0010;</xsl:text>
    <xsl:text>&#0009;owl:sameAs&#0009;&lt;</xsl:text>
    <xsl:value-of select="@rdf:about"/>
    <xsl:text>&gt; ;&#0010;</xsl:text>
    <xsl:text>&#0009;foaf:name&#0009;"</xsl:text>
    <xsl:value-of select="skos:prefLabel"/>
    <xsl:text>" .&#0010;</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>
