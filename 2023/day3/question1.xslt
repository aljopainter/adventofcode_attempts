<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:l="local:functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                exclude-result-prefixes="#all"
                expand-text="yes">

    <xsl:output method="xml" indent="yes" />

    <xsl:template match="." >
        <xsl:variable name="lines" as="xs:string*"
                      select="tokenize(., '\n')[string-length(.) gt 0]" />

        <xsl:variable name="parts" as="xs:integer*" >
            <xsl:for-each select="(1 to count($lines))">
                <xsl:variable name="lineIndex" as="xs:integer" select="xs:integer(.)" />

                <xsl:variable name="segments" as="element(segment)*" select="l:getSegments($lines[$lineIndex])" />
                <xsl:for-each select="(1 to count($segments))" >
                    <xsl:variable name="segmentIndex" as="xs:integer"       select="xs:integer(.)" />
                    <xsl:variable name="segment"      as="element(segment)" select="$segments[$segmentIndex]" />
                    <xsl:variable name="segmentStart" as="xs:integer"       select="l:segmentStart($segments, $segmentIndex)" />
                    <xsl:if test="$segment/@number eq 'yes'
                                  and
                                  l:hasAdjacentSymbol($segment,
                                                      $lineIndex,
                                                      $lines,
                                                      $segmentStart)" >
                        <xsl:sequence select="xs:integer($segment)" />
                    </xsl:if>
                </xsl:for-each>

            </xsl:for-each>
        </xsl:variable>

        <first_question>{ sum($parts) }</first_question>
    </xsl:template>

    <xsl:function name="l:getSegments" as="element(segment)*" >
        <xsl:param name="line" as="xs:string" />

        <xsl:analyze-string select="$line" regex="[0-9]+" >
            <xsl:matching-substring>
                <segment number="yes" length="{string-length(.)}">{.}</segment>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <segment number="no" length="{string-length(.)}">{.}</segment>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="l:segmentStart" as="xs:integer" >
        <xsl:param name="segments" as="element(segment)*" />
        <xsl:param name="i"        as="xs:integer"        />

        <xsl:sequence select="sum($segments[position() lt $i]/xs:integer(@length)) + 1" />
    </xsl:function>

    <xsl:function name="l:hasAdjacentSymbol" as="xs:boolean" >
        <xsl:param name="segment"    as="element(segment)" />
        <xsl:param name="lineIndex"  as="xs:integer"       />
        <xsl:param name="lines"      as="xs:string*"       />
        <xsl:param name="start"      as="xs:integer"       />

        <xsl:sequence select="some $range in l:getRanges($segment, $lineIndex,
                                                         $lines, $start)
                              satisfies $range => matches('[^.0-9]')" />
    </xsl:function>

    <xsl:function name="l:getRanges" as="xs:string+" >
        <xsl:param name="segment"    as="element(segment)" />
        <xsl:param name="lineIndex"  as="xs:integer"       />
        <xsl:param name="lines"      as="xs:string*"       />
        <xsl:param name="start"      as="xs:integer"       />

        <xsl:for-each select="(max(($lineIndex - 1, 1)) to min(($lineIndex + 1, count($lines))))" >
            <xsl:variable name="rangeLine"   as="xs:integer" select="xs:integer(.)"                    />

            <xsl:variable name="checkLength" as="xs:integer" select="xs:integer($segment/@length) + 2" />
            <xsl:variable name="checkStart"  as="xs:integer" select="max((1, $start - 1))"             />

            <xsl:sequence select="substring($lines[$rangeLine], $checkStart, $checkLength)"             />
        </xsl:for-each>
    </xsl:function>

</xsl:stylesheet>
