import 'package:flutter/material.dart';

class AudioBooks extends StatelessWidget {
  const AudioBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: const Color.fromARGB(106, 21, 53, 104),
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("comming soon"), Icon(Icons.face_outlined)],
          ),
        ),
      ),
    );
  }
}
