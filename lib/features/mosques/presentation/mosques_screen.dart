import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/mosque_draft.dart';
import 'mosque_editor_screen.dart';

class MosquesScreen extends ConsumerWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosquesAsync = ref.watch(mosquesProvider);

    return mosquesAsync.when(
      data: (mosques) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _IntroCard(
              mosqueCount: mosques.length,
              onAdd: () => _openEditor(context, ref),
            ),
            const SizedBox(height: 16),
            if (mosques.isEmpty)
              const _EmptyState()
            else
              for (final mosque in mosques) ...[
                _MosqueCard(
                  mosque: mosque,
                  onEdit: () => _openEditor(context, ref, mosqueId: mosque.id),
                  onSetPrimary: () => _setPrimary(context, ref, mosque.id),
                  onToggleActive: () => _toggleActive(context, ref, mosque),
                  onDelete: () => _confirmDelete(context, ref, mosque),
                ),
                if (mosque != mosques.last) const SizedBox(height: 12),
              ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _LoadError(
        error: error,
        onRetry: () => ref.invalidate(mosquesProvider),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    int? mosqueId,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MosqueEditorScreen(mosqueId: mosqueId),
      ),
    );
    refreshMilestone3Data(ref, mosqueId: mosqueId, includeSettings: false);
  }

  Future<void> _setPrimary(
    BuildContext context,
    WidgetRef ref,
    int mosqueId,
  ) async {
    try {
      await ref.read(mosqueRepositoryProvider).setPrimary(mosqueId);
      refreshMilestone3Data(ref, mosqueId: mosqueId, includeSettings: false);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showError(context, error);
    }
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    Mosque mosque,
  ) async {
    try {
      await ref
          .read(mosqueRepositoryProvider)
          .save(
            MosqueDraft(
              id: mosque.id,
              name: mosque.name,
              area: mosque.area,
              latitude: mosque.latitude,
              longitude: mosque.longitude,
              isPrimary: mosque.isPrimary,
              isActive: !mosque.isActive,
              notes: mosque.notes,
            ),
          );
      refreshMilestone3Data(ref, mosqueId: mosque.id, includeSettings: false);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showError(context, error);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Mosque mosque,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete mosque?'),
          content: Text(
            'Delete ${mosque.name} and all of its timing rules? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(mosqueRepositoryProvider).delete(mosque.id);
      refreshMilestone3Data(ref, includeSettings: false);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.mosqueCount, required this.onAdd});

  final int mosqueCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mosque records',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Manage the primary mosque, archive inactive entries, and maintain offset, fixed, or seasonal Jamaat rules.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CountChip(label: 'Mosques', value: '$mosqueCount'),
                _CountChip(
                  label: 'Primary',
                  value: mosqueCount > 0 ? '1 enforced' : 'None',
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Mosque'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MosqueCard extends StatelessWidget {
  const _MosqueCard({
    required this.mosque,
    required this.onEdit,
    required this.onSetPrimary,
    required this.onToggleActive,
    required this.onDelete,
  });

  final Mosque mosque;
  final VoidCallback onEdit;
  final VoidCallback onSetPrimary;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (mosque.area != null && mosque.area!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          mosque.area!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<_MosqueMenuAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _MosqueMenuAction.edit:
                        onEdit();
                        return;
                      case _MosqueMenuAction.setPrimary:
                        onSetPrimary();
                        return;
                      case _MosqueMenuAction.toggleActive:
                        onToggleActive();
                        return;
                      case _MosqueMenuAction.delete:
                        onDelete();
                        return;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _MosqueMenuAction.edit,
                      child: Text('Edit'),
                    ),
                    if (!mosque.isPrimary)
                      const PopupMenuItem(
                        value: _MosqueMenuAction.setPrimary,
                        child: Text('Set as primary'),
                      ),
                    PopupMenuItem(
                      value: _MosqueMenuAction.toggleActive,
                      child: Text(mosque.isActive ? 'Archive' : 'Activate'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _MosqueMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (mosque.isPrimary)
                  _Badge(
                    label: 'Primary / notification',
                    icon: Icons.star_rounded,
                    tone: scheme.primary,
                  ),
                _Badge(
                  label: mosque.isActive ? 'Active' : 'Archived',
                  icon: mosque.isActive
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  tone: mosque.isActive ? scheme.secondary : scheme.outline,
                ),
                if (mosque.latitude != null && mosque.longitude != null)
                  _Badge(
                    label:
                        '${mosque.latitude!.toStringAsFixed(4)}, ${mosque.longitude!.toStringAsFixed(4)}',
                    icon: Icons.place_rounded,
                    tone: scheme.tertiary,
                  ),
              ],
            ),
            if (mosque.notes != null && mosque.notes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                mosque.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
                if (!mosque.isPrimary)
                  FilledButton.tonalIcon(
                    onPressed: onSetPrimary,
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Set Primary'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, required this.tone});

  final String label;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load mosques.',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No mosque records yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first mosque to unlock the primary home schedule and comparison table.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MosqueMenuAction { edit, setPrimary, toggleActive, delete }
