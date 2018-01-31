import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ConvertKYGtoXML {

    private File csvDirectory;
    private File convertedDirectory;
    private File processedKYGFileDirectory;
    private File corruptKYGFileDirectory;
    private File errorLog;
    
    private ConvertKYGtoXML(String[] args) {
        if (args.length == 5) {
             csvDirectory = new File(args[0]);
             convertedDirectory = new File(args[1]);
             processedKYGFileDirectory = new File(args[2]);
             corruptKYGFileDirectory = new File(args[3]);
             errorLog = new File (args[4]);
        }
        else {
            System.out.println("Error: 5 parameters expected. You supplied " + args.length);
            System.exit(0);
        }
    }

    public static void main(String[] args) {
        ConvertKYGtoXML convertKYGtoXML = new ConvertKYGtoXML(args);
        convertKYGtoXML.runConversion();
    }

    private boolean runConversion() {
        File[] csvFiles = csvDirectory.listFiles();
        for (File csvFile : csvFiles) {
            if (csvFile.isFile() && csvFile.getName().toLowerCase().endsWith(".txt")) {
                try {
                    DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
                    DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
                    Document document = documentBuilder.newDocument();

                    //Create the root node of the xml document
                    Element rootElement = document.createElement("root");
                    document.appendChild(rootElement);

                    BufferedReader bufferedReader = new BufferedReader(new FileReader(csvFile));
                    String line;
                    int lineNumber = 0;
                    while ((line = bufferedReader.readLine()) != null) {
                        // This fancy regex splits on commas that are not found within quotes
                        String[] parts = line.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");

                        // Replace extra double quotes
                        for (int i = 0; i < parts.length; i++) {
                            parts[i] = parts[i].replace("\"", "").replace(" ", "_").replace("/", "-");
                        }

                        // The * indicates the end of a file
                        if (parts.length > 0 && (parts[0].startsWith("*") || parts[0].toLowerCase().startsWith("interpretation"))) {
                            break;
                        }

                        if (!createNode(parts, lineNumber, document, rootElement)) {
                            cleanUp(csvFile, parts, lineNumber);
                            break;
                        }
                        lineNumber++;
                    }
                    bufferedReader.close();

                    // Write the XML file to the file system
                    TransformerFactory transformerFactory = TransformerFactory.newInstance();
                    Transformer transformer = transformerFactory.newTransformer();
                    transformer.setOutputProperty(OutputKeys.METHOD, "xml");
                    transformer.setOutputProperty(OutputKeys.INDENT, "yes");
                    transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");
                    transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
                    DOMSource domSource = new DOMSource(document);
                    StreamResult streamResult = new StreamResult(new File(convertedDirectory.getPath() + "\\" + csvFile.getName().replace(".txt", ".xml").replace(".TXT", ".xml")));
                    transformer.transform(domSource, streamResult);
                    
                    //If everything has gone well, move the file from the drop directory to the completed directory
                    Path source = Paths.get(csvFile.getPath());
                    Path dest = Paths.get(processedKYGFileDirectory + "\\" + csvFile.getName());
                    try {
                        Files.move(source, dest);
                        System.out.println("Great Success!");
                    }
                    catch(Exception e) {
                        BufferedWriter errorWriter = new BufferedWriter(new FileWriter(errorLog));
                        errorWriter.write("ERROR: Could not move file to processed directory - " + csvFile.getPath());
                        errorWriter.close();
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return true;
    }

    private boolean createNode(String[] parts, int lineNumber, Document document, Element rootElement) {
        if ((parts.length == 1 || parts.length == 2) && lineNumber < 27) {
            if (parts[0].length() == 0) {
                return false;
            }

            Element element = document.createElement(parts[0]);
            element.appendChild(document.createTextNode(parts.length == 2 ? parts[1].replace("_", " ") : ""));
            rootElement.appendChild(element);
        }
        else if (parts.length > 2) {
            Element resultsElement = document.createElement("result");

            for (int i = 0; i < parts.length; i++) {
                Element result = document.createElement("result" + i);
                result.appendChild(document.createTextNode(parts[i].replace("_", " ")));
                resultsElement.appendChild(result);
            }
            rootElement.appendChild(resultsElement);
        }

        return true;
    }

    private boolean cleanUp(File csvFile, String[] parts, int lineNumber) {
        BufferedWriter bufferedWriter = null;
        try {
            // Write the error to the error log
            bufferedWriter = new BufferedWriter(new FileWriter(errorLog));
            bufferedWriter.write("ERROR: Unexpected row identifier - \"" + parts[0] + "\" in " + csvFile.getPath() + " on line " + lineNumber);

            // Delete the xml file in progress
            File corruptFile = new File(convertedDirectory.getPath() + "\\" + csvFile.getName());
            if (!corruptFile.delete()) {
                bufferedWriter.write("ERROR: Could not delete file - " + corruptFile.getPath());
            }

            // Move the corrupt file to the redo directory
            Path source = Paths.get(csvFile.getPath());
            Path dest = Paths.get(corruptKYGFileDirectory + "\\" + csvFile.getName());
            try {
                Files.move(source, dest);
                System.out.println("Great Success!");
            }
            catch(Exception e) {
                BufferedWriter errorWriter = new BufferedWriter(new FileWriter(errorLog));
                errorWriter.write("ERROR: Could not move file to corrupt directory - " + corruptFile.getPath());
                errorWriter.close();
            }
        }
        catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        finally {
            try {
                if (bufferedWriter != null)
                    bufferedWriter.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return true;
    }

}
