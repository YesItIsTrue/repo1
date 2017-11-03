<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>
	<xsl:template match="/">
		<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:///c:/apps/HL7/src/SS_XML_Files/DONT_TOUCH/SS_BIOMED.xsd">
			<xsl:for-each select="HL7/ORU_R01">
				<TK_test_seq>
					<test_mstr>
						<test_lab_ID>
							<xsl:value-of select="MSH/MSH.3/MSH.3.1"/>
						</test_lab_ID>
					</test_mstr>
					<people_mstr>
						<people_lastname>
							<xsl:value-of select="PID/PID.5/PID.5.1/PID.5.1.1"/>
						</people_lastname>
						<people_firstname>
							<xsl:value-of select="PID/PID.5/PID.5.2"/>
						</people_firstname>
						<people_midname>
							<xsl:value-of select="PID/PID.5/PID.5.3"/>
						</people_midname>
						<people_prefname>
							<xsl:value-of select="PID/PID.9/PID.9.1/PID.9.1.1"/>
						</people_prefname>
						<people_dob>
							<year>
								<xsl:value-of select="substring(PID/PID.7,'1','4')"/>
							</year>
							<month>
								<xsl:value-of select="substring(PID/PID.7,'5','2')"/>
							</month>
							<day>
								<xsl:value-of select="substring(PID/PID.7,'7','2')"/>
							</day>
						</people_dob>
						<people_gender>
							<xsl:value-of select="PID/PID.8"/>
						</people_gender>
						<people_ssn>
							<xsl:value-of select="PID/PID.19"/>
						</people_ssn>
						<people_homephone>
							<xsl:value-of select="PID/PID.13/PID.13.1"/>
						</people_homephone>
						<people_workphone>
							<xsl:value-of select="PID/PID.14/PID.14.1"/>
						</people_workphone>
					</people_mstr>
					<patient_mstr>
						<patient_notes>
							<xsl:value-of select="NTE/NTE.3"/>
						</patient_notes>
					</patient_mstr>
					<addr_mstr>
						<addr_addr1>
							<xsl:value-of select="PID/PID.11/PID.11.1"/>
						</addr_addr1>
						<addr_addr2>
							<xsl:value-of select="PID/PID.11/PID.11.2"/>
						</addr_addr2>
						<addr_city>
							<xsl:value-of select="PID/PID.11/PID.11.3"/>
						</addr_city>
						<state_iso>
							<xsl:value-of select="PID/PID.11/PID.11.4"/>
						</state_iso>
						<addr_zip>
							<xsl:value-of select="PID/PID.11/PID.11.5"/>
						</addr_zip>
						<country_iso>
							<xsl:value-of select="PID/PID.12"/>
						</country_iso>
					</addr_mstr>
					<tk_mstr>
						<TK_ID>
							<xsl:value-of select="ZCF/ZCF.28"/>
						</TK_ID>
						<tk_lab_sample_ID>
							<xsl:value-of select="OBR/OBR.3/OBR.3.1"/>
						</tk_lab_sample_ID>
						<tk_test_desc>
							<xsl:value-of select="OBR/OBR.4/OBR.4.2"/>
						</tk_test_desc>
						<coll_begin>
							<year>
								<xsl:value-of select="substring(OBR/OBR.7,'1','4')"/>
							</year>
							<month>
								<xsl:value-of select="substring(OBR/OBR.7,'5','2')"/>
							</month>
							<day>
								<xsl:value-of select="substring(OBR/OBR.7,'7','2')"/>
							</day>
						</coll_begin>
						<coll_end>
							<year>
								<xsl:value-of select="substring(OBR/OBR.8,'1','4')"/>
							</year>
							<month>
								<xsl:value-of select="substring(OBR/OBR.8,'5','2')"/>
							</month>
							<day>
								<xsl:value-of select="substring(OBR/OBR.8,'7','2')"/>
							</day>
						</coll_end>
						<volume>
							<xsl:value-of select="OBR/OBR.9/OBR.9.1"/>
						</volume>
					</tk_mstr>
					<xsl:for-each select="OBX">
						<tkr_det>
							<set_id>
								<xsl:value-of select="OBX.1"/>
							</set_id>
							<tkr_item>
								<xsl:value-of select="OBX.3/OBX.3.1"/>
							</tkr_item>
							<tkr_result>
								<xsl:value-of select="OBX.5/OBX.5.1"/>
							</tkr_result>
							<tkr_ref_uom>
								<xsl:value-of select="OBX.6/OBX.6.1"/>
							</tkr_ref_uom>
							<tkr_lab_ref>
								<xsl:value-of select="OBX.7"/>
							</tkr_lab_ref>
						</tkr_det>
					</xsl:for-each>
				</TK_test_seq>
			</xsl:for-each>
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="BIOMED" userelativepaths="yes" externalpreview="no" url="..\HL7_XML_Files\DONT_TOUCH\HL7_BIOMED.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength=""
		          urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal"
		          customvalidator="">
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
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="..\SS_XML_Files\DONT_TOUCH\SS_BIOMED.xml" destSchemaRoot="root" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="..\HL7_XML_Files\DONT_TOUCH\HL7_BIOMED.xml" srcSchemaRoot="HL7" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/xsl:for-each" x="239" y="41"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="661" y="252"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="581" y="270"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="621" y="288"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/year/xsl:value-of" x="541" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/month/xsl:value-of" x="501" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/day/xsl:value-of" x="461" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/year/xsl:value-of" x="421" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/month/xsl:value-of" x="381" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/day/xsl:value-of" x="341" y="239"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each" x="621" y="239"/>
			</template>
			<template match="@*|node()"></template>
			<template match="para">
				<block path="p/xsl:apply-templates" x="479" y="142"/>
				<block path="root/xsl:for-each" x="519" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:attribute/xsl:for-each" x="369" y="112"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:attribute/xsl:for-each/xsl:value-of" x="439" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="279" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="239" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="199" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/year/xsl:value-of" x="159" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/month/xsl:value-of" x="119" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_begin/day/xsl:value-of" x="79" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/year/xsl:value-of" x="39" y="142"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/month/xsl:value-of" x="479" y="102"/>
				<block path="root/xsl:for-each/TK_test_seq/tk_mstr/coll_end/day/xsl:value-of" x="519" y="102"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each" x="319" y="142"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->