<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:l="local:functions"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="#all"
  expand-text="yes">

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:output indent="yes" />

  <xsl:template match="/" >
    <root>
      <xsl:variable name="lines" as="xs:string*"
                    select="tokenize(/a, '\n')[string-length(.) gt 0]" />
      <first_question_sum>
        {sum( $lines!l:firstAndLastDigits(.) )}
      </first_question_sum>
      <second_question_sum>
        {sum( $lines!(l:allDigits(.) => l:firstAndLastDigits()) )}
      </second_question_sum>
    </root>
  </xsl:template>
  
  <xsl:function name="l:firstAndLastDigits" as="xs:integer" >
    <xsl:param name="string" as="xs:string" />
    
    <xsl:variable name="chars" as="xs:string*"
                  select="string-to-codepoints($string)
                          !codepoints-to-string(.)
                          [matches(., '[0-9]')]" />
    
    <xsl:sequence select="xs:integer($chars[1] || $chars[last()])" />
  </xsl:function>
  
  <xsl:variable name="stringToDigit" as="map(xs:string, xs:string)" >
    <xsl:map>
      <xsl:map-entry key="'one'"   select="'1'" />
      <xsl:map-entry key="'two'"   select="'2'" />
      <xsl:map-entry key="'three'" select="'3'" />
      <xsl:map-entry key="'four'"  select="'4'" />
      <xsl:map-entry key="'five'"  select="'5'" />
      <xsl:map-entry key="'six'"   select="'6'" />
      <xsl:map-entry key="'seven'" select="'7'" />
      <xsl:map-entry key="'eight'" select="'8'" />
      <xsl:map-entry key="'nine'"  select="'9'" />
      <xsl:map-entry key="'zero'"  select="'0'" />
    </xsl:map>
  </xsl:variable>
  
  <xsl:function name="l:allDigits" as="xs:string" >
    <xsl:param name="inputString" as="xs:string"  />
    
    <xsl:variable name="digits" as="xs:string*" >
      <xsl:for-each select="(1 to string-length($inputString))" >
        <xsl:variable name="s" as="xs:string" select="substring($inputString, .)" />
          <xsl:sequence select="if (string-length($s) eq 0)
                                then ''
                                else if ($s => matches('^[0-9]'))
                                then substring($s, 1)
                                else if (not(empty(l:maybeDigit($s))))
                                then l:maybeDigit($s)
                                else ''" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($digits)" />
  </xsl:function>
      
  <xsl:function name="l:maybeDigit" as="xs:string?" >
    <xsl:param name="string" as="xs:string" />
    
    <xsl:for-each select="map:keys($stringToDigit)" >
      <xsl:if test="matches($string, '^'|| .)" >
        <xsl:sequence select="$stringToDigit(.)" />
      </xsl:if>
    </xsl:for-each>
  </xsl:function>
  
</xsl:stylesheet>
