import "package:flutter/material.dart";

//journal page

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(children: [TextField(
          autocorrect: true,autofocus: true,enabled: true,decoration: InputDecoration(hintText: "what are you grateful about"),
          
        ),TextField(
          autocorrect: true,autofocus: true,enabled: true,decoration: InputDecoration(hintText: "what are you grateful about"),
          
        ),TextField(
          autocorrect: true,autofocus: true,enabled: true,decoration: InputDecoration(hintText: "what are you grateful about"),
          
        ),
        OutlinedButton(onPressed: (){}, child: Icon(Icons.add_a_photo_outlined))],)
    ,Row(
      children: [
        OutlinedButton(onPressed: (){}, child: Text("new entry")),
        OutlinedButton(onPressed: (){}, child: Text("show entries")),
      ],
      
    ),
    ListView.builder(
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        return 
        Card(child: Text("testing"),);
      },
    ),  ],
    );
  }
}
