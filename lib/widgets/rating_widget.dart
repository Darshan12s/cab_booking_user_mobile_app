import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final double initialRating;
  final Function(double rating, String comment)? onSubmit;

  const RatingWidget({super.key, this.initialRating = 0.0, this.onSubmit});

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Rate your Driver:"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = (index + 1).toDouble();
                });
              },
              child: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Please add your Comment",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _rating > 0 ? _submitRating : null,
            child: const Text("Submit Rating"),
          ),
        ),
      ],
    );
  }

  void _submitRating() {
    widget.onSubmit?.call(_rating, _commentController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
