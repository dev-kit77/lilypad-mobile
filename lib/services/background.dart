import 'package:background_fetch/background_fetch.dart';
import 'package:lilypad/services/ui/push.dart';
import 'package:lilypad/services/content.dart';
import 'package:lilypad/services/geolocation.dart';
import 'package:lilypad/services/log.dart';

class BackgroundService {
  BackgroundService._();

  static Future<void> init() async {
    //configure background fetcher
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      //Event callback
      (String taskId) async {
        //log start of task
        LogService.log(
          "Background event received: $taskId",
          src: 'Background Service',
        );

        //get last feed update
        DateTime? lastUpdate = ContentService.latest;

        if (lastUpdate != null) {
          //fetch feed
          try {
            await ContentService.fetchFeed(noCache: true);
          } on Exception {
            //log fetch failure
            LogService.err(
              "Background event failed to fetch feed: $taskId",
              src: 'Background Service',
            );
            //close background task
            BackgroundFetch.finish(taskId);
            return;
          }

          //get new latest feed update
          DateTime? newLatest = ContentService.latest;

          //check for null feed and if new latest is after previous
          if (newLatest != null && lastUpdate.isBefore(newLatest)) {
            NotificationService.newPosts(
              'New Posts in ${GeolocationService.locale}',
            );
          }
        }

        //close background task
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        //log timeout callback
        LogService.warn(
          "Background event timeout: $taskId",
          src: 'Background Service',
        );

        //end task
        BackgroundFetch.finish(taskId);
      },
    );

    switch (status) {
      case 2:
        //log config status
        LogService.log(
          "Background fetcher configure status: $status - Background Service Enabled",
          src: 'Background Service',
        );
        break;
      case 1:
        //log config status
        LogService.warn(
          "Background fetcher configure status: $status - Background Service explicitly disabled for this app or for the whole system.",
          src: 'Background Service',
        );
        break;
      case 0:
        //log config status
        LogService.warn(
          "Background fetcher configure status: $status - Background Service unavailable and the user cannot enable.",
          src: 'Background Service',
        );
        break;
    }
  }
}
