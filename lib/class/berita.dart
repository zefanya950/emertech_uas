class Berita {
  final int id;
  String judul;
  String deskripsi;
  String tanggal;
  String penulis;
  final List? kategoris;

  Berita(
      {required this.id,
      required this.judul,
      required this.deskripsi,
      required this.tanggal,
      required this.penulis,
      required this.kategoris});
  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
        id: json['idberita'],
        judul: json['judul'],
        deskripsi: json['deskripsi'],
        tanggal: json['tanggal'],
        penulis: json['penulis'],
        kategoris: json['kategoris']);
  }
}

List<Berita> Beritas = [];
