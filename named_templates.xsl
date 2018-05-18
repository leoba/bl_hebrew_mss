<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> May 11, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> Doug Emery</xd:p>
      <xd:p>Named templates for extracting selecting language names for BL manuscripts
      based on BL textLang element</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:param name="subtags" select="document('language-subtag-registry.xml')"/>
  <xsl:param name="isoCodes" select="document('iso-639-2.xml')"/>
  
  <!--  
    template: getLangNames
    
    Figure our which language names to use; default to provided textLang text if present; 
    otherwise, parse the codes.
  -->
  <xsl:template name="getLangNames">
    <xsl:param name="langElement"/>
    <xsl:choose>
      <!-- If the BL has given language name text, then use that. -->
      <xsl:when test="$langElement/text() and not(matches($langElement/text(),'^\s*$'))">
        <xsl:value-of select="$langElement/text()"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Otherwise, we parse the codes -->
        <xsl:call-template name="translateLangCodes">
          <xsl:with-param name="langElement" select="$langElement"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template name="translateLangCodes">
    <xsl:param name="langElement"/>
    <xsl:variable name="codeList">
      <xsl:value-of select="$langElement/@mainLang"/>
      <xsl:if test="$langElement/@otherLangs and not(normalize-space($langElement/@otherLangs) = '')">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$langElement/@otherLangs"/>
      </xsl:if>
    </xsl:variable> 
    <xsl:for-each select="tokenize($codeList, '\s')">
      <xsl:call-template name="translateOneCode">
        <!-- Pass in the code, but only use the first subtag element, the language;
          e.g., convert 'yi-Hebr' to 'yi'.
        -->
        <xsl:with-param name="code" select="replace(., '-.*$', '')"/>
      </xsl:call-template>
      <xsl:if test="not(position() = last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="translateOneCode">
    <xsl:param name="code"/>
    <xsl:choose>
      <!-- See if the code is an IANA language code. -->
      <xsl:when test="$subtags/subtags/unit/subtag/text() = $code">
        <xsl:value-of select="$subtags/subtags/unit/subtag[text() = $code]/parent::unit/description/text()"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- It's not an IANA code, so pull the name from the ISO 639-2 list. -->
        <xsl:value-of select="$isoCodes/iso-639-2/language/code[text() = $code]/parent::language/name/text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>