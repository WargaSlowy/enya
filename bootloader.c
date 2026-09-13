typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

volatile uint16_t *memori_vga = (volatile uint16_t *)0xB8000;

void cetak_teks(const char* teks, uint8_t warna) {
  int indeks = 0;

  while (teks[indeks] != '\0') {
    uint16_t karakter = (uint16_t)teks[indeks];
    uint16_t attribut = (uint16_t)warna << 8;

    memori_vga[indeks] = karakter | attribut;

    indeks++;
  }
}


__attribute__((section(".text.mulai")))
void mulai_bootloader(void) {

  const char *pesan = "AMBALOADER INI KEPUNYAAN LOH YA  ";
  
  // 0x1 berarti biru
  // 0x2 hijau
  // 0x7 = abu terang
  // 0xF = putih
  cetak_teks("RUSDILOADER KHAS SUMEDANG ", 0x7);

  while (1) {
    __asm__ volatile ("hlt");
  }
}
