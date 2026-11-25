import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show runWithClient;
import 'package:lilypad/models/post.dart';
import 'package:lilypad/services/cache.dart';
import 'package:lilypad/ui/pages/view_post.dart';

import '../../support/content_fixtures.dart';
import '../../support/http_stub.dart';
import '../../support/ui_test_helpers.dart';

void main() {
  setUp(() => CacheService.clear());

  testWidgets('renders the post and replies returned by the API', (
    tester,
  ) async {
    final api = StubClient()
      ..queueJson(<String, Object?>{
        'replies': <Object?>[
          postJson(id: 'reply-1', content: 'a reply'),
        ],
      });

    final Post post = Post.fromMap(
      postJson(id: 'post-1', content: 'the original post'),
    );

    await runWithClient(() async {
      await pumpThemed(tester, ViewPostWidget(post: post));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }, () => api);

    expect(find.text('the original post'), findsOneWidget);
    expect(find.text('a reply'), findsOneWidget);
  });
}
