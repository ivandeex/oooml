<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:f="urn:ooo2db:function"    
  exclude-result-prefixes="xlink math mml saxon f"
  >

  <xsl:strip-space elements="*"/>
  <xsl:output method="html" indent="no" encoding="utf-8"/>

  <xsl:template match="/article">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="articleinfo"/>

  <xsl:template match="epigraph">
    <xsl:result-document href="{concat(document-uri(/),'_epigraph_',position(),'.txt')}">
      <xsl:value-of select="concat('&#10;','== ','Epigraph',' ==','&#10;&#10;')"/>
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="sect1">
    <xsl:result-document href="{concat(document-uri(/),'_sect_',position(),'.txt')}">
      <xsl:value-of select="concat('&#10;','== ',title,' ==','&#10;&#10;')"/>
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="sect2">
    <xsl:value-of select="concat('&#10;','=== ',title,' ===','&#10;&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="sect3">
    <xsl:value-of select="concat('&#10;','==== ',title,' ====','&#10;&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="sect4">
    <xsl:value-of select="concat('&#10;','===== ',title,' =====','&#10;&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="sect5">
    <xsl:value-of select="concat('&#10;','====== ',title,' ======','&#10;&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry/para">
    <xsl:if test="name(preceding-sibling::node()[1])='para'">
      <br/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="para">
    <xsl:if test="name(preceding-sibling::node()[1])='para'">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="inlineequation">
    <math>
      <xsl:value-of select="alt"/>
    </math>
  </xsl:template>

  <xsl:template name="programlisting">
    <pre>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <xsl:template match="listitem">
    <xsl:text>* </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="systemitem|parameter|varname|constant">
    <span class="{name()}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="subscript">
    <sub>
      <xsl:apply-templates/>
    </sub>
  </xsl:template>

  <xsl:template match="superscript">
    <sup>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>

  <xsl:template match="tgroup">
    <xsl:text>{| border="1" cellpadding="5" cellspacing="0" align="center"&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>|}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="row">
    <xsl:text>|-&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:text>| </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="title"/>

  <xsl:template match="mml:*"/>
  
</xsl:stylesheet>

  
