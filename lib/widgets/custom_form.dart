import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ValidationFunction = String? Function(String?);

class CustomForm extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData? headerIcon;
  final Color? headerIconColor;
  final List<CustomFormField> fields;
  final List<Widget>? footerWidgets;
  final String? infoNote;

  final IconData? infoIcon;

  final Function(Map<String, dynamic>)? onSubmit;

  final String submitButtonText;

  final String? cancelButtonText;

  final VoidCallback? onCancel;

  final bool liveUpdate;

  final double fieldSpacing;

  final EdgeInsets padding;

  final MainAxisAlignment buttonAlignment;

  final bool showPreview;

  const CustomForm({
    Key? key,
    this.title,
    this.subtitle,
    this.headerIcon,
    this.headerIconColor,
    required this.fields,
    this.footerWidgets,
    this.infoNote,
    this.infoIcon = Icons.info_outline,
    this.onSubmit,
    this.submitButtonText = 'Salvar',
    this.cancelButtonText,
    this.onCancel,
    this.liveUpdate = true,
    this.fieldSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.buttonAlignment = MainAxisAlignment.end,
    this.showPreview = true,
  }) : super(key: key);

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();

    for (var field in widget.fields) {
      if (field.initialValue != null) {
        _formData[field.name] = field.initialValue;
      }
    }
  }

  void _updateField(String name, dynamic value) {
    setState(() {
      _formData[name] = value;
    });
  }

  Map<String, dynamic> get formData => _formData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showPreview) _buildPreviewSection(theme),

            if (widget.showPreview) SizedBox(height: widget.fieldSpacing * 2),

            ...widget.fields.map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormField(field, theme),
                  SizedBox(height: widget.fieldSpacing),
                ],
              );
            }),

            if (widget.footerWidgets != null) ...widget.footerWidgets!,

            if (widget.infoNote != null) _buildInfoNote(theme),

            if (widget.infoNote != null) SizedBox(height: widget.fieldSpacing),

            Row(
              mainAxisAlignment: widget.buttonAlignment,
              children: [
                if (widget.cancelButtonText != null)
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    child: Text(widget.cancelButtonText!),
                  ),
                if (widget.cancelButtonText != null) const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.submitButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(ThemeData theme) {
    String previewTitle = widget.title ?? 'Preview';
    String previewSubtitle = widget.subtitle ?? '';

    for (var field in widget.fields) {
      if (_formData.containsKey(field.name)) {
        if (field.isTitle &&
            _formData[field.name] != null &&
            _formData[field.name].toString().isNotEmpty) {
          previewTitle = _formData[field.name].toString();
        } else if (field.isSubtitle &&
            _formData[field.name] != null &&
            _formData[field.name].toString().isNotEmpty) {
          previewSubtitle = _formData[field.name].toString();
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          if (widget.headerIcon != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                    theme.colorScheme.primary.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Icon(
                widget.headerIcon,
                size: 40,
                color: widget.headerIconColor ?? theme.colorScheme.onPrimary,
              ),
            ),
          if (widget.headerIcon != null) const SizedBox(height: 16),
          Text(
            previewTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (previewSubtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              previewSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField(CustomFormField field, ThemeData theme) {
    switch (field.type) {
      case CustomFormFieldType.text:
        return TextFormField(
          initialValue: field.initialValue?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            prefixIcon: field.icon != null ? Icon(field.icon) : null,
            border: const OutlineInputBorder(),
            helperText: field.helperText,
          ),
          maxLines: field.maxLines,
          keyboardType: field.keyboardType,
          textCapitalization: field.textCapitalization,
          validator: field.validator,
          enabled: field.enabled,
          obscureText: field.obscureText,
          onChanged: (value) {
            _updateField(field.name, value);
            if (field.onChanged != null) field.onChanged!(value);
          },
        );

      case CustomFormFieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: _formData[field.name]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            prefixIcon: field.icon != null ? Icon(field.icon) : null,
            border: const OutlineInputBorder(),
            helperText: field.helperText,
          ),
          items:
              field.dropdownItems?.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item.value,
                  child: Text(item.label),
                );
              }).toList() ??
              [],
          validator: field.validator,
          onChanged: field.enabled
              ? (value) {
                  _updateField(field.name, value);
                  if (field.onChanged != null) field.onChanged!(value);
                }
              : null,
        );

      case CustomFormFieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          subtitle: field.hint != null ? Text(field.hint!) : null,
          value: _formData[field.name] == true,
          onChanged: field.enabled
              ? (value) {
                  _updateField(field.name, value);
                  if (field.onChanged != null) field.onChanged!(value);
                }
              : null,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );

      case CustomFormFieldType.switch_:
        return SwitchListTile(
          title: Text(field.label),
          subtitle: field.hint != null ? Text(field.hint!) : null,
          value: _formData[field.name] == true,
          onChanged: field.enabled
              ? (value) {
                  _updateField(field.name, value);
                  if (field.onChanged != null) field.onChanged!(value);
                }
              : null,
          contentPadding: EdgeInsets.zero,
        );

      case CustomFormFieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(field.label, style: theme.textTheme.titleSmall),
              ),
            ...?field.radioItems?.map(
              (item) => RadioListTile<String>(
                title: Text(item.label),
                value: item.value,
                groupValue: _formData[field.name]?.toString(),
                onChanged: field.enabled
                    ? (value) {
                        _updateField(field.name, value);
                        if (field.onChanged != null) field.onChanged!(value);
                      }
                    : null,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        );

      case CustomFormFieldType.dateTime:
        return InkWell(
          onTap: field.enabled
              ? () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _formData[field.name] ?? DateTime.now(),
                    firstDate: field.minDate ?? DateTime(1900),
                    lastDate: field.maxDate ?? DateTime(2100),
                  );
                  if (picked != null) {
                    _updateField(field.name, picked);
                    if (field.onChanged != null) field.onChanged!(picked);
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              prefixIcon: field.icon != null ? Icon(field.icon) : null,
              border: const OutlineInputBorder(),
              helperText: field.helperText,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formData[field.name] != null
                      ? field.dateFormat?.format(_formData[field.name]) ??
                            _formData[field.name].toString()
                      : field.hint ?? 'Selecione uma data',
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        );

      case CustomFormFieldType.custom:
        return field.customBuilder?.call(context, _formData[field.name], (
              value,
            ) {
              _updateField(field.name, value);
              if (field.onChanged != null) field.onChanged!(value);
            }) ??
            Container();
    }
  }

  Widget _buildInfoNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Icon(widget.infoIcon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.infoNote!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.onSubmit != null) {
        widget.onSubmit!(_formData);
      }
    }
  }
}

enum CustomFormFieldType {
  text,
  dropdown,
  checkbox,
  switch_,
  radio,
  dateTime,
  custom,
}

class CustomFormItem {
  final String label;
  final String value;

  const CustomFormItem({required this.label, required this.value});
}

class CustomFormField {
  final String name;

  final CustomFormFieldType type;

  final String label;

  final String? hint;

  final String? helperText;

  final IconData? icon;

  final dynamic initialValue;

  final ValidationFunction? validator;

  final Function(dynamic)? onChanged;

  final bool enabled;

  final bool obscureText;

  final TextInputType? keyboardType;

  final TextCapitalization textCapitalization;

  final int? maxLines;

  final List<CustomFormItem>? dropdownItems;

  final List<CustomFormItem>? radioItems;

  final DateTime? minDate;

  final DateTime? maxDate;

  final DateFormat? dateFormat;

  final Widget Function(BuildContext, dynamic, Function(dynamic))?
  customBuilder;

  final bool isTitle;

  final bool isSubtitle;

  const CustomFormField({
    required this.name,
    required this.type,
    required this.label,
    this.hint,
    this.helperText,
    this.icon,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.dropdownItems,
    this.radioItems,
    this.minDate,
    this.maxDate,
    this.dateFormat,
    this.customBuilder,
    this.isTitle = false,
    this.isSubtitle = false,
  });
}
