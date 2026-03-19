import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 2, height: 2);
  final pixel = image.getPixel(0, 0);
  print('Pixel type: ${pixel.runtimeType}');
  print('Pixel R: ${pixel.r}');
}
