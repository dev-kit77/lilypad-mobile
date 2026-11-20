import 'base_reply.dart';
import 'user.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:material_ui/material_ui.dart';

/// Component to take post data in and display
class ReplyWidget extends StatefulWidget {
  const ReplyWidget({
    super.key,
    this.noReplies,
    this.noUpvotes,
    this.content,
    this.username,
    this.lastUpdated,
    this.userStatus,
    this.userBio,
    this.lastModified,
    required this.replyUser,
  });

  final int? noReplies;
  final int? noUpvotes;
  final String? content;
  final String? username;
  final String? lastUpdated;
  final String? userStatus;
  final String? userBio;
  final String? lastModified;
  final String? replyUser;

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
      onFlip: () => flippableCardIsFront = !flippableCardIsFront,
      direction: FlipDirection.VERTICAL,
      speed: 400,
      front: BaseReplyWidget(
        username: widget.username,
        content: widget.content,
        lastModified: widget.lastUpdated,
        noUpvotes: widget.noUpvotes,
        noReplies: widget.noReplies,
        replyUsername: widget.replyUser!,
      ),
      back: UserWidget(
        username: widget.username,
        userStatus: widget.userStatus,
        userBio: widget.userBio,
      ),
    );
  }
}
