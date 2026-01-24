import 'package:flutter/material.dart';
import '../../domain/entities/match.dart';

class MatchCardWidget extends StatelessWidget {
  final Match match;
  final String myUserId;

  const MatchCardWidget({
    super.key,
    required this.match,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    final other = match.otherUserId(myUserId);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match con', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(other, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                if (match.listingId != null) ...[
                  const SizedBox(height: 4),
                  Text('Publicación: ${match.listingId}', style: const TextStyle(color: Colors.black54)),
                ],
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline),
        ],
      ),
    );
  }
}
