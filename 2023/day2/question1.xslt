<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:l="local:functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                exclude-result-prefixes="#all"
                expand-text="yes">

    <xsl:output method="xml" indent="yes" />

    <xsl:variable name="maxCount" as="map(xs:string, xs:integer)" >
        <xsl:map>
            <xsl:map-entry key="'red'"   select="xs:integer(12)" />
            <xsl:map-entry key="'green'" select="xs:integer(13)" />
            <xsl:map-entry key="'blue'"  select="xs:integer(14)" />
        </xsl:map>
    </xsl:variable>

    <xsl:template match="/" >
        <xsl:variable name="lines" as="xs:string*"
                      select="tokenize(/a, '\n')[string-length(.) gt 0]" />

        <day2>
        <first_question>{
            sum(
            for $i in (1 to count($lines))
            return $i[l:lineIsPossible($lines[$i])]
            )
            
        }</first_question>
        </day2>

    </xsl:template>

    <xsl:function name="l:getRgb" as="map(*)" >
        <xsl:param name="draw" as="xs:string" />

        <xsl:map>
            <xsl:for-each select="tokenize($draw, ', ')" >
                <xsl:map-entry key="substring-after(., ' ')"
                               select="xs:integer(substring-before(., ' '))" />
            </xsl:for-each>
        </xsl:map>

    </xsl:function>

    <xsl:function name="l:getDraws" as="xs:string*" >
        <xsl:param name="line" as="xs:string" />

        <xsl:for-each select="tokenize($line => substring-after(': '), '; ')" >
            <xsl:sequence select="." />
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="l:lineIsPossible" as="xs:boolean" >
        <xsl:param name="line" as="xs:string" />

        <xsl:variable name="draws" as="xs:string*" select="l:getDraws($line)" />

        <xsl:sequence select="every $d in $draws
                              satisfies l:rgbIsPossible(l:getRgb($d))" />
    </xsl:function>

    <xsl:function name="l:rgbIsPossible" as="xs:boolean" >
        <xsl:param name="rgb" as="map(xs:string, xs:integer)" />
        
        <xsl:sequence select="every $c in map:keys($rgb)
                              satisfies $rgb($c) le $maxCount($c)" />
    </xsl:function>

</xsl:stylesheet>
