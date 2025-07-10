import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const SearchAppBar({
    required this.controller,
    required this.onSearch,
    required this.onClear,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: kToolbarHeight,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Buscar filmes...',
                  border: InputBorder.none,
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClear,
                        )
                      : null,
                ),
                onSubmitted: (_) => onSearch(),
                textInputAction: TextInputAction.search,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}