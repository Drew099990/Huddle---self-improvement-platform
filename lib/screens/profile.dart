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
    await Hive.initFlutter();
    _box = await Hive.openBox('profilepic');
    final savedPath = _box.get('profileImagePath') as String?;
    if (mounted) {
      setState(() {
        _selectedImagePath = savedPath;
      });
    }
  }

  bool picSelect = false;

  Future<void> _pickProfileImage() async {
    setState(() {});
    picSelect = true;
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
    setState(() {
      picSelect = false;
    });
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color.fromARGB(148, 34, 39, 58),
                        content: Text("message shared with the world !!!"),
                      ),
                    );
                    Navigator.pop(context);
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
                    bottom: -60,
                    child: InkWell(
                      onTap: _pickProfileImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: picSelect
                              ? Border.all(
                                  color: const Color.fromARGB(87, 40, 107, 184),
                                  width: 6,
                                )
                              : Border.all(color: Colors.white, width: 6),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!))
                              : const AssetImage("lib/assets/ab.jpg"),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 210,
                    bottom: 15,
                    child: InkWell(
                      onTap: _pickProfileImage,

                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(111, 0, 85, 119),
                          ),
                          color: const Color.fromARGB(255, 241, 243, 245),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: const Color.fromARGB(146, 19, 87, 133),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'William',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '@william',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            print("tapped");
                            // TODO: Show subscription modal
                            try {
                              showBottomSheet(
                                context: context,
                                builder: (_) => Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      131,
                                      55,
                                      92,
                                      114,
                                    ),
                                  ),
                                  height: 433,
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.black38,
                                      ),

                                      Container(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            151,
                                            14,
                                            71,
                                            117,
                                          ),
                                        ),

                                        child: Column(
                                          children: [
                                            Divider(height: 10, thickness: 5),

                                            Text(
                                              "hello there, Friend (❁´◡`❁) ",
                                              style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            Text(
                                              "Upgrade to premium",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                  210,
                                                  248,
                                                  234,
                                                  209,
                                                ),
                                              ),
                                            ),
                                            Divider(height: 10),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        height: 300,
                                        width: 600,
                                        padding: EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Perks("Remove all Ads"),
                                            Perks("Unlimited Favorites"),
                                            Perks("Access to All Games"),
                                            Perks("Become a Beta Tester"),
                                            Perks("Peace and Joy ^_^"),
                                            SizedBox(height: 15),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    border: Border.all(
                                                      width: 4,
                                                      color:
                                                          const Color.fromARGB(
                                                            210,
                                                            86,
                                                            101,
                                                            143,
                                                          ),
                                                    ),
                                                    color: const Color.fromARGB(
                                                      210,
                                                      91,
                                                      125,
                                                      170,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Upgrade",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            235,
                                                            231,
                                                            183,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            151,
                                            14,
                                            71,
                                            117,
                                          ),
                                        ),
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: Text(
                                          "Thanks for the support, appreciate the help !!!",
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              185,
                                              179,
                                              161,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } catch (e) {
                              print(e);
                            }
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
                              border: Border.all(
                                width: 2,
                                color: Colors.black54,
                              ),
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

  Widget Perks(String perk) {
    return Row(
      children: [
        Icon(
          Icons.star_border_outlined,
          size: 40,
          color: const Color.fromARGB(242, 197, 204, 218),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            perk,
            style: TextStyle(
              fontSize: 15,
              color: const Color.fromARGB(255, 246, 246, 248),
            ),
          ),
        ),
      ],
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
