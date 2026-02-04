import 'package:flutter/material.dart';
import '../services/autocomplete_service.dart';

/// Widget simplifié d'autocomplétion utilisant le widget Autocomplete de Flutter
/// 
/// Cette version utilise le widget Autocomplete natif de Flutter pour une
/// intégration plus simple et un comportement standard.
class SimpleAutocompleteField extends StatelessWidget {
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
  
  /// Validateur du champ
  final String? Function(String?)? validator;
  
  /// Indique si le champ est requis
  final bool required;

  const SimpleAutocompleteField({
    super.key,
    required this.controller,
    required this.type,
    required this.autocompleteService,
    required this.label,
    this.hintText,
    this.icon,
    this.onSelected,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.length < 2) {
          return const Iterable<String>.empty();
        }
        
        return autocompleteService.getSuggestions(
          textEditingValue.text,
          type,
        );
      },
      onSelected: (String selection) {
        controller.text = selection;
        onSelected?.call(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Synchroniser avec le contrôleur externe
        fieldController.text = controller.text;
        fieldController.addListener(() {
          controller.text = fieldController.text;
        });

        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon) : null,
            suffixIcon: fieldController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      fieldController.clear();
                      controller.clear();
                    },
                    tooltip: 'Effacer',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: validator,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200.0,
                maxWidth: 400.0,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        type == AutocompleteType.product
                            ? Icons.shopping_basket
                            : Icons.store,
                        size: 20,
                      ),
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
