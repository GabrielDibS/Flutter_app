import 'package:flutter/material.dart';

class InvertextoScaffold extends StatelessWidget {
  final String titulo;
  final Widget body;

  const InvertextoScaffold({
    super.key,
    required this.titulo,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
    );
  }
}
