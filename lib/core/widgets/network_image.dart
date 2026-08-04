import 'package:new_strucuture/core/exports.dart';

// Amer
class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.image,
    this.isUser = false,
    this.height,
    this.width,
  });

  final String image;
  final bool isUser;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      height: height,
      width: width,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        isUser ? ImageAssets.appIconWithoutBG : ImageAssets.appIconWithoutBG,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}
