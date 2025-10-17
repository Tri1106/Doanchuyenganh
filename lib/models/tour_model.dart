class Tour {
  final String tourID;
  final String providerID;
  final String tourName;
  final String? destination;
  final double price;
  final bool status;
  final String? imageURL;
  final int? soCho;
  final String? diemThamQuan;
  final String? amThuc;
  final String? doiTuongThichHop;
  final String? thoiGianTuong;
  final String? phuongTien;
  final String? khuyenMai;
  final bool isFeatured;

  Tour({
    required this.tourID,
    required this.providerID,
    required this.tourName,
    this.destination,
    required this.price,
    required this.status,
    this.imageURL,
    this.soCho,
    this.diemThamQuan,
    this.amThuc,
    this.doiTuongThichHop,
    this.thoiGianTuong,
    this.phuongTien,
    this.khuyenMai,
    required this.isFeatured,
  });

  // Hàm tạo từ JSON
  factory Tour.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool _toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }

    return Tour(
      tourID: json['TourID'] ?? '',
      providerID: json['ProviderID'] ?? '',
      tourName: json['TourName'] ?? '',
      destination: json['Destination'],
      price: _toDouble(json['Price']),
      status: _toBool(json['Status']),
      imageURL: json['ImageURL'],
      soCho: _toInt(json['SoCho']),
      diemThamQuan: json['DiemThamQuan'],
      amThuc: json['AmThuc'],
      doiTuongThichHop: json['DoiTuongThichHop'],
      thoiGianTuong: json['ThoiGianTuong'],
      phuongTien: json['PhuongTien'],
      khuyenMai: json['KhuyenMai'],
      isFeatured: _toBool(json['IsFeatured']),
    );
  }

  // Chuyển ngược lại sang JSON (nếu cần gửi về server)
  Map<String, dynamic> toJson() {
    return {
      'TourID': tourID,
      'ProviderID': providerID,
      'TourName': tourName,
      'Destination': destination,
      'Price': price,
      'Status': status,
      'ImageURL': imageURL,
      'SoCho': soCho,
      'DiemThamQuan': diemThamQuan,
      'AmThuc': amThuc,
      'DoiTuongThichHop': doiTuongThichHop,
      'ThoiGianTuong': thoiGianTuong,
      'PhuongTien': phuongTien,
      'KhuyenMai': khuyenMai,
      'IsFeatured': isFeatured,
    };
  }
}
