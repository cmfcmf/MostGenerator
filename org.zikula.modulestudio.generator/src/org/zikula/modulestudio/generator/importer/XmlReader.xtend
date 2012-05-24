package org.zikula.modulestudio.generator.importer

import java.io.File
import java.io.IOException
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.parsers.ParserConfigurationException
import org.w3c.dom.Document
import org.xml.sax.SAXException

class XmlReader {

    //String DTD = 'resources/pntables.dtd'
    File inputFile
    public Document document

    new(String fileName) throws Exception {
        if (fileName.isEmpty()) {
            throw new Exception(
                    "Error: invalid filename given. Please provide an xml file.");
        }
        inputFile = new File(fileName);
        readFileContent();
    }

    def private readFileContent() {
        try {
            val builderFactory = DocumentBuilderFactory::newInstance
            // Activate validation against document type definition
            builderFactory.setValidating(true)
            val builder = builderFactory.newDocumentBuilder

            // Set error handler
            // ErrorHandler errorHandler = new DefaultHandler();
            val errorHandler = new XmlReadErrorHandler()
            builder.errorHandler = errorHandler

            // Parse xml document and generate document object tree
            document = builder.parse(inputFile)
        } catch (ParserConfigurationException e) {
            println(e.toString)
        } catch (SAXException e) {
            println(e.toString)
        } catch (IOException e) {
            println(e.toString)
        }
        /**
         *
        try {
            val source = new DOMSource(document)
            val result = new StreamResult(System.out)
            val tf = TransformerFactory::newInstance
            val transformer = tf.newTransformer
            // pass dtd file for validation
            transformer.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM, this.DTD)
            transformer.transform(source, result)
        } catch (TransformerConfigurationException e) {
            println(e.toString)
        } catch (TransformerException e) {
            println(e.toString)
        }
         */
    }
}