import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';

import 'base_post.dart';
import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.post});

  final Post post;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // State field(s) for FlippableCard widget.
  final flippableCardController = FlipCardController();
  bool flippableCardIsFront = true;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      controller: flippableCardController,
      onFlip: () async => {
        if (widget.post.user.uuid != null)
          {
            widget.post.user = await ContentService.fetchUser(
              widget.post.user.uuid!,
            ),
          },

        flippableCardIsFront = !flippableCardIsFront,
      },
      direction: FlipDirection.VERTICAL,
      speed: 400,
      front: BasePostWidget(post: widget.post),
      back: UserWidget(user: widget.post.user),
    );
  }
}
