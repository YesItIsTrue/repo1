/* ADD IMPORT FOR JAVA.IO AND JAVA.NET.URI: */
import java.io.*;
import java.net.URI;

import com.stylusstudio.xmlpipeline.runtime.*;

// This file was automatically generated from: 
// c:/apps/HL7/src/HL7toSS.pipeline
//
// The following directories and jars must be in your classpath:
// c:/apps/HL7/src/
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/Components/XML Converters for Java/lib/XMLConverters.jar
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/bin/saxonsa.jar
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/bin/Plugins/XMLPipeline.jar
//


public class HL7toSS extends AbstractPipeline implements PipelineOperation {

public static final String REQUIRED_RUNTIME_VERSION = "Java Deployer 1.06";
public static final String XQUERY_PROCESSOR = "DataDirect XQuery";
public static final String FO_PROCESSOR = "RenderX XEP";
public static final String VALIDATE_PROCESSOR = "Java built-in";
public static final String XSLT_PROCESSOR = "Java built-in";
public static final String EXECUTION_LOG	= "stdout";

    /* DECLARE CLASS VARIABLES HERE */
    private static URI inboundFileArg;
    private static URI HL7FileArg;
    private static URI MPAXMLFileArg;
    private static URI MPAXMLErrorFileArg;
    private static URI BioMedXMLFileArg;
    private static URI BioMedXMLErrorFileArg;


	public static void main(String[] args) throws Exception {
		
	  	/* CHECK TO MAKE SURE THE RIGHT NUMBER OF ARGUMENTS WERE GIVEN: */
	    if(args.length != 6) {
	      System.out.println("This program expects 6 arguments.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE ARGUMENTS AREN'T EMPTY STRINGS: */
	    for(int i = 0; i < args.length; i++) {
	      if(args[i].trim().length() == 0) {
	        System.out.println("Some wise guy tried to supply empty argument(s)!");
	        return;
	      }
	    }
	    
	    /* DECLARE FILES FOR USE IN PRESENCE CHECKS: */
	    File inboundFile = new File(args[0].trim());
	    File HL7File = new File(args[1].trim());
	    File MPAXMLFile = new File(args[2].trim());
	    File MPAXMLErrorFile = new File(args[3].trim());
	    File BioMedXMLFile = new File(args[4].trim());
	    File BioMedXMLErrorFile = new File(args[5].trim());
	    
	    /* CHECK TO MAKE SURE THE INPUT FILE EXISTS: */
	    if(!inboundFile.isFile()) {
	      System.out.println("The input file specified does not exist.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE HL7 FILE DOES NOT EXIST: */
	    if(HL7File.exists()) {
	      System.out.println("The HL7 XML file specified already exists.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE MPA XML FILE DOES NOT EXIST: */
	    if(MPAXMLFile.exists()) {
	      System.out.println("The MPA XML file specified already exists.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE MPA XML ERROR FILE DOES NOT EXIST: */
	    if(MPAXMLErrorFile.exists()) {
	      System.out.println("The MPA XML error file specified already exists.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE BIOMED XML FILE DOES NOT EXIST: */
	    if(BioMedXMLFile.exists()) {
	      System.out.println("The BioMed XML file specified already exists.");
	      return;
	    }
	    
	    /* CHECK TO MAKE SURE THE BIOMED XML ERROR FILE DOES NOT EXIST: */
	    if(BioMedXMLErrorFile.exists()) {
	      System.out.println("The BioMed XML Error file specified already exists.");
	      return;
	    }

		HL7toSS thePipeline = new HL7toSS();
		
		/* ALL CHECKS PASSED */
		/* ASSIGN THE SPECIFIED ARGUMENTS TO THE CLASS VARIABLES: */
		HL7toSS.inboundFileArg = inboundFile.toURI();
		HL7toSS.HL7FileArg = HL7File.toURI();
		HL7toSS.MPAXMLFileArg = MPAXMLFile.toURI();
		HL7toSS.MPAXMLErrorFileArg = MPAXMLErrorFile.toURI();
		HL7toSS.BioMedXMLFileArg = BioMedXMLFile.toURI();
		HL7toSS.BioMedXMLErrorFileArg = BioMedXMLErrorFile.toURI();
		
		try {
			// If an embedding application needs to bind to any input or output 
			// ports, that code would go here, before the call to go();

			thePipeline.go();
		} finally {
			thePipeline.close();
		}
	}

	public static RuntimeManager createRuntimeManager() {
		RuntimeManager manager = new RuntimeManager();
		manager.setExecutionLog(EXECUTION_LOG);
		manager.setProperty("XQuery", "DataDirect XQuery");
		manager.setProperty("FO", "RenderX XEP");
		manager.setProperty("Validate", "Java built-in");
		manager.setProperty("XSLT", "Java built-in");
		return manager;
	}




	ConvertToXML convertToXML;
	ChooseOperation choose;
	XSLTOperation MPAXSLTOperator;
	XercesValidateOperation MPAValidateOperator;
	XSLTOperation BIOMEDXSLTOperator;
	XercesValidateOperation BIOMEDValidateOperator;

	EdgeImpl edge_2;
	EdgeImpl edge_3;
	EdgeImpl edge_4;
	EdgeImpl edge_5;
	EdgeImpl edge_6;

	public HL7toSS() {
		super("main", createRuntimeManager(), "file:///c:/apps/HL7/src/HL7toSS.pipeline", REQUIRED_RUNTIME_VERSION);
		setParentEnvironment(null);
		
		// Create all the public ports required for the pipeline

	}


	public boolean init() throws Exception {

		// Create all the objects required for the pipeline
		convertToXML = new ConvertToXML("Convert to XML", getEnvironment());
		convertToXML.setAdapter("converter:EDI:user=file://c:\\apps\\HL7\\src\\SEF_files\\HL7Converter.sef");
		choose = new ChooseOperation("Choose", getEnvironment());
		choose.setXPathExpressions(new String[] {
				"//OBR//OBR.4.2[contains(text(),\"/\")]",
			});
		MPAXSLTOperator = new XSLTOperation("MPA XSLT operator", ContentType.XML, getEnvironment());
		MPAValidateOperator = new XercesValidateOperation("MPA Validate operator", getEnvironment());
		MPAValidateOperator.setSchemaUrl("SS_XML_Files/DONT_TOUCH/SS_MPA.xsd;");
		BIOMEDXSLTOperator = new XSLTOperation("BIOMED XSLT operator", ContentType.XML, getEnvironment());
		BIOMEDValidateOperator = new XercesValidateOperation("BIOMED Validate operator", getEnvironment());
		BIOMEDValidateOperator.setSchemaUrl("SS_XML_Files/DONT_TOUCH/SS_BIOMED.xsd;");

		edge_2 = new EdgeImpl("edge_2", getEnvironment(), DataType.NODE, DataType.NODE);
		edge_3 = new EdgeImpl("edge_3", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_4 = new EdgeImpl("edge_4", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_5 = new EdgeImpl("edge_5", getEnvironment(), DataType.NODE, DataType.NODE);
		edge_6 = new EdgeImpl("edge_6", getEnvironment(), DataType.NODE, DataType.NODE);

		// Connect all the operation objects with edge objects.

		// convertToXML.setInputUrl("Inbound_EDI_Files/Sample_UTOX_HL7.txt", DataType.NONE);
		convertToXML.setInputUrl(HL7toSS.inboundFileArg.toString(), DataType.NONE);
		
		// convertToXML.setOutputUrl("HL7_XML_Files/HL7_OUTPUT.xml", DataType.NODE);
		convertToXML.setOutputUrl(HL7toSS.HL7FileArg.toString(), DataType.NODE);
		
		convertToXML.addOutputEdge(edge_2);
		choose.addInputEdge("Input #0", edge_2);
		choose.addOutputEdge("Output #0", edge_3);
		choose.addOutputEdge("Output 'no match'", edge_4);
		MPAXSLTOperator.setScriptUrl("XSL_files/MPA.xsl");
		MPAXSLTOperator.addInputEdge(edge_3);
		MPAXSLTOperator.addOutputEdge(edge_5);
		MPAValidateOperator.addInputEdge(edge_5);
		
		// MPAValidateOperator.setOutputUrl("Output valid", "SS_XML_Files/SS_MPA_OUTPUT.xml", DataType.NODE);
		MPAValidateOperator.setOutputUrl("Output valid", HL7toSS.MPAXMLFileArg.toString(), DataType.NODE);
		
		// MPAValidateOperator.setOutputUrl("Output invalid", "Error_log/ERROR_MPA_OUTPUT.xml", DataType.NODE);
		MPAValidateOperator.setOutputUrl("Output invalid", HL7toSS.MPAXMLErrorFileArg.toString(), DataType.NODE);
				
		BIOMEDXSLTOperator.setScriptUrl("XSL_files/BIOMED.xsl");
		BIOMEDXSLTOperator.addInputEdge(edge_4);
		BIOMEDXSLTOperator.addOutputEdge(edge_6);
		BIOMEDValidateOperator.addInputEdge(edge_6);
		
		// BIOMEDValidateOperator.setOutputUrl("Output valid", "SS_XML_Files/SS_BIOMED_OUTPUT.xml", DataType.NODE);
		BIOMEDValidateOperator.setOutputUrl("Output valid", HL7toSS.BioMedXMLFileArg.toString(), DataType.NODE);
		
		//BIOMEDValidateOperator.setOutputUrl("Output invalid", "Error_log/ERROR_BIOMED_OUTPUT.xml", DataType.NODE);
		BIOMEDValidateOperator.setOutputUrl("Output invalid", HL7toSS.BioMedXMLErrorFileArg.toString(), DataType.NODE);
	
		return true;
	}
	
	public void process() throws Exception {
		convertToXML.go();
		choose.go();
		MPAXSLTOperator.go();
		MPAValidateOperator.go();
		BIOMEDXSLTOperator.go();
		BIOMEDValidateOperator.go();
	}

	public void close() {
		closeOperation(BIOMEDValidateOperator);
		closeOperation(BIOMEDXSLTOperator);
		closeOperation(MPAValidateOperator);
		closeOperation(MPAXSLTOperator);
		closeOperation(choose);
		closeOperation(convertToXML);
		getManager().close();
	}


}
