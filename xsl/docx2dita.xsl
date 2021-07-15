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
version="2.0">

  <xsl:import href="../../org.dita-community.common.xslt/xsl/relpath_util.xsl"/>
  
  <xd:doc
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    scope="stylesheet">
    <xd:desc>
      <xd:p>DOCX to DITA generic transformation</xd:p>
      <xd:p>Copyright (c) 2009, 2013 DITA For Publishers, Inc.</xd:p>
      <xd:p>Transforms a DOCX document.xml file into a DITA topic using a style-to-tag mapping. </xd:p>
      <xd:p>This transform is intended to be the base for more specialized transforms that provide
        style-specific overrides. The input to this transform is the document.xml file within a DOCX
        package. </xd:p>
      <xd:p>Originally developed by Really Strategies, Inc.</xd:p>
    </xd:desc>
  </xd:doc>
  <!--==========================================
    DOCX to DITA generic transformation
    
    Copyright (c) 2009, 2012 DITA For Publishers, Inc.

    Transforms a DOCX document.xml file into a DITA topic using
    a style-to-tag mapping.
    
    This transform is intended to be the base for more specialized
    transforms that provide style-specific overrides.
    
    The input to this transform is the document.xml file within a DOCX
    package.
    
    
    Originally developed by Really Strategies, Inc.
    
    =========================================== -->
  
  
  <xsl:param name="styleMapUri" as="xs:string"/>
  <xsl:param name="mediaDirUri" select="relpath:newFile($outputDir, 'topics/media')" as="xs:string"/>  
  <xsl:param name="outputDir" as="xs:string"/>
  <xsl:param name="rootTopicName" as="xs:string?" select="()"/>
  <xsl:param name="rootMapName" as="xs:string" select="$rootTopicName"/>
  <xsl:param name="submapNamePrefix" as="xs:string" select="'map'"/>
  <xsl:param name="filterBr" as="xs:string" select="'false'"/>
  <xsl:param name="filterTabs" as="xs:string" select="'false'"/>
  <xsl:param name="includeWordBackPointers" as="xs:string" select="'true'"/>
  <!-- When true, include <data> elements that reflect Word bookmark start and end markers -->
  <xsl:param name="includeWordBookmarks" as="xs:string" select="'false'"/>
  <xsl:param name="language" as="xs:string" select="'en-US'"/>
  
  <xsl:param name="topicExtension" select="'.dita'" as="xs:string"/><!-- Extension for generated topic files -->
  <xsl:param name="fileNamePrefix" select="''" as="xs:string"/><!-- Prefix for genenerated file names -->
  <xsl:param name="chartsAsTables" select="'false'" as="xs:string"/><!-- When true, capture Word charts as tables with the chart data -->
  <xsl:variable name="chartsAsTablesBoolean" as="xs:boolean" 
    select="matches($chartsAsTables, 'true|yes|on|1', 'i')"/>

  <xsl:param name="tableWidthsProportional" as="xs:string" select="'false'"/>
  <xsl:variable name="tableWidthsProportionalBoolean" as="xs:boolean"
    select="matches($tableWidthsProportional, 'true|yes|on|1', 'i')"
  />  
  
  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/>
  
  <!-- Because MathML container will be different in DITA 1.3, we need to allow for setting the
    intended version. The version is noted in the topic shells, but we cannot access that info
  from within XSLT/XPATH. Default value is 1.2. -->
  <xsl:param name="ditaVersion" select="'1.2'" as="xs:string" />
  
  <!-- Because we only have differences between DITA 1.2 and DITA 1.3 (right now), if $ditaVersion is
    not 1.3, then assume 1.2 -->
  <xsl:variable name="isDita12" as="xs:boolean" select="if ($ditaVersion ne '1.3') then true() else false()" />
  
  <xsl:variable name="isDita13" as="xs:boolean" select="if ($ditaVersion = ('1.3')) then true() else false()" />
  
  <!-- When true, use any external (linked) filename as the name for referenced graphics,
       rather than the internal names. Note that tools that deal with the graphic files
       extracted from the DOCX file will have to know how the internal names map to external
       names (which they can know by examining the word/_rels/document.xml.rels file in the
       package).
    -->
  <xsl:param name="useLinkedGraphicNames" as="xs:string" select="'no'"/>
  <xsl:variable name="useLinkedGraphicNamesBoolean" as="xs:boolean" 
    select="matches($useLinkedGraphicNames, 'yes|true|1', 'i')"
  />
  
  <!-- Prefix to add to image filenames when constructing image references
       in the result XML.
    -->
  <xsl:param name="imageFilenamePrefix" as="xs:string?"
    select="$fileNamePrefix"
  />
  
  <!-- If true, issue warnings about unstyled paragraphs. Unstyled paragraphs
       map to <p> by default.
    -->
  <xsl:param name="warnOnUnstyledParas" as="xs:string" select="'false'"/>
  <xsl:variable name="warnOnUnstyledParasBoolean"
     select="matches($warnOnUnstyledParas, 'yes|true|1', 'i')"
  />
  
  <!-- When true, use topic titles as navigation titles in generated
       topicrefs.
    -->
  <xsl:param name="generateNavtitles" as="xs:string" select="'true'"/>
  <xsl:variable name="generateNavtitlesBoolean"
     select="matches($generateNavtitles, 'yes|true|1', 'i')"
  />

  <xsl:param
    name="debug"
    select="'false'"
    as="xs:string"/>
  <xsl:variable
    name="debugBoolean"
    as="xs:boolean"
    select="matches($debug, 'true|yes|1|on', 'i')"/>
  
  <xsl:param name="saveIntermediateDocs" as="xs:string" select="'false'"/>
  <xsl:variable name="doSaveIntermediateDocs" as="xs:boolean" 
    select="$debugBoolean or matches($saveIntermediateDocs, 'true|yes|1|on', 'i')"
  />  
  
  <!-- Ensure that the root topic name has a value. -->
  <xsl:variable name="finalRootTopicName" as="xs:string"
       select="if ($rootTopicName)
                  then $rootTopicName
                  else if ($rootMapName)
                          then $rootMapName
                          else 'root-topic'"
  />

  <xsl:variable name="rootMapUrl" select="concat($rootMapName, '.ditamap')" as="xs:string"/>
  <xsl:variable name="rootTopicUrl" 
    as="xs:string?" 
    select="concat($finalRootTopicName, $topicExtension)"/>
  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or 
    starts-with($rawPlatformString, 'Win'))
    then 'windows'
    else 'nx'
    "
  />
  
  <xsl:variable name="filterTabsBoolean" as="xs:boolean" select="matches($filterTabs, 'yes|true|1', 'i')"/>
  <xsl:variable name="filterBrBoolean" as="xs:boolean" select="matches($filterBr, 'yes|true|1', 'i')"/>
  <xsl:variable name="includeWordBackPointersBoolean" as="xs:boolean" 
    select="matches($includeWordBackPointers, 'yes|true|1', 'i')"/>
  
  <xsl:variable name="includeWordBookmarksBoolean" as="xs:boolean" 
    select="matches($includeWordBookmarks, 'yes|true|1', 'i')"/>
  
  <!-- To make it easy to get to the original input doc later -->
  <xsl:variable name="documentXML" as="document-node()" select="root(.)"/>
  
  <!-- Characters that map to the Symbols font in Word. -->
  <xsl:character-map name="symbols" xmlns="http://www.w3.org/1999/XSL/Transform">
      <output-character character="&#xF020;" string="&#x0020;"/>
      <output-character character="&#xF021;" string="&#x0021;"/>
      <output-character character="&#xF022;" string="&#x2200;"/>
      <output-character character="&#xF023;" string="&#x0023;"/>
      <output-character character="&#xF024;" string="&#x2203;"/>
      <output-character character="&#xF025;" string="&#x0025;"/>
      <output-character character="&#xF026;" string="&#x0026;"/>
      <output-character character="&#xF027;" string="&#x220B;"/>
      <output-character character="&#xF028;" string="&#x0028;"/>
      <output-character character="&#xF029;" string="&#x0029;"/>
      <output-character character="&#xF02A;" string="&#x2217;"/>
      <output-character character="&#xF02B;" string="&#x002B;"/>
      <output-character character="&#xF02C;" string="&#x002C;"/>
      <output-character character="&#xF02D;" string="&#x2212;"/>
      <output-character character="&#xF02E;" string="&#x002E;"/>
      <output-character character="&#xF02F;" string="&#x002F;"/>
      <output-character character="&#xF030;" string="&#x0030;"/>
      <output-character character="&#xF031;" string="&#x0031;"/>
      <output-character character="&#xF032;" string="&#x0032;"/>
      <output-character character="&#xF033;" string="&#x0033;"/>
      <output-character character="&#xF034;" string="&#x0034;"/>
      <output-character character="&#xF035;" string="&#x0035;"/>
      <output-character character="&#xF036;" string="&#x0036;"/>
      <output-character character="&#xF037;" string="&#x0037;"/>
      <output-character character="&#xF038;" string="&#x0038;"/>
      <output-character character="&#xF039;" string="&#x0039;"/>
      <output-character character="&#xF03A;" string="&#x003A;"/>
      <output-character character="&#xF03B;" string="&#x003B;"/>
      <output-character character="&#xF03C;" string="&#x003C;"/>
      <output-character character="&#xF03D;" string="&#x003D;"/>
      <output-character character="&#xF03E;" string="&#x003E;"/>
      <output-character character="&#xF03F;" string="&#x003F;"/>
      <output-character character="&#xF040;" string="&#x2245;"/>
      <output-character character="&#xF041;" string="&#x0391;"/>
      <output-character character="&#xF042;" string="&#x0392;"/>
      <output-character character="&#xF043;" string="&#x03A7;"/>
      <output-character character="&#xF044;" string="&#x0394;"/>
      <output-character character="&#xF045;" string="&#x0395;"/>
      <output-character character="&#xF046;" string="&#x03A6;"/>
      <output-character character="&#xF047;" string="&#x0393;"/>
      <output-character character="&#xF048;" string="&#x0397;"/>
      <output-character character="&#xF049;" string="&#x0399;"/>
      <output-character character="&#xF04A;" string="&#x03D1;"/>
      <output-character character="&#xF04B;" string="&#x039A;"/>
      <output-character character="&#xF04C;" string="&#x039B;"/>
      <output-character character="&#xF04D;" string="&#x039C;"/>
      <output-character character="&#xF04E;" string="&#x039D;"/>
      <output-character character="&#xF04F;" string="&#x039F;"/>
      <output-character character="&#xF050;" string="&#x03A0;"/>
      <output-character character="&#xF051;" string="&#x0398;"/>
      <output-character character="&#xF052;" string="&#x03A1;"/>
      <output-character character="&#xF053;" string="&#x03A3;"/>
      <output-character character="&#xF054;" string="&#x03A4;"/>
      <output-character character="&#xF055;" string="&#x03A5;"/>
      <output-character character="&#xF056;" string="&#x03C2;"/>
      <output-character character="&#xF057;" string="&#x03A9;"/>
      <output-character character="&#xF058;" string="&#x039E;"/>
      <output-character character="&#xF059;" string="&#x03A8;"/>
      <output-character character="&#xF05A;" string="&#x0396;"/>
      <output-character character="&#xF05B;" string="&#x005B;"/>
      <output-character character="&#xF05C;" string="&#x2234;"/>
      <output-character character="&#xF05D;" string="&#x005D;"/>
      <output-character character="&#xF05E;" string="&#x22A5;"/>
      <output-character character="&#xF05F;" string="&#x005F;"/>
      <output-character character="&#xF060;" string="&#xF8E5;"/>
      <output-character character="&#xF061;" string="&#x03B1;"/>
      <output-character character="&#xF062;" string="&#x03B2;"/>
      <output-character character="&#xF063;" string="&#x03C7;"/>
      <output-character character="&#xF064;" string="&#x03B4;"/>
      <output-character character="&#xF065;" string="&#x03B5;"/>
      <output-character character="&#xF066;" string="&#x03C6;"/>
      <output-character character="&#xF067;" string="&#x03B3;"/>
      <output-character character="&#xF068;" string="&#x03B7;"/>
      <output-character character="&#xF069;" string="&#x03B9;"/>
      <output-character character="&#xF06A;" string="&#x03D5;"/>
      <output-character character="&#xF06B;" string="&#x03BA;"/>
      <output-character character="&#xF06C;" string="&#x03BB;"/>
      <output-character character="&#xF06D;" string="&#x03BC;"/>
      <output-character character="&#xF06E;" string="&#x03BD;"/>
      <output-character character="&#xF06F;" string="&#x03BF;"/>
      <output-character character="&#xF070;" string="&#x03C0;"/>
      <output-character character="&#xF071;" string="&#x03B8;"/>
      <output-character character="&#xF072;" string="&#x03C1;"/>
      <output-character character="&#xF073;" string="&#x03C3;"/>
      <output-character character="&#xF074;" string="&#x03C4;"/>
      <output-character character="&#xF075;" string="&#x03C5;"/>
      <output-character character="&#xF076;" string="&#x03D6;"/>
      <output-character character="&#xF077;" string="&#x03C9;"/>
      <output-character character="&#xF078;" string="&#x03BE;"/>
      <output-character character="&#xF079;" string="&#x03C8;"/>
      <output-character character="&#xF07A;" string="&#x03B6;"/>
      <output-character character="&#xF07B;" string="&#x007B;"/>
      <output-character character="&#xF07C;" string="&#x007C;"/>
      <output-character character="&#xF07D;" string="&#x007D;"/>
      <output-character character="&#xF07E;" string="&#x223C;"/>
      <output-character character="&#xF0A0;" string="&#x20AC;"/>
      <output-character character="&#xF0A1;" string="&#x03D2;"/>
      <output-character character="&#xF0A2;" string="&#x2032;"/>
      <output-character character="&#xF0A3;" string="&#x2264;"/>
      <output-character character="&#xF0A4;" string="&#x2044;"/>
      <output-character character="&#xF0A5;" string="&#x221E;"/>
      <output-character character="&#xF0A6;" string="&#x0192;"/>
      <output-character character="&#xF0A7;" string="&#x2663;"/>
      <output-character character="&#xF0A8;" string="&#x2666;"/>
      <output-character character="&#xF0A9;" string="&#x2665;"/>
      <output-character character="&#xF0AA;" string="&#x2660;"/>
      <output-character character="&#xF0AB;" string="&#x2194;"/>
      <output-character character="&#xF0AC;" string="&#x2190;"/>
      <output-character character="&#xF0AD;" string="&#x2191;"/>
      <output-character character="&#xF0AE;" string="&#x2192;"/>
      <output-character character="&#xF0AF;" string="&#x2193;"/>
      <output-character character="&#xF0B0;" string="&#x00B0;"/>
      <output-character character="&#xF0B1;" string="&#x00B1;"/>
      <output-character character="&#xF0B2;" string="&#x2033;"/>
      <output-character character="&#xF0B3;" string="&#x2265;"/>
      <output-character character="&#xF0B4;" string="&#x00D7;"/>
      <output-character character="&#xF0B5;" string="&#x221D;"/>
      <output-character character="&#xF0B6;" string="&#x2202;"/>
      <output-character character="&#xF0B7;" string="&#x2022;"/>
      <output-character character="&#xF0B8;" string="&#x00F7;"/>
      <output-character character="&#xF0B9;" string="&#x2260;"/>
      <output-character character="&#xF0BA;" string="&#x2261;"/>
      <output-character character="&#xF0BB;" string="&#x2248;"/>
      <output-character character="&#xF0BC;" string="&#x2026;"/>
      <output-character character="&#xF0BD;" string="&#xF8E6;"/>
      <output-character character="&#xF0BE;" string="&#xF8E7;"/>
      <output-character character="&#xF0BF;" string="&#x21B5;"/>
      <output-character character="&#xF0C0;" string="&#x2135;"/>
      <output-character character="&#xF0C1;" string="&#x2111;"/>
      <output-character character="&#xF0C2;" string="&#x211C;"/>
      <output-character character="&#xF0C3;" string="&#x2118;"/>
      <output-character character="&#xF0C4;" string="&#x2297;"/>
      <output-character character="&#xF0C5;" string="&#x2295;"/>
      <output-character character="&#xF0C6;" string="&#x2205;"/>
      <output-character character="&#xF0C7;" string="&#x2229;"/>
      <output-character character="&#xF0C8;" string="&#x222A;"/>
      <output-character character="&#xF0C9;" string="&#x2283;"/>
      <output-character character="&#xF0CA;" string="&#x2287;"/>
      <output-character character="&#xF0CB;" string="&#x2284;"/>
      <output-character character="&#xF0CC;" string="&#x2282;"/>
      <output-character character="&#xF0CD;" string="&#x2286;"/>
      <output-character character="&#xF0CE;" string="&#x2208;"/>
      <output-character character="&#xF0CF;" string="&#x2209;"/>
      <output-character character="&#xF0D0;" string="&#x2220;"/>
      <output-character character="&#xF0D1;" string="&#x2207;"/>
      <output-character character="&#xF0D2;" string="&#xF6DA;"/>
      <output-character character="&#xF0D3;" string="&#xF6D9;"/>
      <output-character character="&#xF0D4;" string="&#xF6DB;"/>
      <output-character character="&#xF0D5;" string="&#x220F;"/>
      <output-character character="&#xF0D6;" string="&#x221A;"/>
      <output-character character="&#xF0D7;" string="&#x22C5;"/>
      <output-character character="&#xF0D8;" string="&#x00AC;"/>
      <output-character character="&#xF0D9;" string="&#x2227;"/>
      <output-character character="&#xF0DA;" string="&#x2228;"/>
      <output-character character="&#xF0DB;" string="&#x21D4;"/>
      <output-character character="&#xF0DC;" string="&#x21D0;"/>
      <output-character character="&#xF0DD;" string="&#x21D1;"/>
      <output-character character="&#xF0DE;" string="&#x21D2;"/>
      <output-character character="&#xF0DF;" string="&#x21D3;"/>
      <output-character character="&#xF0E0;" string="&#x25CA;"/>
      <output-character character="&#xF0E1;" string="&#x2329;"/>
      <output-character character="&#xF0E2;" string="&#xF8E8;"/>
      <output-character character="&#xF0E3;" string="&#xF8E9;"/>
      <output-character character="&#xF0E4;" string="&#xF8EA;"/>
      <output-character character="&#xF0E5;" string="&#x2211;"/>
      <output-character character="&#xF0E6;" string="&#xF8EB;"/>
      <output-character character="&#xF0E7;" string="&#xF8EC;"/>
      <output-character character="&#xF0E8;" string="&#xF8ED;"/>
      <output-character character="&#xF0E9;" string="&#xF8EE;"/>
      <output-character character="&#xF0EA;" string="&#xF8EF;"/>
      <output-character character="&#xF0EB;" string="&#xF8F0;"/>
      <output-character character="&#xF0EC;" string="&#xF8F1;"/>
      <output-character character="&#xF0ED;" string="&#xF8F2;"/>
      <output-character character="&#xF0EE;" string="&#xF8F3;"/>
      <output-character character="&#xF0EF;" string="&#xF8F4;"/>
      <output-character character="&#xF0F1;" string="&#x232A;"/>
      <output-character character="&#xF0F2;" string="&#x222B;"/>
      <output-character character="&#xF0F3;" string="&#x2320;"/>
      <output-character character="&#xF0F4;" string="&#xF8F5;"/>
      <output-character character="&#xF0F5;" string="&#x2321;"/>
      <output-character character="&#xF0F6;" string="&#xF8F6;"/>
      <output-character character="&#xF0F7;" string="&#xF8F7;"/>
      <output-character character="&#xF0F8;" string="&#xF8F8;"/>
      <output-character character="&#xF0F9;" string="&#xF8F9;"/>
      <output-character character="&#xF0FA;" string="&#xF8FA;"/>
      <output-character character="&#xF0FB;" string="&#xF8FB;"/>
      <output-character character="&#xF0FC;" string="&#xF8FC;"/>
      <output-character character="&#xF0FD;" string="&#xF8FD;"/>
      <output-character character="&#xF0FE;" string="&#xF8FE;"/>
  </xsl:character-map>
  
  <xsl:output name="indented" 
    method="xml"
    indent="yes"
    use-character-maps="symbols"
  />
  <xsl:output 
    method="xml"
    indent="no"
    use-character-maps="symbols"
  />
  <xsl:include
    href="office-open-utils.xsl"/>
  <xsl:include
    href="wordml2simple.xsl"/>
  <xsl:include 
    href="spreadsheetml2simple.xsl"/>
  <xsl:include
    href="wordml2simpleLevelFixup.xsl"/>
  <xsl:include
    href="wordml2simpleMathTypeFixup.xsl"/>
  <xsl:include
    href="wordml2simpleAddLevels.xsl"/>
  <xsl:include
    href="simple2dita.xsl"/>
  <xsl:include
    href="modeMapUrl.xsl"/>
  <xsl:include
    href="modeTopicUrl.xsl"/>
  <xsl:include
    href="resultdocs-xref-fixup.xsl"/>
  <xsl:include 
    href="omml2mml.xsl"/>
  <xsl:include
    href="final-fixup.xsl"
  />
  
  <xsl:template
    match="/"
    priority="10">
    <xsl:apply-templates select="." mode="report-parameters"/>
    <xsl:variable name="doDebug" as="xs:boolean" select="$debugBoolean"/>
    <xsl:variable name="stylesDoc" as="document-node()"
      select="document('styles.xml', .)"
    />      
    
    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:message> + [INFO] Generating initial simple WP doc....</xsl:message>
    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:variable
      name="simpleWpDocBase"
      as="element()">
      <xsl:call-template
        name="processDocumentXml">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="stylesDoc" as="document-node()" tunnel="yes"
          select="$stylesDoc"/>
      </xsl:call-template>
    </xsl:variable>    
    <xsl:variable
      name="tempDoc"
      select="relpath:newFile($outputDir, 'simpleWpDoc.xml')"
      as="xs:string"/>
    <!-- NOTE: do not set this check to true(): it will fail when run within RSuite -->
    <xsl:if
      test="$doSaveIntermediateDocs">
      <xsl:result-document format="indented"
        href="{$tempDoc}">
        <xsl:message> + [DEBUG] Intermediate simple WP doc saved as <xsl:sequence
            select="$tempDoc"/></xsl:message>
        <xsl:sequence
          select="$simpleWpDocBase"/>
      </xsl:result-document>
    </xsl:if>
    
    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:message> + [INFO] Doing level fixup....</xsl:message>
    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:variable name="simpleWpDocLevelFixupResult" as="element()">
      <xsl:apply-templates select="$simpleWpDocBase" mode="simpleWpDoc-levelFixupRoot">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
<!--      <xsl:sequence select="$simpleWpDocBase"/>-->
    </xsl:variable>
    
    <xsl:if
      test="$doSaveIntermediateDocs">
    <xsl:variable
      name="tempDocLevelFixup"
      select="relpath:newFile($outputDir, 'simpleWpDocLevelFixup.xml')"
      as="xs:string"/>
      <xsl:result-document format="indented"
        href="{$tempDocLevelFixup}">
        <xsl:message> + [DEBUG] Intermediate simple WP level fixup result doc saved as <xsl:sequence
            select="$tempDocLevelFixup"/></xsl:message>
        <xsl:sequence
          select="$simpleWpDocLevelFixupResult"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:variable name="simpleWpDocMathTypeFixupResult"
      as="document-node()"
    >
      <xsl:choose>      
      <xsl:when test="$simpleWpDocLevelFixupResult//rsiwp:run[@style='MTConvertedEquation']">  
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Doing MathType simpleWpDoc fixup....</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:document>
          <xsl:apply-templates select="$simpleWpDocLevelFixupResult" mode="simpleWpDoc-MathTypeFixup">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates>
        </xsl:document>
      </xsl:when>
        <xsl:otherwise>
          <xsl:document>
            <xsl:sequence select="$simpleWpDocLevelFixupResult"/>
          </xsl:document>
        </xsl:otherwise>
      </xsl:choose>    
    </xsl:variable>

    <xsl:if
      test="$doSaveIntermediateDocs">
    <xsl:variable
      name="tempDocMathTypeFixup"
      select="relpath:newFile($outputDir, 'simpleWpDocMathTypeFixup.xml')"
      as="xs:string"/>
      <xsl:result-document format="indented"
        href="{$tempDocMathTypeFixup}">
        <xsl:message> + [DEBUG] Intermediate simple WP MathType fixup result doc saved as <xsl:sequence
            select="$tempDocMathTypeFixup"/></xsl:message>
        <xsl:sequence
          select="$simpleWpDocMathTypeFixupResult"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:message> + [INFO] Doing general simpleWpDoc fixup....</xsl:message>
    <xsl:message> + [INFO] ====================================</xsl:message>

    <xsl:variable name="simpleWpDoc"
      as="document-node()"
    >
      <xsl:document>
        <xsl:apply-templates select="$simpleWpDocMathTypeFixupResult" mode="simpleWpDoc-fixup">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:document>
    </xsl:variable>

    <xsl:if
      test="$doSaveIntermediateDocs">
      <xsl:variable
        name="tempDocFixup"
        select="relpath:newFile($outputDir, 'simpleWpDocFixup.xml')"
        as="xs:string"/>
      <xsl:result-document format="indented"
        href="{$tempDocFixup}">
        <xsl:message> + [DEBUG] Fixed-up simple WP doc saved as <xsl:sequence
            select="$tempDocFixup"/></xsl:message>
        <xsl:sequence
          select="$simpleWpDoc"/>
      </xsl:result-document>
    </xsl:if>
    
    <xsl:variable name="simpleWithLevels" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$simpleWpDoc" mode="simpleWp-addLevels">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:document>
    </xsl:variable>
    <xsl:if
      test="$doSaveIntermediateDocs">
      <xsl:variable
        name="tempDocFixup"
        select="relpath:newFile($outputDir, 'simpleWpWithLevels.xml')"
        as="xs:string"/>
      <xsl:result-document format="indented"
        href="{$tempDocFixup}">
        <xsl:message> + [DEBUG] Simple WP doc with levels added saved as <xsl:sequence
            select="$tempDocFixup"/></xsl:message>
        <xsl:sequence
          select="$simpleWithLevels"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:message> + [INFO] Generating DITA result....</xsl:message>
    <xsl:message> + [INFO] ====================================</xsl:message>


    <xsl:apply-templates
      select="$simpleWithLevels/*"
      >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param 
        name="resultUrl" 
        select="relpath:newFile($outputDir, 'temp.output')" 
        tunnel="yes"        
      />
    </xsl:apply-templates>
    <xsl:message> + [INFO] ====================================</xsl:message>
    <xsl:message> + [INFO] Done.</xsl:message>
    <xsl:message> + [INFO] ====================================</xsl:message>
  </xsl:template>
  
  
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:message> 
      ==========================================
      DOCX 2 DITA
      
      Version: ^version^ - build ^buildnumber^ at ^timestamp^
      
      Parameters:
      
      + styleMapUri     = "<xsl:sequence select="$styleMapUri"/>"
      + mediaDirUri     = "<xsl:sequence select="$mediaDirUri"/>"  
      + rootMapName     = "<xsl:sequence select="$rootMapName"/>"
      + rootTopicName   = "<xsl:sequence select="$rootTopicName"/>" (<xsl:value-of select="$finalRootTopicName"/>)
      + submapNamePrefix= "<xsl:sequence select="$submapNamePrefix"/>"      
      + rootMapUrl      = "<xsl:sequence select="$rootMapUrl"/>"
      + rootTopicUrl    = "<xsl:sequence select="$rootTopicUrl"/>"
      + topicExtension  = "<xsl:sequence select="$topicExtension"/>"
      + fileNamePrefix  = "<xsl:sequence select="$fileNamePrefix"/>"      
      + filterBr        = "<xsl:sequence select="$filterBr"/>"      
      + filterTabs      = "<xsl:sequence select="$filterTabs"/>"      
      + language        = "<xsl:sequence select="$language"/>"      
      + outputDir       = "<xsl:sequence select="$outputDir"/>"  
      + debug           = "<xsl:sequence select="$debug"/>"
      + includeWordBackPointers= "<xsl:sequence select="$includeWordBackPointersBoolean"/>"  
      + chartsAsTables  = "<xsl:sequence select="$chartsAsTablesBoolean"/>"  
      + saveIntermediateDocs  = "<xsl:sequence select="$saveIntermediateDocs"/>"
      + tableWidthsProportional = "<xsl:sequence select="$tableWidthsProportional"/>" (<xsl:value-of select="$tableWidthsProportionalBoolean"/>)
      
      Global Variables:
      
      + platform         = "<xsl:sequence select="$platform"/>"
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      + doSaveIntermediateDocs = "<xsl:sequence select="$doSaveIntermediateDocs"/>"
      
      ==========================================
    </xsl:message>
  </xsl:template>
  
  
</xsl:stylesheet>
