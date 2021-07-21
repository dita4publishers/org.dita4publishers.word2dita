<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:idPkg="http://ns.adobe.com/AdobeInDesign/idml/1.0/packaging"
  xmlns:local="urn:local-functions"  
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:wpml="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  
  exclude-result-prefixes="local relpath saxon map idPkg"
  version="3.0">
  
  <!-- =======================================================================
     Load IDML Package
     
     Brings all the IDML content into a single document 
     ======================================================================= -->
  
  <xsl:mode name="i2s-load-idml-package"
    on-no-match="shallow-copy"   
  />
  
  <xsl:template match="Document" mode="i2s-load-idml-package" as="document-node()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-load-idml-package: Starting...</xsl:message>
    </xsl:if>
    <xsl:document>
      <xsl:copy>
        <xsl:attribute name="xml:base" select="base-uri(.)"/>
        <xsl:apply-templates select="@*, node()" mode="#current">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:document>
  </xsl:template>
  
  <xsl:template mode="i2s-load-idml-package" match="idPkg:*[@src]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug" expand-text="yes">
      <xsl:message>+ [DEBUG] i2s-load-idml-package: Handling {name(.)}: src="{@src}"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="content" as="node()*"
      select="document(@src, root(.))/*"
    />
    <xsl:copy select="$content">
      <xsl:attribute name="xml:base" select="base-uri($content[1])"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  
</xsl:stylesheet>