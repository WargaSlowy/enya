typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define ALAMAT_VGA 0xB8000
#define LEBAR_VGA 80
#define TINGGI_VGA 25

volatile uint16_t* memori_vga = (volatile uint16_t*)ALAMAT_VGA;
static uint32_t baris = 0;
static uint32_t kolom = 0;

enum WarnaVGA {
  VGA_HITAM = 0,
  VGA_BIRU = 1,
  VGA_HIJAU = 2,
  VGA_CYAN = 3,
  VGA_MERAH = 4,
  VGA_MAGENTA = 5,
  VGA_COKLAT = 6,
  VGA_ABU_TERANG = 7,
  VGA_ABU_GELAP = 8,
  VGA_BIRU_TERANG = 9,
  VGA_HIJAU_TERANG = 10,
  VGA_CYAN_TERANG = 11,
  VGA_MERAH_TERANG = 12,
  VGA_PINK = 13,
  VGA_KUNING = 14,
  VGA_PUTIH = 15,
};

static uint8_t buat_warna(uint8_t foreground, uint8_t background) {
  return foreground | (background << 4);
}

static uint16_t buat_entry_vga(char karakter, uint8_t warna) {
  return (uint16_t)karakter | ((uint16_t)warna << 8);
}

static void bershikan_layar(void) {
  uint8_t warna = buat_warna(VGA_ABU_TERANG, VGA_HIJAU);

  for (uint32_t y = 0; y < TINGGI_VGA; y++) {
    for (uint32_t x = 0; x < LEBAR_VGA; x++) {
      uint32_t indeks = y * LEBAR_VGA + x;

      memori_vga[indeks] = buat_entry_vga(' ', warna);
    }
  }

  baris = 0;
  kolom = 0;
}

static void baris_baru(void) {
  kolom = 0;
  baris++;

  if (baris >= TINGGI_VGA) {
    baris = 0;
  }
}

static void cetak_karakter(char karakter, uint8_t warna) {
  if (karakter == '\n') {
    baris_baru();
    return;
  }

  uint32_t indeks = baris * LEBAR_VGA + kolom;
  memori_vga[indeks] = buat_entry_vga(karakter, warna);

  kolom++;

  if (kolom >= LEBAR_VGA) {
    baris_baru();
  }
}

static void cetak_teks(const char* teks, uint8_t warna) {
  int indeks = 0;

  while (teks[indeks] != '\0') {
    cetak_karakter(teks[indeks], warna);
    indeks++;
  }
}

static void cetak_hex(uint32_t nilai, uint8_t warna) {
  const char* digit_hex = "0123456789ABCDEF";

  cetak_teks("0x", warna);

  for (int geser = 28; geser >= 0; geser -= 4) {
    uint8_t digit = (nilai >> geser) & 0x0F;

    cetak_karakter(digit_hex[digit], warna);
  }
}

static void hentikan_cpu(void) {
  while (1) {
    __asm__ volatile(
        "cli\n"
        "hlt\n");
  }
}

__attribute__((section(".text.mulai"))) void mulai_bootloader(void) {
  uint8_t warna_normal = buat_warna(VGA_ABU_TERANG, VGA_HITAM);
  uint8_t warna_sukses = buat_warna(VGA_HIJAU_TERANG, VGA_HITAM);
  uint8_t warna_info = buat_warna(VGA_CYAN_TERANG, VGA_HITAM);
  bershikan_layar();

  cetak_teks("BOOTLOADER BUATAN WARGA SLOWY", warna_info);
  cetak_teks("[bootloader] STAGE 2 berjalan dengan aman di alamat: ", warna_sukses);
  cetak_hex(0x1000, warna_normal);
  cetak_teks("\n", warna_normal);
  cetak_teks("[bootloader] Kernel sudah dimuat ke alamat: ", warna_sukses);
  cetak_hex(0x10000, warna_normal);
  cetak_teks("\n\n", warna_normal);

  void (*mulai_kernel)(void) = (void (*)(void))0x10000;

  mulai_kernel();

  cetak_teks("\nError: kernel balik lagi ke bootloader", buat_warna(VGA_MERAH_TERANG, VGA_HITAM));
  hentikan_cpu();
}
