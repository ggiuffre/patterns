import 'package:patterns/src/data/repositories/events.dart';
import 'package:test/test.dart';

import 'factories.dart';

main() {
  test("A HybridEventRepository stores as many events as its child repositories have in total", () async {
    final repository1 = InMemoryEventRepository()
      ..add(randomEvent())
      ..add(randomEvent());
    final repository2 = InMemoryEventRepository()..add(randomEvent());
    final hybridRepository = HybridEventRepository(repositories: [repository1, repository2]);
    final eventsLength = await hybridRepository.list.last.then((events) => events.length);
    expect(eventsLength, 3);
  });

  test("A HybridEventRepository stores events from its child repositories", () async {
    final repository1 = InMemoryEventRepository()..add(randomEvent());
    final repository2 = InMemoryEventRepository()..add(randomEvent());
    final hybridRepository = HybridEventRepository(repositories: [repository1, repository2]);
    final events1 = await repository1.list.last;
    final events2 = await repository2.list.last;
    expect(await hybridRepository.list.last.then((events) => events.toSet()), events1.followedBy(events2).toSet());
  });

  test("A HybridEventRepository reflects changes made to any of its child repositories", () async {
    final repository1 = InMemoryEventRepository()..add(randomEvent());
    final repository2 = InMemoryEventRepository()..add(randomEvent());
    final hybridRepository = HybridEventRepository(repositories: [repository1, repository2]);
    repository1.add(randomEvent());
    final events1 = await repository1.list.last;
    final events2 = await repository2.list.last;
    expect(await hybridRepository.list.last.then((events) => events.toSet()), events1.followedBy(events2).toSet());
  });
}
