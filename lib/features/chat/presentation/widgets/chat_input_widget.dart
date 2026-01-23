import 'package:flutter/material.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSend;
  final bool isSending;

  const ChatInputWidget({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isSending) {
      widget.onSend(_controller.text);
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón de adjuntar (futuro)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: widget.isSending
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Adjuntos próximamente'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              color: Theme.of(context).colorScheme.primary,
            ),

            // Campo de texto
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  setState(() => _hasText = text.trim().isNotEmpty);
                },
                onSubmitted: (_) => _handleSend(),
                enabled: !widget.isSending,
              ),
            ),

            const SizedBox(width: 8),

            // Botón de enviar
            if (widget.isSending)
              const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  _hasText ? Icons.send : Icons.mic,
                  color: _hasText
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: _hasText ? _handleSend : null,
              ),
          ],
        ),
      ),
    );
  }
}