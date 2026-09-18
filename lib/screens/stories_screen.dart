import 'package:flutter/material.dart';

class Story {
  final String title;
  final String content;
  const Story(this.title, this.content);
}

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  static const List<Story> _stories = [
    Story('قصة سيدنا آدم عليه السلام',
        'خلق الله سيدنا آدم من طين، وعلّمه الأسماء كلها، وأسجد له الملائكة إلا إبليس. أسكنه الله الجنة مع زوجه حواء، ونهاهما عن شجرة واحدة، لكن الشيطان وسوس لهما فأكلا منها، فنزلا إلى الأرض ليكونا أول البشر فيها.'),
    Story('قصة سيدنا نوح عليه السلام',
        'دعا نوح قومه إلى عبادة الله وحده تسعمائة وخمسين عامًا، لكن أكثرهم أعرضوا. أمره الله ببناء سفينة، فبناها وسط سخرية قومه. ثم جاء الطوفان الكبير، ونجا نوح ومن آمن معه والحيوانات في السفينة.'),
    Story('قصة سيدنا إبراهيم عليه السلام',
        'كسر إبراهيم أصنام قومه وأثبت لهم بطلان عبادتها، فألقوه في النار، فجعلها الله عليه بردًا وسلامًا. وهو أبو الأنبياء، وقد بنى الكعبة مع ابنه إسماعيل عليهما السلام.'),
    Story('قصة سيدنا يوسف عليه السلام',
        'رأى يوسف رؤيا فحسده إخوته وألقوه في البئر، فأخذته قافلة وبيع في مصر. صبر على الابتلاءات، ومنّ الله عليه بالحكمة وتفسير الأحلام، حتى صار عزيز مصر، والتقى بإخوته وأبيه بعد سنوات من الفراق.'),
    Story('قصة سيدنا موسى عليه السلام',
        'وُلد موسى في زمن فرعون الذي كان يقتل أبناء بني إسرائيل، فألقته أمه في النهر بأمر الله فربّي في قصر فرعون. أرسله الله نبيًا إلى فرعون، وأيّده بالمعجزات حتى نجّى بني إسرائيل من الظلم.'),
    Story('قصة سيدنا محمد صلى الله عليه وسلم',
        'وُلد النبي محمد في مكة يتيمًا، ونشأ معروفًا بالصدق والأمانة. أرسله الله رحمة للعالمين، ودعا إلى توحيد الله بالحكمة والصبر رغم الأذى، حتى نشر الإسلام في الجزيرة العربية وما حولها.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('قصص الأنبياء', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        ),
        for (final story in _stories)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              title: Text(story.title, style: theme.textTheme.titleMedium),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(story.content, textAlign: TextAlign.right, style: theme.textTheme.bodyLarge?.copyWith(height: 1.7)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
