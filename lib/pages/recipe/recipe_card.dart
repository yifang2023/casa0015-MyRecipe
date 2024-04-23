part of 'recipe_page.dart';

// recipe car widget
class RecipeCard extends StatelessWidget {
  final RecipeBean data;

  const RecipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Color(0xFFF2F4FB), // background color of the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  data.coverUrl,
                  width: double.infinity, // image width fills the card
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                data.title, // card title
                style: const TextStyle(
                  // fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001F4C), // title color
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // show ellipsis for overflow
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const Icon(Icons.access_time,
                  color: Colors.grey, size: 14), // add clock icon
              const SizedBox(width: 4),
              Text(
                data.getDuration(), // show cooking duration
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
