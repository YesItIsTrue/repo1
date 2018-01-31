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
						<xsl:value-of select="root/clientref"/>
					</TK_ID>
					<tk_lab_sample_ID>
						<xsl:value-of select="root/sampleid"/>
					</tk_lab_sample_ID>
					<TK_test_type>HE</TK_test_type>
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
				<BHE_mstr>
					<BHE_sample_weight>
						<xsl:value-of select="root/sample_weight"/>
					</BHE_sample_weight>
					<BHE_sample_type>
						<xsl:value-of select="root/sample_type"/>
					</BHE_sample_type>
					<BHE_hair_color>
						<xsl:value-of select="root/hair_color"/>
					</BHE_hair_color>
					<BHE_treatment>
						<xsl:value-of select="root/treatment"/>
					</BHE_treatment>
					<BHE_shampoo>
						<xsl:value-of select="root/shampoo"/>
					</BHE_shampoo>
					<BHE_ratio_ca_mg>
						<xsl:value-of select="root/ca-mg_ratio"/>
					</BHE_ratio_ca_mg>
					<BHE_ratio_ca_p>
						<xsl:value-of select="root/ca-p_ratio"/>
					</BHE_ratio_ca_p>
					<BHE_ratio_na_k>
						<xsl:value-of select="root/na-k_ratio"/>
					</BHE_ratio_na_k>
					<BHE_ratio_zn_cu>
						<xsl:value-of select="root/zn-cu_ratio"/>
					</BHE_ratio_zn_cu>
					<BHE_ratio_zn_cd>
						<xsl:value-of select="root/zn-cd_ratio"/>
					</BHE_ratio_zn_cd>
				</BHE_mstr>
			</TK_test_seq>
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="HE" userelativepaths="yes" externalpreview="no" url="H140513-2354-1.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
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
			<SourceSchema srcSchemaPath="H140513-2354-1.xml" srcSchemaRoot="root" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/TK_test_seq/people_mstr/people_lastname/xsl:value-of" x="390" y="126"/>
				<block path="root/TK_test_seq/people_mstr/people_firstname/xsl:value-of" x="430" y="144"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/&gt;[0]" x="254" y="70"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if" x="300" y="72"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each" x="450" y="102"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each/xsl:if" x="320" y="132"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:for-each/xsl:if/xsl:value-of" x="390" y="162"/>
				<block path="root/TK_test_seq/people_mstr/people_midname/xsl:if/xsl:value-of" x="270" y="162"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="430" y="216"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="350" y="234"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="310" y="252"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/year/xsl:value-of" x="270" y="222"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/month/xsl:value-of" x="230" y="222"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/day/xsl:value-of" x="190" y="222"/>
				<block path="root/TK_test_seq/xsl:for-each" x="390" y="222"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->