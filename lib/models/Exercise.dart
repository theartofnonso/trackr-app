/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Exercise type in your schema. */
class Exercise extends amplify_core.Model {
  static const classType = const _ExerciseModelType();
  final String id;
  final String? _name;
  final List<String>? _primary;
  final List<String>? _secondary;
  final BodyPart? _bodyPart;
  final String? _asset;
  final String? _notes;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ExerciseModelIdentifier get modelIdentifier {
      return ExerciseModelIdentifier(
        id: id
      );
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get primary {
    try {
      return _primary!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get secondary {
    try {
      return _secondary!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  BodyPart get bodyPart {
    try {
      return _bodyPart!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get asset {
    return _asset;
  }
  
  String? get notes {
    return _notes;
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Exercise._internal({required this.id, required name, required primary, required secondary, required bodyPart, asset, notes, required createdAt, required updatedAt}): _name = name, _primary = primary, _secondary = secondary, _bodyPart = bodyPart, _asset = asset, _notes = notes, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Exercise({String? id, required String name, required List<String> primary, required List<String> secondary, required BodyPart bodyPart, String? asset, String? notes, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Exercise._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      primary: primary != null ? List<String>.unmodifiable(primary) : primary,
      secondary: secondary != null ? List<String>.unmodifiable(secondary) : secondary,
      bodyPart: bodyPart,
      asset: asset,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Exercise &&
      id == other.id &&
      _name == other._name &&
      DeepCollectionEquality().equals(_primary, other._primary) &&
      DeepCollectionEquality().equals(_secondary, other._secondary) &&
      _bodyPart == other._bodyPart &&
      _asset == other._asset &&
      _notes == other._notes &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Exercise {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("primary=" + (_primary != null ? _primary!.toString() : "null") + ", ");
    buffer.write("secondary=" + (_secondary != null ? _secondary!.toString() : "null") + ", ");
    buffer.write("bodyPart=" + (_bodyPart != null ? amplify_core.enumToString(_bodyPart)! : "null") + ", ");
    buffer.write("asset=" + "$_asset" + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Exercise copyWith({String? name, List<String>? primary, List<String>? secondary, BodyPart? bodyPart, String? asset, String? notes, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Exercise._internal(
      id: id,
      name: name ?? this.name,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      bodyPart: bodyPart ?? this.bodyPart,
      asset: asset ?? this.asset,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Exercise copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<List<String>>? primary,
    ModelFieldValue<List<String>?>? secondary,
    ModelFieldValue<BodyPart>? bodyPart,
    ModelFieldValue<String?>? asset,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Exercise._internal(
      id: id,
      name: name == null ? this.name : name.value,
      primary: primary == null ? this.primary : primary.value,
      secondary: secondary == null ? this.secondary : secondary.value,
      bodyPart: bodyPart == null ? this.bodyPart : bodyPart.value,
      asset: asset == null ? this.asset : asset.value,
      notes: notes == null ? this.notes : notes.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Exercise.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _primary = json['primary']?.cast<String>(),
      _secondary = json['secondary']?.cast<String>(),
      _bodyPart = amplify_core.enumFromString<BodyPart>(json['bodyPart'], BodyPart.values),
      _asset = json['asset'],
      _notes = json['notes'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'primary': _primary, 'secondary': _secondary, 'bodyPart': amplify_core.enumToString(_bodyPart), 'asset': _asset, 'notes': _notes, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'primary': _primary,
    'secondary': _secondary,
    'bodyPart': _bodyPart,
    'asset': _asset,
    'notes': _notes,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ExerciseModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ExerciseModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PRIMARY = amplify_core.QueryField(fieldName: "primary");
  static final SECONDARY = amplify_core.QueryField(fieldName: "secondary");
  static final BODYPART = amplify_core.QueryField(fieldName: "bodyPart");
  static final ASSET = amplify_core.QueryField(fieldName: "asset");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Exercise";
    modelSchemaDefinition.pluralName = "Exercises";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.PRIMARY,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.SECONDARY,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.BODYPART,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.ASSET,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.NOTES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ExerciseModelType extends amplify_core.ModelType<Exercise> {
  const _ExerciseModelType();
  
  @override
  Exercise fromJson(Map<String, dynamic> jsonData) {
    return Exercise.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Exercise';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Exercise] in your schema.
 */
class ExerciseModelIdentifier implements amplify_core.ModelIdentifier<Exercise> {
  final String id;

  /** Create an instance of ExerciseModelIdentifier using [id] the primary key. */
  const ExerciseModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ExerciseModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ExerciseModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}