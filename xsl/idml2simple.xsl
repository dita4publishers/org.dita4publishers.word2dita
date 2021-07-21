<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  
  xmlns:local="urn:local-functions"
  
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:wpml="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  
  exclude-result-prefixes="local relpath saxon map"
  version="3.0">
  
  <xsl:import href="i2s-gather-article-content.xsl"/>
  <xsl:import href="i2s-load-idml-package.xsl"/>
  
  <xsl:key name="formats" match="stylemap:output" use="@name"/>
  <xsl:key name="styleMapsById" 
    match="stylemap:style | stylemap:paragraphStyle | stylemap:characterStyle"
    use="@styleId"
  />
  <xsl:key name="styleMapsByName" 
    match="stylemap:style | stylemap:paragraphStyle | stylemap:characterStyle"
    use="lower-case(@styleName)"
  />
  <xsl:key name="stylesByName" match="Style" use="@styleName"/>
  
  <xsl:key name="elementsBySelf" match="*[@Self]" use="@Self"/>
  
  <xsl:variable name="styleMapDoc" as="document-node()"
    select="document($styleMapUri)"
  />
  
  <xsl:mode name="idml2simple"
    on-no-match="shallow-skip"
  />
  
  
  <xsl:template match="/" name="processDesignMapXML">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- The Document element is in the root of the IDML package.
      
         It contains any Article elements.
         
      -->
    <xsl:message> + [INFO] idml2simple: Starting...</xsl:message>

    <xsl:if test="empty(/*/Article)">
      <xsl:message terminate="yes">- [WARN] No Article elements in designmap.xml, cannot continue.</xsl:message>
    </xsl:if>
    
    <!-- Pull the contents of the IDML package into a single document for convenience
      -->
    <xsl:variable name="idmlPackage" as="document-node()">
      <xsl:apply-templates select="/Document" mode="i2s-load-idml-package">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:variable name="doDebug" as="xs:boolean" select="true() or $doDebug"/>
    
    <xsl:variable name="articles" as="element(Article)*"
      select="$idmlPackage/*/Article"
    />
        
    <document
      sourceDoc="{document-uri(.)}"
      >
      <body>
        <xsl:apply-templates select="$articles" mode="idml2simple">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </body>
    </document>
    <xsl:message> + [INFO] idml2simple: Intermediate simpleML document generated.</xsl:message>
    
  </xsl:template>
  
  <!--
     Each article relates a set of stories into a sequence, defining the reading order.
     
     To make this easier to handle, we first process the story sequence to gather all
     the content and then process that.
     -->
  <xsl:template match="Article" mode="idml2simple">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="articleContent" as="node()*">
      <xsl:apply-templates select="." mode="i2s-gather-article-content">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:apply-templates select="$articleContent" mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template mode="idml2simple" match="ParagraphStyleRange">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="styleId" as="xs:string"
      select="tokenize(@AppliedParagraphStyle, '/')[2]"
    />
    <!-- <ParagraphStyleRange AppliedParagraphStyle="ParagraphStyle/Z_Original%3aoverset"> -->
    <p style="{$styleId}">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </p>
    
  </xsl:template>
  
  <xsl:template mode="idml2simple" match="CharacterStyleRange">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        
    <xsl:variable name="styleId" as="xs:string?"
      select="tokenize(@AppliedCharacterStyle, '/')[last()]"
    />
    <!-- <CharacterStyleRange AppliedCharacterStyle="CharacterStyle/$ID/[No character style]"> -->
    <run style="{$styleId}">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </run>
    
  </xsl:template>
  
  <xsl:template mode="idml2simple" match="Content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:value-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>