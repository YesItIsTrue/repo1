<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<TK_test_seq>
				<people_mstr>
					<people_lastname>
						<xsl:value-of select="root/patient_lastname"/>
					</people_lastname>
					<people_firstname>
						<xsl:value-of select="root/patient_firstname"/>
					</people_firstname>
					<people_midname>
						<xsl:value-of select="root/patient_middlename"/>
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
				<addr_mstr>
					<addr_addr1>
						<xsl:value-of select="root/patient_address1"/>
					</addr_addr1>
					<addr_addr2>
						<xsl:value-of select="root/patient_address2"/>
					</addr_addr2>
					<addr_city>
						<xsl:value-of select="root/patient_city"/>
					</addr_city>
					<state_iso>
						<xsl:value-of select="root/patient_state"/>
					</state_iso>
					<addr_zip>
						<xsl:value-of select="root/patient_zip"/>
					</addr_zip>
					<country_iso>
						<xsl:value-of select="root/patient_country"/>
					</country_iso>
				</addr_mstr>
				<tk_mstr>
					<TK_ID>
						<xsl:value-of select="root/client_ref"/>
					</TK_ID>
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
						<tkr_lab_ref>
							<xsl:value-of select="result1"/>
						</tkr_lab_ref>
						<tkr_lab_results>
							<xsl:value-of select="result2"/>
						</tkr_lab_results>
					</tkr_det>
				</xsl:for-each>
			</TK_test_seq>
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="KYG" userelativepaths="yes" externalpreview="no" url="KYG-06861-12802-US.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
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
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="SS_MPA.xml" destSchemaRoot="root" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="KYG-06861-12802-US.xml" srcSchemaRoot="root" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="99" y="122"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="130" y="147"/>
				<block path="root/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="163" y="172"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/year/xsl:value-of" x="74" y="192"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/month/xsl:value-of" x="114" y="207"/>
				<block path="root/TK_test_seq/tk_mstr/coll_begin/day/xsl:value-of" x="152" y="221"/>
				<block path="root/TK_test_seq/xsl:for-each" x="192" y="275"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->