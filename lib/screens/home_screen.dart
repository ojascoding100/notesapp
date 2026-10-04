import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/neo_brutalist_theme.dart';
import '../widgets/dot_grid_painter.dart';
import '../widgets/tactile_button.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  // Pre-generate rotation angles for cards to keep them stable across rebuilds.
  final Map<String, double> _rotationAngles = {};
  final math.Random _rng = math.Random();

  double _angleFor(String id, int index) {
    return _rotationAngles.putIfAbsent(
        id, () => (_rng.nextDouble() * 4 - 2) * (math.pi / 180));
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Color _getCardColor(Note note, int index) {
    return NB.colorMap[note.colorLabel] ??
        NB.cardColors[index % NB.cardColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.canvas,
      body: Stack(
        children: [
          // Micro-dot grid background
          Positioned.fill(child: CustomPaint(painter: DotGridPainter())),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildCategoryChips(context),
                Expanded(child: _buildNotesGrid(context)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: _buildFab(context),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // "IDEA BOARD" badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: NB.pillDecoration(color: NB.cardWhite),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: NB.buttercupYellow),
                    const SizedBox(width: 6),
                    Text(
                      'IDEA BOARD',
                      style: NB.pillCaption().copyWith(
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Search button
              _buildHeaderIconButton(Icons.search_rounded),
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NB.skyBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: NB.borderBlack, width: NB.strokeWidth),
                ),
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Brain Playground badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: NB.pillDecoration(
              color: NB.buttercupYellow,
              shadow: NB.shadowCompact,
            ),
            child: Text(
              '✨ BRAIN PLAYGROUND',
              style: NB.pillCaption().copyWith(
                    fontSize: 10,
                    letterSpacing: 1.0,
                    color: NB.textPrimary,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Text('My Brain Dumps 🧠', style: NB.display1()),
          const SizedBox(height: 4),
          Text(
            'Sticky thoughts, wild ideas & scribbles',
            style: NB.bodyRegular().copyWith(
                  fontStyle: FontStyle.italic,
                  color: NB.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: NB.cardWhite,
        shape: BoxShape.circle,
        border: Border.all(color: NB.borderBlack, width: NB.strokeWidth),
        boxShadow: const [
          BoxShadow(
              color: NB.borderBlack,
              offset: Offset(2, 2),
              blurRadius: 0),
        ],
      ),
      child: Icon(icon, size: 20, color: NB.textPrimary),
    );
  }

  // ─── Category Pills ──────────────────────────────────────────────────────

  Widget _buildCategoryChips(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final allCategories = ['All', 'Inventions', 'Lists', 'Inspirations'];
    final noteCount = provider.notes.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: allCategories.map((cat) {
            final isSelected = provider.selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => provider.setCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? NB.textPrimary : NB.cardWhite,
                    borderRadius: BorderRadius.circular(NB.pillRadius),
                    border: Border.all(
                        color: NB.borderBlack, width: NB.strokeWidth),
                    boxShadow: [
                      BoxShadow(
                        color: NB.borderBlack,
                        offset: isSelected
                            ? const Offset(1, 1)
                            : const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat,
                        style: NB.pillCaption().copyWith(
                              fontSize: 13,
                              color: isSelected
                                  ? NB.cardWhite
                                  : NB.textPrimary,
                            ),
                      ),
                      if (cat == 'All') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : NB.dim.withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(NB.pillRadius),
                          ),
                          child: Text(
                            '$noteCount',
                            style: NB.pillCaption().copyWith(
                                  fontSize: 11,
                                  color: isSelected
                                      ? NB.cardWhite
                                      : NB.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Notes Grid ──────────────────────────────────────────────────────────

  Widget _buildNotesGrid(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NB.hotOrange),
      );
    }

    final notes = provider.filteredNotes;

    if (notes.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) =>
            _buildNoteCard(notes[index], index),
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Transform.rotate(
        angle: -3 * (math.pi / 180),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: NB.cardDecoration(
                color: NB.buttercupYellow,
                radius: 24,
                shadow: NB.shadowResting,
              ),
              child: const Center(
                child: Text('📝✨', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Whoops! Your brain\nis empty',
              textAlign: TextAlign.center,
              style: NB.titleMedium().copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            TactileButton(
              onTap: () {
                Navigator.push(
                  context,
                  _pageRoute(const EditorScreen()),
                );
              },
              color: NB.hotOrange,
              child: Text(
                '✨  Spark an Idea',
                style: NB.buttonLabel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Note Card ───────────────────────────────────────────────────────────

  Widget _buildRichTextPreview(String text) {
    final style = NB.bodyRegular().copyWith(color: NB.textPrimary.withValues(alpha: 0.7));
    
    // Very simple bold parser for **text**
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    final matches = exp.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(text, style: style, maxLines: 5, overflow: TextOverflow.ellipsis);
    }
    
    List<TextSpan> spans = [];
    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: style.copyWith(fontWeight: FontWeight.bold, color: NB.textPrimary),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    final cardColor = _getCardColor(note, index);
    final dateStr = DateFormat('MMM d').format(note.dateAdded);
    final angle = _angleFor(note.id, index);

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(NB.cardRadius),
          border: Border.all(color: NB.borderBlack, width: NB.strokeWidth),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text('Delete',
                style: NB.pillCaption().copyWith(color: Colors.white)),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) {
        context.read<NotesProvider>().deleteNote(note.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note deleted',
                style: NB.bodyRegular().copyWith(color: Colors.white)),
            backgroundColor: NB.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NB.badgeRadius),
              side: const BorderSide(
                  color: NB.borderBlack, width: NB.strokeWidth),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, _pageRoute(EditorScreen(note: note)));
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Transform.rotate(
                angle: angle * value,
                child: child,
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card body
              Container(
                decoration: NB.cardDecoration(
                  color: cardColor,
                  shadow: NB.shadowResting,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      if (note.emoji.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.emoji,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                note.title,
                                style: NB.titleMedium(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          note.title,
                          style: NB.titleMedium(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      // Content snippet
                      Expanded(
                        child: _buildRichTextPreview(note.content),
                      ),
                      const SizedBox(height: 8),
                      // Bottom row: timestamp pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: NB.cardWhite,
                              borderRadius:
                                  BorderRadius.circular(NB.pillRadius),
                              border: Border.all(
                                  color: NB.borderBlack,
                                  width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: NB.borderBlack,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 10, color: NB.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: NB.pillCaption()
                                      .copyWith(color: NB.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (note.wordCount > 0)
                            Text(
                              '${note.wordCount}w',
                              style: NB.pillCaption()
                                  .copyWith(color: NB.textMuted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Corner pin / tape accent (top-right rivet)
              Positioned(
                top: -5,
                right: 12,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: NB.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: NB.borderBlack, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: NB.cardWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NB.cardRadius),
              side: const BorderSide(
                  color: NB.borderBlack, width: NB.strokeWidth),
            ),
            title: Text('Delete Note?', style: NB.titleMedium()),
            content: Text('This action cannot be undone.',
                style: NB.bodyRegular()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: NB.buttonLabel()
                        .copyWith(color: NB.textMuted)),
              ),
              TactileButton(
                onTap: () => Navigator.pop(ctx, true),
                color: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Text('Delete', style: NB.buttonLabel()),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, _pageRoute(const EditorScreen()));
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: NB.hotOrange,
          shape: BoxShape.circle,
          border:
              Border.all(color: NB.borderBlack, width: NB.fabStrokeWidth),
          boxShadow: const [NB.shadowFab],
        ),
        child: const Icon(Icons.add_rounded, size: 42, color: Colors.white),
      ),
    );
  }

  // ─── Shared page route ───────────────────────────────────────────────────

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }
}
