import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/listing.dart';
import '../providers/bookmark_provider.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final isBookmarked = bookmarkProvider.isBookmarked(listing.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          listing.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(listing.category),
                        const SizedBox(height: 4),
                        Text(listing.address),
                        const SizedBox(height: 4),
                        Text(listing.contactNumber),
                      ],
                    ),
                  ),
                  // Bookmark button
                  IconButton(
                    onPressed: () {
                      bookmarkProvider.toggleBookmark(listing.id);
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                  ),
                ],
              ),
              if (showActions) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
