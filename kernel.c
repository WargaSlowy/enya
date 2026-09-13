typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define ALAMAT_VGA 0xB8000
#define LEBAR_VGA 80
// #define TINGGI_VGA 25

static volatile uint16_t* memori_vga = (volatile uint16_t*)ALAMAT_VGA;

static void tulis_teks(const char* teks, uint32_t baris, uint32_t kolom, uint32_t warna) {
  uint32_t indeks_teks = 0;

  while (teks[indeks_teks] != '\0') {
    uint32_t posisi = baris * LEBAR_VGA + kolom;

    uint16_t entry = (uint16_t)teks[indeks_teks] | ((uint16_t)warna << 8);

    memori_vga[posisi] = entry;

    indeks_teks++;
    kolom++;
  }
}

__attribute__((section(".text.mulai"))) void mulai_kernel(void) {
  uint8_t warna_hijau = 0x0A;
  uint8_t warna_putih = 0x0F;

  tulis_teks("[kernel] kernel berhasil untuk diambil kerjanya", 8, 0, warna_hijau);
  tulis_teks("Bootloader sudah kelar tugasnya wak", 10, 0, warna_putih);

  while (1) {
    __asm__ volatile(
        "cli\n"
        "hlt\n");
  }
}
