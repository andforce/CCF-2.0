//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CharUnicodeBlock.h"


@implementation CharUnicodeBlock
int const blockStarts[] = {
        0x0000,   // 0000..007F; Basic Latin
        0x0080,   // 0080..00FF; Latin-1 Supplement
        0x0100,   // 0100..017F; Latin Extended-A
        0x0180,   // 0180..024F; Latin Extended-B
        0x0250,   // 0250..02AF; IPA Extensions
        0x02B0,   // 02B0..02FF; Spacing Modifier Letters
        0x0300,   // 0300..036F; Combining Diacritical Marks
        0x0370,   // 0370..03FF; Greek and Coptic
        0x0400,   // 0400..04FF; Cyrillic
        0x0500,   // 0500..052F; Cyrillic Supplement
        0x0530,   // 0530..058F; Armenian
        0x0590,   // 0590..05FF; Hebrew
        0x0600,   // 0600..06FF; Arabic
        0x0700,   // 0700..074F; Syriac
        0x0750,   // 0750..077F; Arabic Supplement
        0x0780,   // 0780..07BF; Thaana
        0x07C0,   // 07C0..07FF; NKo
        0x0800,   // 0800..083F; Samaritan
        0x0840,   // 0840..085F; Mandaic
        0x0860,   //             unassigned
        0x08A0,   // 08A0..08FF; Arabic Extended-A
        0x0900,   // 0900..097F; Devanagari
        0x0980,   // 0980..09FF; Bengali
        0x0A00,   // 0A00..0A7F; Gurmukhi
        0x0A80,   // 0A80..0AFF; Gujarati
        0x0B00,   // 0B00..0B7F; Oriya
        0x0B80,   // 0B80..0BFF; Tamil
        0x0C00,   // 0C00..0C7F; Telugu
        0x0C80,   // 0C80..0CFF; Kannada
        0x0D00,   // 0D00..0D7F; Malayalam
        0x0D80,   // 0D80..0DFF; Sinhala
        0x0E00,   // 0E00..0E7F; Thai
        0x0E80,   // 0E80..0EFF; Lao
        0x0F00,   // 0F00..0FFF; Tibetan
        0x1000,   // 1000..109F; Myanmar
        0x10A0,   // 10A0..10FF; Georgian
        0x1100,   // 1100..11FF; Hangul Jamo
        0x1200,   // 1200..137F; Ethiopic
        0x1380,   // 1380..139F; Ethiopic Supplement
        0x13A0,   // 13A0..13FF; Cherokee
        0x1400,   // 1400..167F; Unified Canadian Aboriginal Syllabics
        0x1680,   // 1680..169F; Ogham
        0x16A0,   // 16A0..16FF; Runic
        0x1700,   // 1700..171F; Tagalog
        0x1720,   // 1720..173F; Hanunoo
        0x1740,   // 1740..175F; Buhid
        0x1760,   // 1760..177F; Tagbanwa
        0x1780,   // 1780..17FF; Khmer
        0x1800,   // 1800..18AF; Mongolian
        0x18B0,   // 18B0..18FF; Unified Canadian Aboriginal Syllabics Extended
        0x1900,   // 1900..194F; Limbu
        0x1950,   // 1950..197F; Tai Le
        0x1980,   // 1980..19DF; New Tai Lue
        0x19E0,   // 19E0..19FF; Khmer Symbols
        0x1A00,   // 1A00..1A1F; Buginese
        0x1A20,   // 1A20..1AAF; Tai Tham
        0x1AB0,   //             unassigned
        0x1B00,   // 1B00..1B7F; Balinese
        0x1B80,   // 1B80..1BBF; Sundanese
        0x1BC0,   // 1BC0..1BFF; Batak
        0x1C00,   // 1C00..1C4F; Lepcha
        0x1C50,   // 1C50..1C7F; Ol Chiki
        0x1C80,   //             unassigned
        0x1CC0,   // 1CC0..1CCF; Sundanese Supplement
        0x1CD0,   // 1CD0..1CFF; Vedic Extensions
        0x1D00,   // 1D00..1D7F; Phonetic Extensions
        0x1D80,   // 1D80..1DBF; Phonetic Extensions Supplement
        0x1DC0,   // 1DC0..1DFF; Combining Diacritical Marks Supplement
        0x1E00,   // 1E00..1EFF; Latin Extended Additional
        0x1F00,   // 1F00..1FFF; Greek Extended
        0x2000,   // 2000..206F; General Punctuation
        0x2070,   // 2070..209F; Superscripts and Subscripts
        0x20A0,   // 20A0..20CF; Currency Symbols
        0x20D0,   // 20D0..20FF; Combining Diacritical Marks for Symbols
        0x2100,   // 2100..214F; Letterlike Symbols
        0x2150,   // 2150..218F; Number Forms
        0x2190,   // 2190..21FF; Arrows
        0x2200,   // 2200..22FF; Mathematical Operators
        0x2300,   // 2300..23FF; Miscellaneous Technical
        0x2400,   // 2400..243F; Control Pictures
        0x2440,   // 2440..245F; Optical Character Recognition
        0x2460,   // 2460..24FF; Enclosed Alphanumerics
        0x2500,   // 2500..257F; Box Drawing
        0x2580,   // 2580..259F; Block Elements
        0x25A0,   // 25A0..25FF; Geometric Shapes
        0x2600,   // 2600..26FF; Miscellaneous Symbols
        0x2700,   // 2700..27BF; Dingbats
        0x27C0,   // 27C0..27EF; Miscellaneous Mathematical Symbols-A
        0x27F0,   // 27F0..27FF; Supplemental Arrows-A
        0x2800,   // 2800..28FF; Braille Patterns
        0x2900,   // 2900..297F; Supplemental Arrows-B
        0x2980,   // 2980..29FF; Miscellaneous Mathematical Symbols-B
        0x2A00,   // 2A00..2AFF; Supplemental Mathematical Operators
        0x2B00,   // 2B00..2BFF; Miscellaneous Symbols and Arrows
        0x2C00,   // 2C00..2C5F; Glagolitic
        0x2C60,   // 2C60..2C7F; Latin Extended-C
        0x2C80,   // 2C80..2CFF; Coptic
        0x2D00,   // 2D00..2D2F; Georgian Supplement
        0x2D30,   // 2D30..2D7F; Tifinagh
        0x2D80,   // 2D80..2DDF; Ethiopic Extended
        0x2DE0,   // 2DE0..2DFF; Cyrillic Extended-A
        0x2E00,   // 2E00..2E7F; Supplemental Punctuation
        0x2E80,   // 2E80..2EFF; CJK Radicals Supplement
        0x2F00,   // 2F00..2FDF; Kangxi Radicals
        0x2FE0,   //             unassigned
        0x2FF0,   // 2FF0..2FFF; Ideographic Description Characters
        0x3000,   // 3000..303F; CJK Symbols and Punctuation
        0x3040,   // 3040..309F; Hiragana
        0x30A0,   // 30A0..30FF; Katakana
        0x3100,   // 3100..312F; Bopomofo
        0x3130,   // 3130..318F; Hangul Compatibility Jamo
        0x3190,   // 3190..319F; Kanbun
        0x31A0,   // 31A0..31BF; Bopomofo Extended
        0x31C0,   // 31C0..31EF; CJK Strokes
        0x31F0,   // 31F0..31FF; Katakana Phonetic Extensions
        0x3200,   // 3200..32FF; Enclosed CJK Letters and Months
        0x3300,   // 3300..33FF; CJK Compatibility
        0x3400,   // 3400..4DBF; CJK Unified Ideographs Extension A
        0x4DC0,   // 4DC0..4DFF; Yijing Hexagram Symbols
        0x4E00,   // 4E00..9FFF; CJK Unified Ideographs
        0xA000,   // A000..A48F; Yi Syllables
        0xA490,   // A490..A4CF; Yi Radicals
        0xA4D0,   // A4D0..A4FF; Lisu
        0xA500,   // A500..A63F; Vai
        0xA640,   // A640..A69F; Cyrillic Extended-B
        0xA6A0,   // A6A0..A6FF; Bamum
        0xA700,   // A700..A71F; Modifier Tone Letters
        0xA720,   // A720..A7FF; Latin Extended-D
        0xA800,   // A800..A82F; Syloti Nagri
        0xA830,   // A830..A83F; Common Indic Number Forms
        0xA840,   // A840..A87F; Phags-pa
        0xA880,   // A880..A8DF; Saurashtra
        0xA8E0,   // A8E0..A8FF; Devanagari Extended
        0xA900,   // A900..A92F; Kayah Li
        0xA930,   // A930..A95F; Rejang
        0xA960,   // A960..A97F; Hangul Jamo Extended-A
        0xA980,   // A980..A9DF; Javanese
        0xA9E0,   //             unassigned
        0xAA00,   // AA00..AA5F; Cham
        0xAA60,   // AA60..AA7F; Myanmar Extended-A
        0xAA80,   // AA80..AADF; Tai Viet
        0xAAE0,   // AAE0..AAFF; Meetei Mayek Extensions
        0xAB00,   // AB00..AB2F; Ethiopic Extended-A
        0xAB30,   //             unassigned
        0xABC0,   // ABC0..ABFF; Meetei Mayek
        0xAC00,   // AC00..D7AF; Hangul Syllables
        0xD7B0,   // D7B0..D7FF; Hangul Jamo Extended-B
        0xD800,   // D800..DB7F; High Surrogates
        0xDB80,   // DB80..DBFF; High Private Use Surrogates
        0xDC00,   // DC00..DFFF; Low Surrogates
        0xE000,   // E000..F8FF; Private Use Area
        0xF900,   // F900..FAFF; CJK Compatibility Ideographs
        0xFB00,   // FB00..FB4F; Alphabetic Presentation Forms
        0xFB50,   // FB50..FDFF; Arabic Presentation Forms-A
        0xFE00,   // FE00..FE0F; Variation Selectors
        0xFE10,   // FE10..FE1F; Vertical Forms
        0xFE20,   // FE20..FE2F; Combining Half Marks
        0xFE30,   // FE30..FE4F; CJK Compatibility Forms
        0xFE50,   // FE50..FE6F; Small Form Variants
        0xFE70,   // FE70..FEFF; Arabic Presentation Forms-B
        0xFF00,   // FF00..FFEF; Halfwidth and Fullwidth Forms
        0xFFF0,   // FFF0..FFFF; Specials
        0x10000,  // 10000..1007F; Linear B Syllabary
        0x10080,  // 10080..100FF; Linear B Ideograms
        0x10100,  // 10100..1013F; Aegean Numbers
        0x10140,  // 10140..1018F; Ancient Greek Numbers
        0x10190,  // 10190..101CF; Ancient Symbols
        0x101D0,  // 101D0..101FF; Phaistos Disc
        0x10200,  //               unassigned
        0x10280,  // 10280..1029F; Lycian
        0x102A0,  // 102A0..102DF; Carian
        0x102E0,  //               unassigned
        0x10300,  // 10300..1032F; Old Italic
        0x10330,  // 10330..1034F; Gothic
        0x10350,  //               unassigned
        0x10380,  // 10380..1039F; Ugaritic
        0x103A0,  // 103A0..103DF; Old Persian
        0x103E0,  //               unassigned
        0x10400,  // 10400..1044F; Deseret
        0x10450,  // 10450..1047F; Shavian
        0x10480,  // 10480..104AF; Osmanya
        0x104B0,  //               unassigned
        0x10800,  // 10800..1083F; Cypriot Syllabary
        0x10840,  // 10840..1085F; Imperial Aramaic
        0x10860,  //               unassigned
        0x10900,  // 10900..1091F; Phoenician
        0x10920,  // 10920..1093F; Lydian
        0x10940,  //               unassigned
        0x10980,  // 10980..1099F; Meroitic Hieroglyphs
        0x109A0,  // 109A0..109FF; Meroitic Cursive
        0x10A00,  // 10A00..10A5F; Kharoshthi
        0x10A60,  // 10A60..10A7F; Old South Arabian
        0x10A80,  //               unassigned
        0x10B00,  // 10B00..10B3F; Avestan
        0x10B40,  // 10B40..10B5F; Inscriptional Parthian
        0x10B60,  // 10B60..10B7F; Inscriptional Pahlavi
        0x10B80,  //               unassigned
        0x10C00,  // 10C00..10C4F; Old Turkic
        0x10C50,  //               unassigned
        0x10E60,  // 10E60..10E7F; Rumi Numeral Symbols
        0x10E80,  //               unassigned
        0x11000,  // 11000..1107F; Brahmi
        0x11080,  // 11080..110CF; Kaithi
        0x110D0,  // 110D0..110FF; Sora Sompeng
        0x11100,  // 11100..1114F; Chakma
        0x11150,  //               unassigned
        0x11180,  // 11180..111DF; Sharada
        0x111E0,  //               unassigned
        0x11680,  // 11680..116CF; Takri
        0x116D0,  //               unassigned
        0x12000,  // 12000..123FF; Cuneiform
        0x12400,  // 12400..1247F; Cuneiform Numbers and Punctuation
        0x12480,  //               unassigned
        0x13000,  // 13000..1342F; Egyptian Hieroglyphs
        0x13430,  //               unassigned
        0x16800,  // 16800..16A3F; Bamum Supplement
        0x16A40,  //               unassigned
        0x16F00,  // 16F00..16F9F; Miao
        0x16FA0,  //               unassigned
        0x1B000,  // 1B000..1B0FF; Kana Supplement
        0x1B100,  //               unassigned
        0x1D000,  // 1D000..1D0FF; Byzantine Musical Symbols
        0x1D100,  // 1D100..1D1FF; Musical Symbols
        0x1D200,  // 1D200..1D24F; Ancient Greek Musical Notation
        0x1D250,  //               unassigned
        0x1D300,  // 1D300..1D35F; Tai Xuan Jing Symbols
        0x1D360,  // 1D360..1D37F; Counting Rod Numerals
        0x1D380,  //               unassigned
        0x1D400,  // 1D400..1D7FF; Mathematical Alphanumeric Symbols
        0x1D800,  //               unassigned
        0x1EE00,  // 1EE00..1EEFF; Arabic Mathematical Alphabetic Symbols
        0x1EF00,  //               unassigned
        0x1F000,  // 1F000..1F02F; Mahjong Tiles
        0x1F030,  // 1F030..1F09F; Domino Tiles
        0x1F0A0,  // 1F0A0..1F0FF; Playing Cards
        0x1F100,  // 1F100..1F1FF; Enclosed Alphanumeric Supplement
        0x1F200,  // 1F200..1F2FF; Enclosed Ideographic Supplement
        0x1F300,  // 1F300..1F5FF; Miscellaneous Symbols And Pictographs
        0x1F600,  // 1F600..1F64F; Emoticons
        0x1F650,  //               unassigned
        0x1F680,  // 1F680..1F6FF; Transport And Map Symbols
        0x1F700,  // 1F700..1F77F; Alchemical Symbols
        0x1F780,  //               unassigned
        0x20000,  // 20000..2A6DF; CJK Unified Ideographs Extension B
        0x2A6E0,  //               unassigned
        0x2A700,  // 2A700..2B73F; CJK Unified Ideographs Extension C
        0x2B740,  // 2B740..2B81F; CJK Unified Ideographs Extension D
        0x2B820,  //               unassigned
        0x2F800,  // 2F800..2FA1F; CJK Compatibility Ideographs Supplement
        0x2FA20,  //               unassigned
        0xE0000,  // E0000..E007F; Tags
        0xE0080,  //               unassigned
        0xE0100,  // E0100..E01EF; Variation Selectors Supplement
        0xE01F0,  //               unassigned
        0xF0000,  // F0000..FFFFF; Supplementary Private Use Area-A
        0x100000  // 100000..10FFFF; Supplementary Private Use Area-B
};

int const blocks[] = {
        BASIC_LATIN,
        LATIN_1_SUPPLEMENT,
        LATIN_EXTENDED_A,
        LATIN_EXTENDED_B,
        IPA_EXTENSIONS,
        SPACING_MODIFIER_LETTERS,
        COMBINING_DIACRITICAL_MARKS,
        GREEK,
        CYRILLIC,
        CYRILLIC_SUPPLEMENTARY,
        ARMENIAN,
        HEBREW,
        ARABIC,
        SYRIAC,
        ARABIC_SUPPLEMENT,
        THAANA,
        NKO,
        SAMARITAN,
        MANDAIC,
        null,
        ARABIC_EXTENDED_A,
        DEVANAGARI,
        BENGALI,
        GURMUKHI,
        GUJARATI,
        ORIYA,
        TAMIL,
        TELUGU,
        KANNADA,
        MALAYALAM,
        SINHALA,
        THAI,
        LAO,
        TIBETAN,
        MYANMAR,
        GEORGIAN,
        HANGUL_JAMO,
        ETHIOPIC,
        ETHIOPIC_SUPPLEMENT,
        CHEROKEE,
        UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS,
        OGHAM,
        RUNIC,
        TAGALOG,
        HANUNOO,
        BUHID,
        TAGBANWA,
        KHMER,
        MONGOLIAN,
        UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED,
        LIMBU,
        TAI_LE,
        NEW_TAI_LUE,
        KHMER_SYMBOLS,
        BUGINESE,
        TAI_THAM,
        null,
        BALINESE,
        SUNDANESE,
        BATAK,
        LEPCHA,
        OL_CHIKI,
        null,
        SUNDANESE_SUPPLEMENT,
        VEDIC_EXTENSIONS,
        PHONETIC_EXTENSIONS,
        PHONETIC_EXTENSIONS_SUPPLEMENT,
        COMBINING_DIACRITICAL_MARKS_SUPPLEMENT,
        LATIN_EXTENDED_ADDITIONAL,
        GREEK_EXTENDED,
        GENERAL_PUNCTUATION,
        SUPERSCRIPTS_AND_SUBSCRIPTS,
        CURRENCY_SYMBOLS,
        COMBINING_MARKS_FOR_SYMBOLS,
        LETTERLIKE_SYMBOLS,
        NUMBER_FORMS,
        ARROWS,
        MATHEMATICAL_OPERATORS,
        MISCELLANEOUS_TECHNICAL,
        CONTROL_PICTURES,
        OPTICAL_CHARACTER_RECOGNITION,
        ENCLOSED_ALPHANUMERICS,
        BOX_DRAWING,
        BLOCK_ELEMENTS,
        GEOMETRIC_SHAPES,
        MISCELLANEOUS_SYMBOLS,
        DINGBATS,
        MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A,
        SUPPLEMENTAL_ARROWS_A,
        BRAILLE_PATTERNS,
        SUPPLEMENTAL_ARROWS_B,
        MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B,
        SUPPLEMENTAL_MATHEMATICAL_OPERATORS,
        MISCELLANEOUS_SYMBOLS_AND_ARROWS,
        GLAGOLITIC,
        LATIN_EXTENDED_C,
        COPTIC,
        GEORGIAN_SUPPLEMENT,
        TIFINAGH,
        ETHIOPIC_EXTENDED,
        CYRILLIC_EXTENDED_A,
        SUPPLEMENTAL_PUNCTUATION,
        CJK_RADICALS_SUPPLEMENT,
        KANGXI_RADICALS,
        null,
        IDEOGRAPHIC_DESCRIPTION_CHARACTERS,
        CJK_SYMBOLS_AND_PUNCTUATION,
        HIRAGANA,
        KATAKANA,
        BOPOMOFO,
        HANGUL_COMPATIBILITY_JAMO,
        KANBUN,
        BOPOMOFO_EXTENDED,
        CJK_STROKES,
        KATAKANA_PHONETIC_EXTENSIONS,
        ENCLOSED_CJK_LETTERS_AND_MONTHS,
        CJK_COMPATIBILITY,
        CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A,
        YIJING_HEXAGRAM_SYMBOLS,
        CJK_UNIFIED_IDEOGRAPHS,
        YI_SYLLABLES,
        YI_RADICALS,
        LISU,
        VAI,
        CYRILLIC_EXTENDED_B,
        BAMUM,
        MODIFIER_TONE_LETTERS,
        LATIN_EXTENDED_D,
        SYLOTI_NAGRI,
        COMMON_INDIC_NUMBER_FORMS,
        PHAGS_PA,
        SAURASHTRA,
        DEVANAGARI_EXTENDED,
        KAYAH_LI,
        REJANG,
        HANGUL_JAMO_EXTENDED_A,
        JAVANESE,
        null,
        CHAM,
        MYANMAR_EXTENDED_A,
        TAI_VIET,
        MEETEI_MAYEK_EXTENSIONS,
        ETHIOPIC_EXTENDED_A,
        null,
        MEETEI_MAYEK,
        HANGUL_SYLLABLES,
        HANGUL_JAMO_EXTENDED_B,
        HIGH_SURROGATES,
        HIGH_PRIVATE_USE_SURROGATES,
        LOW_SURROGATES,
        PRIVATE_USE_AREA,
        CJK_COMPATIBILITY_IDEOGRAPHS,
        ALPHABETIC_PRESENTATION_FORMS,
        ARABIC_PRESENTATION_FORMS_A,
        VARIATION_SELECTORS,
        VERTICAL_FORMS,
        COMBINING_HALF_MARKS,
        CJK_COMPATIBILITY_FORMS,
        SMALL_FORM_VARIANTS,
        ARABIC_PRESENTATION_FORMS_B,
        HALFWIDTH_AND_FULLWIDTH_FORMS,
        SPECIALS,
        LINEAR_B_SYLLABARY,
        LINEAR_B_IDEOGRAMS,
        AEGEAN_NUMBERS,
        ANCIENT_GREEK_NUMBERS,
        ANCIENT_SYMBOLS,
        PHAISTOS_DISC,
        null,
        LYCIAN,
        CARIAN,
        null,
        OLD_ITALIC,
        GOTHIC,
        null,
        UGARITIC,
        OLD_PERSIAN,
        null,
        DESERET,
        SHAVIAN,
        OSMANYA,
        null,
        CYPRIOT_SYLLABARY,
        IMPERIAL_ARAMAIC,
        null,
        PHOENICIAN,
        LYDIAN,
        null,
        MEROITIC_HIEROGLYPHS,
        MEROITIC_CURSIVE,
        KHAROSHTHI,
        OLD_SOUTH_ARABIAN,
        null,
        AVESTAN,
        INSCRIPTIONAL_PARTHIAN,
        INSCRIPTIONAL_PAHLAVI,
        null,
        OLD_TURKIC,
        null,
        RUMI_NUMERAL_SYMBOLS,
        null,
        BRAHMI,
        KAITHI,
        SORA_SOMPENG,
        CHAKMA,
        null,
        SHARADA,
        null,
        TAKRI,
        null,
        CUNEIFORM,
        CUNEIFORM_NUMBERS_AND_PUNCTUATION,
        null,
        EGYPTIAN_HIEROGLYPHS,
        null,
        BAMUM_SUPPLEMENT,
        null,
        MIAO,
        null,
        KANA_SUPPLEMENT,
        null,
        BYZANTINE_MUSICAL_SYMBOLS,
        MUSICAL_SYMBOLS,
        ANCIENT_GREEK_MUSICAL_NOTATION,
        null,
        TAI_XUAN_JING_SYMBOLS,
        COUNTING_ROD_NUMERALS,
        null,
        MATHEMATICAL_ALPHANUMERIC_SYMBOLS,
        null,
        ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS,
        null,
        MAHJONG_TILES,
        DOMINO_TILES,
        PLAYING_CARDS,
        ENCLOSED_ALPHANUMERIC_SUPPLEMENT,
        ENCLOSED_IDEOGRAPHIC_SUPPLEMENT,
        MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS,
        EMOTICONS,
        null,
        TRANSPORT_AND_MAP_SYMBOLS,
        ALCHEMICAL_SYMBOLS,
        null,
        CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B,
        null,
        CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C,
        CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D,
        null,
        CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT,
        null,
        TAGS,
        null,
        VARIATION_SELECTORS_SUPPLEMENT,
        null,
        SUPPLEMENTARY_PRIVATE_USE_AREA_A,
        SUPPLEMENTARY_PRIVATE_USE_AREA_B
};

+ (UnicodeBlock)unicodeBlockOf:(unichar)c {
    int top, bottom, current;
    bottom = 0;
    top = 256;  //blockStarts's count
    current = top / 2;

    // invariant: top > current >= bottom && codePoint >= unicodeBlockStarts[bottom]
    while (top - bottom > 1) {
        if (c >= blockStarts[current]) {
            bottom = current;
        } else {
            top = current;
        }
        current = (top + bottom) / 2;
    }

    int a = blocks[current];
    return (UnicodeBlock) blocks[current];
}

@end