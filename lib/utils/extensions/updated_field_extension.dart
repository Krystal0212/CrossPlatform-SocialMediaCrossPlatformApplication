extension UpdateFieldsExtension on Map<String, dynamic> {
  // A generic function that updates the field only if it's not empty.
  T updateField<T>(String key, T originalValue) {
    return this[key] != null && this[key].toString().isNotEmpty ?  this[key]as T : originalValue ;
  }
}
