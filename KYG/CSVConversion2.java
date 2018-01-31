import com.stylusstudio.xmlpipeline.runtime.*;

// This file was automatically generated from:
// c:/apps/CSVConversion/TKconverter2.pipeline
//
// The following directories and jars must be in your classpath:
// c:/apps/CSVConversion/
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/Components/XML Converters for Java/lib/XMLConverters.jar
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/bin/saxonsa.jar
// C:/Program Files (x86)/Stylus Studio 2009 Release 2 XML Enterprise Suite/bin/Plugins/XMLPipeline.jar
//


public class CSVConversion2 extends AbstractPipeline implements PipelineOperation {

	public static final String REQUIRED_RUNTIME_VERSION = "Java Deployer 1.06";
	public static final String XQUERY_PROCESSOR = "DataDirect XQuery";
	public static final String FO_PROCESSOR = "RenderX XEP";
	public static final String VALIDATE_PROCESSOR = "Java built-in";
	public static final String XSLT_PROCESSOR = "Saxon";
	public static final String EXECUTION_LOG	= "stdout";

	private String inFile;
	private String outFile;
	private String corruptFile;


	public static void main(String[] args) throws Exception {

		if (args.length != 3) {
		  System.out.println("Error: Program expects 3 arguments. You supplied " + args.length);
		  return;
		}

		CSVConversion2 thePipeline = new CSVConversion2(args);
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
		manager.setProperty("XSLT", "Saxon");
		return manager;
	}




	ChooseOperation choose_2;
	SaxonXSLTOperation FM_xsl;
	SaxonXSLTOperation HE_xsl;
	SaxonXSLTOperation UTEE_xsl;
	SaxonXSLTOperation UTM_xsl;
	SaxonXSLTOperation KYG_xsl;

	EdgeImpl edge_2;
	EdgeImpl edge_3;
	EdgeImpl edge_4;
	EdgeImpl edge_5;
	EdgeImpl edge_6;

	public CSVConversion2(String[] args) {
		super("main", createRuntimeManager(), "file:///c:/apps/CSVConversion/TKconverter2.pipeline", REQUIRED_RUNTIME_VERSION);
		setParentEnvironment(null);
		
		// Create all the public ports required for the pipeline
		inFile = args[0];
		outFile = args[1];
		corruptFile = args[2];

	}


	public boolean init() throws Exception {

		// Create all the objects required for the pipeline
		choose_2 = new ChooseOperation("Choose #2", getEnvironment());
		choose_2.setXPathExpressions(new String[] {
				"//client_ref[starts-with(//client_ref/text(), 'FM')]",
				"//client_ref[starts-with(//client_ref/text(), 'HE')]",
				"//client_ref[starts-with(//client_ref/text(), 'UTEE')]",
				"//client_ref[starts-with(//client_ref/text(), 'UTM')]",
				"//client_ref[starts-with(//client_ref/text(), 'KYG')]",
			});
		FM_xsl = new SaxonXSLTOperation("FM.xsl", ContentType.UNKNOWN, getEnvironment());
		HE_xsl = new SaxonXSLTOperation("HE.xsl", ContentType.UNKNOWN, getEnvironment());
		UTEE_xsl = new SaxonXSLTOperation("UTEE.xsl", ContentType.UNKNOWN, getEnvironment());
		UTM_xsl = new SaxonXSLTOperation("UTM.xsl", ContentType.UNKNOWN, getEnvironment());
		KYG_xsl = new SaxonXSLTOperation("KYG.xsl", ContentType.UNKNOWN, getEnvironment());

		edge_2 = new EdgeImpl("edge_2", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_3 = new EdgeImpl("edge_3", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_4 = new EdgeImpl("edge_4", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_5 = new EdgeImpl("edge_5", getEnvironment(), DataType.NODE, DataType.DOCUMENT);
		edge_6 = new EdgeImpl("edge_6", getEnvironment(), DataType.NODE, DataType.DOCUMENT);

		// Connect all the operation objects with edge objects.
		choose_2.setInputUrl("Input #0", inFile, DataType.NODE);
		choose_2.addOutputEdge("Output #0", edge_2);
		choose_2.addOutputEdge("Output #1", edge_3);
		choose_2.addOutputEdge("Output #2", edge_4);
		choose_2.addOutputEdge("Output #3", edge_5);
		choose_2.addOutputEdge("Output #4", edge_6);
		choose_2.setOutputUrl("Output 'no match'", corruptFile, DataType.NODE);
		FM_xsl.setScriptUrl("CSVStandards/FM.xsl");
		FM_xsl.addInputEdge(edge_2);
		FM_xsl.setOutputUrl(outFile, DataType.ANY);
		HE_xsl.setScriptUrl("CSVStandards/HE.xsl");
		HE_xsl.addInputEdge(edge_3);
		HE_xsl.setOutputUrl(outFile, DataType.ANY);
		UTEE_xsl.setScriptUrl("CSVStandards/UTEE.xsl");
		UTEE_xsl.addInputEdge(edge_4);
		UTEE_xsl.setOutputUrl(outFile, DataType.ANY);
		UTM_xsl.setScriptUrl("CSVStandards/UTM.xsl");
		UTM_xsl.addInputEdge(edge_5);
		UTM_xsl.setOutputUrl(outFile, DataType.ANY);
		KYG_xsl.setScriptUrl("CSVStandards/KYG.xsl");
		KYG_xsl.addInputEdge(edge_6);
		KYG_xsl.setOutputUrl(outFile, DataType.ANY);

	
		return true;
	}
	
	public void process() throws Exception {
		choose_2.go();
		FM_xsl.go();
		HE_xsl.go();
		UTEE_xsl.go();
		UTM_xsl.go();
		KYG_xsl.go();
	}

	public void close() {
		closeOperation(KYG_xsl);
		closeOperation(UTM_xsl);
		closeOperation(UTEE_xsl);
		closeOperation(HE_xsl);
		closeOperation(FM_xsl);
		closeOperation(choose_2);
		getManager().close();
	}


}
