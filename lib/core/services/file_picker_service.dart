import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  static Future<String?> pickFile({required FileType type}) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
      );
      if (result != null) {
        String filePath = result.files.single.path!;
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

class ImagePickerService {
  static Future<String?> pickFile({required ImageSource source}) async {
    final ImagePicker picker = ImagePicker();
    try {
      XFile? result = await picker.pickImage(source: source);
      if (result != null) {
        String filePath = result.path;
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

Future<List<PlatformFile>?> pickAndUploadFiles() async {
  try {
    // Open file picker
    FilePickerResult? result = await FilePicker.pickFiles(
      compressionQuality: 0,
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;

      return files;
    } else {
      return null;
    }
  } catch (e) {
    rethrow;
  }
}
