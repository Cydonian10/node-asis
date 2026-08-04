import PdfPrinter from 'pdfmake';
import { BufferOptions, TDocumentDefinitions } from 'pdfmake/interfaces.js';

const fonts = {
  Roboto: {
    normal: 'fonts/Roboto-Regular.ttf',
    bold: 'fonts/Roboto-Medium.ttf',
    italics: 'fonts/Roboto-Italic.ttf',
    bolditalics: 'fonts/Roboto-MediumItalic.ttf',
  },
};

class PrinterPdf {
  private printer = new PdfPrinter(fonts);

  public createPdf(
    docDefinition: TDocumentDefinitions,
    options: BufferOptions = {},
  ) {
    return this.printer.createPdfKitDocument(docDefinition, options);
  }
}

export const printerPdf = new PrinterPdf();
