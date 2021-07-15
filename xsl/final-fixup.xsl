<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:local="urn:local-functions"
  xmlns:rsiwp="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  exclude-result-prefixes="xs rsiwp stylemap local relpath xsi"
  version="3.0">
  <!-- ==========================================================================================
       Final Fixup Mode
       
       Base templates for the final-fixup mode. Implement your own final-fixup templates
       to extend or override these base templates.
       
       Copyright (c) 2021 DITA for Publishers
       ========================================================================================== -->

  <xsl:template mode="final-fixup" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] final-fixup: handling <xsl:sequence select="name(.)"/></xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*,node()" mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@id" priority="2">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Override this template to implement specific ID generators -->
    <xsl:variable name="idGenerator" select="string(../@idGenerator)" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$idGenerator = '' or $idGenerator = 'default'">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] final-fixup/@ID: Using default ID generator, returning "<xsl:sequence select="string(.)"/>"</xsl:message>
        </xsl:if>
        <xsl:copy/><!-- Use the base generated ID value. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> - [WARNING] Unrecognized ID generator name "<xsl:sequence select="$idGenerator"/>"</xsl:message>
        <xsl:copy/><!-- Use the base generated ID value. -->
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@idGenerator | @class">
    <!-- Suppress -->
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="text() | processing-instruction()">
    <xsl:copy/>
  </xsl:template>
  
</xsl:stylesheet>