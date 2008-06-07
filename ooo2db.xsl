<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
  xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
  xmlns:config="http://openoffice.org/2001/config"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
  xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
  xmlns:math="http://www.w3.org/1998/Math/MathML"
  xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
  xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

  xmlns:dom="http://www.w3.org/2001/xml-events"
  xmlns:ooo="http://openoffice.org/2004/office"
  xmlns:oooc="http://openoffice.org/2004/calc"
  xmlns:ooow="http://openoffice.org/2004/writer"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:xforms="http://www.w3.org/2002/xforms"
  
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:f="urn:ooo2db:function"  
  xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  
  exclude-result-prefixes="office meta table number dc fo chart math script
                           xsl draw svg dr3d form config text style
                           dom ooo oooc ooow xsi xsd xforms
                           saxon f manifest xlink"
  >
  
  <xsl:param name="copy-mathml" select="0"/>
  <xsl:param name="gap-spaces" select="0"/>
  <xsl:param name="sense-italic" select="1"/>
  <xsl:param name="in_2_px" select="145.68"/>
  
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes" saxon:indent-spaces="2"
    doctype-public="-//OASIS//DTD DocBook XML V4.3//EN"
    doctype-system="http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd"
    encoding="utf-8"/>
  
  <xsl:key name="headchildren" match="text:p | text:alphabetical-index | table:table | text:span |
    text:ordered-list | office:annotation | text:unordered-list | text:list | text:footnote | text:a |
    text:list-item | draw:plugin | draw:text-box | text:footnote-body | text:section"
    use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5'])[last()])"/>
  <xsl:key name="children" match="text:h[@text:outline-level='2']"
    use="generate-id(preceding-sibling::text:h[@text:outline-level='1'][1])"/>
  <xsl:key name="children" match="text:h[@text:outline-level='3']"
    use="generate-id(preceding-sibling::text:h[@text:outline-level='2' or @text:outline-level='1'][1])"/>
  <xsl:key name="children" match="text:h[@text:outline-level='4']"
    use="generate-id(preceding-sibling::text:h[@text:outline-level='3' or @text:outline-level='2' or @text:outline-level='1'][1])"/>
  <xsl:key name="children" match="text:h[@text:outline-level='5']"
    use="generate-id(preceding-sibling::text:h[@text:outline-level='4' or @text:outline-level='3' or @text:outline-level='2' or @text:outline-level='1'][1])"/>
  <xsl:key name="secondary_children" match="text:p[@text:style-name = 'Index 2']"
    use="generate-id(preceding-sibling::text:p[@text:style-name = 'Index 1'][1])"/>

  <xsl:variable name="auto-styles" select="/office:document-content/office:automatic-styles/style:style"/>
  <xsl:variable name="file-types" select="document('META-INF/manifest.xml',/)/manifest:manifest/manifest:file-entry"/>
  
  <xsl:function name="f:style">
    <xsl:param name="name"/>
    <xsl:variable name="ref" select="$auto-styles[@style:name=$name]/@style:parent-style-name"/>
    <xsl:value-of select="replace((if ($ref) then $ref else $name),'_20_',' ')"/>
  </xsl:function>

  <xsl:function name="f:path">
    <xsl:param name="path"/>
    <xsl:value-of select="if (starts-with($path,'./')) then substring($path,3) else $path"/>
  </xsl:function>
  
  <xsl:function name="f:mime-type">
    <xsl:param name="path"/>
    <xsl:value-of select="$file-types[@manifest:full-path = f:path($path)]/@manifest:media-type"/>
  </xsl:function>

  <xsl:function name="f:sub-extension">
    <xsl:param name="path"/>
    <xsl:value-of select="if (contains($path,'.')) then f:sub-extension(substring-after($path,'.')) else $path"/>
  </xsl:function>
  
  <xsl:function name="f:extension">
    <xsl:param name="path"/>
    <xsl:value-of select="if (contains($path,'.')) then f:sub-extension($path) else ''"/>
  </xsl:function>
  
  <xsl:function name="f:img-format">
    <xsl:param name="path"/>
    <xsl:variable name="p" select="upper-case(f:extension($path))"/>
    <xsl:value-of select="if ($p != '' and
                              contains('BMP.EPS.GIF.JPG.JPEG.PCX.PNG.SVG.TIFF.TIF.WMF',$p))
                          then $p else 'WMF'"/>
  </xsl:function>

  <xsl:variable name="sym-src-x20" select="'&#xf020;&#xf021;&#xf022;&#xf023;&#xf024;&#xf025;&#xf026;&#xf027;&#xf028;&#xf029;&#xf02a;&#xf02b;&#xf02c;&#xf02d;&#xf02e;&#xf02f;'"/>
  <xsl:variable name="sym-src-x30" select="'&#xf030;&#xf031;&#xf032;&#xf033;&#xf034;&#xf035;&#xf036;&#xf037;&#xf038;&#xf039;&#xf03a;&#xf03b;&#xf03c;&#xf03d;&#xf03e;&#xf03f;'"/>
  <xsl:variable name="sym-src-x40" select="'&#xf040;&#xf041;&#xf042;&#xf043;&#xf044;&#xf045;&#xf046;&#xf047;&#xf048;&#xf049;&#xf04a;&#xf04b;&#xf04c;&#xf04d;&#xf04e;&#xf04f;'"/>
  <xsl:variable name="sym-src-x50" select="'&#xf050;&#xf051;&#xf052;&#xf053;&#xf054;&#xf055;&#xf056;&#xf057;&#xf058;&#xf059;&#xf05a;&#xf05b;&#xf05c;&#xf05d;&#xf05e;&#xf05f;'"/>
  <xsl:variable name="sym-src-x60" select="'&#xf060;&#xf061;&#xf062;&#xf063;&#xf064;&#xf065;&#xf066;&#xf067;&#xf068;&#xf069;&#xf06a;&#xf06b;&#xf06c;&#xf06d;&#xf06e;&#xf06f;'"/>
  <xsl:variable name="sym-src-x70" select="'&#xf070;&#xf071;&#xf072;&#xf073;&#xf074;&#xf075;&#xf076;&#xf077;&#xf078;&#xf079;&#xf07a;&#xf07b;&#xf07c;&#xf07d;&#xf07e;&#xf07f;'"/>
  <xsl:variable name="sym-src-xa0" select="'&#xf0a0;&#xf0a1;&#xf0a2;&#xf0a3;&#xf0a4;&#xf0a5;&#xf0a6;&#xf0a7;&#xf0a8;&#xf0a9;&#xf0aa;&#xf0ab;&#xf0ac;&#xf0ad;&#xf0ae;&#xf0af;'"/>
  <xsl:variable name="sym-src-xb0" select="'&#xf0b0;&#xf0b1;&#xf0b2;&#xf0b3;&#xf0b4;&#xf0b5;&#xf0b6;&#xf0b7;&#xf0b8;&#xf0b9;&#xf0ba;&#xf0bb;&#xf0bc;&#xf0bd;&#xf0be;&#xf0bf;'"/>
  <xsl:variable name="sym-src-xc0" select="'&#xf0c0;&#xf0c1;&#xf0c2;&#xf0c3;&#xf0c4;&#xf0c5;&#xf0c6;&#xf0c7;&#xf0c8;&#xf0c9;&#xf0ca;&#xf0cb;&#xf0cc;&#xf0cd;&#xf0ce;&#xf0cf;'"/>
  <xsl:variable name="sym-src-xd0" select="'&#xf0d0;&#xf0d1;&#xf0d2;&#xf0d3;&#xf0d4;&#xf0d5;&#xf0d6;&#xf0d7;&#xf0d8;&#xf0d9;&#xf0da;&#xf0db;&#xf0dc;&#xf0dd;&#xf0de;&#xf0df;'"/>
  <xsl:variable name="sym-src-xe0" select="'&#xf0e0;&#xf0e1;&#xf0e2;&#xf0e3;&#xf0e4;&#xf0e5;&#xf0e6;&#xf0e7;&#xf0e8;&#xf0e9;&#xf0ea;&#xf0eb;&#xf0ec;&#xf0ed;&#xf0ee;&#xf0ef;'"/>
  <xsl:variable name="sym-src-xf0" select="'&#xf0f0;&#xf0f1;&#xf0f2;&#xf0f3;&#xf0f4;&#xf0f5;&#xf0f6;&#xf0f7;&#xf0f8;&#xf0f9;&#xf0fa;&#xf0fb;&#xf0fc;&#xf0fd;&#xf0fe;&#xf0ff;'"/>

  <xsl:variable name="uni-dst-x20" select="'&#x0020;&#x0021;&#x2200;&#x0023;&#x2203;&#x0025;&#x0026;&#x220d;&#x0028;&#x0029;&#x002a;&#x002b;&#x002c;&#x002d;&#x002e;&#x002f;'"/>
  <xsl:variable name="uni-dst-x30" select="'&#x0030;&#x0031;&#x0032;&#x0033;&#x0034;&#x0035;&#x0036;&#x0037;&#x0038;&#x0039;&#x003a;&#x003b;&#x003c;&#x003d;&#x003e;&#x003f;'"/>
  <xsl:variable name="uni-dst-x40" select="'&#x2245;&#x0391;&#x0392;&#x03a7;&#x0394;&#x0395;&#x03a6;&#x0393;&#x0397;&#x0399;&#x03d1;&#x039a;&#x039b;&#x039c;&#x039d;&#x039f;'"/>
  <xsl:variable name="uni-dst-x50" select="'&#x03a0;&#x0398;&#x03a1;&#x03a3;&#x03a4;&#x03a5;&#x03c2;&#x03a9;&#x039e;&#x03a8;&#x0396;&#x005b;&#x2234;&#x005d;&#x22a5;&#x005f;'"/>
  <xsl:variable name="uni-dst-x60" select="'&#x00af;&#x03b1;&#x03b2;&#x03c7;&#x03b4;&#x03b5;&#x03d5;&#x03b3;&#x03b7;&#x03b9;&#x03c6;&#x03ba;&#x03bb;&#x03bc;&#x03bd;&#x03bf;'"/>
  <xsl:variable name="uni-dst-x70" select="'&#x03c0;&#x03b8;&#x03c1;&#x03c3;&#x03c4;&#x03c5;&#x03d6;&#x03c9;&#x03be;&#x03c8;&#x03b6;&#x007b;&#x007c;&#x007d;&#x007e;&#x0020;'"/>
  <xsl:variable name="uni-dst-xa0" select="'&#x0020;&#x03d2;&#x2032;&#x2264;&#x2044;&#x221e;&#x0192;&#x2663;&#x2666;&#x2665;&#x2660;&#x2194;&#x2190;&#x2191;&#x2192;&#x2193;'"/>
  <xsl:variable name="uni-dst-xb0" select="'&#x00b0;&#x00b1;&#x2033;&#x2265;&#x00d7;&#x221d;&#x2202;&#x2022;&#x00f7;&#x2260;&#x2261;&#x2248;&#x2026;&#x2502;&#x2500;&#x21b5;'"/>
  <xsl:variable name="uni-dst-xc0" select="'&#x2135;&#x2111;&#x211c;&#x2118;&#x2297;&#x2295;&#x2298;&#x2229;&#x222a;&#x2283;&#x2287;&#x2284;&#x2282;&#x2286;&#x2208;&#x2209;'"/>
  <xsl:variable name="uni-dst-xd0" select="'&#x2220;&#x2207;&#x00ae;&#x00a9;&#x2122;&#x220f;&#x221a;&#x2219;&#x00ac;&#x2227;&#x2228;&#x21d4;&#x21d0;&#x21d1;&#x21d2;&#x21d3;'"/>
  <xsl:variable name="uni-dst-xe0" select="'&#x25ca;&#x2329;&#x00ae;&#x00a9;&#x2122;&#x2211;&#x239b;&#x239c;&#x239d;&#x23a1;&#x23a2;&#x23a3;&#x23a7;&#x23a8;&#x23a9;&#x23aa;'"/>
  <xsl:variable name="uni-dst-xf0" select="'&#x0020;&#x232a;&#x222b;&#x2320;&#x23ae;&#x2321;&#x239e;&#x239f;&#x23a0;&#x23a4;&#x23a5;&#x23a6;&#x23ab;&#x23ac;&#x23ad;&#x0020;'"/>
  
  <xsl:variable name="sym-src" select="concat($sym-src-x20,$sym-src-x30,$sym-src-x40,$sym-src-x50,$sym-src-x60,$sym-src-x70,$sym-src-xa0,$sym-src-xb0,$sym-src-xc0,$sym-src-xd0,$sym-src-xe0,$sym-src-xf0)"/>
  <xsl:variable name="uni-dst" select="concat($uni-dst-x20,$uni-dst-x30,$uni-dst-x40,$uni-dst-x50,$uni-dst-x60,$uni-dst-x70,$uni-dst-xa0,$uni-dst-xb0,$uni-dst-xc0,$uni-dst-xd0,$uni-dst-xe0,$uni-dst-xf0)"/>
  <xsl:variable name="math-glyphs" select="translate(concat($sym-src,$uni-dst),' ','')"/>
  
  <xsl:function name="f:normalize">
    <xsl:param name="s"/>
    <xsl:value-of select="translate($s,$sym-src,$uni-dst)"/>
  </xsl:function>
  
  <xsl:function name="f:is-inline-math">
    <xsl:param name="node"/>
    <xsl:variable name="props" select="$auto-styles[@style:name = $node/@text:style-name]/style:text-properties"/>
    <xsl:choose>
      <xsl:when test="$sense-italic != 1"/>
      <xsl:when test="local-name($node)='span' and $props/@fo:font-style='italic'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:when test="local-name($node)='span' and $props/@style:font-name='Symbol' and $props/@style:font-style-complex='italic'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:when test="false() and local-name($node)='' and translate($node, $math-glyphs, '')=''">
        <xsl:value-of select="1"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="f:size">
    <xsl:param name="str"/>
    <xsl:choose>
      <xsl:when test="ends-with($str,'in')">
        <xsl:value-of select="concat(round(number(substring-before($str,'in')) * $in_2_px),'px')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="/office:document-content">
    <!--xsl:call-template name="craft-doctype"/-->
    <xsl:variable name="meta" select="document('meta.xml', /)/office:document-meta"/>    
    <article lang="{$meta/office:meta/dc:language}">
      <xsl:for-each select="$meta/office:meta">
        <xsl:call-template name="craft-article-info"/>
      </xsl:for-each>
      <xsl:for-each select="office:body/office:text">
        <xsl:variable name="epigraph" select="text:p[f:style(@text:style-name)='Заголовок Документа'][following-sibling::text:h]"/>
        <xsl:if test="$epigraph">
          <epigraph>
            <xsl:apply-templates select="$epigraph" mode="epigraph"/>
          </epigraph>
        </xsl:if>
        <xsl:apply-templates select="key('headchildren', generate-id())"/>
        <xsl:apply-templates select="text:h[@text:outline-level='1']"/>      
      </xsl:for-each>
    </article>
  </xsl:template>

  <xsl:template name="craft-article-info">
    <articleinfo>
      <title>
        <xsl:value-of select="dc:title"/>
      </title>
      <author>
        <xsl:choose>
          <xsl:when test="contains(meta:initial-creator,' ')">
            <firstname>
              <xsl:value-of select="substring-before(meta:initial-creator,' ')"/>
            </firstname>
            <surname>
              <xsl:value-of select="substring-after(meta:initial-creator,' ')"/>            
            </surname>
          </xsl:when>
          <xsl:otherwise>
            <othername>
              <xsl:value-of select="meta:initial-creator"/>
            </othername>
          </xsl:otherwise>
        </xsl:choose>
      </author>
      <pubdate>
        <xsl:value-of select="substring-before(meta:creation-date,'T')"/>
      </pubdate>
      <date>
        <xsl:value-of select="substring-before(dc:date,'T')"/>
      </date>
      <issuenum>
        <xsl:value-of select="meta:editing-cycles"/>
      </issuenum>
    </articleinfo>
  </xsl:template>
  
  <xsl:template name="craft-doctype">
    <xsl:text>&#10;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" [</xsl:text>
    <xsl:for-each select="descendant::text:variable-decl">
      <xsl:variable name="name">
        <xsl:value-of select="@text:name"/>
      </xsl:variable>
      <xsl:if test="contains(@text:name,'entitydecl')">
        <xsl:text disable-output-escaping="yes">&lt;!ENTITY </xsl:text>
        <xsl:value-of select="substring-after(@text:name,'entitydecl_')"/>
        <xsl:text> "</xsl:text>
        <xsl:value-of select="//text:variable-set[@text:name= $name][1]"/>
        <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text disable-output-escaping="yes">]&gt;</xsl:text>
    <xsl:text>&#10;</xsl:text>    
  </xsl:template>
  
  <xsl:template match="text:section">
    <xsl:choose>
      <xsl:when test="@text:name='ArticleInfo'">
        <articleinfo>
          <xsl:apply-templates/>
        </articleinfo>
      </xsl:when>
      <xsl:when test="@text:name='Abstract'">
        <abstract>
          <xsl:apply-templates/>
        </abstract>
      </xsl:when>
      <xsl:when test="@text:name='Appendix'">
        <appendix>
          <xsl:apply-templates/>
        </appendix>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="sectvar">
          <xsl:text>sect</xsl:text>
          <xsl:value-of select="count(ancestor::text:section)+1"/>
        </xsl:variable>
        <xsl:variable name="idvar">
          <xsl:text> id="</xsl:text>
          <xsl:value-of select="@text:name"/>
          <xsl:text>"</xsl:text>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
        <xsl:value-of select="$sectvar"/>
        <xsl:value-of select="$idvar"/>
        <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
        <xsl:value-of select="$sectvar"/>
        <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:h[@text:outline-level='1']">
    <xsl:choose>
      <xsl:when test=".='Abstract'">
        <abstract>
          <xsl:apply-templates select="key('headchildren', generate-id())"/>
          <xsl:apply-templates select="key('children', generate-id())"/>
        </abstract>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-section">
          <xsl:with-param name="current" select="@text:outline-level"/>
          <xsl:with-param name="prev" select="1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:h[@text:outline-level='2'] |
    text:h[@text:outline-level='3']| text:h[@text:outline-level='4'] |
    text:h[@text:outline-level='5']">
    <xsl:variable name="level" select="@text:outline-level"/>
    <xsl:call-template name="make-section">
      <xsl:with-param name="current" select="$level"/>
      <xsl:with-param name="prev" select="preceding-sibling::text:h[@text:outline-level &lt;
        $level][1]/@text:outline-level "/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="make-section">
    <xsl:param name="current"/>
    <xsl:param name="prev"/>
    <xsl:choose>
      <xsl:when test="$current &gt; $prev+1">
        <xsl:element name="sect{$prev + 1}">
          <xsl:call-template name="id.attribute"/>
          <title/>
          <xsl:call-template name="make-section">
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="prev" select="$prev +1"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="sect{string($current)}">
          <xsl:call-template name="id.attribute"/>
          <title><xsl:value-of select="."/></title>
          <xsl:variable name="headchildren" select="key('headchildren', generate-id())"/>
          <xsl:variable name="children" select="key('children', generate-id())"/>
          <xsl:apply-templates select="$headchildren"/>
          <xsl:apply-templates select="$children"/>
          <xsl:if test="not($children) and not($headchildren)">
            <para/>
          </xsl:if>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:variable-set|text:variable-get">
    <xsl:if test="contains(@text:name,'entitydecl')">
      <xsl:value-of select="concat('&amp;',substring-after(@text:name,'entitydecl_'),';')"
        disable-output-escaping="yes"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text:p[@text:style-name='XMLComment']">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>
  
  <xsl:template match="text:section[@text:name='ArticleInfo']/text:p[not(@text:style-name='XMLComment')]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text:p" mode="#all">
    <xsl:choose>
      <xsl:when test="@text:style-name='Table'"/>
      <xsl:otherwise>
        <xsl:if test="not( child::text:span[@text:style-name = 'XrefLabel'] )">
          <para>
            <xsl:call-template name="id.attribute"/>
            <xsl:apply-templates/>
          </para>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:p[f:style(@text:style-name)='Заголовок Документа'][following-sibling::text:h]"/>
  
  <xsl:template match="text:p[f:style(@text:style-name)='Исходный код']">
    <xsl:if test="not(preceding-sibling::node()[local-name()='p' and f:style(@text:style-name)='Исходный код'])">
      <programlisting>
        <xsl:call-template name="programlisting">
          <xsl:with-param name="first" select="true()"/>
        </xsl:call-template>
      </programlisting>
    </xsl:if>
  </xsl:template>

  <xsl:template name="programlisting">
    <xsl:param name="first"/>
    <xsl:if test="not($first)">
      <xsl:value-of select="'&#10;'"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:variable name="next" select="following-sibling::node()[1][local-name()='p' and f:style(@text:style-name)='Исходный код']"/>
    <xsl:if test="$next">
      <xsl:for-each select="$next">
        <xsl:call-template name="programlisting"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text:ordered-list">
    <orderedlist>
      <xsl:apply-templates/>
    </orderedlist>
  </xsl:template>
  
  <xsl:template match="office:styles"/>

  <xsl:template match="text:bookmark-start"/>
  <xsl:template match="text:bookmark-end"/>
  
  <xsl:template match="text:footnote-citation"/>
  
  <xsl:template match="text:p[@text:style-name='Mediaobject']">
    <mediaobject>
      <xsl:apply-templates/>
    </mediaobject>
  </xsl:template>
  
  <xsl:template match="office:annotation/text:p">
    <note>
      <remark>
        <xsl:apply-templates/>
      </remark>
    </note>
  </xsl:template>
  
  <xsl:template match="table:table">
    <xsl:choose>
      <xsl:when test="following-sibling::text:p[@text:style-name='Table']">
        <table frame="all">
          <xsl:attribute name="id">
            <xsl:value-of select="@table:name"/>
          </xsl:attribute>
          <title>
            <xsl:value-of
              select="following-sibling::text:p[@text:style-name='Table']"/>
          </title>
          <xsl:call-template name="generictable"/>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <informaltable frame="all">
          <xsl:call-template name="generictable"/>
        </informaltable>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="generictable">
    <xsl:variable name="cells" select="count(descendant::table:table-cell)"/>
    <xsl:variable name="rows">
      <xsl:value-of select="count(descendant::table:table-row) "/>
    </xsl:variable>
    <xsl:variable name="cols">
      <xsl:value-of select="$cells div $rows"/>
    </xsl:variable>
    <xsl:variable name="numcols">
      <xsl:choose>
        <xsl:when test="child::table:table-column/@table:number-columns-repeated">
          <xsl:value-of select="number(table:table-column/@table:number-columns-repeated+1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$cols"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="tgroup">
      <xsl:attribute name="cols">
        <xsl:value-of select="$numcols"/>
      </xsl:attribute>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="1"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="colspec">
    <xsl:param name="left"/>
    <xsl:if test="number($left &lt; ( table:table-column/@table:number-columns-repeated +2)  )">
      <xsl:element name="colspec">
        <xsl:attribute name="colnum">
          <xsl:value-of select="$left"/>
        </xsl:attribute>
        <xsl:attribute name="colname">c <xsl:value-of select="$left"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:call-template name="colspec">
        <xsl:with-param name="left" select="$left+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="table:table-column">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="table:table-header-rows">
    <thead>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>
  
  <xsl:template match="table:table-header-rows/table:table-row">
    <row>
      <xsl:apply-templates/>
    </row>
  </xsl:template>
  
  <xsl:template match="table:table/table:table-row">
    <xsl:if test="not(preceding-sibling::table:table-row)">
      <xsl:text disable-output-escaping="yes">&lt;tbody&gt;</xsl:text>
    </xsl:if>
    <row>
      <xsl:apply-templates/>
    </row>
    <xsl:if test="not(following-sibling::table:table-row)">
      <xsl:text disable-output-escaping="yes">&lt;/tbody&gt;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="table:table-cell">
    <entry>
      <xsl:if test="@table:number-columns-spanned &gt;'1'">
        <xsl:attribute name="namest">
          <xsl:value-of
            select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)])
            +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+1)"/>
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:value-of
            select="concat('c',count(preceding-sibling::table:table-cell[not(@table:number-columns-spanned)])
            +sum(preceding-sibling::table:table-cell/@table:number-columns-spanned)+
            @table:number-columns-spanned)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </entry>
  </xsl:template>

  <xsl:template match="text:unordered-list|text:list">
    <xsl:choose>
      <xsl:when test="@text:style-name='Var List'">
        <variablelist>
          <xsl:apply-templates/>
        </variablelist>
      </xsl:when>
      <xsl:when test="@text:style-name='UnOrdered List'">
        <variablelist>
          <xsl:apply-templates/>
        </variablelist>
      </xsl:when>
      <xsl:otherwise>
        <itemizedlist>
          <xsl:apply-templates/>
        </itemizedlist>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:list-item">
    <xsl:choose>
      <xsl:when test="parent::text:unordered-list/@text:style-name='Var List'">
        <varlistentry>
          <xsl:for-each select="text:p[@text:style-name='VarList Term']">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </varlistentry>
      </xsl:when>
      <xsl:otherwise>
        <listitem>
          <xsl:apply-templates/>
        </listitem>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:footnote">
    <footnote>
      <xsl:apply-templates/>
    </footnote>
  </xsl:template>

  <xsl:template match="text:footnote-body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="draw:text-box"/>
  
  <xsl:template match="draw:frame">
    <xsl:variable name="img-path" select="f:path(draw:image/@xlink:href)"/>
    <xsl:variable name="obj-path" select="f:path(draw:object/@xlink:href)"/>
    <xsl:variable name="ole-path" select="f:path(draw:ole-object/@xlink:href)"/>
    <xsl:choose>
      <xsl:when test="f:mime-type(concat($obj-path,'/')) = 'application/vnd.oasis.opendocument.formula'">
        <xsl:variable name="math" select="document(concat($obj-path,'/content.xml'),/)"/>
        <xsl:variable name="anno" select="$math/math:math/math:semantics/math:annotation"/>
        <inlineequation>
          <alt>
            <xsl:if test="$anno/@math:encoding != 'StarMath 5.0'">
              <xsl:attribute name="vendor">
                <xsl:value-of select="$anno/@math:encoding"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$anno"/>
          </alt>
          <xsl:if test="$copy-mathml = 1">
            <xsl:apply-templates select="$math" mode="mml"/>
          </xsl:if>
          <xsl:if test="$img-path != ''">
            <graphic fileref="{$img-path}" format="{f:img-format($img-path)}" width="{f:size(@svg:width)}"/>
          </xsl:if>
        </inlineequation>
      </xsl:when>
      <xsl:when test="$ole-path != ''">
        <inlinemediaobject>
          <imageobject>
            <imagedata fileref="{$ole-path}" format="{f:img-format($img-path)}" width="{f:size(@svg:width)}"/>
            <xsl:if test="$img-path != ''">
              <imagedata fileref="{$img-path}" format="{f:img-format($img-path)}" width="{f:size(@svg:width)}"/>
            </xsl:if>
          </imageobject>
        </inlinemediaobject>
      </xsl:when>
      <xsl:otherwise>
        <inlinegraphic fileref="{$img-path}" format="{f:img-format($img-path)}" width="{f:size(@svg:width)}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="mml">
    <xsl:choose>
      <xsl:when test="local-name() = 'annotation'"/>
      <xsl:otherwise>
        <xsl:element name="mml:{local-name()}">
          <xsl:apply-templates select="node()|@*" mode="mml"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*" mode="mml">
    <xsl:choose>
      <xsl:when test="local-name() = 'stretchy'"/>
      <xsl:otherwise>
        <xsl:attribute name="mml:{local-name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()" mode="mml">
    <xsl:variable name="s" select="translate(.,'&#xe083;','+')"/>
    <xsl:value-of select="$s"/>
  </xsl:template>
 
  <xsl:template match="comment()" mode="mml"/>
  
  <xsl:template match="text:span">
    <xsl:variable name="style" select="f:style(@text:style-name)"/>
    <xsl:choose>
      <xsl:when test="local-name(parent::*[1])='h'"/>
      <xsl:when test="preceding-sibling::node()[1][local-name()='span' and f:style(@text:style-name)=$style]"/>
      <xsl:when test="$style='Пункт определения'">
        <systemitem>
          <xsl:call-template name="span-script"/>
        </systemitem>
      </xsl:when>
      <xsl:when test="$style='Мат. обозначение' or $style='InlineFormulaStyle'">
        <varname>
          <xsl:call-template name="span-script"/>
        </varname>
      </xsl:when>
      <xsl:when test="$style='Шрифт имени'">
        <citetitle pubwork="refentry">
          <xsl:call-template name="span-script"/>
        </citetitle>
      </xsl:when>
      <xsl:when test="f:is-inline-math(.)">
        <xsl:choose>
          <xsl:when test="preceding-sibling::node()[1][f:is-inline-math(.)]"/>
          <xsl:otherwise>
            <replaceable>
              <xsl:call-template name="span-script">
                <xsl:with-param name="check-for-math" select="1"/>
              </xsl:call-template>
            </replaceable>            
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="span-script"/>
        <xsl:variable name="next" select="following-sibling::node()[1]"/>          
        <xsl:if test="$gap-spaces = 1 and local-name($next)='span' and not(starts-with($next,' '))">
          <xsl:value-of select="' '"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="span-script">
    <xsl:param name="ref-style" select="@text:style-name"/>
    <xsl:param name="style" select="f:style($ref-style)"/>
    <xsl:param name="check-for-math" select="0"/>
    <xsl:variable name="pos" select="$auto-styles[@style:name = $ref-style]/style:text-properties/@style:text-position"/>
    <xsl:choose>
      <xsl:when test="starts-with($pos,'sub ')">
        <subscript>
          <xsl:apply-templates/>
        </subscript>
      </xsl:when>
      <xsl:when test="starts-with($pos,'super ')">
        <superscript>
          <xsl:apply-templates/>
        </superscript>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$check-for-math=1">
        <xsl:variable name="next" select="following-sibling::node()[1][f:is-inline-math(.)]"/>
        <xsl:if test="$next">
          <xsl:for-each select="$next">
            <xsl:call-template name="span-script">
              <xsl:with-param name="check-for-math" select="1"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next" select="following-sibling::node()[1][local-name()='span' and f:style(@text:style-name)=$style]"/>
        <xsl:if test="$next">
          <xsl:for-each select="$next">
            <xsl:call-template name="span-script">
              <xsl:with-param name="style" select="$style"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:a">
    <xsl:choose>
      <xsl:when test="contains(@xlink:href,'://')">
        <ulink url="{@xlink:href}">
          <xsl:apply-templates/>
        </ulink>
      </xsl:when>
      <xsl:when test="not(contains(@xlink:href,'#'))">
        <olink targetdocent="{@xlink:href}">
          <xsl:apply-templates/>
        </olink>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="linkvar" select="substring-after(@xlink:href,'#')"/>
        <link linkend="{substring-before($linkvar,'%')}">
          <xsl:apply-templates/>
        </link>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:line-break"/>
  <xsl:template match="text:tab-stop"/>
  
  <xsl:template match="text:reference-ref">
    <xref linkend="{@text:ref-name}"/>
  </xsl:template>
  
  <xsl:template name="id.attribute">
    <xsl:if test="child::text:reference-mark-start">
      <xsl:attribute name="id">
        <xsl:value-of select="child::text:reference-mark-start/@text:name"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text:reference-mark-start"/>
  <xsl:template match="text:reference-mark-end"/>
  
  <xsl:template match="comment">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>
  
  <xsl:template match="text:alphabetical-index-mark-start">
    <indexterm class="startofrange" id="{@text:id}">
      <primary>
        <xsl:value-of select="@text:key1"/>
      </primary>
      <xsl:if test="@text:key2">
        <secondary>
          <xsl:value-of select="@text:key2"/>
        </secondary>
      </xsl:if>
    </indexterm>
  </xsl:template>
  
  <xsl:template match="text:alphabetical-index-mark-end">
    <xsl:element name="indexterm">
      <xsl:attribute name="startref">
        <xsl:value-of select="@text:id"/>
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text disable-output-escaping="yes">endofrange</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text:alphabetical-index">
    <xsl:element name="index">
      <xsl:element name="title">
        <xsl:value-of select="text:index-body/text:index-title/text:p"/>
      </xsl:element>
      <xsl:apply-templates select="text:index-body"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text:index-body">
    <xsl:for-each select="text:p[@text:style-name = 'Index 1']">
      <xsl:element name="indexentry">
        <xsl:element name="primaryie">
          <xsl:value-of select="."/>
        </xsl:element>
        <xsl:if test="key('secondary_children', generate-id())">
          <xsl:element name="secondaryie">
            <xsl:value-of select="key('secondary_children', generate-id())"/>
          </xsl:element>
        </xsl:if>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:value-of select="f:normalize(.)"/>
  </xsl:template>

</xsl:stylesheet>

  
