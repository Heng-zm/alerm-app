import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SoundSelectionScreen extends StatefulWidget {
  final String initialSound;
  final bool initialLoopStatus;

  const SoundSelectionScreen({
    super.key,
    required this.initialSound,
    required this.initialLoopStatus,
  });

  @override
  State<SoundSelectionScreen> createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  late String _selectedSound;
  late bool _loopSound;

  final List<String> _inAppSounds = [
    'Radar.mp3',
    'Waves.mp3',
    'Chimes.mp3',
    'Signal.mp3'
  ];

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.initialSound;
    _loopSound = widget.initialLoopStatus;
  }

  void _onBackPressed() {
    Navigator.pop(context, {'sound': _selectedSound, 'loop': _loopSound});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        // FIX: Enclosed the statement in a block {}.
        if (didPop) {
          return;
        }
        _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _onBackPressed,
          ),
          title: const Text('Sound'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Loop Sound',
                    style: TextStyle(color: Colors.white, fontSize: 17)),
                trailing: Switch(
                  value: _loopSound,
                  onChanged: (bool value) => setState(() => _loopSound = value),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF34C759),
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Import from device',
                        style:
                            TextStyle(color: Color(0xFFFF9F0A), fontSize: 17)),
                    onTap: _pickSoundFile,
                  ),
                  Divider(color: Colors.grey[850], height: 1, indent: 16),
                  ..._inAppSounds.map((sound) {
                    final isSelected = _selectedSound == sound;
                    return ListTile(
                      title: Text(_formatSoundName(sound),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFFFF9F0A))
                          : null,
                      onTap: () => setState(() => _selectedSound = sound),
                    );
                  }),
                ],
              ),
            ),
            if (!_inAppSounds.contains(_selectedSound))
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(_formatSoundName(_selectedSound),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 17)),
                  trailing: const Icon(Icons.check, color: Color(0xFFFF9F0A)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSoundFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );
      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        setState(() => _selectedSound = fileName);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick audio file.')),
        );
      }
    }
  }

  String _formatSoundName(String sound) {
    if (sound.endsWith('.mp3') ||
        sound.endsWith('.wav') ||
        sound.endsWith('.m4a')) {
      return sound.substring(0, sound.lastIndexOf('.'));
    }
    return sound;
  }
}
