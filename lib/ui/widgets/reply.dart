import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/content.dart';

import 'base_reply.dart';
import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class ReplyWidget extends StatefulWidget {
  const ReplyWidget({super.key, required this.post, this.replying});

  final Post post;
  final Post? replying;

  @override
  State<ReplyWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
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
      front: BaseReplyWidget(post: widget.post, replying: widget.replying),
      back: UserWidget(user: widget.post.user),
    );
  }
}
