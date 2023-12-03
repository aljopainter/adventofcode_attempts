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

        <output>
            <first_question>{ sum($parts) }</first_question>

            <xsl:variable name="numbers" as="element(number)*" select="l:getNumbers($lines)" />
            <xsl:variable name="stars"   as="element(star)*"   select="l:getStars($lines)" />

            <second_question>{ sum ( l:getGears($numbers, $stars) ) }</second_question>
        </output>

    </xsl:template>

    <xsl:function name="l:getNumbers" as="element(number)*" >
        <xsl:param name="lines" as="xs:string*" />

        <xsl:for-each select="(1 to count($lines))">
            <xsl:variable name="lineIndex" as="xs:integer" select="xs:integer(.)" />

            <xsl:variable name="segments" as="element(segment)*" select="l:getSegments($lines[$lineIndex])" />
            <xsl:for-each select="(1 to count($segments))" >
                <xsl:variable name="segmentIndex" as="xs:integer"       select="xs:integer(.)" />
                <xsl:variable name="segment"      as="element(segment)" select="$segments[$segmentIndex]" />
                <xsl:variable name="segmentStart" as="xs:integer"       select="l:segmentStart($segments, $segmentIndex)" />
                <xsl:if test="$segment/@number eq 'yes'">
                    <number lineIndex="{$lineIndex}" numberStart="{$segmentStart}"
                            numberEnd="{$segmentStart + string-length($segment) - 1}" >
                        <xsl:value-of select="$segment" />
                    </number>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="l:getStars" as="element(star)*" >
        <xsl:param name="lines" as="xs:string*" />

        <xsl:for-each select="(1 to count($lines))">
            <xsl:variable name="lineIndex" as="xs:integer" select="xs:integer(.)" />
            <xsl:for-each select="l:index-of-string($lines[$lineIndex], '*')" >
                <star lineIndex="{$lineIndex}" starIndex="{.}" />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="l:getNumbersAroundStar" as="element(number)*" >
        <xsl:param name="numbers" as="element(number)*" />
        <xsl:param name="star"    as="element(star)"    />

        <xsl:variable name="lineIndex" as="xs:integer" select="xs:integer($star/@lineIndex)" />

        <xsl:for-each select="(max(($lineIndex - 1, 1)) to $lineIndex + 1)" >
            <xsl:variable name="checkLine" as="xs:integer"  select="xs:integer(.)"                />
            <xsl:variable name="starIndex" as="xs:integer"  select="xs:integer($star/@starIndex)" />
            <xsl:variable name="columns"   as="xs:integer*" select="($starIndex - 1,
                                                                     $starIndex,
                                                                     $starIndex + 1)"             />

            <xsl:for-each select="$numbers" >
                <xsl:variable name="numberLine"    as="xs:integer"   select="xs:integer(./@lineIndex)"     />
                <xsl:variable name="numberStart"   as="xs:integer"   select="xs:integer(./@numberStart)"   />
                <xsl:variable name="numberEnd"     as="xs:integer"   select="xs:integer(./@numberEnd)"     />
                <xsl:variable name="numberColumns" as="xs:integer*"  select="($numberStart to $numberEnd)" />

                <xsl:if test="($checkLine eq $numberLine) and ($columns = $numberColumns)" >
                    <xsl:sequence select="." />
                </xsl:if>

            </xsl:for-each>

        </xsl:for-each>
    </xsl:function>

    <xsl:function name="l:getGears" as="xs:integer*" >
        <xsl:param name="numbers" as="element(number)*" />
        <xsl:param name="stars"   as="element(star)*"   />

        <xsl:for-each select="$stars" >
            <xsl:variable name="numbersAroundStars" as="element(number)*"
                          select="l:getNumbersAroundStar($numbers, .)" />
            <xsl:if test="count($numbersAroundStars) eq 2" >
                <xsl:sequence select="xs:integer($numbersAroundStars[1])
                                      *
                                      xs:integer($numbersAroundStars[2])" />
            </xsl:if>
        </xsl:for-each>

    </xsl:function>

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

    <!-- From http://www.xsltfunctions.com/xsl/functx_index-of-string.html -->
    <xsl:function name="l:index-of-string" as="xs:integer*" >
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="substring" as="xs:string"/>

        <xsl:sequence select="if (contains($arg, $substring))
                              then (string-length(substring-before($arg, $substring))+1,
                                    for $other in
                                       l:index-of-string(substring-after($arg, $substring),
                                                           $substring)
                                    return
                                      $other +
                                      string-length(substring-before($arg, $substring)) +
                                      string-length($substring))
                              else ()"/>
    </xsl:function>

</xsl:stylesheet>
