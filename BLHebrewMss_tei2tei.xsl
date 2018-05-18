<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:ms="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:x="urn:schemas-microsoft-com:office:excel"
    xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:html="http://www.w3.org/TR/REC-html40"
    version="2.0">
    <!-- DE - 2018-05-18 - indent lines to aid inspection of textLang element -->
    <xsl:output omit-xml-declaration="yes" indent="yes"/>

    <!--  DE - 2018-05-18 - import the templates for working with language codes -->
    <xsl:include href="named_templates.xsl"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b>Feburary 24, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Dot Porter</xd:p>
            <xd:p>This document takes BL TEI and converts it to OPenn TEI (roughly following
                BiblioPhilly conventions, but without mapping keywords) </xd:p>
            <xd:p>Note that for reasons I don't understand the "material" values for
                Uk_Or_1024_20160523_144621.xml don't map so to make the output valid you need to add
                them (it is a paper ms)</xd:p>
        </xd:desc>
        <xd:desc>
            <xd:p><xd:b>Update on:</xd:b>May 18, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> Doug Emery</xd:p>
            <xd:p>Use language names in textLang element; prefer text provided if present in BL TEI;
              otherwise, pull the value based on the code. First, check the IANA Language Subtag
              Registry:
              https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
              If the language code is not found there, look at the ISO 639-2 three-letter codes:
              https://www.loc.gov/standards/iso639-2/php/code_list.php
            </xd:p>
            <xd:p>
              Where script modifiers have been used, like 'tmr-Hebr' for Aramaic in Hebrew script,
              only the language code has been used.
            </xd:p>
            <xd:p>
              I'm not sure what method the BL used for language codes, but it looks inconsistent.
              The TEI guidelines recommend using the IANA registry
              (http://www.tei-c.org/release/doc/tei-p5-doc/en/html/CH.html#CHSH), and for the most
              part the language codes follow this pattern:
                  &lt;textLang mainLang="he" otherLangs="yi-Hebr de"&gt;
              Here the IANA codes are used. These are are predominately twoletters: 'he', 'yi', and
              'de' for Hebrew, Yiddish, and German, with 'Hebr' used to indicate the script. However,
              sometimes a three-letter code is used: 'ger' and 'per' for German and Persian, instead
              of the IANA 'de' and 'fa'. In these cases, rather than convert to IANA, I pull
              the code from the ISO 639-2 list.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <!-- process this file against the empty.xml and it will grab all the BL TEI in the "metadata" directory -->
        <xsl:for-each select="collection(iri-to-uri('metadata/?select=*.xml;recurse=yes'))">
            <!-- Output files will be named with the original filename with "new-" prepended -->
            <xsl:variable name="fileName"
                select="concat('new-', tokenize(document-uri(.), '/')[position() = last()])"/>
            <xsl:result-document href="new-tei/{$fileName}">

                <!-- calling variables for the titleStmt: titles (English and Hebrew), ID, and summary (used for Title in those cases where a Title is not in the original TEI -->
                <xsl:variable name="title-en" select="//tei:msItem[@n = '0']/tei:title[1]"/>
                <xsl:variable name="title-he"
                    select="normalize-space(//tei:msDesc[1]/tei:msContents/tei:msItem[@n = '0']/tei:title[2])"/>
                <xsl:variable name="id" select="//tei:msIdentifier/tei:idno"/>
                <xsl:variable name="contents_summary"
                    select="replace(//tei:msDesc[1]/tei:msContents[1]/tei:summary[1], '&quot;', '')"/>


                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Description of <xsl:choose><xsl:when test="$title-en"
                                                ><xsl:value-of select="$title-en"
                                                /></xsl:when><xsl:otherwise><xsl:value-of
                                                select="$contents_summary"
                                        /></xsl:otherwise></xsl:choose>
                                    <xsl:if test="$title-he">(<xsl:value-of select="$title-he"
                                        />)</xsl:if></title>
                                <respStmt>
                                    <resp>cataloger</resp>
                                    <persName>Ilana Tahan</persName>
                                </respStmt>
                                <respStmt>
                                    <resp>submitter</resp>
                                    <persName>Agata Paluch</persName>
                                </respStmt>
                                <respStmt>
                                    <resp>converted to OPenn TEI format</resp>
                                    <orgName>Schoenberg Institute for Manuscript Studies</orgName>
                                </respStmt>
                                <funder>The Polonsky Foundation</funder>
                            </titleStmt>
                            <publicationStmt>
                                <publisher>The British Library</publisher>

                                <!-- BL manuscripts and metadata are in the Public Domain -->
                                <!-- I have included part of the BL Ethical Terms of Use and a link to the full document -->
                                <!-- I think it's important that we be seen as respecting the BL's terms in making the data available -->
                                <availability>
                                    <licence
                                        target="https://creativecommons.org/publicdomain/zero/1.0/"
                                        >This metadata, accompanying images, and the content of
                                        London, British Library, Oriental Manuscripts <xsl:value-of
                                            select="$id"/>: <xsl:choose><xsl:when test="$title-en"
                                                  ><xsl:value-of select="$title-en"
                                                  /></xsl:when><xsl:otherwise><xsl:value-of
                                                  select="$contents_summary"
                                            /></xsl:otherwise></xsl:choose> are free of known
                                        copyright restrictions and in the public domain. See the
                                        Creative Commons Zero 1.0 Universal page for usage details,
                                        https://creativecommons.org/publicdomain/zero/1.0/.</licence>
                                    <licence target="https://www.bl.uk/help/ethical-terms-of-use">
                                        The [British] Library respects the intellectual property
                                        rights, including moral rights, of rights holders and makes
                                        all reasonable effort to contact and consult rights owners,
                                        including, where appropriate, communities directly, or via
                                        local community organisations. Given the importance of the
                                        historical record, and the fact that that some of our
                                        digitised collections include materials that are sensitive
                                        to particular communities and groups, we ask that any use of
                                        the digitised collections is undertaken with the appropriate
                                        care. Irrespective of its copyright status, items and/or
                                        collections should not be altered or used in ways that might
                                        be derogatory to the originating individuals or communities.
                                        (Please follow the link for the complete text of the BL
                                        Ethical Terms of Use)</licence>
                                </availability>
                            </publicationStmt>

                            <!-- pulling condition, additions, and related resources into the notes -->
                            <xsl:variable name="condition-note" select="//tei:condition/tei:p"/>
                            <xsl:variable name="additions">
                                <xsl:for-each select="//tei:additions/tei:p">
                                    <note>
                                        <xsl:value-of select="."/>
                                    </note>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:variable name="related_resources">
                                <xsl:value-of select="//tei:adminInfo/tei:recordHist"/>
                            </xsl:variable>
                            <notesStmt>
                                <xsl:if test="$condition-note">
                                    <note>
                                        <xsl:value-of select="$condition-note"/>
                                    </note>
                                </xsl:if>
                                <xsl:if test="$additions">
                                    <note>
                                        <xsl:value-of select="$additions"/>
                                    </note>
                                </xsl:if>
                                <xsl:if test="$related_resources">
                                    <note type="relatedResource">
                                        <xsl:value-of select="$related_resources"/>
                                    </note>
                                </xsl:if>
                            </notesStmt>
                            <sourceDesc>
                                <msDesc>
                                    <msIdentifier>
                                        <country>United Kingdom</country>
                                        <settlement>London</settlement>
                                        <institution>British Library</institution>
                                        <repository>Oriental Manuscripts</repository>
                                        <collection>Hebrew Manuscripts Digitisation
                                            Project</collection>

                                        <!-- building identifiers -->
                                        <xsl:variable name="id_with_underscore"
                                            select="replace($id, ' ', '_')"/>
                                        <xsl:variable name="record_url"
                                                >http://www.bl.uk/manuscripts/FullDisplay.aspx?ref=<xsl:value-of
                                                select="$id_with_underscore"/></xsl:variable>
                                        <xsl:variable name="alt_id"
                                            >https://www.bl.uk/hebrew-manuscripts</xsl:variable>
                                        <xsl:variable name="alt_id_type">bl_website</xsl:variable>

                                        <idno type="call-number">
                                            <xsl:value-of select="$id"/>
                                        </idno>
                                        <altIdentifier type="resource">
                                            <idno>
                                                <xsl:value-of select="$record_url"/>
                                            </idno>
                                        </altIdentifier>
                                        <altIdentifier type="{$alt_id_type}">
                                            <idno>
                                                <xsl:value-of select="$alt_id"/>
                                            </idno>
                                        </altIdentifier>
                                    </msIdentifier>

                                    <!-- building variables for languages  -->

                                    <xsl:variable name="mainLang">
                                        <xsl:choose>
                                            <xsl:when
                                                test="//tei:msDesc/tei:msContents/tei:textLang/@mainLang">
                                                <xsl:value-of
                                                  select="//tei:msDesc/tei:msContents/tei:textLang/@mainLang"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="//tei:msDesc/tei:msItem[@n = '0']/tei:textLang/@mainLang">
                                                <xsl:value-of
                                                  select="//tei:msDesc/tei:msItem[@n = '0']/tei:textLang/@mainLang"
                                                />
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="otherLang">
                                        <xsl:choose>
                                            <xsl:when
                                                test="//tei:msDesc/tei:msContents/tei:textLang/@otherLangs">
                                                <xsl:value-of
                                                  select="//tei:msDesc/tei:msContents/tei:textLang/@otherLangs"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="//tei:msDesc/tei:msItem[@n = '0']/tei:textLang/@otherLangs">
                                                <xsl:value-of
                                                  select="//tei:msDesc/tei:msItem[@n = '0']/tei:textLang/@otherLangs"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>empty</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <!-- DE - 2018-05-18 - parse the textLang element to get the language names -->
                                    <xsl:variable name="langNames">
                                      <xsl:call-template name="getLangNames">
                                        <xsl:with-param name="langElement" select="//tei:msDesc/tei:msContents/tei:textLang"/>
                                      </xsl:call-template>
                                    </xsl:variable>



                                    <msContents>
                                        <summary>
                                            <xsl:value-of select="$contents_summary"/>
                                        </summary>
                                        <textLang mainLang="{$mainLang}">
                                            <xsl:if test="not($otherLang = 'empty')">
                                                <xsl:attribute name="otherLangs" select="$otherLang"
                                                />
                                            </xsl:if>
                                            <xsl:value-of select="$langNames"/>
                                        </textLang>
                                        <!-- Building msItems -->
                                        <!-- We pull in msItems from across the manuscript, ignoring msPart -->
                                        <!-- That is, all msItems are pulled but which msPart they belong to is not noted -->
                                        <!-- This uses @from and @to where available -->
                                        <xsl:for-each select="//tei:msItem[not(n = '0')]">
                                            <xsl:choose>
                                                <xsl:when test="tei:locus[2]">
                                                  <xsl:for-each select="tei:locus">
                                                  <xsl:variable name="from" select="@from"/>
                                                  <xsl:variable name="to" select="@to"/>
                                                  <xsl:variable name="n" select="@n"/>
                                                  <xsl:variable name="item-title"
                                                  select="following-sibling::tei:title"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$from">
                                                  <msItem n="{$from}">
                                                  <locus from="{$from}" to="{$to}"><xsl:value-of
                                                  select="$from"/>-<xsl:value-of select="$to"
                                                  /></locus>
                                                  <title>
                                                  <xsl:value-of select="$item-title"/>
                                                  </title>
                                                  </msItem>
                                                  </xsl:when>
                                                  <xsl:when test="$n">
                                                  <msItem n="{$n}">
                                                  <locus n="{$n}">
                                                  <xsl:value-of select="$n"/>
                                                  </locus>
                                                  <title>
                                                  <xsl:value-of select="$item-title"/>
                                                  </title>
                                                  </msItem>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:variable name="from" select="tei:locus/@from"/>
                                                  <xsl:variable name="to" select="tei:locus/@to"/>
                                                  <xsl:variable name="n" select="tei:locus/@n"/>
                                                  <xsl:variable name="item-title" select="tei:title"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$from">
                                                  <msItem n="{$from}">
                                                  <locus from="{$from}" to="{$to}"><xsl:value-of
                                                  select="$from"/>-<xsl:value-of select="$to"
                                                  /></locus>
                                                  <title>
                                                  <xsl:value-of select="$item-title"/>
                                                  </title>
                                                  </msItem>
                                                  </xsl:when>
                                                  <xsl:when test="$n">
                                                  <msItem n="{$n}">
                                                  <locus n="{$n}">
                                                  <xsl:value-of select="$n"/>
                                                  </locus>
                                                  <title>
                                                  <xsl:value-of select="$item-title"/>
                                                  </title>
                                                  </msItem>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </msContents>
                                    <physDesc>
                                        <objectDesc>
                                            <!-- BL has a wide variety of support materials -->
                                            <xsl:variable name="support-material">
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'perg')"
                                                  >parchment</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'chart')"
                                                  >paper</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'paper')"
                                                  >paper</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'mixed')"
                                                  >mixed</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'leather')"
                                                  >leather</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'unknown')"
                                                  >unknown</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'wooden_board')"
                                                  >wooden_board</xsl:when>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="support">
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'perg')"
                                                  >Parchment</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'chart')"
                                                  >Paper</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'paper')"
                                                  >Paper</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'mixed')"
                                                  >Mixed</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'leather')"
                                                  >Leather</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'unknown')"
                                                  >Unknown</xsl:when>
                                                  <xsl:when
                                                  test="contains(//tei:msDesc/tei:physDesc[1]//tei:supportDesc[1]/@material, 'wooden_board')"
                                                  >Wooden board</xsl:when>
                                                </xsl:choose>
                                            </xsl:variable>

                                            <!-- We take the full values of extent, foliation, and collation -->
                                            <supportDesc material="{$support-material}">
                                                <support>
                                                  <p>
                                                  <xsl:value-of select="$support"/>
                                                  </p>
                                                </support>
                                                <xsl:variable name="extent"
                                                  select="//tei:extent/text()"/>
                                                <extent>
                                                  <xsl:value-of select="$extent"/>
                                                </extent>
                                                <xsl:if test="//tei:foliation/tei:p[2]">
                                                  <xsl:variable name="foliation"
                                                  select="//tei:foliation/tei:p[2]"/>
                                                  <foliation>
                                                  <xsl:value-of select="$foliation"/>
                                                  </foliation>
                                                </xsl:if>


                                                <collation>
                                                  <p>
                                                  <xsl:for-each select="//tei:collation">
                                                  <xsl:apply-templates select="."/>
                                                  </xsl:for-each>
                                                  </p>


                                                </collation>

                                            </supportDesc>
                                            <!-- Building layout by combining various bits from the BL TEI -->
                                            <layoutDesc>
                                                <layout>
                                                  <xsl:variable name="columns"
                                                  select="//tei:layout/@columns"/>
                                                  <xsl:variable name="ruledLines"
                                                  select="//tei:layout/@ruledLines"/>
                                                  <xsl:variable name="writtenLines"
                                                  select="//tei:layout/@writtenLines"/>
                                                  <p>Columns: <xsl:value-of select="$columns"/>;
                                                  ruled lines: <xsl:value-of select="$ruledLines"/>;
                                                  written lines: <xsl:value-of
                                                  select="$writtenLines"/>; <xsl:for-each
                                                  select="//tei:layout/tei:p"><xsl:value-of
                                                  select="."/>
                                                  </xsl:for-each></p>
                                                </layout>
                                            </layoutDesc>
                                        </objectDesc>
                                        <!-- one single scriptNote -->
                                        <scriptDesc>
                                            <xsl:variable name="script-summary"
                                                select="//tei:handDesc/tei:summary"/>
                                            <scriptNote>
                                                <xsl:value-of select="$script-summary"/>
                                            </scriptNote>
                                        </scriptDesc>
                                        <xsl:if test="//tei:decoNote">
                                            <!-- We break out decoNotes with multiple @locus values into separate decoNotes -->
                                            <decoDesc>
                                                <xsl:variable name="decoNote-summary"
                                                  select="//tei:decoDesc/tei:summary"/>
                                                <xsl:if test="$decoNote-summary">
                                                  <decoNote>
                                                  <xsl:value-of select="$decoNote-summary"/>
                                                  </decoNote>
                                                </xsl:if>
                                                <xsl:for-each select="//tei:decoNote">
                                                  <xsl:variable name="decoNote" select="text()"/>
                                                  <xsl:variable name="type" select="@type"/>
                                                  <xsl:variable name="locus" select="tei:locus/@n"/>
                                                  <xsl:choose>
                                                  <xsl:when test="contains(tei:locus/@n, ',')">
                                                  <xsl:for-each select="tokenize($locus, ', ')">
                                                  <decoNote>
                                                  <xsl:if test="$type">
                                                  <xsl:attribute name="type">
                                                  <xsl:value-of select="$type"/>
                                                  </xsl:attribute>
                                                  </xsl:if>
                                                  <locus>
                                                  <xsl:value-of select="."/>
                                                  </locus>
                                                  <xsl:value-of select="$decoNote"/>
                                                  </decoNote>
                                                  </xsl:for-each>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <decoNote>
                                                  <xsl:if test="$type">
                                                  <xsl:attribute name="type">
                                                  <xsl:value-of select="$type"/>
                                                  </xsl:attribute>
                                                  </xsl:if>
                                                  <xsl:if test="$locus">
                                                  <locus>
                                                  <xsl:value-of select="$locus"/>
                                                  </locus>
                                                  </xsl:if>
                                                  <xsl:value-of select="$decoNote"/>
                                                  </decoNote>
                                                  </xsl:otherwise>
                                                  </xsl:choose>

                                                </xsl:for-each>
                                            </decoDesc>
                                        </xsl:if>
                                        <!-- We take the full value of bining -->
                                        <bindingDesc>
                                            <binding>
                                                <p>
                                                  <xsl:for-each select="//tei:binding/tei:p">
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="."/>
                                                  </xsl:for-each>
                                                </p>
                                            </binding>
                                        </bindingDesc>
                                    </physDesc>
                                    <!-- We rearrange values from the history section of the BL TEI to suit our own requirements -->
                                    <history>
                                        <origin>
                                            <xsl:variable name="when"
                                                select="//tei:msDesc/tei:history//@when"/>
                                            <xsl:variable name="notBefore"
                                                select="//tei:msDesc/tei:history//@notBefore"/>
                                            <xsl:variable name="notAfter"
                                                select="//tei:msDesc/tei:history//@notAfter"/>
                                            <xsl:if test="$when">
                                                <origDate when="{$when}"/>
                                            </xsl:if>
                                            <xsl:if test="$notBefore">
                                                <origDate notBefore="{$notBefore}"
                                                  notAfter="{$notAfter}"/>
                                            </xsl:if>

                                            <xsl:if
                                                test="//tei:msDesc/tei:history/tei:provenance/tei:p/tei:name[@type = 'place']">
                                                <origPlace>
                                                  <xsl:value-of
                                                  select="//tei:msDesc/tei:history/tei:provenance/tei:p/tei:name[@type = 'place']"
                                                  />
                                                </origPlace>
                                            </xsl:if>
                                        </origin>
                                        <!-- We can have multiple provenance sections -->
                                        <xsl:for-each
                                            select="//tei:msDesc/tei:history/tei:provenance/tei:p/tei:name[not(@type = 'place')]">
                                            <provenance>
                                                <xsl:value-of select="."/>
                                            </provenance>
                                        </xsl:for-each>
                                        <!-- Acquisition is in provenance, with an "Acquisition: " note -->
                                        <xsl:for-each
                                            select="//tei:msDesc/tei:history/tei:acquisition/tei:p">
                                            <provenance>Acquisition: <xsl:value-of select="."
                                                /></provenance>
                                        </xsl:for-each>
                                    </history>
                                </msDesc>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>

                    <facsimile>
                        <surface n="78v" xml:id="surface-lewis-e-206-164">
                            <graphic height="4412px" url="master/5506_0163.tif" width="3590px"/>
                            <graphic height="190px" url="thumb/5506_0163_thumb.jpg" width="154px"/>
                            <graphic height="1800px" url="web/5506_0163_web.jpg" width="1464px"/>
                        </surface>
                    </facsimile>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>

    </xsl:template>
    <!-- this template is required for collation to display correctly -->
    <xsl:template match="//tei:hi[@rend = 'sup']">(<xsl:value-of select="."/>)</xsl:template>

</xsl:stylesheet>
