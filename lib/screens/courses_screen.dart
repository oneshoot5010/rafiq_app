import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/courses_data.dart';

IconData _iconFromName(String name) {
  switch (name) {
    case 'mosque':
      return Icons.mosque_outlined;
    case 'water_drop':
      return Icons.water_drop_outlined;
    case 'nights_stay':
      return Icons.nights_stay_outlined;
    case 'favorite':
      return Icons.favorite_outline;
    case 'auto_stories':
      return Icons.auto_stories_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: coursesData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final course = coursesData[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseLessonsScreen(course: course),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: Icon(_iconFromName(course.icon),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(course.description,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        Text('${course.lessons.length} دروس',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CourseLessonsScreen extends StatefulWidget {
  final Course course;
  const CourseLessonsScreen({super.key, required this.course});

  @override
  State<CourseLessonsScreen> createState() => _CourseLessonsScreenState();
}

class _CourseLessonsScreenState extends State<CourseLessonsScreen> {
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  String get _prefsKey => 'course_progress_${widget.course.title}';

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completed = (prefs.getStringList(_prefsKey) ?? []).toSet();
    });
  }

  Future<void> _markCompleted(String lessonTitle) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _completed.add(lessonTitle));
    await prefs.setStringList(_prefsKey, _completed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.course.lessons;
    final progress =
        lessons.isEmpty ? 0.0 : _completed.length / lessons.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_completed.length} من ${lessons.length} دروس مكتملة'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final lesson = lessons[i];
                final done = _completed.contains(lesson.title);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: done
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                    child: Icon(
                      done ? Icons.check : Icons.menu_book_outlined,
                      size: 18,
                      color: done ? Colors.black : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(lesson.title),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ),
                    );
                    _loadProgress();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.content,
              style: const TextStyle(fontSize: 17, height: 1.9),
            ),
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  widget.lesson.reference,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('تم إكمال الدرس'),
                onPressed: () async {
                  final courseScreenState = context
                      .findAncestorStateOfType<_CourseLessonsScreenState>();
                  await courseScreenState?._markCompleted(widget.lesson.title);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
