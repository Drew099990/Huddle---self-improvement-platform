import "package:flutter/material.dart";

//profile page

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),

          child: Column(
            children: [
              Container(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 10,
                      color: const Color.fromARGB(106, 21, 53, 104),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: MediaQuery.of(context).size.width * 0.25,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(100),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://media.istockphoto.com/id/1285965933/photo/audiobooks-concept.jpg?s=1024x1024&w=is&k=20&c=5W_usVS6XBX3V1DM8Q3NKQsXvEG13Yh0znl9_dv4zsU=",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "william",
                style: TextStyle(
                  fontSize: 40,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(158, 46, 63, 92),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 4,
          color: const Color.fromARGB(125, 167, 176, 206),
          thickness: 2,
        ),

        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(225, 46, 63, 92),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Card(
                color: const Color.fromARGB(255, 237, 238, 240),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Active days",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: const Color.fromARGB(158, 46, 63, 92),
                      ),
                    ),
                    Text("8", style: TextStyle(color: Colors.black45)),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(160, 64, 80, 102),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.10,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Card(
                color: const Color.fromARGB(255, 237, 238, 240),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Journal entries",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: const Color.fromARGB(158, 46, 63, 92),
                      ),
                    ),
                    Text("5", style: TextStyle(color: Colors.black45)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(160, 64, 80, 102),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.width * 0.65,
              child: Card(
                color: const Color.fromARGB(255, 237, 238, 240),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "community posts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: const Color.fromARGB(158, 46, 63, 92),
                      ),
                    ),
                    Text("4", style: TextStyle(color: Colors.black45)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 40),
        Text(
          "powered by sleepy panda",
          style: TextStyle(color: Colors.black45),
        ),
      ],
    );
  }
}
