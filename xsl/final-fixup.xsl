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

  <xsl:template mode="final-fixup" match="*" priority="-1">
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
  
  <!-- Convert multi-format phrases produced from the auto-styling process into nested
         phrase-level elements.
      -->
  <xsl:template mode="final-fixup" match="ph[matches(@outputclass, '^(b|i|u|sub|sup)-.+')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message>[DEBUG] final-fixup: Phrase where outputclass matches '^(b|i|u|sub|sup)-.+')': <xsl:sequence select="."/></xsl:message>
    </xsl:if>
    <xsl:variable name="attributes" as="attribute()*">
      <xsl:apply-templates mode="#current" select="@*">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="tokens" as="xs:string+" select="tokenize(@outputclass, '-')"/>
    <xsl:apply-templates select="head($tokens)" mode="final-fixup-format-to-tags">
      <xsl:with-param name="attributes" as="attribute()*" select="$attributes"/>
      <xsl:with-param name="tokens" as="xs:string*" select="tail($tokens)" tunnel="yes"/>
      <xsl:with-param name="content" as="node()*" select="node()" tunnel="yes"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template mode="final-fixup-format-to-tags" match=".[. = ('b','i','u','linethrough','sub','sup')]">
    <xsl:param name="attributes" as="attribute()*"/> 
    <xsl:param name="tokens" as="xs:string*" tunnel="yes"/>
    <xsl:param name="content" as="node()*" tunnel="yes"/>
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">      
      <xsl:message expand-text="true">[DEBUG] final-fixup-format-to-tags: Tokens: ({string-join($tokens, ', ')})</xsl:message>
      <xsl:message expand-text="true">[DEBUG] final-fixup-format-to-tags: Token "{.}" in list of style tokens. Generating new element.</xsl:message>
    </xsl:if>
    
    <xsl:element name="{.}">
      <xsl:sequence select="$attributes[name(.) ne 'outputclass']"/>
      <!-- NOTE: only the first (top-level) element generated will have actual attributes -->
      <xsl:choose>
        <xsl:when test="exists($tokens)">
          <xsl:apply-templates select="head($tokens)" mode="final-fixup-format-to-tags">
            <xsl:with-param name="tokens" as="xs:string*" select="tail($tokens)" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$content"/>
        </xsl:otherwise>
      </xsl:choose>          
    </xsl:element>
  </xsl:template>
  
  <xsl:template mode="final-fixup-format-to-tags" match=".[not(. = ('b','i','u','linethrough','sub','sup'))]">
    <xsl:param name="tokens" as="xs:string*" tunnel="yes"/>
    <xsl:param name="content" as="node()*" tunnel="yes"/>
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">      
      <xsl:message expand-text="true">[DEBUG] final-fixup-format-to-tags: Token "{.}" NOT in list of style tokens. Generating ph element with @outputclass.</xsl:message>
    </xsl:if>
    
    <ph outputclass="{.}">
      <xsl:choose>
        <xsl:when test="exists($tokens)">
          <xsl:apply-templates select="head($tokens)" mode="final-fixup-format-to-tags">
            <xsl:with-param name="tokens" as="xs:string*" select="tail($tokens)" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$content"/>
        </xsl:otherwise>
      </xsl:choose>          
    </ph>
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@id">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Override this template to implement specific ID generators -->
    <xsl:variable name="idGenerator" select="string(../@idGenerator)" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$idGenerator = '' or $idGenerator = 'default'">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] final-fixup/@ID: Using default ID generator, returning "<xsl:sequence select="string(.)"/>"</xsl:message>
        </xsl:if>
        <xsl:sequence select="."/><!-- Use the base generated ID value. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> - [WARNING] Unrecognized ID generator name "<xsl:sequence select="$idGenerator"/>"</xsl:message>
        <xsl:sequence select="."/><!-- Use the base generated ID value. -->
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@idGenerator | @class">
    <!-- Suppress -->
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="@*">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template mode="final-fixup" match="text() | processing-instruction()">
    <xsl:sequence select="."/>
  </xsl:template>
  
</xsl:stylesheet>