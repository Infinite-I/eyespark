import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

/// Bottom slide-up panel for history and info.
class ControlPanel extends StatelessWidget {
  final ScrollController? scrollController;

  const ControlPanel({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(context),
                Flexible(
                  child: state.history.isEmpty
                      ? _buildEmptyState(context)
                      : _buildHistoryList(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'Say "Scan" or "What\'s ahead"',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, AppState state) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final entry = state.history[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.mic_rounded, size: 16, color: Colors.purple.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
