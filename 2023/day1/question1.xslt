<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:l="local:functions"
  exclude-result-prefixes="#all"
  expand-text="yes">

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:output indent="yes" />

  <xsl:template match="/" >
    <root>
      <sum>
        {sum( (tokenize(/a, '\n')[string-length(.) gt 0])!l:firstAndLastDigits(.) )}
      </sum>
      <xsl:for-each select="tokenize(/a, '\n')[string-length(.) gt 0]">
        <line>{l:firstAndLastDigits(.)}</line>
      </xsl:for-each>
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
  
</xsl:stylesheet>
