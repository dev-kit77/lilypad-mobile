import 'package:lilypad/models/post.dart';
import 'package:lilypad/models/user.dart';

import 'log.dart';

///CacheObject class to store the data and when it was retrieved/expires
class CacheObject {
  final Object? obj;
  final DateTime retrievedAt = DateTime.now();
  final DateTime expiryAt = DateTime.now().add(Duration(seconds: 120));

  CacheObject(this.obj);
}

class CacheService {
  static final Map<String, CacheObject> _cache = <String, CacheObject>{};
  static final List<bool> _ignore = [];

  CacheService._();

  ///Method to cache an object with either a key derived from the object or
  static void store({Object? o, String? key}) {
    //create cache container
    CacheObject entry = CacheObject(o);

    //if key given use
    if (key != null) {
      //add to map
      _cache[key] = entry;
      LogService.log(
        'Cached ${o.hashCode} at $key with Expiry=${entry.expiryAt.toLocal()}',
        src: 'Cache Service',
      );
    } else {
      //check type
      if (o is User) {
        //deal with null uuid for anonymous user as a shared uuid for cache only
        User u = o;
        _cache[u.uuid ?? 'anon'] = entry;
        LogService.log(
          'Cached User ${o.hashCode} with UUID=${u.uuid ?? 'anon'}, Expiry=${entry.expiryAt.toLocal()}',
          src: 'Cache Service',
        );
      } else if (o is Post) {
        Post u = o;
        _cache[u.uuid] = entry;
        LogService.log(
          'Cached Post ${o.hashCode} with UUID=${u.uuid}, Expiry=${entry.expiryAt.toLocal()}',
          src: 'Cache Service',
        );
      } else {
        //catch other objects by hashcode to maintain functionality
        _cache[o.hashCode.toString()] = entry;
        LogService.log(
          'Cached ${o.runtimeType} at ${o.hashCode} with Expiry=${entry.expiryAt.toLocal()}',
          src: 'Cache Service',
        );
      }
    }
  }

  ///Method to add a single ignore to the ignore stack.
  static void ignore() {
    _ignore.add(true);
  }

  ///Method to retrieve an object from the cache. Returns the object if cache is valid and not ignore at top of stack or null otherwise.
  static Object? fetch(String key) {
    //ignore cache if items on remove stack
    if (_ignore.isNotEmpty && _ignore.removeLast() == true) {
      return null;
    }

    ///get cache
    CacheObject? entry = _cache[key];

    //check if valid
    if (entry != null && entry.expiryAt.isAfter(DateTime.now())) {
      LogService.log(
        'Fetched ${entry.obj.runtimeType} at $key with Expiry=${entry.expiryAt.toLocal()}',
        src: 'Cache Service',
      );
      return entry.obj;
    } else {
      //invalid - remove key if exists
      _cache.remove(key);

      LogService.warn(
        'Entry at $key invalid. Entry dropped.',
        src: 'Cache Service',
      );

      //return null for invalid entry
      return null;
    }
  }

  static void free(String key) {
    _cache.remove(key);
  }

  ///Method to clear the cache and ignore stack
  static void clear() {
    _cache.clear();
    _ignore.clear();
  }

  ///Method to free invalid entries
  static void freeInvalid() {
    _cache.removeWhere((key, value) => value.expiryAt.isBefore(DateTime.now()));
  }
}
