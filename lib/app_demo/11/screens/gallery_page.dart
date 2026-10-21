import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/11/screens/home_page.dart';
import 'package:flutter_x_widgets/app_demo/11/utils/theme.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  final List<String> _images = const [
    'assets/images/test1.png',
    'https://picsum.photos/id/10/800/800', // Forest
    'https://picsum.photos/id/11/800/800', // Landscape
    'https://picsum.photos/id/12/800/800', // Beach
    'https://picsum.photos/id/13/800/800', // City
    'https://picsum.photos/id/14/800/800', // Coast
  ];

  void _openEditor(BuildContext context, ImageProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomePage(imageProvider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photo List',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '选择',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PhotoEditorTheme.accentPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final path = _images[index];
                  final isNetwork = path.startsWith('http');
                  final provider =
                      isNetwork
                          ? NetworkImage(path) as ImageProvider
                          : AssetImage(path);

                  return GestureDetector(
                    onTap: () => _openEditor(context, provider),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1A1A1A),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: provider,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                          // Subtle gradient overlap for depth
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black45],
                                stops: [0.7, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            // Placeholder for "Add" action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add functionality not implemented'),
              ),
            );
          },
          backgroundColor: const Color(0xFFFFB800),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 32),
        ),
      ),
    );
  }
}
