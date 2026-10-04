import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/neo_brutalist_theme.dart';
import '../widgets/tactile_button.dart';

class MarkdownTextController extends TextEditingController {
  MarkdownTextController({super.text});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final String currentText = text;
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    final matches = exp.allMatches(currentText);

    if (matches.isEmpty) {
      return TextSpan(style: style, text: currentText);
    }

    List<TextSpan> spans = [];
    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: currentText.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0), // Keep asterisks but make bold visually
        style: style?.copyWith(fontWeight: FontWeight.bold) ??
            const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }
    if (start < currentText.length) {
      spans.add(TextSpan(text: currentText.substring(start)));
    }

    return TextSpan(style: style, children: spans);
  }
}


class EditorScreen extends StatefulWidget {
  final Note? note;

  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  String _selectedColor = 'yellow';
  String _selectedCategory = 'All';
  String _selectedEmoji = '';

  bool get _isEditing => widget.note != null;

  static const List<String> emojis = [
    '',
    '⚡',
    '🎵',
    '🚀',
    '💡',
    '🎨',
    '📌',
    '🔥',
    '✨',
    '🧪',
    '💎',
    '🌟',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        MarkdownTextController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.colorLabel ?? 'yellow';
    _selectedCategory = widget.note?.category ?? 'All';
    _selectedEmoji = widget.note?.emoji ?? '';

    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = '${_titleController.text} ${_contentController.text}'.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a title or content',
            style: NB.bodyRegular().copyWith(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NB.badgeRadius),
            side: const BorderSide(
                color: NB.borderBlack, width: NB.strokeWidth),
          ),
        ),
      );
      return;
    }

    final provider = context.read<NotesProvider>();

    if (_isEditing) {
      final updated = widget.note!;
      updated.title = title.isEmpty ? 'Untitled' : title;
      updated.content = content;
      updated.colorLabel = _selectedColor;
      updated.category = _selectedCategory;
      updated.emoji = _selectedEmoji;
      provider.updateNote(updated);
    } else {
      final newNote = Note(
        id: DateTime.now().toIso8601String(),
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        dateAdded: DateTime.now(),
        colorLabel: _selectedColor,
        category: _selectedCategory,
        emoji: _selectedEmoji,
      );
      provider.addNote(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        NB.colorMap[_selectedColor] ?? NB.buttercupYellow;
    // Adaptive full-bleed canvas: mix the note color slightly toward white
    // for a writing-paper feel, but keep it very obviously tinted.
    final canvasColor = Color.lerp(bgColor, Colors.white, 0.35)!;

    return Scaffold(
      backgroundColor: canvasColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Stack(
            children: [
              // Subtle doodle watermarks
              _buildDoodleWatermarks(bgColor),
              Column(
                children: [
                  _buildTopBar(context),
                  _buildMetaInfo(),
                  Expanded(child: _buildEditorBody()),
                  _buildBottomToolbar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Doodle Watermarks ───────────────────────────────────────────────────

  Widget _buildDoodleWatermarks(Color tint) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              bottom: 60,
              right: -10,
              child: Transform.rotate(
                angle: 15 * (math.pi / 180),
                child: Icon(
                  Icons.auto_awesome,
                  size: 120,
                  color: tint.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -20,
              child: Transform.rotate(
                angle: -20 * (math.pi / 180),
                child: Icon(
                  Icons.brush_rounded,
                  size: 100,
                  color: tint.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 10,
              child: Transform.rotate(
                angle: 25 * (math.pi / 180),
                child: Icon(
                  Icons.star_rounded,
                  size: 80,
                  color: tint.withValues(alpha: 0.10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          // Chunky back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: NB.cardDecoration(
                color: NB.cardWhite,
                radius: 14,
                shadow: NB.shadowCompact,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 22, color: NB.textPrimary),
            ),
          ),
          const SizedBox(width: 8),

          // CANVAS EDITOR badge (hidden on very narrow screens)
          if (MediaQuery.of(context).size.width > 380) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: NB.pillDecoration(color: NB.cardWhite),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded,
                      size: 14, color: NB.textPrimary),
                  const SizedBox(width: 5),
                  Text(
                    'CANVAS EDITOR',
                    style: NB.pillCaption()
                        .copyWith(fontSize: 10, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Color switcher capsule
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: NB.pillDecoration(color: NB.cardWhite),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: NB.colorMap.entries.map((entry) {
                    final isSelected = _selectedColor == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: isSelected ? 26 : 20,
                        height: isSelected ? 26 : 20,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? NB.borderBlack
                                : NB.borderBlack.withValues(alpha: 0.3),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: NB.textPrimary)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Save pill button
          TactileButton(
            onTap: _saveNote,
            color: NB.hotOrange,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded,
                    size: 18, color: Colors.white),
                const SizedBox(width: 5),
                Text('Save', style: NB.buttonLabel().copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Meta Info ───────────────────────────────────────────────────────────

  Widget _buildMetaInfo() {
    final now = _isEditing ? widget.note!.dateAdded : DateTime.now();
    final dateStr = DateFormat('MMM d, yyyy').format(now);
    final timeStr = DateFormat('h:mm a').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          // Timestamp pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NB.cardWhite.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(NB.pillRadius),
              border: Border.all(
                  color: NB.borderBlack.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 12, color: NB.textMuted),
                const SizedBox(width: 4),
                Text(
                  '$dateStr • $timeStr • $_wordCount words',
                  style: NB.pillCaption().copyWith(color: NB.textMuted),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: NB.pillDecoration(
              color: _isEditing ? NB.mintGreen : NB.buttercupYellow,
            ),
            child: Text(
              _isEditing ? '✏️ EDITING' : '📝 DRAFT',
              style: NB.pillCaption().copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Editor Body ─────────────────────────────────────────────────────────

  Widget _buildEditorBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji + Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: NB.cardDecoration(
                    color: NB.cardWhite.withValues(alpha: 0.7),
                    radius: 12,
                    shadow: const BoxShadow(
                      color: NB.borderBlack,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji.isEmpty ? '✏️' : _selectedEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: NB.titleLarge(),
                  decoration: InputDecoration(
                    hintText: 'Name this masterpiece...',
                    hintStyle:
                        NB.titleLarge().copyWith(color: NB.textPrimary.withValues(alpha: 0.25)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Borderless content input – writing on colored paper
          TextField(
            controller: _contentController,
            style: NB.bodyLarge(),
            decoration: InputDecoration(
              hintText: 'Let your thoughts flow...',
              hintStyle:
                  NB.bodyLarge().copyWith(color: NB.textPrimary.withValues(alpha: 0.25)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: null,
            minLines: 12,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 32),
          // Decorative star watermark
          Center(
            child: Icon(
              Icons.star_rounded,
              size: 70,
              color: (NB.colorMap[_selectedColor] ?? NB.buttercupYellow)
                  .withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Emoji Picker ────────────────────────────────────────────────────────

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NB.cardWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
              left: BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
              right:
                  BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NB.dim,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pick a sticker ✨', style: NB.titleMedium()),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: NB.cardDecoration(
                        color: isSelected
                            ? NB.buttercupYellow
                            : NB.canvas,
                        radius: 14,
                        shadow: isSelected
                            ? NB.shadowPressed
                            : NB.shadowCompact,
                      ),
                      child: Center(
                        child: Text(
                          emoji.isEmpty ? '✖️' : emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ─── Toolbar Actions ─────────────────────────────────────────────────────

  void _insertText(String text, {int offsetFromEnd = 0}) {
    int cursorPos = _contentController.selection.base.offset;
    if (cursorPos < 0) {
      cursorPos = _contentController.text.length;
    }
    final String currentText = _contentController.text;
    final String newText = currentText.substring(0, cursorPos) +
        text +
        currentText.substring(cursorPos);
    _contentController.value = _contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: cursorPos + text.length - offsetFromEnd),
    );
  }

  void _insertPrefix(String prefix) {
    final selection = _contentController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _insertText('\n$prefix');
    } else {
      final text = _contentController.text;
      final selectedStr = selection.textInside(text);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedStr');
      _contentController.value = _contentController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + prefix.length),
      );
    }
  }

  void _insertBullet() => _insertPrefix('• ');
  
  void _insertCheckbox() => _insertPrefix('- [ ] ');

  void _toggleBold() {
    final selection = _contentController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _insertText('****', offsetFromEnd: 2);
    } else {
      final text = _contentController.text;
      final selectedStr = selection.textInside(text);
      // Remove asterisks if already bold, else add them
      if (selectedStr.startsWith('**') && selectedStr.endsWith('**') && selectedStr.length >= 4) {
        final unbolded = selectedStr.substring(2, selectedStr.length - 2);
        final newText = text.replaceRange(selection.start, selection.end, unbolded);
        _contentController.value = _contentController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.end - 4),
        );
      } else {
        final newText = text.replaceRange(selection.start, selection.end, '**$selectedStr**');
        _contentController.value = _contentController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.end + 4),
        );
      }
    }
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon! ✨',
          style: NB.bodyRegular().copyWith(color: Colors.white),
        ),
        backgroundColor: NB.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NB.badgeRadius),
          side: const BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Bottom Toolbar ──────────────────────────────────────────────────────

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: NB.cardWhite,
        border: Border(
          top: BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _toolbarButton(Icons.format_bold_rounded, _toggleBold),
            _toolbarButton(Icons.format_list_bulleted_rounded, _insertBullet),
            _toolbarButton(Icons.checklist_rounded, _insertCheckbox),
            _toolbarButton(Icons.send_rounded, () => _showNotImplemented('Sharing')),
            _toolbarButton(Icons.mic_rounded, () => _showNotImplemented('Voice notes')),
            _toolbarButton(Icons.image_rounded, () => _showNotImplemented('Image attachments')),
            const Spacer(),
            TactileButton(
              onTap: _showCategoryPicker,
              color: NB.lavender,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_rounded,
                      size: 14, color: NB.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCategory == 'All'
                        ? 'Idea Vault'
                        : _selectedCategory,
                    style: NB.pillCaption()
                        .copyWith(fontSize: 12, color: NB.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: NB.canvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: NB.borderBlack.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Icon(icon, size: 18, color: NB.textPrimary),
        ),
      ),
    );
  }

  // ─── Category Picker ─────────────────────────────────────────────────────

  void _showCategoryPicker() {
    final categories = ['All', 'Inventions', 'Lists', 'Inspirations'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NB.cardWhite,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
              left: BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
              right:
                  BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NB.dim,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pick a category 📂', style: NB.titleMedium()),
              const SizedBox(height: 16),
              ...categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: NB.cardDecoration(
                        color: isSelected
                            ? NB.buttercupYellow
                            : NB.canvas,
                        radius: 14,
                        shadow: isSelected
                            ? NB.shadowPressed
                            : NB.shadowCompact,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: NB.textPrimary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            cat,
                            style: NB.titleMedium().copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
