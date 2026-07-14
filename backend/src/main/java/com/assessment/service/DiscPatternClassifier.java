package com.assessment.service;

import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Classifies a converted D/I/S/C quadruple into one of the 40 classic DISC
 * patterns (pattern_index 1-40, looked up in disc_pattern_profiles).
 *
 * Ported directly from the 40 mutually-exclusive BH7:CU7 boolean formulas on
 * the "Psikogram" tab of the source spreadsheet (each one an AND(...) over
 * the converted D/I/S/C values) — same rules are reused for the MOST, LEAST
 * and DIF lines, just with different converted inputs. Rules are evaluated
 * in order and the first match wins, matching Excel's MATCH(1, range, 0).
 */
@Component
public class DiscPatternClassifier {

    public int classify(BigDecimal dConv, BigDecimal iConv, BigDecimal sConv, BigDecimal cConv) {
        double d = dConv.doubleValue();
        double i = iConv.doubleValue();
        double s = sConv.doubleValue();
        double c = cConv.doubleValue();

        if (d<=0 && i<=0 && s<=0 && c>0) return 1;
        if (d>0 && i<=0 && s<=0 && c<=0) return 2;
        if (d>0 && i<=0 && s<=0 && c>0 && c>=d) return 3;
        if (d>0 && i>0 && s<=0 && c<=0 && i>=d) return 4;
        if (d>0 && i>0 && s<=0 && c>0 && i>=d && d>=c) return 5;
        if (d>0 && i>0 && s>0 && c<=0 && i>=d && d>=s) return 6;
        if (d>0 && i>0 && s>0 && c<=0 && i>=s && s>=d) return 7;
        if (d>0 && i<=0 && s>0 && c>0 && s>=d && d>=c) return 8;
        if (d>0 && i>0 && s<=0 && c<=0 && d>=i) return 9;
        if (d>0 && i>0 && s>0 && c<=0 && d>=i && i>=s) return 10;
        if (d>0 && i<=0 && s>0 && c<=0 && d>=s) return 11;
        if (d<=0 && i>0 && s>0 && c>0 && c>=i && i>=s) return 12;
        if (d<=0 && i>0 && s>0 && c>0 && c>=s && s>=i) return 13;
        if (d<=0 && i>0 && s>0 && c>0 && i>=s && i>=c) return 14;
        if (d<=0 && i<=0 && s>0 && c<=0) return 15;
        if (d<=0 && i<=0 && s>0 && c>0 && c>=s) return 16;
        if (d<=0 && i<=0 && s>0 && c>0 && s>=c) return 17;
        if (i<=0 && s<=0 && d>0 && c>0 && d>=c) return 18;
        if (d>0 && i>0 && c>0 && s<=0 && d>=i && i>=c) return 19;
        if (d>0 && s>0 && i>0 && c<=0 && d>=s && s>=i) return 20;
        if (d>0 && s>0 && c>0 && i<=0 && d>=s && s>=c) return 21;
        if (d>0 && i>0 && c>0 && s<=0 && d>=c && c>=i) return 22;
        if (d>0 && s>0 && c>0 && i<=0 && d>=c && c>=s) return 23;
        if (d<=0 && s<=0 && c<=0 && i>0) return 24;
        if (i>0 && s>0 && d<=0 && c<=0 && i>=s) return 25;
        if (i>0 && c>0 && d<=0 && s<=0 && i>=c) return 26;
        if (d>0 && i>0 && c>0 && s<=0 && i>=c && c>=d) return 27;
        if (d<=0 && i>0 && s>0 && c>0 && i>=c && c>=s) return 28;
        if (d>0 && i<=0 && s>0 && c<=0 && s>=d) return 29;
        if (i>0 && s>0 && d<=0 && c<=0 && s>=i) return 30;
        if (d>0 && i>0 && s>0 && c<=0 && s>=d && d>=i) return 31;
        if (d>0 && i>0 && s>0 && c<=0 && s>=i && i>=d) return 32;
        if (i>0 && s>0 && c>0 && d<=0 && s>=i && i>=c) return 33;
        if (d>0 && i<=0 && s>0 && c>0 && s>=c && c>=d) return 34;
        if (i>0 && s>0 && c>0 && d<=0 && s>=c && c>=i) return 35;
        if (i>0 && c>0 && d<=0 && s<=0 && c>=i) return 36;
        if (d>0 && i>0 && c>0 && s<=0 && c>=d && d>=i) return 37;
        if (d>0 && s>0 && c>0 && i<=0 && c>=d && d>=s) return 38;
        if (d>0 && i>0 && c>0 && s<=0 && c>=i && i>=d) return 39;
        if (d>0 && s>0 && c>0 && i<=0 && c>=s && s>=d) return 40;

        // No rule matched (all-zero or a tie pattern the source spreadsheet
        // itself doesn't cover) — the spreadsheet's MATCH(1,...,0) would
        // throw #N/A here. Fall back to the closest single-dominant-trait
        // pattern so the report never breaks.
        double max = Math.max(Math.max(d, i), Math.max(s, c));
        if (max == d) return 2;
        if (max == i) return 24;
        if (max == s) return 15;
        return 1;
    }
}
