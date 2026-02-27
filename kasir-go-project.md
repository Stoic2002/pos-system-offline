# KasirGo — Simple POS untuk UMKM
## "Kasir Pixel, Cuan Real"
## Implementation Plan / MCP Prompt

---

## Project Overview

Build a Flutter mobile app called **KasirGo** — a simple, offline-first Point of Sale (POS)
app for Indonesian UMKM (small businesses). Target semua jenis UMKM: warung makan, toko
kelontong, café, toko fashion, jasa, dll.

**Tagline:** "Bayar sekali, pakai selamanya. Tanpa internet, tanpa langganan."
**Design Theme:** Pixel art / blocky — dark mode, terinspirasi Minecraft & Roblox.

**Model bisnis:** One-time purchase (Rp 49.000–79.000) dengan 30 hari trial gratis.

---

## Tech Stack

```
Flutter (Dart) — UI & business logic
├── sqflite                  → SQLite local database (full offline)
├── riverpod                 → state management
├── fl_chart                 → grafik laporan keuangan
├── pdf + printing           → generate & print PDF struk/laporan
├── blue_thermal_printer     → Bluetooth thermal printer support
├── qr_flutter               → tampilan QR QRIS
├── share_plus               → share struk/laporan via WhatsApp
├── image_picker             → foto produk dari kamera/galeri
├── intl                     → format angka & tanggal Indonesia
└── google_fonts             → tipografi (Press Start 2P + VT323)
```

**Target:** Android 8.0+ (minSdk 26)
**Package:** com.kasirgo.app
**100% offline** — tidak butuh internet sama sekali.

---

## Database Schema (SQLite)

```sql
-- Produk
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT,
  price REAL NOT NULL,
  cost_price REAL DEFAULT 0,
  stock INTEGER DEFAULT 0,
  low_stock_alert INTEGER DEFAULT 5,
  image_path TEXT,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Transaksi
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT NOT NULL UNIQUE,
  total_amount REAL NOT NULL,
  discount_amount REAL DEFAULT 0,
  payment_method TEXT NOT NULL, -- 'cash', 'qris', 'transfer'
  amount_paid REAL DEFAULT 0,
  change_amount REAL DEFAULT 0,
  note TEXT,
  status TEXT DEFAULT 'completed', -- 'completed', 'voided'
  created_at INTEGER NOT NULL
);

-- Item Transaksi
CREATE TABLE transaction_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  product_price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id)
);

-- Stok Log
CREATE TABLE stock_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  type TEXT NOT NULL, -- 'sale', 'restock', 'adjustment'
  quantity_change INTEGER NOT NULL,
  stock_before INTEGER NOT NULL,
  stock_after INTEGER NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Hutang Pelanggan (Bon)
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  total_amount REAL NOT NULL,
  paid_amount REAL DEFAULT 0,
  status TEXT DEFAULT 'unpaid', -- 'unpaid', 'partial', 'paid'
  due_date INTEGER,
  note TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Pembayaran Hutang
CREATE TABLE debt_payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  debt_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (debt_id) REFERENCES debts(id)
);

-- Pengaturan Toko
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
-- Isi default settings:
-- store_name, store_address, store_phone, qris_image_path,
-- transfer_bank, transfer_account, transfer_name,
-- receipt_footer, currency_symbol ('Rp'), tax_enabled, tax_percentage
```

---

## Folder Structure Flutter

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + routing
├── core/
│   ├── database/
│   │   ├── database_helper.dart      # SQLite init & migrations
│   │   └── dao/                      # Data Access Objects
│   │       ├── product_dao.dart
│   │       ├── transaction_dao.dart
│   │       ├── stock_dao.dart
│   │       └── debt_dao.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── transaction.dart
│   │   ├── transaction_item.dart
│   │   ├── stock_log.dart
│   │   ├── debt.dart
│   │   └── cart_item.dart
│   ├── providers/                    # Riverpod providers
│   │   ├── cart_provider.dart
│   │   ├── product_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── debt_provider.dart
│   │   └── settings_provider.dart
│   ├── services/
│   │   ├── receipt_service.dart      # Generate struk PDF & gambar
│   │   ├── report_service.dart       # Generate laporan PDF
│   │   ├── printer_service.dart      # Bluetooth printing
│   │   └── backup_service.dart       # Export/import data
│   └── theme/
│       ├── pixel_theme.dart       # Dark pixel theme (Minecraft/Roblox style)
│       ├── pixel_colors.dart      # Semua konstanta warna
│       └── pixel_text_styles.dart # Press Start 2P + VT323 styles
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # Setup awal nama toko, dll
│   ├── cashier/
│   │   ├── cashier_screen.dart       # Layar kasir utama
│   │   ├── cart_widget.dart          # Keranjang belanja
│   │   ├── payment_sheet.dart        # Bottom sheet pembayaran
│   │   └── receipt_screen.dart       # Struk setelah transaksi
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   ├── product_form_screen.dart  # Tambah/edit produk
│   │   └── product_card.dart
│   ├── inventory/
│   │   ├── inventory_screen.dart     # Daftar stok semua produk
│   │   ├── restock_sheet.dart        # Input stok masuk
│   │   └── stock_log_screen.dart     # Riwayat keluar masuk stok
│   ├── reports/
│   │   ├── report_screen.dart        # Tab: Harian / Mingguan / Bulanan
│   │   ├── daily_report.dart
│   │   ├── monthly_report.dart
│   │   └── report_chart.dart         # Grafik fl_chart
│   ├── debts/
│   │   ├── debt_list_screen.dart
│   │   ├── debt_form_screen.dart     # Tambah hutang baru
│   │   ├── debt_detail_screen.dart   # Detail + riwayat cicilan
│   │   └── debt_payment_sheet.dart   # Input pembayaran hutang
│   ├── history/
│   │   ├── history_screen.dart       # Riwayat semua transaksi
│   │   └── transaction_detail_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── store_settings.dart       # Nama toko, alamat, dll
│       ├── payment_settings.dart     # Setup QRIS, rekening transfer
│       ├── receipt_settings.dart     # Kustomisasi struk
│       └── backup_screen.dart        # Export/import data
└── shared/
    ├── widgets/
    │   ├── pixel_button.dart
    │   ├── pixel_text_field.dart
    │   ├── pixel_card.dart
    │   ├── currency_text.dart        # Format "Rp 15.000"
    │   ├── empty_state.dart
    │   └── loading_overlay.dart
    └── utils/
        ├── currency_formatter.dart   # Format Rupiah
        ├── date_formatter.dart
        └── invoice_generator.dart   # Generate nomor invoice unik
```

---

## UI Design

**Style:** Pixel art / blocky — terinspirasi Minecraft & Roblox. Dark theme default.
Semua elemen harus terasa "chunky", kotak, dan pixel-perfect. Tidak ada rounded corners,
tidak ada shadow halus — semua sharp edges dan border tebal.

**Color Palette:**
```dart
// Backgrounds
background      = #1A1A1A   // Layar utama gelap
surface         = #262626   // Card / container
surfaceVariant  = #2F2F2F   // Input / secondary container

// Borders
border          = #404040   // Border default
borderLight     = #555555   // Border subtle

// Primary — Hijau Minecraft (grass block)
primary         = #5DB85D   // Hijau utama
primaryDark     = #3A7D3A   // Hijau gelap (pressed state)
primaryLight    = #7ECF7E   // Hijau terang (highlight)

// Accents
accent          = #FFD700   // Kuning Roblox / Minecraft gold
accentOrange    = #FF6B35   // Orange CTA
accentBlue      = #00C8FF   // Biru info

// Text
textPrimary     = #E8E8E8   // Teks utama
textSecondary   = #9E9E9E   // Teks sekunder
textMuted       = #666666   // Teks muted

// Status
success         = #5DB85D   // Sama dengan primary
warning         = #FFD700   // Kuning gold
danger          = #FF4444   // Merah pixel
```

**Fonts:**
- Header / AppBar / Title: `Press Start 2P` (Google Fonts) — font pixel klasik
- Body / Label / Input: `VT323` (Google Fonts) — pixel font yang readable
- Angka besar (harga, total): `Press Start 2P` ukuran besar

**Border & Shape Rules:**
- **ZERO border radius** di semua elemen — semua sudut 90° tajam
- Border width: **2px** untuk elemen normal, **3px** untuk elemen aktif/focused
- Semua button: flat, kotak, border 2px solid
- Card/container: border 1–2px solid #404040
- Bottom sheet: border-top 3px solid primary
- Input field: border 2px, focused border primary 2px

**Pixel UI Patterns:**
- Semua button punya efek "pressed" dengan offset shadow kotak (bukan blur):
  ```dart
  // Normal state
  BoxShadow(offset: Offset(3, 3), color: Colors.black, blurRadius: 0)
  // Pressed state  
  BoxShadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 0)
  ```
- Divider: 1px solid #404040 (bukan Divider widget biasa)
- Icon: gunakan icon sederhana atau pixel-style custom icons
- AppBar: border-bottom 2px solid primary, background #262626
- TabBar indicator: border-bottom 3px solid primary (bukan underline default)
- Chip/filter: kotak, border 1.5px, tanpa radius

**Pixel Accent Elements:**
- Setiap section header punya border-left 3px solid primary (seperti Minecraft tooltip)
- Badge/status chip: background warna dengan opacity 0.15 + border warna penuh
- Loading: teks "LOADING..." dengan animasi titik pixel, bukan CircularProgressIndicator
  biasa — atau gunakan LinearProgressIndicator dengan warna primary
- Empty state: ikon besar + teks dengan font VT323 ukuran 20+

**Contoh Widget Pixel:**

```dart
// Pixel Container
Container(
  decoration: BoxDecoration(
    color: PixelColors.surface,
    border: Border.all(color: PixelColors.border, width: 2),
    // NO borderRadius
  ),
)

// Pixel Button
Container(
  decoration: BoxDecoration(
    color: PixelColors.primary,
    border: Border.all(color: PixelColors.primaryDark, width: 2),
    boxShadow: [BoxShadow(
      offset: Offset(3, 3),
      color: Colors.black,
      blurRadius: 0,
    )],
  ),
  child: Text('BAYAR', style: GoogleFonts.pressStart2p(
    color: Colors.black, fontSize: 12,
  )),
)

// Section Header (Minecraft tooltip style)
Container(
  decoration: BoxDecoration(
    color: PixelColors.surfaceVariant,
    border: Border(
      left: BorderSide(color: PixelColors.primary, width: 3),
    ),
  ),
  child: Text('> PRODUK', style: GoogleFonts.vt323(
    color: PixelColors.primary, fontSize: 18, letterSpacing: 2,
  )),
)
```

**AppBar Style:**
```dart
AppBar(
  backgroundColor: PixelColors.surface,
  titleTextStyle: GoogleFonts.pressStart2p(
    color: PixelColors.primary, fontSize: 13,
  ),
  shape: Border(bottom: BorderSide(color: PixelColors.primary, width: 2)),
)
```

**Bottom Navigation Bar Style:**
- Background: #262626
- Border-top: 2px solid primary
- Selected item: primary color + Press Start 2P label
- Unselected: #666666

**Input Field Style:**
```dart
InputDecoration(
  filled: true,
  fillColor: PixelColors.surfaceVariant,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.zero,  // NO RADIUS
    borderSide: BorderSide(color: PixelColors.border, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: PixelColors.primary, width: 2),
  ),
  hintStyle: GoogleFonts.vt323(color: PixelColors.textMuted),
)
```

**Numpad Payment (layar kasir):**
- Grid 4x3 tombol angka
- Tiap tombol: kotak besar, border 2px, background #2F2F2F
- Tap: background berubah ke primaryDark, offset shadow dikurangi
- Font angka: Press Start 2P atau VT323 ukuran besar

**Color Coding per Fitur:**
- Kasir / transaksi: primary green (#5DB85D)
- Stok menipis: warning yellow (#FFD700)
- Stok habis / danger: red (#FF4444)
- Hutang / bon: accent orange (#FF6B35)
- Laporan / stats: accent blue (#00C8FF)
- Lunas / success: primary green

---

## Screen-by-Screen Specification

### 1. Onboarding Screen
Muncul hanya saat pertama kali buka app.
- Input nama toko (required)
- Input alamat toko (optional)
- Input nomor HP toko (optional)
- Tombol "Mulai Pakai KasirGo"
- Simpan ke tabel settings

---

### 2. Cashier Screen (Home / Main Screen)
Layar utama dan paling sering dipakai.

**Layout:**
- AppBar: nama toko + ikon settings
- Search bar produk (filter realtime)
- Filter kategori (chips horizontal scroll)
- Grid produk (2 kolom) — tap untuk tambah ke keranjang
- FAB / bottom panel: ringkasan keranjang + tombol "Bayar"

**Produk Card:**
- Foto produk (atau ikon default per kategori)
- Nama produk
- Harga (format Rupiah)
- Badge stok: hijau (aman), kuning (menipis), merah (habis)
- Tap → tambah 1 ke keranjang
- Long press → lihat detail / set quantity manual

**Keranjang (bottom sheet expandable):**
- List item + quantity +/- controls
- Subtotal per item
- Input diskon (nominal atau %)
- Total akhir
- Tombol "Proses Pembayaran"

---

### 3. Payment Bottom Sheet
Muncul setelah tap "Proses Pembayaran".

**Tabs: Cash | QRIS | Transfer**

**Cash tab:**
- Total yang harus dibayar
- Input nominal uang diterima (dengan numpad besar)
- Display kembalian otomatis realtime
- Tombol "Selesai & Cetak Struk"

**QRIS tab:**
- Tampilkan gambar QR yang sudah diupload di settings
- Total yang harus dibayar
- Tombol "Konfirmasi Pembayaran Diterima"

**Transfer tab:**
- Info rekening (nama bank, nomor, nama pemilik)
- Total yang harus dibayar
- Tombol "Konfirmasi Pembayaran Diterima"

---

### 4. Receipt Screen
Muncul setelah transaksi selesai.

**Tampilan struk digital:**
- Logo/nama toko + alamat
- Nomor invoice + tanggal & jam
- List item (nama, qty, harga satuan, subtotal)
- Garis pemisah
- Total, diskon, grand total
- Metode pembayaran, uang diterima, kembalian
- Footer custom (ucapan terima kasih, dll)

**Action buttons:**
- Share via WhatsApp (sebagai gambar)
- Print (Bluetooth printer)
- Simpan ke galeri
- Kembali ke kasir (clear cart)

---

### 5. Product List Screen
- Search bar
- Filter kategori
- List produk dengan: foto, nama, harga, stok, kategori
- FAB: tambah produk baru
- Swipe kiri: hapus
- Tap: edit produk

---

### 6. Product Form Screen
Tambah / edit produk.
- Foto produk (kamera atau galeri, opsional)
- Nama produk (required)
- Kategori (dropdown + bisa tambah baru)
- Harga jual (required)
- Harga beli / HPP (opsional, untuk hitung margin)
- Stok awal
- Batas alert stok menipis
- Toggle: produk aktif/nonaktif

---

### 7. Inventory Screen
- Summary bar: total produk, stok habis, stok menipis
- List semua produk dengan stok real-time
- Highlight merah: stok habis, kuning: menipis
- Tap produk → sheet dengan opsi: restock / lihat log stok
- Tab: Semua | Menipis | Habis

**Restock Sheet:**
- Nama produk
- Stok sekarang
- Input jumlah tambah
- Input harga beli (opsional, untuk update HPP)
- Catatan restock
- Tombol "Simpan Restock"

---

### 8. Report Screen
**3 tabs: Hari Ini | Minggu Ini | Bulan Ini**

Setiap tab menampilkan:
- Total omzet (angka besar, warna hijau)
- Total transaksi
- Total item terjual
- Grafik bar chart (fl_chart): omzet per hari/jam
- Breakdown metode pembayaran (pie chart / list)
- Top 5 produk terlaris
- Estimasi profit (kalau HPP diisi)

**Action:**
- Tombol "Export PDF" → generate laporan PDF
- Tombol "Share" → share laporan sebagai gambar

---

### 9. Transaction History Screen
- Filter: hari ini, minggu ini, bulan ini, custom range
- Search by nomor invoice
- List transaksi: nomor invoice, tanggal, total, metode bayar, status
- Tap → detail transaksi lengkap
- Transaksi voided ditampilkan dengan strikethrough

**Transaction Detail:**
- Detail lengkap seperti struk
- Tombol "Void Transaksi" (dengan konfirmasi, stok dikembalikan)
- Tombol "Cetak Ulang Struk"

---

### 10. Debt List Screen (Bon Pelanggan)
- Summary: total piutang belum lunas
- List hutang: nama, total, sudah bayar, sisa, status
- Filter: Semua | Belum Lunas | Lunas Sebagian | Lunas
- FAB: tambah hutang baru
- Tap: detail hutang + riwayat cicilan

**Debt Form Screen:**
- Nama pelanggan (required)
- Nomor HP (opsional, untuk share reminder via WA)
- Total hutang
- Tanggal jatuh tempo (opsional)
- Catatan
- Opsi: langsung hubungkan ke transaksi yang belum dibayar

**Debt Detail Screen:**
- Info hutang lengkap
- Progress bar: sudah bayar / total
- Riwayat cicilan dengan tanggal
- Tombol "Bayar Sebagian / Lunas"
- Tombol "Kirim Reminder WhatsApp" → buka WA dengan pesan template:
  ```
  Halo [nama], mengingatkan tagihan di [nama toko] 
  sebesar Rp [jumlah] belum terlunasi. Terima kasih 🙏
  ```

---

### 11. Settings Screen

**Pengaturan Toko:**
- Nama toko, alamat, nomor HP
- Logo toko (untuk struk)

**Pengaturan Pembayaran:**
- Upload gambar QR QRIS
- Nama bank transfer, nomor rekening, nama pemilik

**Pengaturan Struk:**
- Toggle: tampilkan logo di struk
- Footer struk (ucapan, dll)
- Preview struk

**Pengaturan Lainnya:**
- Bahasa: Indonesia (default)
- Format mata uang: Rp (default)
- Toggle pajak + persentase pajak

**Backup & Restore:**
- Export semua data ke file JSON
- Import / restore dari file JSON
- Hapus semua data (dengan konfirmasi berlapis)

---

## Key Logic & Business Rules

### Invoice Number Generator
```dart
// Format: KG-YYYYMMDD-XXXX
// Contoh: KG-20250227-0001
String generateInvoiceNumber(int todayCount) {
  final date = DateFormat('yyyyMMdd').format(DateTime.now());
  final seq = (todayCount + 1).toString().padLeft(4, '0');
  return 'KG-$date-$seq';
}
```

### Cart Logic
- Tap produk → tambah 1 qty ke cart
- Kalau produk sudah di cart → increment qty
- Qty tidak boleh melebihi stok yang tersedia
- Stok = 0 → produk tidak bisa ditambah (tampil disabled)
- Diskon maksimal = total sebelum diskon (tidak bisa minus)

### Stock Management
- Setiap transaksi completed → kurangi stok otomatis
- Setiap void transaksi → kembalikan stok
- Restock → tambah stok + catat di stock_log
- Alert stok menipis: muncul di inventory + badge di produk

### Debt (Bon) Logic
- Status otomatis berubah:
  - paid_amount == 0 → 'unpaid'
  - paid_amount > 0 && paid_amount < total → 'partial'
  - paid_amount >= total → 'paid'
- Total piutang aktif = SUM(total - paid) WHERE status != 'paid'

---

## Receipt Service

```dart
// Generate struk sebagai widget → convert ke gambar → share
// Library: pdf (dart) untuk PDF, screenshot untuk gambar

class ReceiptService {
  // Generate PDF struk
  Future<File> generateReceiptPDF(Transaction tx, List<TransactionItem> items);
  
  // Capture struk sebagai PNG (untuk share WA)
  Future<File> captureReceiptAsImage(Widget receiptWidget);
  
  // Share via WhatsApp
  Future<void> shareToWhatsApp(File imageFile);
  
  // Print via Bluetooth
  Future<void> printReceipt(Transaction tx, List<TransactionItem> items);
}
```

**Bluetooth Printer Support:**
- Scan printer Bluetooth nearby
- Pair dan simpan printer default
- Format ESC/POS untuk thermal printer
- Test print dari settings
- Fallback ke share gambar kalau tidak ada printer

---

## Report PDF Template

Laporan harian/bulanan dalam PDF berisi:
- Header: nama toko, periode laporan, tanggal generate
- Ringkasan: omzet, transaksi, profit estimasi
- Tabel breakdown per hari (laporan bulanan) atau per jam (laporan harian)
- Breakdown metode pembayaran
- Top 10 produk terlaris: nama, qty, omzet
- Footer: "Generated by KasirGo"

---

## Backup & Restore

```dart
// Export: ambil semua data dari SQLite → serialize ke JSON → save ke file
// Import: baca file JSON → validasi → masukkan ke SQLite

Map<String, dynamic> exportData() => {
  'version': 1,
  'exported_at': DateTime.now().toIso8601String(),
  'store_name': settings['store_name'],
  'products': [...],
  'transactions': [...],
  'transaction_items': [...],
  'stock_logs': [...],
  'debts': [...],
  'debt_payments': [...],
  'settings': {...},
};
```

---

## Navigation Structure

```
BottomNavigationBar (4 tab):
├── 🏪 Kasir         → CashierScreen
├── 📦 Produk/Stok   → ProductListScreen (+ sub: InventoryScreen)
├── 📊 Laporan       → ReportScreen (+ sub: HistoryScreen, DebtScreen)
└── ⚙️  Lainnya      → SettingsScreen (+ sub: BackupScreen, dll)
```

---

## Onboarding Flow

```
App dibuka pertama kali
→ Cek settings: store_name ada?
  → Tidak: OnboardingScreen
  → Ya: CashierScreen (home)
```

---

## Error Handling

- Database error: tampilkan snackbar + log error
- Stok tidak cukup: tampilkan dialog konfirmasi
- Void transaksi: konfirmasi berlapis (dialog + ketik "HAPUS")
- Import data gagal: rollback semua perubahan, tampilkan pesan error
- Printer tidak tersambung: fallback ke share gambar otomatis

---

## Phase Roadmap

```
Phase 1 — MVP (3–4 minggu)
├── Setup database & models
├── Onboarding screen
├── Cashier screen (produk + cart)
├── Payment: Cash saja dulu
├── Struk: tampil di layar + share WA
└── Product CRUD

Phase 2 — Core Complete (3–4 minggu)
├── QRIS & Transfer payment method
├── Inventory management + restock
├── Laporan harian & bulanan + chart
├── Transaction history + void
└── Settings dasar

Phase 3 — Power Features (2–3 minggu)
├── Hutang pelanggan (bon) lengkap
├── Export laporan PDF
├── Bluetooth printer support
└── Backup & restore data

Phase 4 — Polish & Launch (1–2 minggu)
├── UI polish & animasi halus
├── Empty state & onboarding flow
├── Performance optimization
├── Testing di berbagai device
└── Play Store submission
```

---

## Play Store Assets yang Perlu Disiapkan

- App icon 512x512px
- Feature graphic 1024x500px
- Screenshot: min 4 screenshot (kasir, laporan, produk, bon)
- Deskripsi pendek (80 karakter): "Kasir UMKM pixel style, offline, bayar sekali selamanya"
- Deskripsi panjang: highlight offline, one-time, fitur bon, dll

---

## Notes Penting

- **Semua teks dalam Bahasa Indonesia** — target pengguna bukan tech-savvy
- **Font size cukup besar** — banyak pengguna UMKM usia 40+
- **Numpad custom** di layar payment — lebih mudah dari keyboard default
- **Konfirmasi sebelum aksi destruktif** — void, hapus, reset data
- **Stok negatif dilarang** — validasi di UI sebelum transaksi
- **Format Rupiah konsisten** — selalu pakai pemisah ribuan, contoh: Rp 15.000
- **Dark mode: opsional** — default light mode saja dulu
- **Tablet support: opsional** — fokus smartphone dulu