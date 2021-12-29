<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mv="urn:schemas-microsoft-com:mac:vml"
  xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
  xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:rels="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:local="urn:local-functions"
  
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:rsiwp="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  
  exclude-result-prefixes="a c pic xs mv mo ve o r m v w10 w wne wp local relpath saxon map"
  version="3.0">
  
  <!--==========================================
      MS Office 2007 Office Open XML to generic
      XML transform.
      
      Copyright (c) 2009, 2020 DITA For Publishers
      
      Mode handleComplexField 
      
      Implements the process of complex fields.
      
      
      @since Issue 53
      
      =========================================== -->

  <!--
    Handle REF fields:  <w:instrText xml:space="preserve"> REF _Ref53511179 \h </w:instrText>
    
    NOTE: The OOXML reference says that the "REF" keyword can be omitted but I'm going to assume
    that newer versions of Word never do that. The default handler will report an omitted REF
    field since it will be unrecognized.
    
    See 17.16.5.51 REF in OOXML Reference
    -->
  <xsl:template mode="handleComplexFieldType" match=".[lower-case(.) eq 'ref']">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="runSequence" as="element()*" tunnel="yes" select="()"/>
    <xsl:param name="stylesDoc" as="document-node()" tunnel="yes"/>
    <xsl:variable name="fieldType" as="xs:string" select="."/>
    
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] handleComplexFieldType: Handing ref field type...</xsl:message>
    </xsl:if>

    <xsl:variable name="instruction" as="xs:string"
      select="normalize-space(string-join(for $text in $runSequence/w:instrText return string($text), ' '))"
    />
    <xsl:if test="$doDebug">
      <xsl:message expand-text="true">+ [DEBUG] handleComplexFieldType:   instruction: "{$instruction}"</xsl:message>
    </xsl:if>
    <xsl:variable name="separator" as="element()?" select="$runSequence[w:fldChar[@w:fldCharType eq 'separate']]"/>
    <xsl:variable name="end" as="element()?" select="$runSequence[w:fldChar[@w:fldCharType eq 'end']]"/>
    
    <xsl:variable name="targetID" as="xs:string" select="tokenize($instruction)[2]"/>
    <xsl:if test="$doDebug">
      <xsl:message expand-text="yes">+ [DEBUG] handleComplexFieldType {$fieldType}: Flags: /{substring-after($instruction, $targetID) => normalize-space()}/</xsl:message>
    </xsl:if>
    <xsl:variable name="flags" as="map(*)">
      <xsl:variable name="flagTokens" as="xs:string*" select="substring-after($instruction, $targetID) => normalize-space() => tokenize('\\')"/>
      <xsl:if test="$doDebug">
        <xsl:message expand-text="yes">+ [DEBUG] handleComplexFieldType {$fieldType}: flagTokens: '{$flagTokens => string-join("', '")}'</xsl:message>
      </xsl:if>
      <xsl:map>
        <xsl:for-each select="$flagTokens[. ne '']">
          <xsl:if test="$doDebug">
            <xsl:message expand-text="yes">+ [DEBUG] handleComplexFieldType {$fieldType}: token[{position()}]="{.}"</xsl:message>
          </xsl:if>
          <xsl:variable name="tokens" as="xs:string*" select="tokenize(., '\s+')"/>
          <xsl:variable name="flagName" as="xs:string?" select="$tokens[1]"/>
          <xsl:map-entry key="$flagName"><xsl:value-of select="$tokens[position() gt 1] => string-join(' ')"/></xsl:map-entry>
        </xsl:for-each>
      </xsl:map>
    </xsl:variable>
    
    
    <!-- FIXME: Handle more flags as needed -->
    <xsl:choose>
      <xsl:when test="map:contains($flags, 'h')">
        <!-- NOTE: The simple2dita processing will treat this as link to a bookmark because the href value
                   is not an absolute URL.
          -->
        <!-- Issue 48: Look up any style-to-tag mapping for "Hyperlink" -->
        <xsl:variable name="styleName" select="'Hyperlink'"/>
        <xsl:variable name="styleId" select="$styleName"/>
        <xsl:variable name="styleMapByName" as="element()?"
          select="key('styleMapsByName', lower-case($styleName), $styleMapDoc)[1]"
        />
        <xsl:variable name="styleMapById" as="element()?"
          select="key('styleMapsById', $styleId, $styleMapDoc)[1]"
        />
        <xsl:variable name="runStyleMap" as="element()?"
          select="($styleMapByName, $styleMapById)[1]"
        />        
        <hyperlink href="{$targetID}"
          styleId="Hyperlink"
          structureType="xref"
          tagName="xref"
        >
          <!-- NOTE: Any of @structureType or @tagName from the style map will override the 
                     values set above on the <hyperlink> element. See https://www.w3.org/TR/xslt-30/#attributes-for-lres -->
          <xsl:sequence select="$runStyleMap/@*, $runStyleMap/stylemap:additionalAttributes"/>
        </hyperlink>
      </xsl:when>
      <xsl:otherwise>
        <!-- Not a hyperlink. Not sure what to do. -->
        <run tagName="ph">{complex field "REF" that is not a hyperlink. Original instruction: <xsl:value-of select="$instruction"/>}</run>
      </xsl:otherwise>
    </xsl:choose>
    <!-- The content of the reference is generated but it's useful to capture what was there: -->
    <xsl:if test="exists($separator)">
      <run tagName="draft-comment"> Original resolved ref content:&#x0a;<xsl:value-of select="$runSequence[. &gt;&gt; $separator][. &lt;&lt; $end] => string-join('') => normalize-space()"/></run>
    </xsl:if>
  </xsl:template>
  
  <!--
    Default handler for unrecognized field types.
    -->
  <xsl:template mode="handleComplexFieldType" match=".[true()]" priority="-1">
    <xsl:param name="runSequence" as="element()*" tunnel="yes" select="()"/>
    <run tagName="draft-comment">{Unsupported complex field type "<xsl:value-of select="."/>":
      <xsl:sequence select="$runSequence"></xsl:sequence>
    }</run>
  </xsl:template>
  
</xsl:stylesheet>