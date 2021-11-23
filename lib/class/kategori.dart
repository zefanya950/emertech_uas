class Kategori {
  int idkategori;
  String nama;
  Kategori({required this.idkategori, required this.nama});

  factory Kategori.fromJSON(Map<String, dynamic> json) {
    return Kategori(
      idkategori: json["idkategori"],
      nama: json["nama"],
    );
  }
}
