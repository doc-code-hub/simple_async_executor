import 'package:simple_async_executor/simple_async_executor.dart';
import 'package:simple_async_executor/src/executors/i_executor.dart';
import 'package:simple_async_executor/src/semaphore/multi_value_semaphore.dart';
import 'package:simple_async_executor/src/semaphore/pool.dart';

/// Comparator to sort the [PriorityTask]s by their priority.
typedef PriorityComparator<P> = int Function(P p1, P p2);

/// Creates a [Executor] that handles its waiting queue with a [PriorityPool]
///
/// [I] - Input type of the [PriorityTask]
/// [O] - Output type of the [PriorityTask]
/// [P] - Priority type of the [PriorityTask]
class PriorityExecutor<I, O, P> extends Executor<PriorityTask<I, O, P>, I, O> {
  /// Creates a [Executor] that handles its waiting queue with a [PriorityPool]
  ///
  /// [I] - Input type of the [PriorityTask]
  /// [O] - Output type of the [PriorityTask]
  /// [P] - Priority type of the [PriorityTask]
  PriorityExecutor({
    List<PriorityTask<I, O, P>>? initialTasks,
    int maxConcurrentTasks = 1,
  })  : assert(
          initialTasks == null ||
              initialTasks.map((t) => t.id).toSet().length ==
                  initialTasks.length,
        ),
        tasks = initialTasks ?? [],
        semaphore = Semaphore(
          maxConcurrentTasks,
          waitingQueue: PriorityPool<Function, int>(
            (p1, p2) => p2.priority.compareTo(p1.priority),
            defaultPriority: 0,
          ),
        );

  @override
  final List<PriorityTask<I, O, P>> tasks;
  @override
  final Semaphore semaphore;

  /// Modifies the priority of the task [taskId]
  void changePriority(int taskId, int priority) {
    assert(tasks.any((t) => t.id == taskId));
    final pool = semaphore.waitingPool;
    assert(pool is PriorityPool);
    final task = tasks.firstWhere((t) => t.id == taskId);
    (pool as PriorityPool<Function, int>).changePriority(
      (item) => item == task.id,
      priority,
    );
  }
}
