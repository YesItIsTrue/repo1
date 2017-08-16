<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<root xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:/C:/apps/HL7/src/SS_XML_Files/DONT_TOUCH/General_UTOX.xsd">
			<test_mstr>
				<test_lab_ID>
					<xsl:value-of select="HL7/ORU_R01/MSH/MSH.3/MSH.3.1"/>
				</test_lab_ID>
			</test_mstr>
			<people_mstr>
				<people_lastname>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.5/PID.5.1/PID.5.1.1"/>
				</people_lastname>
				<people_firstname>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.5/PID.5.2"/>
				</people_firstname>
				<people_midname>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.5/PID.5.3"/>
				</people_midname>
				<people_perfname>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.9/PID.9.1/PID.9.1.1"/>
				</people_perfname>
				<people_dob>
					<year>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.7,'1','4')"/>
					</year>
					<month>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.7,'5','2')"/>
					</month>
					<day>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.7,'7','2')"/>
					</day>
				</people_dob>
				<people_gender>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.8"/>
				</people_gender>
				<people_homephone>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.13/PID.13.1"/>
				</people_homephone>
				<people_workphone>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.14/PID.14.1"/>
				</people_workphone>
				<people__char1>
					<SSN>
						<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.19"/>
					</SSN>
				</people__char1>
			</people_mstr>
			<patent_mstr>
				<patent_comments>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_4/NTE/NTE.3"/>
				</patent_comments>
			</patent_mstr>
			<addr_mstr>
				<addr_addr1>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.11/PID.11.1"/>
				</addr_addr1>
				<addr_addr2>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.11/PID.11.2"/>
				</addr_addr2>
				<addr_city>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.11/PID.11.3"/>
				</addr_city>
				<state_iso>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.11/PID.11.4"/>
				</state_iso>
				<addr_zip>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.11/PID.11.5"/>
				</addr_zip>
				<country_iso>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_2/PID/PID.12"/>
				</country_iso>
			</addr_mstr>
			<tk_mstr>
				<TK_ID>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_4/ZCF/ZCF.28"/>
				</TK_ID>
				<tk_lab_sample_ID>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.3/OBR.3.1"/>
				</tk_lab_sample_ID>
				<tk_test_desc>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.4/OBR.4.2"/>
				</tk_test_desc>
				<coll_begin>
					<year>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.7,'1','4')"/>
					</year>
					<month>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.7,'5','2')"/>
					</month>
					<day>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.7,'7','2')"/>
					</day>
				</coll_begin>
				<coll_end>
					<year>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.8,'1','4')"/>
					</year>
					<month>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.8,'5','2')"/>
					</month>
					<day>
						<xsl:value-of select="substring(HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.8,'7','2')"/>
					</day>
				</coll_end>
				<volume>
					<xsl:value-of select="HL7/ORU_R01/GROUP_1/GROUP_4/OBR/OBR.9/OBR.9.1"/>
				</volume>
			</tk_mstr>
			<xsl:for-each select="HL7/ORU_R01/GROUP_1/GROUP_4/GROUP_5/OBX">
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
		</root>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="DATE_HL7_FILENAME.xml" userelativepaths="yes" externalpreview="no" url="HL7_XML_Files\DONT_TOUCH\DATE_HL7_FILENAME.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0"
		          profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="yes"
		          validator="internal" customvalidator="">
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
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="SS_XML_Files\DONT_TOUCH\DATE_SS_FILENAME.xml" destSchemaRoot="root" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="HL7_XML_Files\DONT_TOUCH\DATE_HL7_FILENAME.xml" srcSchemaRoot="HL7" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="root/people_mstr/people_dob/year/xsl:value-of" x="435" y="216"/>
				<block path="root/people_mstr/people_dob/month/xsl:value-of" x="355" y="234"/>
				<block path="root/people_mstr/people_dob/day/xsl:value-of" x="395" y="252"/>
				<block path="root/tk_mstr/coll_begin/year/xsl:value-of" x="315" y="215"/>
				<block path="root/tk_mstr/coll_begin/month/xsl:value-of" x="275" y="215"/>
				<block path="root/tk_mstr/coll_begin/day/xsl:value-of" x="235" y="215"/>
				<block path="root/tk_mstr/coll_end/year/xsl:value-of" x="195" y="215"/>
				<block path="root/tk_mstr/coll_end/month/xsl:value-of" x="155" y="215"/>
				<block path="root/tk_mstr/coll_end/day/xsl:value-of" x="115" y="215"/>
				<block path="root/xsl:for-each" x="395" y="215"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->