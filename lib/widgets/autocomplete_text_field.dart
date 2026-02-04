import 'package:flutter/material.dart';
import '../services/autocomplete_service.dart';

/// Widget de champ de texte avec autocomplétion intelligente
/// 
/// Ce widget fournit des suggestions d'autocomplétion basées sur l'historique
/// des saisies. Il supporte la sélection de suggestions et la saisie libre.
class AutocompleteTextField extends StatefulWidget {
  /// Contrôleur du champ de texte
  final TextEditingController controller;
  
  /// Type d'autocomplétion (produit ou magasin)
  final AutocompleteType type;
  
  /// Service d'autocomplétion
  final AutocompleteService autocompleteService;
  
  /// Label du champ
  final String label;
  
  /// Texte d'aide (hint)
  final String? hintText;
  
  /// Icône du champ
  final IconData? icon;
  
  /// Callback appelé lors de la sélection d'une suggestion
  final ValueChanged<String>? onSelected;
  
  /// Callback appelé lors du changement de texte
  final ValueChanged<String>? onChanged;
  
  /// Validateur du champ
  final String? Function(String?)? validator;
  
  /// Indique si le champ est requis
  final bool required;
  
  /// Nombre minimum de caractères avant d'afficher les suggestions
  final int minCharsForSuggestions;

  const AutocompleteTextField({
    super.key,
    required this.controller,
    required this.type,
    required this.autocompleteService,
    required this.label,
    this.hintText,
    this.icon,
    this.onSelected,
    this.onChanged,
    this.validator,
    this.required = false,
    this.minCharsForSuggestions = 2,
  });

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged(String text) {
    // Appeler le callback externe si fourni
    widget.onChanged?.call(text);

    // Mettre à jour les suggestions
    if (text.length >= widget.minCharsForSuggestions) {
      setState(() {
        _suggestions = widget.autocompleteService.getSuggestions(
          text,
          widget.type,
        );
      });
      
      if (_suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      setState(() {
        _suggestions = [];
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _getTextFieldHeight()),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200.0,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(suggestion),
                    onTap: () => _onSuggestionSelected(suggestion),
                    leading: Icon(
                      widget.type == AutocompleteType.product
                          ? Icons.shopping_basket
                          : Icons.store,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSuggestionSelected(String suggestion) {
    widget.controller.text = suggestion;
    widget.onSelected?.call(suggestion);
    _removeOverlay();
    setState(() {
      _suggestions = [];
    });
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300.0;
  }

  double _getTextFieldHeight() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 56.0;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.required ? '${widget.label} *' : widget.label,
          hintText: widget.hintText,
          prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    _onTextChanged('');
                  },
                  tooltip: 'Effacer',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: widget.validator,
        onChanged: _onTextChanged,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}
