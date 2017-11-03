<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>
	<xsl:template match="/">
		<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:///c:/apps/HL7/src/SS_XML_Files/DONT_TOUCH/SS_MPA.xsd">
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
					<xsl:for-each select="OBR">
						<tk_mstr>
							<TK_ID>
								<xsl:value-of select="../ZCF/ZCF.28"/>
							</TK_ID>
							<tk_lab_sample_ID>
								<xsl:value-of select="OBR.3/OBR.3.1"/>
							</tk_lab_sample_ID>
							<tk_test_desc>MPA</tk_test_desc>
							<SNP_ID>
								<xsl:value-of select="OBR.4/OBR.4.1"/>
							</SNP_ID>
							<SNP_gene>
								<xsl:value-of select="substring-before(OBR.4/OBR.4.2,'/')"/>
							</SNP_gene>
							<SNP_variation>
								<xsl:value-of select="substring-after(OBR.4/OBR.4.2,'/')"/>
							</SNP_variation>
							<coll_begin>
								<year>
									<xsl:value-of select="substring(OBR.7,'1','4')"/>
								</year>
								<month>
									<xsl:value-of select="substring(OBR.7,'5','2')"/>
								</month>
								<day>
									<xsl:value-of select="substring(OBR.7,'7','2')"/>
								</day>
							</coll_begin>
						</tk_mstr>
					</xsl:for-each>
					<xsl:for-each select="OBX">
						<tkr_det>
							<set_id>
								<xsl:value-of select="OBX.1"/>
							</set_id>
							<tkr_item>
								<xsl:value-of select="OBX.3/OBX.3.1"/>
							</tkr_item>
							<item-check>
								<xsl:value-of select="OBX.3/OBX.3.2"/>
							</item-check>
							<xsl:choose>
								<xsl:when test="OBX.1 = 1">
									<tkr_lab_ref>
										<xsl:value-of select="OBX.5/OBX.5.1"/>
									</tkr_lab_ref>
								</xsl:when>
								<xsl:otherwise>
									<tkr_lab_results>
										<xsl:value-of select="OBX.5/OBX.5.1"/>
									</tkr_lab_results>
								</xsl:otherwise>
							</xsl:choose>
						</tkr_det>
					</xsl:for-each>
				</TK_test_seq>
			</xsl:for-each>
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="MPA" userelativepaths="yes" externalpreview="no" url="..\HL7_XML_Files\DONT_TOUCH\HL7_MPA.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength=""
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
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="..\SS_XML_Files\DONT_TOUCH\SS_MPA.xml" destSchemaRoot="root" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="..\HL7_XML_Files\DONT_TOUCH\HL7_MPA.xml" srcSchemaRoot="HL7" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/xsl:for-each" x="390" y="72"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/year/xsl:value-of" x="230" y="252"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/month/xsl:value-of" x="390" y="270"/>
				<block path="root/xsl:for-each/TK_test_seq/people_mstr/people_dob/day/xsl:value-of" x="430" y="288"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each" x="390" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each/tk_mstr/SNP_gene/xsl:value-of" x="350" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each/tk_mstr/SNP_variation/xsl:value-of" x="310" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each/tk_mstr/coll_begin/year/xsl:value-of" x="190" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each/tk_mstr/coll_begin/month/xsl:value-of" x="150" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each/tk_mstr/coll_begin/day/xsl:value-of" x="110" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each[1]" x="430" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each[1]/tkr_det/xsl:choose" x="270" y="222"/>
				<block path="root/xsl:for-each/TK_test_seq/xsl:for-each[1]/tkr_det/xsl:choose/=[0]" x="224" y="216"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->