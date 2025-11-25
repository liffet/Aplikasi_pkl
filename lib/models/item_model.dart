    import 'category_model.dart';
    import 'floor_model.dart';
    import 'room_model.dart';

    class ItemModel {
      final int id;
      final int? categoryId;
      final int? roomId;

      final String code;
      final String name;
      final String installDate;
      final String replacementDate;
      final String? photo;

      final CategoryModel? category;
      final RoomModel? room;
      final FloorModel? floor;

      ItemModel({
        required this.id,
        this.categoryId,
        this.roomId,
        required this.code,
        required this.name,
        this.category,
        required this.installDate,
        required this.replacementDate,
        this.photo,
        this.room,
        this.floor,
      });

      factory ItemModel.fromJson(Map<String, dynamic> json) {
        // Photo handling
        final rawPhoto = json['photo'];
        final String? photoUrl =
            (rawPhoto != null && rawPhoto.toString().isNotEmpty)
                ? rawPhoto.toString()
                : null;

        return ItemModel(
          id: json['id'] ?? 0,
          categoryId: json['category_id'],
          roomId: json['room']?['id'],
          code: json['code'] ?? '',
          name: json['name'] ?? '',

          // Convert category object
          category: json['category'] != null
              ? CategoryModel.fromJson(json['category'])
              : null,

          // Dates
          installDate: json['install_date'] ?? '',
          replacementDate: json['replacement_date'] ?? '',
          photo: photoUrl,

          // Convert room & floor object
          room: json['room'] != null ? RoomModel.fromJson(json['room']) : null,
          floor: json['floor'] != null ? FloorModel.fromJson(json['floor']) : null,
        );
      }

      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'category_id': categoryId,  
          'room_id': roomId,
          'code': code,
          'name': name,
          'install_date': installDate,
          'replacement_date': replacementDate,
          'photo': photo,
          'category': category != null ? category!.toJson() : null,
          'room': room != null ? room!.toJson() : null,
          'floor': floor != null ? floor!.toJson() : null,
        };
      }
    }
