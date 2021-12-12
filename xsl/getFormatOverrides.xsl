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
  
  xmlns:local="urn:local-functions"
  
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:rsiwp="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:swpx="urn:ns:wordinator:simplewpml"
  xmlns="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  expand-text="true"
  exclude-result-prefixes="a c pic xs mv mo ve o r m v w10 w wne wp local relpath saxon map swpx"
  version="3.0">
  
  <!--==========================================
      MS Office 2007 Office Open XML to generic
      XML transform.
      
      Copyright (c) 2009, 2021 DITA For Publishers
      
      Mode refine-style-map
      
      Adds local format overrides to simple wordprocessing markup.
      
      Issue 79: Module created
      
      =========================================== -->

  <xsl:mode name="get-format-overrides"
  />
  
  <xsl:template mode="get-format-overrides" match="w:p">
    <xsl:if test="$captureFormatOverrides">
      <xsl:apply-templates select="w:pPr" mode="#current"/>      
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:r">
    <xsl:if test="$captureFormatOverrides">
      <xsl:apply-templates select="w:rPr" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <!-- NOTE: Don't process w:rPr that may be within w:pPr -->
  <xsl:template mode="get-format-overrides" match="w:pPr | w:r/w:rPr">
    <formatOverrides>
      <xsl:apply-templates mode="#current"/>
    </formatOverrides>

    <!--
      <w:pPr>
        <w:ind w:left="432"/>
        <w:jc w:val="center"/>
        <w:rPr>
          <w:b/>0
          <w:bCs/>
          <w:i/>
          <w:iCs/>
        </w:rPr>
      </w:pPr>
      -->
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" 
    match="w:ind">
    <xsl:apply-templates select="@*" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides"
    match="
    w:ind/@w:end | 
    w:ind/@w:firstLine | 
    w:ind/@w:hanging | 
    w:ind/@w:left | 
    w:ind/@w:start">

<!--    <xsl:message>+ [DEBUG] get-format-overrides: Handling {name(..)}/@{name(.)}...</xsl:message>-->
    
    <formatProperty name="indent-{local-name(.)}"
      value="{number(.) div 20.0}pt"
      datatype="pt"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" 
    match="
    w:ind/@w:endChars |
    w:ind/@w:firstLineChars |
    w:ind/@w:hangingChars
    "
    >

<!--    <xsl:message>+ [DEBUG] get-format-overrides: Handling {name(..)}/@{name(.)}...</xsl:message>-->
    
    <xsl:variable name="rawValue" as="xs:double"
      select="."      
    />
    <!-- Convert 100ths of character with to character width -->
    <formatProperty name="indent-{local-name(.)}"
      value="{$rawValue div 100}"
      datatype="em"
    />
  </xsl:template>


  <xsl:template mode="get-format-overrides" 
    match="w:color"
    >
    
    <!--    <xsl:message>+ [DEBUG] get-format-overrides: Handling {name(..)}/{name(.)}...</xsl:message>-->
    
    <formatProperty name="color"
      value="{@w:val}"
      datatype="color"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" 
    match="w:jc"
    >
    
<!--    <xsl:message>+ [DEBUG] get-format-overrides: Handling {name(..)}/{name(.)}...</xsl:message>-->
    
    <formatProperty name="justification"
      value="{@w:val}"
      datatype="enum"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:shd">
  <!-- 
  <w:shd w:val="pct20" w:themeColor="accent6" w:themeFill="accent3" />
  -->
    <xsl:apply-templates mode="#current" select="@*"/>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:shd/@*">
    <formatProperty name="shade-{local-name(.)}"
      value="{.}"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:outlineLvl">
    <formatProperty name="outlineLevel"
      value="{@w:val}"
      datatype="integer"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:vertAlign">
    <formatProperty name="valign"
      value="{@w:val}"
      datatype="enum"
    />
  </xsl:template>
  
  <!-- Expand/compress -->
  <xsl:template mode="get-format-overrides" match="w:w">
    <formatProperty name="characterspacing"
      value="{@w:val}"
      datatype="percentage"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:u">
    <xsl:apply-templates mode="#current" select="@*"/>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:u/@w:val" priority="10">
    <formatProperty name="underlineStyle"
      value="{.}"
      datatype="enum"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:u/@w:*">
    <xsl:variable name="propertyName" as="xs:string"
      select="upper-case(substring(local-name(.), 1,1)) || substring(local-name(.), 2)"
    />
    <formatProperty name="underline{$propertyName}"
      value="{.}"
      datatype="color"
    />
  </xsl:template>
  
  
  
  <!-- Style specs that are just flags, i.e., w:strike -->
  <xsl:template mode="get-format-overrides" match="w:strike | w:vanish">
    <formatProperty name="{local-name(.)}"
      value="true"
      datatype="toggle"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:framePr">
    <xsl:apply-templates mode="#current" select="@*"/>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:framePr/@*">
    <formatProperty name="frame-{local-name(.)}"
      value="{.}"
    />
  </xsl:template>

  <xsl:template mode="get-format-overrides" 
    match="
    w:highlight |
    w:pageBreakBefore |
    w:textAlignment |
    w:textDirection |
    w:wordWrap
    ">
    <formatProperty name="{local-name(.)}"
      value="{@w:val}"
    />
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="text()">
    <!-- We never want text in this mode -->
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="w:*" priority="-1">
<!--    <xsl:message>+ [DEBUG] get-format-overrides: Fallback for {name(.)}...</xsl:message>-->
    
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="get-format-overrides" match="@*" priority="-1">
<!--    <xsl:message>+ [DEBUG] get-format-overrides: Fallback for @{name(.)}...</xsl:message>-->
    
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
</xsl:stylesheet>