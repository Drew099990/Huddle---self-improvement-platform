import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
// Redesigned profile page

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String avatarUrl =
      "https://media.istockphoto.com/id/1285965933/photo/audiobooks-concept.jpg?s=1024x1024&w=is&k=20&c=5W_usVS6XBX3V1DM8Q3NKQsXvEG13Yh0znl9_dv4zsU=";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(232, 4, 41, 44),
        centerTitle: true,
        title: Text(
          'Personal view',
          style: TextStyle(
            color: Colors.white60,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black54),
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
                    decoration: BoxDecoration(
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
                        backgroundImage: NetworkImage(avatarUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: -30,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 64),
              // Name and handle
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
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                          'Active days',
                          '8',
                          Icons.calendar_today,
                          size.width,
                        ),
                        _buildStatCard('Journal', '5', Icons.book, size.width),
                        _buildStatCard('Posts', '4', Icons.forum, size.width),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Actions
                    // Recent activity header
                    Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Recent items
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, __) => Divider(height: 16),
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.note, color: Colors.grey[700]),
                          ),
                          title: Text('Journal entry #${index + 1}'),
                          subtitle: Text('A short excerpt from the journal...'),
                          trailing: Text(
                            '2d',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    // Footer card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.12),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final sleepypanda = "https://sleepypanda.vercel.app";

                          final Link = Uri.tryParse(sleepypanda);

                          final webview = await launchUrl(
                            Link!,
                            mode: LaunchMode.inAppWebView,
                          ); // Handle footer tap
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.language, color: Colors.grey[700]),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.facebook_outlined,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.mail_outline,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'powered by sleepy panda',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
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
    double width,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 20),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
