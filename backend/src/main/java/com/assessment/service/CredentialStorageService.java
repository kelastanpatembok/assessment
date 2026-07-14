package com.assessment.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Local-disk storage for generated credential PDFs, keyed by batch ID (not the
 * human-readable filename, so collisions across batches are impossible).
 *
 * Not backed by S3/object storage yet — swap this out once that's available.
 * Files are only ever reachable through CredentialController's SUPERADMIN-gated
 * endpoints; nothing under this directory is served statically.
 */
@Slf4j
@Service
public class CredentialStorageService {

    @Value("${app.storage.credentials-path:./storage/credentials}")
    private String storagePath;

    public void save(Long batchId, byte[] pdfBytes) {
        try {
            Path dir = Paths.get(storagePath);
            Files.createDirectories(dir);
            Path file = dir.resolve(batchId + ".pdf");
            Files.write(file, pdfBytes);
            log.info("Credential PDF stored: batchId={}, path={}", batchId, file);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to store credential PDF for batch " + batchId, e);
        }
    }

    public byte[] read(Long batchId) {
        try {
            Path file = Paths.get(storagePath).resolve(batchId + ".pdf");
            return Files.readAllBytes(file);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to read credential PDF for batch " + batchId, e);
        }
    }

    public void delete(Long batchId) {
        try {
            Files.deleteIfExists(Paths.get(storagePath).resolve(batchId + ".pdf"));
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to delete credential PDF for batch " + batchId, e);
        }
    }
}
