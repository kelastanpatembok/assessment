package com.assessment.service;

import com.assessment.dto.CredentialDTO;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDFont;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.List;
import java.util.Locale;

/**
 * Renders a printable credentials sheet (username + password per student) to PDF.
 *
 * This is the only place plaintext passwords are persisted (as a file on disk, via
 * CredentialStorageService) — access to the generated file is gated behind the
 * SUPERADMIN-only /credentials/batches endpoints, never served from a public path.
 */
@Service
public class CredentialPdfService {

    private static final int ROWS_PER_PAGE = 30;
    private static final float MARGIN = 40f;
    private static final float ROW_HEIGHT = 18f;
    private static final Locale ID_LOCALE = new Locale("id", "ID");

    private static final PDFont FONT = PDType1Font.HELVETICA;
    private static final PDFont FONT_BOLD = PDType1Font.HELVETICA_BOLD;

    public byte[] generatePdf(List<CredentialDTO> credentials, String schoolName, String categoryName, LocalDateTime generatedAt) {
        try (PDDocument document = new PDDocument()) {
            List<List<CredentialDTO>> pages = paginate(credentials);
            if (pages.isEmpty()) {
                pages = List.of(List.of());
            }

            for (int pageIndex = 0; pageIndex < pages.size(); pageIndex++) {
                renderPage(document, pages.get(pageIndex), pageIndex, pages.size(), schoolName, categoryName, generatedAt);
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            document.save(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to generate credentials PDF", e);
        }
    }

    /**
     * Human-readable filename suggested on download: [School]-[TestCategory]-[Month]-[Year], no spaces.
     * Not used as the on-disk storage key (that's the batch ID) so collisions here are harmless.
     */
    public String buildDisplayFilename(String schoolName, String categoryName, LocalDateTime generatedAt) {
        String month = generatedAt.getMonth().getDisplayName(TextStyle.FULL, ID_LOCALE);
        String monthCapitalized = month.substring(0, 1).toUpperCase(ID_LOCALE) + month.substring(1);
        String base = String.format("%s-%s-%s-%d",
                stripSpaces(schoolName), stripSpaces(categoryName), monthCapitalized, generatedAt.getYear());
        return base + ".pdf";
    }

    private String stripSpaces(String value) {
        return value == null ? "" : value.replaceAll("\\s+", "");
    }

    private List<List<CredentialDTO>> paginate(List<CredentialDTO> credentials) {
        return java.util.stream.IntStream.range(0, (int) Math.ceil(credentials.size() / (double) ROWS_PER_PAGE))
                .mapToObj(i -> credentials.subList(i * ROWS_PER_PAGE, Math.min((i + 1) * ROWS_PER_PAGE, credentials.size())))
                .toList();
    }

    private void renderPage(PDDocument document, List<CredentialDTO> pageCredentials, int pageIndex, int totalPages,
                             String schoolName, String categoryName, LocalDateTime generatedAt) throws IOException {
        PDPage page = new PDPage(PDRectangle.A4);
        document.addPage(page);

        float pageWidth = PDRectangle.A4.getWidth();
        float pageHeight = PDRectangle.A4.getHeight();
        float contentWidth = pageWidth - (2 * MARGIN);

        try (PDPageContentStream stream = new PDPageContentStream(document, page)) {
            float y = pageHeight - MARGIN;

            y = writeCentered(stream, schoolName, FONT_BOLD, 16, pageWidth, y);
            y -= 4;
            y = writeCentered(stream, categoryName, FONT_BOLD, 12, pageWidth, y);
            y -= 2;
            String generatedLabel = "Generated on " + generatedAt.format(
                    DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy HH:mm", ID_LOCALE));
            y = writeCentered(stream, generatedLabel, FONT, 9, pageWidth, y);

            y -= 10;
            stream.setLineWidth(1f);
            stream.moveTo(MARGIN, y);
            stream.lineTo(pageWidth - MARGIN, y);
            stream.stroke();
            y -= 20;

            // Table columns: No. | Username | Password
            float colNoWidth = contentWidth * 0.09f;
            float colUserWidth = contentWidth * 0.53f;
            float colPassWidth = contentWidth * 0.38f;
            float colNoX = MARGIN;
            float colUserX = colNoX + colNoWidth;
            float colPassX = colUserX + colUserWidth;

            y = writeRow(stream, FONT_BOLD, 9.5f, y, colNoX, colUserX, colPassX, "No.", "Username", "Password");
            stream.moveTo(MARGIN, y + 4);
            stream.lineTo(pageWidth - MARGIN, y + 4);
            stream.stroke();
            y -= 4;

            int rowNumber = pageIndex * ROWS_PER_PAGE + 1;
            for (CredentialDTO credential : pageCredentials) {
                y = writeRow(stream, FONT, 9.5f, y, colNoX, colUserX, colPassX,
                        String.valueOf(rowNumber), credential.username(), credential.password());
                rowNumber++;
            }

            String footer = "Page " + (pageIndex + 1) + " of " + totalPages;
            writeCentered(stream, footer, FONT, 9, pageWidth, MARGIN);
        }
    }

    private float writeCentered(PDPageContentStream stream, String text, PDFont font, float size, float pageWidth, float y) throws IOException {
        float textWidth = font.getStringWidth(text) / 1000f * size;
        float x = (pageWidth - textWidth) / 2f;
        stream.beginText();
        stream.setFont(font, size);
        stream.newLineAtOffset(x, y);
        stream.showText(text);
        stream.endText();
        return y - (size + 4);
    }

    private float writeRow(PDPageContentStream stream, PDFont font, float size, float y,
                            float colNoX, float colUserX, float colPassX,
                            String no, String username, String password) throws IOException {
        stream.beginText();
        stream.setFont(font, size);
        stream.newLineAtOffset(colNoX, y);
        stream.showText(no);
        stream.endText();

        stream.beginText();
        stream.setFont(font, size);
        stream.newLineAtOffset(colUserX, y);
        stream.showText(username);
        stream.endText();

        stream.beginText();
        stream.setFont(font, size);
        stream.newLineAtOffset(colPassX, y);
        stream.showText(password);
        stream.endText();

        return y - ROW_HEIGHT;
    }
}
