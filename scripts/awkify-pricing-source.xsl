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
    <xsl:text>BEGIN {&#0010;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#0010;</xsl:text>
  </xsl:template>

  <xsl:template match="owl:NamedIndividual">
    <xsl:text>&#0009;bps["</xsl:text>
    <xsl:value-of select="figi-gii:hasUniqueTextIdentifier"/>
    <xsl:text>"] = "</xsl:text>
    <xsl:value-of select="figi-gii:hasUniqueTextIdentifier"/>
    <xsl:text>";&#0010;</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>
