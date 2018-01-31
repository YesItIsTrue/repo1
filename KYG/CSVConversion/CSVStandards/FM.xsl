<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<TK_test_seq>
				<people_mstr>
					<xsl:variable name="seq" select="tokenize(//patient_name/text(), ' ')"/>
					<xsl:variable name="count" select="count(tokenize(//patient_name/text(), ' '))"/>
					<people_lastname>
						<xsl:value-of select="$seq[$count]"/>
					</people_lastname>
					<people_firstname>
						<xsl:value-of select="$seq[1]"/>
					</people_firstname>
					<people_midname>
						<xsl:if test="$count &gt; 2">
							<xsl:for-each select="$seq">
								<xsl:if test="not(position() = 1) and not(position() = $count)">
									<xsl:value-of select="$seq[position()]"/>
								</xsl:if>
								<xsl:if test="not(position() = ($count - 1))"/>
							</xsl:for-each>
							<xsl:value-of select="$seq[2]"/>
						</xsl:if>
					</people_midname>
					<people_dob>
						<year>
							<xsl:value-of select="substring(root/patient_dob,7,4)"/>
						</year>
						<month>
							<xsl:value-of select="substring(root/patient_dob,1,2)"/>
						</month>
						<day>
							<xsl:value-of select="substring(root/patient_dob,4,2)"/>
						</day>
					</people_dob>
				</people_mstr>
				<patient_mstr>
					<patient_notes>
						<xsl:value-of select="root/special_note"/>
					</patient_notes>
				</patient_mstr>
				<tk_mstr>
					<TK_ID>
						<xsl:value-of select="root/client_ref"/>
					</TK_ID>
					<tk_lab_sample_ID>
						<xsl:value-of select="root/sampleid"/>
					</tk_lab_sample_ID>
					<TK_notes>
						<xsl:value-of select="root/special_note"/>
					</TK_notes>
					<coll_begin>
						<year>
							<xsl:value-of select="substring(root/date_collected,7,4)"/>
						</year>
						<month>
							<xsl:value-of select="substring(root/date_collected,1,2)"/>
						</month>
						<day>
							<xsl:value-of select="substring(root/date_collected,4,2)"/>
						</day>
					</coll_begin>
					<TK_test_type>FM</TK_test_type>
					<TK_comments>
						<xsl:value-of select="root/comments"/>
					</TK_comments>
				</tk_mstr>
				<xsl:for-each select="root/result">
					<tkr_det>
						<tkr_item>
							<xsl:value-of select="result0"/>
						</tkr_item>
						<TKR_lab_resval>
							<xsl:value-of select="result1"/>
						</TKR_lab_resval>
						<tkr_lab_ref>
							<xsl:value-of select="result2"/>
						</tkr_lab_ref>
						<TKR_minusSD>
							<xsl:value-of select="result3"/>
						</TKR_minusSD>
						<TKR_meanSD>
							<xsl:value-of select="result4"/>
						</TKR_meanSD>
						<TKR_plusSD>
							<xsl:value-of select="result5"/>
						</TKR_plusSD>
					</tkr_det>
				</xsl:for-each>
				<BFM_mstr>
					<BFM_provocation>
						<xsl:value-of select="root/provocation"/>
					</BFM_provocation>
					<BFM_detox_agent>
						<xsl:value-of select="root/detoxification_agent"/>
					</BFM_detox_agent>
					<BFM_dosage>
						<xsl:value-of select="root/dosage"/>
					</BFM_dosage>
					<BFM_dent_amal>
						<xsl:value-of select="root/dental_amalgams"/>
					</BFM_dent_amal>
					<BFM_qty>
						<xsl:value-of select="root/quantity"/>
					</BFM_qty>
				</BFM_mstr>
			</TK_test_seq>
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="FM" userelativepaths="yes" externalpreview="no" url="F140529-2605-1.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
		          commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="SS_MPA2.xml" destSchemaRoot="root" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="F140529-2605-1.xml" srcSchemaRoot="root" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/TK_test_seq/people_mstr/people_lastname/xsl:value-of" x="284" y="81"/>
				<block path="root/TK_test_seq/people_mstr/people_firstname/xsl:value-of" x="313" y="92"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/&gt;[0]" x="185" y="45"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if" x="218" y="46"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each" x="328" y="65"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each/xsl:if" x="233" y="85"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each/xsl:if/xsl:value-of" x="284" y="104"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:value-of" x="196" y="104"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="313" y="139"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="255" y="150"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="225" y="162"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/year/xsl:value-of" x="196" y="143"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/month/xsl:value-of" x="167" y="143"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/day/xsl:value-of" x="138" y="143"/>
				<block path="root/TK_test_seq/xsl:for-each" x="284" y="143"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->