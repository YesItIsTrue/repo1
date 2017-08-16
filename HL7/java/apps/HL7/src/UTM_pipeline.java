
import com.ddtek.xmlconverter.ConverterFactory;
import com.ddtek.xmlconverter.ConverterResolver;
import java.io.*;
import java.net.URI;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXParseException;

// This file was automatically generated from:
// file:///c:/apps/HL7/src/UTM_pipeline.pipeline
//
// The following directories and jars must be in your classpath:
// c:/apps/HL7/src/
// c:/apps/HL7/src/lib/XMLConverters.jar

public class UTM_pipeline implements ErrorHandler {

	int m_valErrorCount;
	int m_valWarningCount;

	public static void main(String[] args) throws Exception {

  	/* FILE DEFINITIONS */
    File inputFile = new File(args[0]);
    File outputFile1 = new File(args[1]);
    File outputFile2 = new File(args[2]);
    File outputFile3 = new File(args[3]);
    
  	/* CHECK TO MAKE SURE THE RIGHT NUMBER OF ARGUMENTS WERE GIVEN: */
    if(args.length != 4) {
      System.out.println("This program expects 4 arguments, an input file and three output files.");
      return;
    }

    /* CHECK TO MAKE SURE THE ARGUMENTS AREN'T EMPTY STRINGS: */
    for(int i = 0; i < args.length; i++) {
      if(args[i].trim().length() == 0) {
        System.out.println("Some wise guy tried to supply empty argument(s)!");
        return;
      }
    }

    /* CHECK TO MAKE SURE THAT THE INPUT FILE EXISTS: */
    if(!inputFile.isFile()) {
      System.out.println("The input file specified does not exist!");
      return;
    }

    /* CHECK TO MAKE SURE THAT THE FIRST OUTPUT FILE DOES NOT ALREADY EXIST: */
    if(outputFile1.exists()) {
      System.out.println("The first output file specified already exists!");
      return;
    }

    /* CHECK TO MAKE SURE THAT THE SECOND OUTPUT FILE DOES NOT ALREADY EXIST: */
    if(outputFile2.exists()) {
      System.out.println("The second output file specified already exists!");
      return;
    }
    
    /* CHECK TO MAKE SURE THAT THE THIRD OUTPUT FILE DOES NOT ALREADY EXIST: */
    if(outputFile3.exists()) {
      System.out.println("The third output file specified already exists!");
      return;
    }

		UTM_pipeline thePipeline = new UTM_pipeline();
		thePipeline.run("file:///c:/apps/HL7/src/UTM_pipeline.pipeline", inputFile.toURI(), outputFile1.toURI(), outputFile2.toURI(), outputFile3.toURI());
	}

	public void run(String baseString, URI inputFile, URI outputFile1, URI outputFile2, URI outputFile3) throws Exception {

		URI    baseURI = new URI(baseString);

		ConverterFactory  cFactory           = new ConverterFactory();
		ConverterResolver resolver           = cFactory.newResolver();
		SchemaFactory     sFactory           = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");
		Validator         validator          = null;
		TransformerFactory tFactory = TransformerFactory.newInstance();
		tFactory.setURIResolver(resolver);

		final String      copyTo_2_uri       = baseURI.resolve(outputFile2).toString();;
		final String      copyTo_3_uri       = baseURI.resolve(outputFile3).toString();;


		// Declarations for node validateOperator
		final String      validateOperator_uri= baseURI.resolve("SS_XML_Files/DONT_TOUCH/General_UTOX.xsd").toString();

		// Declares for XSLT node XSLTOperator
		String            XSLTOperator_uri   = baseURI.resolve("HL7toUTM.xsl").toString();
		final String      convertToXML_conv  = "converter:EDI:val=no:field=no:indent=yes:opt=yes:count=no:hexpand=yes:empty=empty";
		String            convertToXML_Input_path= baseURI.resolve(inputFile).toString();;
		final String      copyTo_uri         = baseURI.resolve(outputFile1).toString();
		File              temp_file          = null;
		OutputStream      temp_strm          = null;

		try {

			// Create a transformer for node XSLTOperator
			Transformer       XSLTOperator       = tFactory.newTransformer(new StreamSource(XSLTOperator_uri));

			System.out.println("Running node convertToXML");
			cFactory.newConvertToXML(convertToXML_conv).convert(new StreamSource(convertToXML_Input_path), new StreamResult(copyTo_uri));

			// Create a temp file buffer for the output from node XSLTOperator
			temp_file = File.createTempFile("pip", ".tmp");
			temp_strm = new FileOutputStream(temp_file);

			System.out.println("Running node XSLTOperator");
			XSLTOperator.transform(new StreamSource(copyTo_uri), new StreamResult(temp_strm));
			temp_strm.close();

			m_valErrorCount = m_valWarningCount = 0;
			try {
				System.out.println("Running node validateOperator");
				Schema validateOperator_schema = sFactory.newSchema(new StreamSource(validateOperator_uri));
				validator = validateOperator_schema.newValidator();
				validator.setErrorHandler(this);
				validator.validate(new StreamSource(temp_file));
			} catch(Exception e) {
				if (m_valErrorCount==0) {
					System.out.println("Validation error: " + e);
					m_valErrorCount = 1;
				}
			}

			if (m_valErrorCount != 0) {
				// The validation failed.
				System.out.println("Node validateOperator failed validation. Error count = " + m_valErrorCount);
				copyFileToFile(temp_file.getAbsolutePath(), new URI(copyTo_3_uri).getPath());
			}

			if (m_valErrorCount==0) {
				copyFileToFile(temp_file.getAbsolutePath(), new URI(copyTo_2_uri).getPath());
			}

		} finally {
			if (temp_strm != null) temp_strm.close();
			if (temp_file != null) temp_file.delete();
		}
	}

	// ErrorHandler implementation for Validation nodes
	public void warning(SAXParseException e) {
		if (m_valWarningCount < 100)
		System.out.println("Validation warning: " + e);
		m_valWarningCount++;
	}
	public void error(SAXParseException e) {
		if (m_valErrorCount < 100)
		System.out.println("Validation error: " + e);
		m_valErrorCount++;
	}
	public void fatalError(SAXParseException e) {
		if (m_valErrorCount < 100)
		System.out.println("Validation fatal error: " + e);
		m_valErrorCount++;
	}

	// Utility routine to copy one file to another file
	private static void copyFileToFile(String inputName, String outputName) throws IOException {
		InputStream inStream = null;
		OutputStream outStream = null;
		try {
			inStream = new FileInputStream(inputName);
			outStream = new FileOutputStream(outputName);
			byte[] buffer = new byte[8000];
			int ret;
			while( (ret=inStream.read(buffer, 0, buffer.length)) > 0)
				outStream.write(buffer, 0, ret);
		} finally {
			if (inStream != null) inStream.close();
			if (outStream != null) outStream.close();
		}
	}

}
