import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "../subpages/minigame.dart";
import "../subpages/favorites.dart";

String? profileImagePath;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _showBroadcast = false;
  String? _selectedImagePath;
  late Box _box;

  @override
  void initState() {
    super.initState();
    _setupHive();
  }

  Future<void> _setupHive() async {
    _box = await Hive.openBox('profilepic');
    setState(() {
      _selectedImagePath = _box.get('profileImagePath');
    });
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _box.put('profileImagePath', path);
      setState(() {
        _selectedImagePath = path;
      });
    }
  }

  void _toggleBroadcast() {
    setState(() {
      _showBroadcast = !_showBroadcast;
    });

    if (_showBroadcast) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          alignment: Alignment.center,
          elevation: 10,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Global Board"),
              IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: const Color.fromARGB(115, 2, 36, 49),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(5),
          actions: [
            TextField(
              enabled: true,
              decoration: InputDecoration(
                hintText: "share a messsage or quote with the world",
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(146, 8, 59, 46),
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 135,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    print("done");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "share message",
                        style: TextStyle(color: Colors.white),
                      ),

                      Icon(Icons.language_outlined, color: Colors.white60),
                    ],
                  ),
                ),
              ),
            ),
          ],
          content: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Color.fromARGB(115, 202, 205, 207),
              ),
            ),
            child: Text(
              ' i am a demo message to from sleepy panda of a message to you just to say welcome! ',
              style: TextStyle(color: const Color.fromARGB(144, 0, 0, 0)),
            ),
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _showBroadcast = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(147, 191, 203, 219),
        centerTitle: true,
        title: const Text(
          'Personal view',
          style: TextStyle(
            color: Color.fromARGB(69, 25, 70, 155),
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cover + avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/assets/appbar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -50,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 6),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: _selectedImagePath != null
                            ? FileImage(File(_selectedImagePath!))
                            : const AssetImage("lib/assets/ab.jpg"),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: -30,
                    child: ElevatedButton.icon(
                      onPressed: _pickProfileImage,
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -100,
                    child: InkWell(
                      onTap: () {
                        // TODO: Show subscription modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Upgrade feature coming soon"),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(134, 165, 57, 14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                37,
                                78,
                                69,
                              ).withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(width: 2, color: Colors.black54),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          "upgrade",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 64),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'William',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '@william',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Stats
                    Row(
                      children: [
                        _buildStatCard(
                          'day installed',
                          '8 days ago',
                          Icons.calendar_today,
                          size.width,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard('Journal', '5 ', Icons.book, size.width),
                        const SizedBox(width: 8),
                        _buildStatCard('Posts', '4 ', Icons.forum, size.width),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.favorite_border_outlined,
                          label: "favorites",
                          color: const Color.fromARGB(132, 29, 77, 54),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => Favorites()),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.campaign_outlined,
                          label: "broadcast",
                          color: Colors.grey[300]!,
                          onTap: _toggleBroadcast,
                        ),

                        _buildActionButton(
                          icon: Icons.gamepad_outlined,
                          label: "mini games",
                          color: const Color.fromARGB(132, 29, 77, 54),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MiniGames()),
                            );
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 16),

                    const Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.note, color: Colors.grey),
                          ),
                          title: Text('Journal entry #${index + 1}'),
                          subtitle: const Text(
                            'A short excerpt from the journal...',
                          ),
                          trailing: const Text(
                            '2d',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      },
                    ),

                    const Divider(height: 16),
                    const SizedBox(height: 24),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.12),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final uri = Uri.parse(
                            'https://sleepypanda.vercel.app',
                          );

                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        },
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.language, color: Colors.grey),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.facebook_outlined,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.mail_outline, color: Colors.grey),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'powered by sleepy panda',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 5),
                            Icon(Icons.touch_app_outlined, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    double screenWidth,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(172, 34, 34, 34),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
