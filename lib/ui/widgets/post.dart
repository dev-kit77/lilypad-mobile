import 'base_post.dart';
import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    this.noReplies,
    this.noUpvotes,
    this.content,
    this.username,
    this.lastUpdated,
    this.userStatus,
    this.userBio,
    this.lastModified,
  });

  final int? noReplies;
  final int? noUpvotes;
  final String? content;
  final String? username;
  final String? lastUpdated;
  final String? userStatus;
  final String? userBio;
  final String? lastModified;

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
      onFlip: () => flippableCardIsFront = !flippableCardIsFront,
      direction: FlipDirection.VERTICAL,
      speed: 400,
      front: BasePostWidget(
        username: widget.username,
        content: widget.content,
        lastModified: widget.lastModified,
        noUpvotes: widget.noUpvotes,
        noReplies: widget.noReplies,
      ),
      back: UserWidget(
        username: widget.username,
        userStatus: widget.userStatus,
        userBio: widget.userBio,
      ),
    );
  }
}
