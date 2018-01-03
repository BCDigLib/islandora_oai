<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:etdms="http://www.ndltd.org/standards/metadata/etdms/1.0/">

<!--
version 2.0 2018-01-03
This stylesheet is the Boston College-specific MODS to DC transformation.
It is based on the Islandora OAI MODS to DC transformation (https://github.com/Islandora/islandora_oai/tree/7.x/transforms).

Outstanding questions:
1) Is the roleTerm crosswalk correct? See https://goo.gl/7KC8aH.
2) Should we use <mods:LocalCollectionName> somehow?
3) Should we announce Handles in <dc:identifier> (they have cdone so with DOIs)? We currently only give the URL. LOC suggests giving the identifier type.
	3a) Do we need to convert the Digitool identifier or can we drop it? I've added logic to drop it.
	3b) We currently have both Handle and streaming link in the MODS for videos. These are both transformed into <dc:identifer>. Is this correct?
4) This script suppresses series names in <mods:relatedItem>. Is this correct?
5) For FPH videos, the transform takes the related item and gives title plus all identifiers for the related item in one string separated by two 
   hyphens. Is this correct?
6) I removed transforms for <mods:temporal> since we don't seem to use that in our MODS implementation. Is that correct?
7) Deleted <mods:mimeType> since BC does not use this. Is that correct?
8) <mods:note> becomes <dc:description>, leading to things like <dc:description>Title supplied by cataloger</dc:description>. Is this OK?
9) This transform takes each <mods:subject/mods:[element_name]> and groups them together into one <dc:subject> separated by 2 hyphens. 
   For example, all <mods:topic> is grouped and separated by 2 hyphens, all <mods:geographic> is grouped, etc. Is this correct?
-->

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="/">
		<xsl:choose>
		<xsl:when test="//mods:modsCollection">
			<srw_dc:dcCollection xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
				<xsl:apply-templates/>
			<xsl:for-each select="mods:modsCollection/mods:mods">
				<srw_dc:dc xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
				<xsl:apply-templates/>
			</srw_dc:dc>
			</xsl:for-each>
			</srw_dc:dcCollection>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="mods:mods">
			<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
				<xsl:apply-templates/>
			</oai_dc:dc>
			</xsl:for-each>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:titleInfo">
		<dc:title>
			<xsl:if test="mods:nonSort and mods:nonSort != '' ">
			<xsl:value-of select="mods:nonSort"/>
			</xsl:if>
			<xsl:value-of select="mods:title"/>
			<xsl:if test="mods:subTitle and mods:subTitle != '' ">
				<xsl:text>: </xsl:text>
				<xsl:value-of select="mods:subTitle"/>
			</xsl:if>
			<xsl:if test="mods:partNumber and mods:partNumber !='' ">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partNumber"/>
			</xsl:if>
			<xsl:if test="mods:partName and mods:partName !=''">
				<xsl:text>. </xsl:text>
				<xsl:value-of select="mods:partName"/>
			</xsl:if>
		</dc:title>
	</xsl:template>

	<xsl:template match="mods:name">
		<xsl:choose>
			<!-- Create dc:creator -->
			<xsl:when test="@usage='primary'">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>
			<!-- Create dc:contributor -->
			<xsl:when
				test="mods:role/mods:roleTerm[@type='text']='Abridger' or mods:role/mods:roleTerm[@type='text']='Actor' or mods:role/mods:roleTerm[@type='text']='Adapter' or mods:role/mods:roleTerm[@type='text']='Animator' or mods:role/mods:roleTerm[@type='text']='Annotator' or mods:role/mods:roleTerm[@type='text']='Arranger' or mods:role/mods:roleTerm[@type='text']='Art director' or mods:role/mods:roleTerm[@type='text']='Author of afterword, colophon, etc.' or mods:role/mods:roleTerm[@type='text']='Author of dialog' or mods:role/mods:roleTerm[@type='text']='Author of introduction, etc.' or mods:role/mods:roleTerm[@type='text']='Autographer' or mods:role/mods:roleTerm[@type='text']='Binding designer' or mods:role/mods:roleTerm[@type='text']='Blurb writer' or mods:role/mods:roleTerm[@type='text']='Book designer' or mods:role/mods:roleTerm[@type='text']='Calligrapher' or mods:role/mods:roleTerm[@type='text']='Cinematographer' or mods:role/mods:roleTerm[@type='text']='Colorist' or mods:role/mods:roleTerm[@type='text']='Commentator' or mods:role/mods:roleTerm[@type='text']='Commentator for written text' or mods:role/mods:roleTerm[@type='text']='Conceptor' or mods:role/mods:roleTerm[@type='text']='Conductor' or mods:role/mods:roleTerm[@type='text']='Contributor' or mods:role/mods:roleTerm[@type='text']='Corrector' or mods:role/mods:roleTerm[@type='text']='Correspondent' or mods:role/mods:roleTerm[@type='text']='Court reporter' or mods:role/mods:roleTerm[@type='text']='Data contributor' or mods:role/mods:roleTerm[@type='text']='Dedicator' or mods:role/mods:roleTerm[@type='text']='Delineator' or mods:role/mods:roleTerm[@type='text']='Director' or mods:role/mods:roleTerm[@type='text']='Draftsman' or mods:role/mods:roleTerm[@type='text']='Editor' or mods:role/mods:roleTerm[@type='text']='Editor of compilation' or mods:role/mods:roleTerm[@type='text']='Editor of moving image work' or mods:role/mods:roleTerm[@type='text']='Engraver' or mods:role/mods:roleTerm[@type='text']='Etcher' or mods:role/mods:roleTerm[@type='text']='Film director' or mods:role/mods:roleTerm[@type='text']='Film editor' or mods:role/mods:roleTerm[@type='text']='Geographic information specialist' or mods:role/mods:roleTerm[@type='text']='Host' or mods:role/mods:roleTerm[@type='text']='Illuminator' or mods:role/mods:roleTerm[@type='text']='Illustrator' or mods:role/mods:roleTerm[@type='text']='Instrumentalist' or mods:role/mods:roleTerm[@type='text']='Interviewee' or mods:role/mods:roleTerm[@type='text']='Interviewer' or mods:role/mods:roleTerm[@type='text']='Lighting designer' or mods:role/mods:roleTerm[@type='text']='Marbler' or mods:role/mods:roleTerm[@type='text']='Markup editor' or mods:role/mods:roleTerm[@type='text']='Metal-engraver' or mods:role/mods:roleTerm[@type='text']='Minute taker' or mods:role/mods:roleTerm[@type='text']='Moderator' or mods:role/mods:roleTerm[@type='text']='Music copyist' or mods:role/mods:roleTerm[@type='text']='Musical director' or mods:role/mods:roleTerm[@type='text']='Musician' or mods:role/mods:roleTerm[@type='text']='Narrator' or mods:role/mods:roleTerm[@type='text']='Onscreen presenter' or mods:role/mods:roleTerm[@type='text']='Organizer' or mods:role/mods:roleTerm[@type='text']='Panelist' or mods:role/mods:roleTerm[@type='text']='Performer' or mods:role/mods:roleTerm[@type='text']='Platemaker' or mods:role/mods:roleTerm[@type='text']='Praeses' or mods:role/mods:roleTerm[@type='text']='Production designer' or mods:role/mods:roleTerm[@type='text']='Project director' or mods:role/mods:roleTerm[@type='text']='Puppeteer' or mods:role/mods:roleTerm[@type='text']='Recording engineer' or mods:role/mods:roleTerm[@type='text']='Redaktor' or mods:role/mods:roleTerm[@type='text']='Renderer' or mods:role/mods:roleTerm[@type='text']='Rubricator' or mods:role/mods:roleTerm[@type='text']='Screenwriter' or mods:role/mods:roleTerm[@type='text']='Set designer' or mods:role/mods:roleTerm[@type='text']='Singer' or mods:role/mods:roleTerm[@type='text']='Speaker' or mods:role/mods:roleTerm[@type='text']='Stage director' or mods:role/mods:roleTerm[@type='text']='Storyteller' or mods:role/mods:roleTerm[@type='text']='Surveyor' or mods:role/mods:roleTerm[@type='text']='Teacher' or mods:role/mods:roleTerm[@type='text']='Transcriber' or mods:role/mods:roleTerm[@type='text']='Type designer' or mods:role/mods:roleTerm[@type='text']='Typographer' or mods:role/mods:roleTerm[@type='text']='Voice actor' or mods:role/mods:roleTerm[@type='text']='Writer of accompanying material' or mods:role/mods:roleTerm[@type='text']='Writer of added commentary' or mods:role/mods:roleTerm[@type='text']='Writer of added lyrics' or mods:role/mods:roleTerm[@type='text']='Writer of added text' or mods:role/mods:roleTerm[@type='text']='Writer of introduction' or mods:role/mods:roleTerm[@type='text']='Writer of preface' or mods:role/mods:roleTerm[@type='text']='Writer of supplementary textual content' or mods:role/mods:roleTerm[@type='text']='Architect' or mods:role/mods:roleTerm[@type='text']='Artist' or mods:role/mods:roleTerm[@type='text']='Attributed name' or mods:role/mods:roleTerm[@type='text']='Author' or mods:role/mods:roleTerm[@type='text']='Cartographer' or mods:role/mods:roleTerm[@type='text']='Choreographer' or mods:role/mods:roleTerm[@type='text']='Compiler' or mods:role/mods:roleTerm[@type='text']='Composer' or mods:role/mods:roleTerm[@type='text']='Compositor' or mods:role/mods:roleTerm[@type='text']='Costume designer' or mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='Designer' or mods:role/mods:roleTerm[@type='text']='Dissertant' or mods:role/mods:roleTerm[@type='text']='Filmmaker' or mods:role/mods:roleTerm[@type='text']='Forger' or mods:role/mods:roleTerm[@type='text']='Inventor' or mods:role/mods:roleTerm[@type='text']='Landscape architect' or mods:role/mods:roleTerm[@type='text']='Librettist' or mods:role/mods:roleTerm[@type='text']='Lithographer' or mods:role/mods:roleTerm[@type='text']='Lyricist' or mods:role/mods:roleTerm[@type='text']='Photographer' or mods:role/mods:roleTerm[@type='text']='Programmer' or mods:role/mods:roleTerm[@type='text']='Reporter' or mods:role/mods:roleTerm[@type='text']='Scenarist' or mods:role/mods:roleTerm[@type='text']='Sculptor'">
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:when>
			<!-- Suppress publisher- and coverage-type MARC roleTerms-->
			<xsl:when
				test="mods:role/mods:roleTerm[@type='text']='Setting' or mods:role/mods:roleTerm[@type='text']='University place' or mods:role/mods:roleTerm[@type='text']='Associated name' or mods:role/mods:roleTerm[@type='text']='Issuing body' or mods:role/mods:roleTerm[@type='text']='Originator' or mods:role/mods:roleTerm[@type='text']='Presenter' or mods:role/mods:roleTerm[@type='text']='Printer' or mods:role/mods:roleTerm[@type='text']='Printer of plates' or mods:role/mods:roleTerm[@type='text']='Printmaker' or mods:role/mods:roleTerm[@type='text']='Provider' or mods:role/mods:roleTerm[@type='text']='Publisher'"/>			
			<!-- Create dc:description that will handle all other roleTerms, whether MARC or not -->
			<xsl:otherwise>
				<dc:description>
					<xsl:value-of select="mods:role/mods:roleTerm[@type='text']"/><xsl:text>: </xsl:text><xsl:call-template name="name"/>
				</dc:description>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:classification">
		<dc:subject>
			<xsl:value-of select="."/>
		</dc:subject>
	</xsl:template>

	<xsl:template match="mods:subject[mods:topic | mods:name | mods:occupation | mods:geographic | mods:hierarchicalGeographic | mods:cartographics | mods:temporal] ">
		<dc:subject>
			<xsl:for-each select="mods:topic">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">--</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="mods:occupation">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">--</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="mods:name">
				<xsl:call-template name="name"/>
			</xsl:for-each>
		</dc:subject>

		<xsl:for-each select="mods:titleInfo/mods:title">
			<dc:subject>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dc:subject>
		</xsl:for-each>

		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:hierarchicalGeographic">
			<dc:coverage>
				<xsl:for-each
					select="mods:continent|mods:country|mods:provence|mods:region|mods:state|mods:territory|mods:county|mods:city|mods:island|mods:area">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">--</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/*">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:if test="mods:temporal">
			<dc:coverage>
				<xsl:for-each select="mods:temporal">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:if>

		<xsl:if test="*[1][local-name()='topic'] and *[local-name()!='topic']">
			<dc:subject>
				<xsl:for-each select="*[local-name()!='cartographics' and local-name()!='geographicCode' and local-name()!='hierarchicalGeographic'] ">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">--</xsl:if>
				</xsl:for-each>
			</dc:subject>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:abstract | mods:tableOfContents | mods:note">
		<dc:description>
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<xsl:for-each select="child::*[@keyDate='yes']">
			<dc:date>
				<xsl:value-of select="."/>
			</dc:date>
		</xsl:for-each>
		<xsl:for-each select="child::*[@point='start']">
			<dc:date>
				<xsl:value-of select="."/>-<xsl:value-of select="following-sibling::*[local-name()][@point='end']"/>
			</dc:date>
		</xsl:for-each>
		<xsl:for-each select="mods:publisher">
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
		<xsl:for-each select="mods:place/mods:placeTerm[@type='text']">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>
		<xsl:for-each select="mods:issuance">
			<dc:type>
				<xsl:value-of select="."/>
			</dc:type>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:genre">
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
	</xsl:template>

	<xsl:template match="mods:typeOfResource">
		<xsl:choose>
			<xsl:when test="@collection='yes'">
				<dc:type>Collection</dc:type>
			</xsl:when>
			<xsl:when test=". ='software' and ../mods:genre='database'">
				<dc:type>DataSet</dc:type>
			</xsl:when>
			<xsl:when test=".='software' and ../mods:genre='online system or service'">
				<dc:type>Service</dc:type>
			</xsl:when>
			<xsl:when test=".='software'">
				<dc:type>Software</dc:type>
			</xsl:when>
			<xsl:when test=".='cartographic material'">
				<dc:type>Image</dc:type>
			</xsl:when>
			<xsl:when test=".='multimedia'">
				<dc:type>InteractiveResource</dc:type>
			</xsl:when>
			<xsl:when test=".='moving image'">
				<dc:type>MovingImage</dc:type>
			</xsl:when>
			<xsl:when test=".='three-dimensional object'">
				<dc:type>PhysicalObject</dc:type>
			</xsl:when>
			<xsl:when test="starts-with(.,'sound recording')">
				<dc:type>Sound</dc:type>
			</xsl:when>
			<xsl:when test=".='still image'">
				<dc:type>StillImage</dc:type>
			</xsl:when>
			<xsl:when test=". ='text'">
				<dc:type>Text</dc:type>
			</xsl:when>
			<xsl:when test=".='notated music'">
				<dc:type>Text</dc:type>
			</xsl:when>
			<!-- Adding logic to handle other weird types we might run into -->
			<xsl:otherwise>
				<dc:type><xsl:value-of select="."/></dc:type>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:if test="mods:extent">
			<dc:format>
				<xsl:value-of select="mods:extent"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:form">
			<dc:format>
				<xsl:value-of select="mods:form"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:internetMediaType">
			<dc:format>
				<xsl:value-of select="mods:internetMediaType"/>
			</dc:format>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mods:extension">
		<xsl:for-each select="etdms:degree/etdms:name">
			<dc:description>
				<xsl:text>Thesis (</xsl:text><xsl:value-of select="."/><xsl:text>) — Boston College, </xsl:text><xsl:value-of select="//mods:originInfo/mods:dateIssued[@keyDate='yes']"/><xsl:text>.</xsl:text>
			</dc:description>
		</xsl:for-each>
		<xsl:for-each select="etdms:degree/etdms:grantor">
			<dc:description>
				<xsl:text>Submitted to: </xsl:text><xsl:value-of select="."/><xsl:text>.</xsl:text>
			</dc:description>
		</xsl:for-each>
		<xsl:for-each select="etdms:degree/etdms:discipline">
			<dc:description>
				<xsl:text>Discipline: </xsl:text><xsl:value-of select="."/><xsl:text>.</xsl:text>
			</dc:description>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:identifier">
		<xsl:variable name="type" select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:choose>
			<xsl:when test="contains ('isbn issn uri doi lccn uri', $type)">
				<dc:identifier>
					<xsl:value-of select="$type"/>: <xsl:value-of select="."/>
				</dc:identifier>
			</xsl:when>
			<xsl:when test="contains('digitool', $type)" />
			<xsl:otherwise>
				<dc:identifier>
					<xsl:value-of select="."/>
				</dc:identifier>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:location">
		<dc:identifier>
			<xsl:for-each select="mods:url">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</dc:identifier>
	</xsl:template>

	<xsl:template match="mods:language">
		<dc:language>
			<xsl:value-of select="normalize-space(mods:languageTerm[@type='text'])"/>
		</dc:language>
	</xsl:template>

	<xsl:template match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'"/>
			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each
						select="mods:titleInfo">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:if test="mods:nonSort and mods:nonSort != '' ">
								<xsl:value-of select="mods:nonSort"/>
							</xsl:if>
							<xsl:value-of select="mods:title"/>
							<xsl:if test="mods:subTitle and mods:subTitle != '' ">
								<xsl:text>: </xsl:text>
								<xsl:value-of select="mods:subTitle"/>
							</xsl:if>
							<xsl:if test="mods:partNumber and mods:partNumber !='' ">
								<xsl:text>. </xsl:text>
								<xsl:value-of select="mods:partNumber"/>
							</xsl:if>
							<xsl:if test="mods:partName and mods:partName !=''">
								<xsl:text>. </xsl:text>
								<xsl:value-of select="mods:partName"/>
							</xsl:if>
							<xsl:if test="position()=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<xsl:for-each select="mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:accessCondition">
		<dc:rights>
			<xsl:value-of select="."/>
		</dc:rights>
	</xsl:template>

	<xsl:template name="name">
		<xsl:variable name="name">
			<xsl:if test="mods:displayForm">
				<xsl:value-of select="mods:displayForm"/>
			</xsl:if>
			<xsl:if test="not(mods:displayForm)">
				<xsl:choose>
					<xsl:when test="mods:namePart[@type='family']">
						<xsl:value-of select="mods:namePart[@type='family']"/><xsl:text>, </xsl:text><xsl:value-of select="mods:namePart[@type='given']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="mods:namePart"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>	
		</xsl:variable>
		<xsl:value-of select="normalize-space($name)"/>
	</xsl:template>
	
	<!-- suppress all else:-->
	<xsl:template match="*"/>
	
</xsl:stylesheet>
