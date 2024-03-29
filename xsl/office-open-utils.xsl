<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:ooutil="http://dita4publishers.org/ns/office-open-utilities"
  xmlns:sheet="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
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
  xmlns:local="urn:local-functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd ooutil mv mo ve o r m v w10 w wne wp pic a rels c local relpath"
  version="3.0">
  <!-- ============================================================ 
    Utilities for operating on Microsoft Office Office Open files.
    
    =============================================================== -->
    
   <xsl:key name="relsById" match="rels:Relationship" use="@Id"/>

    <xsl:function name="ooutil:resolveSharedString" as="xs:string">
      <xsl:param name="vElement" as="element(sheet:v)"/>
      <xsl:variable name="sharedStringsDoc" as="document-node()?"
        select="ooutil:getSharedStringsDoc($vElement)"
      />
<!--      <xsl:message> + [DEBUG] ooutil:resolveSharedString: $sharedStringsDoc = <xsl:sequence select="boolean($sharedStringsDoc)"/></xsl:message>-->
      <!-- NOTE: value is zero-based index into the shared string table. -->
      <xsl:variable name="index0Based" as="xs:integer" select="$vElement"/>
<!--      <xsl:message> + [DEBUG] ooutil:resolveSharedString: index = <xsl:sequence select="$index0Based"/></xsl:message>-->
      <xsl:variable name="index1Based" as="xs:integer" select="$index0Based + 1"/>
      <xsl:variable name="siElem" as="element()?"
        select="$sharedStringsDoc/*/*[$index1Based]"
      />
<!--      <xsl:message> + [DEBUG] ooutil:resolveSharedString: siElem = <xsl:sequence select="$siElem"/></xsl:message>-->
      
      <xsl:variable name="result" as="xs:string" select="string($siElem)"/>
      <xsl:sequence select="$result"/>
    </xsl:function>
    
  <xsl:function name="local:getRunStyleId" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="baseStyle" as="xs:string?">
      <xsl:apply-templates select="$context" mode="local:getRunStyleId"/>
    </xsl:variable>
    <xsl:variable name="formatOverrideString" as="xs:string?" select="local:getFormatOverrideString($context)"/>
    <xsl:variable name="candStyle" as="xs:string?"
      select="
      if (exists($baseStyle) and $baseStyle ne '')
      then $baseStyle
      else if (exists($formatOverrideString) and $formatOverrideString ne '')
      then 'FormattedRun'
      else ()
      "
    />
    <xsl:variable name="result" as="xs:string"
      select="($candStyle, '')[1]"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:template mode="local:getRunStyleId" match="w:rPr/w:rStyle" as="xs:string">
      <xsl:sequence select="(string(@w:val), '')[1]"/>
  </xsl:template>

  <xsl:template mode="local:getRunStyleId" match="w:rPr[empty(w:rStyle)]" as="xs:string">
    <xsl:variable name="styleTokens" as="xs:string*">
      <!-- Ensure that we generate style names in a consistent order -->
      <xsl:apply-templates mode="local:getRunStyleId-styleTokens" 
        select="w:b, w:i, w:u, w:vertAlign, w:strike, w:* except (w:b, w:i, w:u, w:vertAlign, w:strike)"/>
    </xsl:variable>
    <xsl:sequence select="string-join($styleTokens, '-')"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:b" as="xs:string">
    <xsl:sequence select="'b'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:i" as="xs:string">
    <xsl:sequence select="'i'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:strike" as="xs:string">
    <xsl:sequence select="'linethrough'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:u" as="xs:string">
    <xsl:sequence select="'u'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:vertAlign[@w:val='subscript']" as="xs:string">
    <xsl:sequence select="'sub'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId-styleTokens" match="w:vertAlign[@w:val='superscript']" as="xs:string">
    <xsl:sequence select="'sup'"/>
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId" match="text()" as="xs:string?" priority="-1">
    <!-- Don't copy text in this mode -->
  </xsl:template>
  
  <xsl:template mode="local:getRunStyleId" match="*" as="xs:string?" priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:function name="ooutil:getSharedStringsDoc" as="document-node()?">
    <xsl:param name="context" as="element()"/>    
    <!-- Context should be an element within a sheet -->

    <xsl:variable name="sharedStringsURI" as="xs:string"
      select="relpath:newFile(relpath:getParent(relpath:getParent(document-uri(root($context)))), 'sharedStrings.xml')"
    />
    <xsl:variable name="resultDoc" as="document-node()?"
      select="document($sharedStringsURI)"
    />    
    <xsl:sequence select="$resultDoc"/>
  </xsl:function>
  
  <xsl:function name="local:getHyperlinkStyle" as="xs:string">
    <!-- Hyperlinks don't have a directly-associated style but 
         should contain at least one text run. So we use
         the first text run as the hyperlink style to determine
         the hyperlink style.
      -->
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="
      if ($context/w:r[1]/w:rPr/w:rStyle) 
      then string($context/w:r[1]/w:rPr/w:rStyle/@w:val)
      else ''
      "/>
  </xsl:function>
  
  <xsl:function name="local:getParaStyleId" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="mapUnstyledParasTo" as="xs:string"/>
    <xsl:sequence select="
      if ($context/w:pPr/w:pStyle) 
         then string($context/w:pPr/w:pStyle/@w:val)
         else $mapUnstyledParasTo
      "/>
  </xsl:function>
  
  <xsl:function name="local:lookupStyleName" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="stylesDoc" as="document-node()"/>
    <xsl:param name="styleId" as="xs:string"/>
    <xsl:variable name="styleElem" as="element()?"
      select="key('stylesById', $styleId, $stylesDoc)[1]"
    />
    <xsl:choose>
      <xsl:when test="$styleElem">
         <xsl:variable name="styleName" as="xs:string"
           select="$styleElem/w:name/@w:val"/>
         <xsl:sequence select="$styleName"/>        
      </xsl:when>
      <xsl:when test="$styleId = ('entry')">
        <!-- There are no default styles for table entries, so no need to say anything. -->
        <xsl:sequence select="$styleId"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> + [WARN] lookupStyleName(): No style definition found for style ID "<xsl:sequence select="$styleId"/>"</xsl:message>
        <xsl:sequence select="$styleId"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
  
</xsl:stylesheet>