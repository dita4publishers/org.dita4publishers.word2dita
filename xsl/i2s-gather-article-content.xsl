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
  expand-text="yes"
  exclude-result-prefixes="local relpath saxon map"
  version="3.0">

<!-- =======================================================================
     Gather article content
     
     Gathers all the content of an article into a single sequence of content
     objects.
     ======================================================================= -->
  
  <xsl:mode name="i2s-copy-article-content"
    on-no-match="shallow-copy"
  />
  
  <xsl:template match="Article" mode="i2s-gather-article-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="doDebug" as="xs:boolean" select="true() or $doDebug"/>

    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-gather-article-content: Starting...</xsl:message>
    </xsl:if>
    
    <xsl:apply-templates mode="#current" select="ArticleMember">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-gather-article-content: Done.</xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ArticleMember" mode="i2s-gather-article-content">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-gather-article-content: ArticleMember, ItemRef="{@ItemRef}"</xsl:message>
    </xsl:if>
    
    <!-- <ArticleMember Self="u14344ArticleMember0" ItemRef="uff00"/> -->
    <xsl:variable name="textFrame" as="element()?" select="key('elementsBySelf', @ItemRef, root(.))"/>
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-gather-article-content:   textFrame:
<xsl:sequence select="$textFrame"/>      
      </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="$textFrame" mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="i2s-gather-article-content" match="TextFrame">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] i2s-gather-article-content: TextFrame, ParentStory="{@ParentStory}"</xsl:message>
    </xsl:if>
    
    <!-- <TextFrame Self="uff00" ParentStory="uff03" -->
    
    <xsl:variable name="story" as="element()?"
      select="key('elementsBySelf', @ParentStory, root(.))"
    />
    
    <xsl:apply-templates select="$story" mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template mode="i2s-gather-article-content" match="Story">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates mode="i2s-copy-article-content">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
</xsl:stylesheet>