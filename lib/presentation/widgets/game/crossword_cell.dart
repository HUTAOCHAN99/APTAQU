import 'package:flutter/material.dart';

class CrosswordCell extends StatefulWidget {
  final bool isWhite;
  final String letter;
  final int? number;
  final double cellSize;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function()? onNext;

  const CrosswordCell({
    super.key,
    required this.isWhite,
    required this.letter,
    required this.number,
    required this.cellSize,
    required this.focusNode,
    required this.onChanged,
    this.onNext,
  });

  @override
  State<CrosswordCell> createState() => _CrosswordCellState();
}

class _CrosswordCellState extends State<CrosswordCell>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.letter);
  }

  @override
  void didUpdateWidget(covariant CrosswordCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letter != widget.letter) {
      _controller.text = widget.letter;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isSmallDevice =
        MediaQuery.of(context).size.width <
        360.0; // Using direct value instead of constant

    if (!widget.isWhite) {
      return Container(color: Colors.black);
    }

    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            if (widget.number != null)
              Positioned(
                top: 2,
                left: 2,
                child: Text(
                  '${widget.number}',
                  style: TextStyle(
                    fontSize: widget.cellSize * (isSmallDevice ? 0.15 : 0.2),
                    color: Colors.black,
                  ),
                ),
              ),
            Center(
              child: TextField(
                controller: _controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.next,
                onChanged: widget.onChanged,
                onSubmitted: (_) => widget.onNext?.call(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
                style: TextStyle(
                  fontSize: widget.cellSize * (isSmallDevice ? 0.35 : 0.4),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLength: 1,
                maxLines: 1,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
