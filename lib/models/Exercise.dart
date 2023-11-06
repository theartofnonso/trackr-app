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
  final User? _user;
  final String? _name;
  final BodyPart? _primaryMuscle;
  final List<BodyPart>? _secondaryMuscles;
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
  
  User get user {
    try {
      return _user!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  BodyPart get primaryMuscle {
    try {
      return _primaryMuscle!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<BodyPart> get secondaryMuscles {
    try {
      return _secondaryMuscles!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  const Exercise._internal({required this.id, required user, required name, required primaryMuscle, required secondaryMuscles, notes, required createdAt, required updatedAt}): _user = user, _name = name, _primaryMuscle = primaryMuscle, _secondaryMuscles = secondaryMuscles, _notes = notes, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Exercise({String? id, required User user, required String name, required BodyPart primaryMuscle, required List<BodyPart> secondaryMuscles, String? notes, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Exercise._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user: user,
      name: name,
      primaryMuscle: primaryMuscle,
      secondaryMuscles: secondaryMuscles != null ? List<BodyPart>.unmodifiable(secondaryMuscles) : secondaryMuscles,
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
      _user == other._user &&
      _name == other._name &&
      _primaryMuscle == other._primaryMuscle &&
      DeepCollectionEquality().equals(_secondaryMuscles, other._secondaryMuscles) &&
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
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("primaryMuscle=" + (_primaryMuscle != null ? amplify_core.enumToString(_primaryMuscle)! : "null") + ", ");
    buffer.write("secondaryMuscles=" + (_secondaryMuscles != null ? _secondaryMuscles!.map((e) => amplify_core.enumToString(e)).toString() : "null") + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Exercise copyWith({User? user, String? name, BodyPart? primaryMuscle, List<BodyPart>? secondaryMuscles, String? notes, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Exercise._internal(
      id: id,
      user: user ?? this.user,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Exercise copyWithModelFieldValues({
    ModelFieldValue<User>? user,
    ModelFieldValue<String>? name,
    ModelFieldValue<BodyPart>? primaryMuscle,
    ModelFieldValue<List<BodyPart>?>? secondaryMuscles,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Exercise._internal(
      id: id,
      user: user == null ? this.user : user.value,
      name: name == null ? this.name : name.value,
      primaryMuscle: primaryMuscle == null ? this.primaryMuscle : primaryMuscle.value,
      secondaryMuscles: secondaryMuscles == null ? this.secondaryMuscles : secondaryMuscles.value,
      notes: notes == null ? this.notes : notes.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Exercise.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _user = json['user']?['serializedData'] != null
        ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
        : null,
      _name = json['name'],
      _primaryMuscle = amplify_core.enumFromString<BodyPart>(json['primaryMuscle'], BodyPart.values),
      _secondaryMuscles = json['secondaryMuscles'] is List
        ? (json['secondaryMuscles'] as List)
          .map((e) => amplify_core.enumFromString<BodyPart>(e, BodyPart.values)!)
          .toList()
        : null,
      _notes = json['notes'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'user': _user?.toJson(), 'name': _name, 'primaryMuscle': amplify_core.enumToString(_primaryMuscle), 'secondaryMuscles': _secondaryMuscles?.map((e) => amplify_core.enumToString(e)).toList(), 'notes': _notes, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'user': _user,
    'name': _name,
    'primaryMuscle': _primaryMuscle,
    'secondaryMuscles': _secondaryMuscles,
    'notes': _notes,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ExerciseModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ExerciseModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PRIMARYMUSCLE = amplify_core.QueryField(fieldName: "primaryMuscle");
  static final SECONDARYMUSCLES = amplify_core.QueryField(fieldName: "secondaryMuscles");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Exercise";
    modelSchemaDefinition.pluralName = "Exercises";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userID"], name: "byUser")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Exercise.USER,
      isRequired: true,
      targetNames: ['userID'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.PRIMARYMUSCLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.enumeration)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Exercise.SECONDARYMUSCLES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.enumeration.name)
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