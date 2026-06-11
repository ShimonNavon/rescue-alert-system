import 'package:flutter/material.dart';

Color _colorFromName(String name) {
  final hash = name.codeUnits.fold(0, (h, c) => h * 31 + c);
  final hue = (hash % 360).abs().toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
}

class PttTabScreen extends StatefulWidget {
  const PttTabScreen({super.key});

  @override
  State<PttTabScreen> createState() => _PttTabScreenState();
}

class _PttTabScreenState extends State<PttTabScreen> {
  int _selectedGroupIndex = 0;

  @override
  Widget build(BuildContext context) {
    const groups = <String>[
      'מוקד אלפא',
      'צוות רפואי בראבו',
      'סיוע כיבוי צ׳רלי',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = constraints.maxHeight - 32;
        final topHeight = contentHeight * 0.4;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: topHeight,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'קבוצות ערוץ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 96,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedGroupIndex;
                              final name = groups[index];
                              final color = _colorFromName(name);
                              final firstLetter = name
                                  .split(' ')
                                  .where((w) => w.isNotEmpty)
                                  .map((w) => w.characters.first)
                                  .join();

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGroupIndex = index;
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: color,
                                      child: Text(
                                        firstLetter,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: LayoutBuilder(
                    builder: (context, cardConstraints) {
                      final buttonSize =
                          (cardConstraints.maxHeight * 0.42).clamp(88.0, 120.0);
                      final iconSize = (buttonSize * 0.34).clamp(28.0, 40.0);

                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'לחצן דיבור',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ערוץ נבחר: ${groups[_selectedGroupIndex]}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'לחיצה ממושכת לשידור לקבוצת התגובה הנבחרת.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.all(buttonSize / 4),
                                minimumSize: Size(buttonSize, buttonSize),
                              ),
                              child: Icon(Icons.mic, size: iconSize),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
