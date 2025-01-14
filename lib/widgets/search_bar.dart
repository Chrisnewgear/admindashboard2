import 'package:flutter/material.dart';

class EnhancedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function() onClear;
  final String hintText;
  final Color? accentColor;
  final Function(bool)? onSearchStateChanged;

  const EnhancedSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    this.hintText = 'Buscar...',
    this.accentColor,
    this.onSearchStateChanged,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && 
          widget.controller.text.isEmpty && 
          _isSearching) {
        _closeSearch();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _animationController.reverse();
      widget.controller.clear();
      widget.onClear();
      _focusNode.unfocus();
    });
    widget.onSearchStateChanged?.call(false);
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
      _animationController.forward();
      _focusNode.requestFocus();
    });
    widget.onSearchStateChanged?.call(true);
  }

  void _toggleSearch() {
    if (_isSearching) {
      _closeSearch();
    } else {
      _openSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.accentColor ?? Theme.of(context).primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_isSearching ? 25 : 50),
      child: Container(
        height: 50,
        width: _isSearching ? MediaQuery.of(context).size.width * 0.8 : 50,
        decoration: BoxDecoration(
          color: _isSearching ? Colors.grey[100] : Colors.transparent, // Fondo solo cuando está expandido
          boxShadow: [
            if (_isSearching) // Solo muestra la sombra si está buscando
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _toggleSearch,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            if (_isSearching)
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
