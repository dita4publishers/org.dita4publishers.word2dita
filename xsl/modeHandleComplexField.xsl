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
  xmlns="http://reallysi.com/namespaces/generic-wordprocessing-xml"
  
  exclude-result-prefixes="a c pic xs mv mo ve o r m v w10 w wne wp local relpath saxon"
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
    Default handler for unrecognized field types.
    -->
  <xsl:template mode="handleComplexFieldType" match=".[true()]" priority="-1">
    <xsl:param name="runSequence" as="element()*" tunnel="yes" select="()"/>
    <run tagName="draft-comment">{Unsupported complex field type "<xsl:value-of select="."/>":
      <xsl:sequence select="$runSequence"></xsl:sequence>
    }</run>
  </xsl:template>
  
</xsl:stylesheet>