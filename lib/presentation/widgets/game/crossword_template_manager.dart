import 'package:al_quran/presentation/widgets/game/crossword_template.dart';
import 'package:al_quran/data/models/game/clue.dart';

class CrosswordTemplateManager {
  static List<CrosswordTemplate> get templates => _templates;

  static final List<CrosswordTemplate> _templates = [
    // --- TEMPLATE BAWAAN (JANGAN DIHAPUS JIKA MASIH DIGUNAKAN) ---
    // Template 1 (7x7) - General Knowledge
    CrosswordTemplate(
      rows: 7,
      cols: 7,
      name: "General Knowledge",
      difficulty: 2,
      layout: [
        '1', '1', '1', '0', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '1', '1', '1', '1',
        '0', '0', '1', '0', '1', '0', '0',
        '1', '1', '1', '1', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '0', '1', '1', '1',
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Ibu kota Indonesia', answer: 'JAKARTA', row: 0, col: 0),
        Clue(number: 4, clue: 'Planet terdekat dari matahari', answer: 'MERKURI', row: 2, col: 0),
        Clue(number: 7, clue: 'Warna pelangi ke-3', answer: 'KUNING', row: 4, col: 0),
        Clue(number: 8, clue: 'Mata uang Amerika', answer: 'DOLLAR', row: 6, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Binatang berkantung', answer: 'KANGURU', row: 0, col: 0),
        Clue(number: 2, clue: 'Mata uang Jepang', answer: 'YEN', row: 0, col: 2),
        Clue(number: 3, clue: 'Presiden pertama RI', answer: 'SOEKARNO', row: 0, col: 4),
        Clue(number: 5, clue: 'Ibukota Prancis', answer: 'PARIS', row: 2, col: 6),
      ],
    ),

    // Template 2 (7x7) - Sains
    CrosswordTemplate(
      rows: 7,
      cols: 7,
      name: "Ilmu Pengetahuan",
      difficulty: 3,
      layout: [
        '1', '1', '1', '0', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '1', '1', '1', '1',
        '0', '0', '1', '0', '1', '0', '0',
        '1', '1', '1', '1', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '0', '1', '1', '1',
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Satelit alami bumi', answer: 'BULAN', row: 0, col: 0),
        Clue(number: 4, clue: 'Simbol kimia untuk emas', answer: 'AU', row: 2, col: 0),
        Clue(number: 7, clue: 'Gaya tarik bumi', answer: 'GRAVITASI', row: 4, col: 0),
        Clue(number: 8, clue: 'Unsur dengan nomor atom 8', answer: 'OKSIGEN', row: 6, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Penemu teori relativitas', answer: 'EINSTEIN', row: 0, col: 0),
        Clue(number: 2, clue: 'Tumbuhan membuat makanan', answer: 'FOTOSINTESIS', row: 0, col: 2),
        Clue(number: 3, clue: 'Unsur dengan nomor atom 1', answer: 'HIDROGEN', row: 0, col: 4),
        Clue(number: 5, clue: 'Planet terbesar di tata surya', answer: 'JUPITER', row: 2, col: 6),
      ],
    ),

    // Template 3 (7x7) - Sejarah
    CrosswordTemplate(
      rows: 7,
      cols: 7,
      name: "Sejarah",
      difficulty: 3,
      layout: [
        '1', '1', '1', '0', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '1', '1', '1', '1',
        '0', '0', '1', '0', '1', '0', '0',
        '1', '1', '1', '1', '1', '1', '1',
        '1', '0', '1', '0', '1', '0', '1',
        '1', '1', '1', '0', '1', '1', '1',
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Perang dunia pertama', answer: 'DUNIA1', row: 0, col: 0),
        Clue(number: 4, clue: 'Kerajaan Hindu pertama di Indonesia', answer: 'KUTAI', row: 2, col: 0),
        Clue(number: 7, clue: 'Pahlawan dari Aceh', answer: 'CUTNYAKDIEN', row: 4, col: 0),
        Clue(number: 8, clue: 'Tahun kemerdekaan Indonesia', answer: '1945', row: 6, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Penjajah Indonesia selama 3.5 tahun', answer: 'JEPANG', row: 0, col: 0),
        Clue(number: 2, clue: 'Kerajaan Budha terbesar', answer: 'SRIWIJAYA', row: 0, col: 2),
        Clue(number: 3, clue: 'Proklamator Indonesia', answer: 'HATTA', row: 0, col: 4),
        Clue(number: 5, clue: 'Penemu benua Amerika', answer: 'COLUMBUS', row: 2, col: 6),
      ],
    ),

    // Template 4 (5x5) - Simple
    CrosswordTemplate(
      rows: 5,
      cols: 5,
      name: "Simple Puzzle",
      difficulty: 1,
      layout: [
        '1', '1', '1', '1', '1',
        '1', '0', '1', '0', '1',
        '1', '1', '1', '1', '1',
        '1', '0', '1', '0', '1',
        '1', '1', '1', '1', '1',
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Buah berwarna merah', answer: 'APEL', row: 0, col: 0),
        Clue(number: 3, clue: 'Hewan berkaki empat', answer: 'KUCING', row: 2, col: 0),
        Clue(number: 5, clue: 'Ibu kota Jawa Barat', answer: 'BANDUNG', row: 4, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Alat untuk menulis', answer: 'PULPEN', row: 0, col: 0),
        Clue(number: 2, clue: 'Warna daun', answer: 'HIJAU', row: 0, col: 2),
        Clue(number: 4, clue: 'Satuan waktu', answer: 'DETIK', row: 0, col: 4),
      ],
    ),

    // --- PAKET SOAL TENTANG AL-QUR'AN (BARU) ---

    // Paket 1: Nama Surat & Konsep Dasar (5x5) - Tingkat Mudah
    CrosswordTemplate(
      rows: 5,
      cols: 5,
      name: "Surat & Konsep Dasar (5x5)",
      difficulty: 1,
      layout: [
        '1', '1', '1', '1', '1', // B A Q A R A H (6) -> jadi BAQAR
        '1', '0', '1', '0', '1', // U 0 L 0 M
        '1', '1', '1', '1', '1', // I S L A M
        '1', '0', '1', '0', '1', // R 0 H 0 H
        '1', '1', '1', '1', '1', // J U Z A M M A (7) -> jadi JUZAM
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Surat terpanjang dalam Al-Qur\'an (5 huruf pertama).', answer: 'BAQAR', row: 0, col: 0),
        Clue(number: 2, clue: 'Agama yang diturunkan kepada Nabi Muhammad SAW.', answer: 'ISLAM', row: 2, col: 0),
        Clue(number: 3, clue: 'Bagian terakhir dari Al-Qur\'an (5 huruf pertama).', answer: 'JUZAM', row: 4, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Kitab suci umat Islam.', answer: 'QURAN', row: 0, col: 0),
        Clue(number: 2, clue: 'Salah satu nama lain Al-Qur\'an.', answer: 'FURQAN', row: 0, col: 2),
        Clue(number: 4, clue: 'Bulan di mana Al-Qur\'an pertama kali diturunkan.', answer: 'RAMADAN', row: 0, col: 4),
      ],
    ),

    // Paket 2: Nabi-Nabi dalam Al-Qur'an (7x7) - Tingkat Sedang
    CrosswordTemplate(
      rows: 7,
      cols: 7,
      name: "Nabi-Nabi dalam Al-Qur'an (7x7)",
      difficulty: 2,
      layout: [
        '1', '1', '1', '1', '0', '1', '1', // A D A M _ I S A
        '0', '1', '0', '1', '1', '1', '1', //   B   N U H
        '1', '1', '1', '1', '1', '0', '1', // I B R A H I M _
        '1', '0', '1', '0', '1', '1', '1', // Y 0 Y 0 M U S A
        '1', '1', '1', '1', '0', '1', '1', // M U H A M M A D (7) -> MUHAMAD
        '1', '0', '1', '0', '0', '1', '0', //   S   D
        '1', '1', '1', '1', '1', '1', '1', // S U L A I M A N
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Nabi pertama yang diciptakan Allah.', answer: 'ADAM', row: 0, col: 0),
        Clue(number: 2, clue: 'Nabi yang dikenal bapak para nabi.', answer: 'IBRAHIM', row: 2, col: 0),
        Clue(number: 3, clue: 'Nabi penutup dan pembawa Al-Qur\'an.', answer: 'MUHAMAD', row: 4, col: 0), // 7 huruf
        Clue(number: 4, clue: 'Nabi yang bisa berbicara dengan hewan.', answer: 'SULAIMAN', row: 6, col: 0), // 8 huruf
      ],
      downClues: [
        Clue(number: 1, clue: 'Nabi yang diselamatkan dari banjir besar.', answer: 'NUH', row: 1, col: 4),
        Clue(number: 2, clue: 'Nabi yang tongkatnya bisa membelah lautan.', answer: 'MUSA', row: 3, col: 4),
        Clue(number: 5, clue: 'Nabi yang diangkat ke langit.', answer: 'ISA', row: 0, col: 5),
        Clue(number: 6, clue: 'Nabi yang memiliki kesabaran luar biasa.', answer: 'AYUB', row: 0, col: 1),
      ],
    ),

    // Paket 3: Ayat & Konsep Penting (6x6) - Tingkat Sulit
    CrosswordTemplate(
      rows: 6,
      cols: 6,
      name: "Ayat & Konsep Penting (6x6)",
      difficulty: 3,
      layout: [
        '1', '1', '1', '1', '1', '0', // W A Q I A H
        '0', '1', '0', '1', '1', '1', //   Q   I H S A N
        '1', '1', '1', '1', '1', '0', // A S H R _
        '1', '0', '1', '0', '1', '1', // R 0 H 0 Q A L A M
        '1', '1', '1', '1', '1', '0', // I K H L A S _
        '0', '1', '0', '1', '1', '1', //   N   A L F I L
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Surat tentang hari kiamat.', answer: 'WAQIAH', row: 0, col: 0),
        Clue(number: 2, clue: 'Surat yang berarti "Masa".', answer: 'ASHR', row: 2, col: 0),
        Clue(number: 3, clue: 'Surat tentang keesaan Allah.', answer: 'IKHLAS', row: 4, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Berbuat baik seolah melihat Allah.', answer: 'IHSAN', row: 1, col: 3),
        Clue(number: 2, clue: 'Surat ke-68, berarti "Pena".', answer: 'QALAM', row: 3, col: 4),
        Clue(number: 4, clue: 'Surat tentang pasukan bergajah.', answer: 'ALFIL', row: 5, col: 4), // ALFIIL (6) -> ALFIL (5)
        Clue(number: 5, clue: 'Bacaan Al-Qur\'an dengan tajwid.', answer: 'TARTIL', row: 0, col: 1),
      ],
    ),

    // Paket 4: Hukum & Istilah Fiqih (7x7) - Tingkat Sedang
    CrosswordTemplate(
      rows: 7,
      cols: 7,
      name: "Hukum & Istilah Fiqih (7x7)",
      difficulty: 2,
      layout: [
        '1', '1', '1', '1', '1', '0', '0', // SHARIAH
        '1', '0', '1', '0', '1', '1', '1', // A 0 K 0 WAJIB
        '1', '1', '1', '1', '1', '0', '0', // HALAL
        '0', '1', '0', '1', '1', '1', '1', //   A   MAKROH
        '1', '1', '1', '1', '1', '0', '0', // ZAKAT
        '1', '0', '1', '0', '1', '1', '1', //   B   IBADAH
        '1', '1', '1', '1', '1', '0', '0', // RIBA
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Aturan syariat Islam.', answer: 'SYARIAH', row: 0, col: 0),
        Clue(number: 2, clue: 'Diperbolehkan dalam Islam.', answer: 'HALAL', row: 2, col: 0),
        Clue(number: 3, clue: 'Harta yang wajib dikeluarkan.', answer: 'ZAKAT', row: 4, col: 0),
        Clue(number: 4, clue: 'Bunga uang yang diharamkan.', answer: 'RIBA', row: 6, col: 0),
      ],
      downClues: [
        Clue(number: 1, clue: 'Perbuatan yang sangat dianjurkan.', answer: 'SUNNAH', row: 0, col: 1),
        Clue(number: 2, clue: 'Hukum yang wajib dilaksanakan.', answer: 'WAJIB', row: 1, col: 4),
        Clue(number: 3, clue: 'Perbuatan yang dianjurkan untuk dihindari.', answer: 'MAKROH', row: 3, col: 4),
        Clue(number: 5, clue: 'Pengabdian diri kepada Allah.', answer: 'IBADAH', row: 5, col: 4),
      ],
    ),

    // Paket 5: Mukjizat & Kisah Al-Qur'an (8x8) - Tingkat Sulit
    CrosswordTemplate(
      rows: 8,
      cols: 8,
      name: "Mukjizat & Kisah Al-Qur'an (8x8)",
      difficulty: 3,
      layout: [
        '1', '1', '1', '1', '1', '1', '1', '0', // MUKJIZAT
        '0', '1', '0', '1', '0', '1', '1', '1', //   U   H   SITIHAJAR
        '1', '1', '1', '1', '1', '1', '1', '1', // KAHAFI
        '1', '0', '1', '0', '1', '0', '1', '0', //   J   Y   M
        '1', '1', '1', '1', '1', '1', '1', '1', // ASHABULFIIL
        '0', '1', '0', '1', '0', '1', '0', '1', //   Z   A   A
        '1', '1', '1', '1', '1', '1', '1', '1', // DZULQARNAIN
        '1', '0', '1', '0', '1', '0', '1', '0', //   A   R   N
      ],
      acrossClues: [
        Clue(number: 1, clue: 'Peristiwa luar biasa yang Allah berikan kepada para Nabi.', answer: 'MUKJIZAT', row: 0, col: 0),
        Clue(number: 2, clue: 'Surat tentang pemuda gua.', answer: 'KAHAFI', row: 2, col: 0),
        Clue(number: 3, clue: 'Kisah pasukan bergajah yang dihancurkan Allah.', answer: 'ASHABULFIIL', row: 4, col: 0), // 11 huruf
        Clue(number: 4, clue: 'Raja yang membangun tembok pembatas Yajuj Majuj.', answer: 'DZULQARNAIN', row: 6, col: 0), // 11 huruf
      ],
      downClues: [
        Clue(number: 1, clue: 'Sumur yang muncul berkat Nabi Ismail.', answer: 'ZAMZAM', row: 0, col: 1),
        Clue(number: 2, clue: 'Istri Nabi Ibrahim dan ibu Nabi Ismail.', answer: 'SITIHAJAR', row: 1, col: 6), // 9 huruf
        Clue(number: 3, clue: 'Nabi yang diberi mukjizat menghidupkan orang mati.', answer: 'ISA', row: 3, col: 4),
        Clue(number: 5, clue: 'Perjalanan malam Nabi Muhammad SAW.', answer: 'ISRA', row: 0, col: 3),
      ],
    ),
  ];

  static List<CrosswordTemplate> getRandomTemplates(int count) {
    final shuffled = List.of(_templates)..shuffle();
    return shuffled.take(count).toList();
  }

  static List<CrosswordTemplate> getTemplatesForDevice(double screenWidth) {
    return screenWidth < 400
        ? _templates.where((t) => t.rows <= 7 && t.cols <= 7).toList() // Menyesuaikan filter untuk Al-Qur'an
        : _templates;
  }
}