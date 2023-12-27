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


/** This is an auto generated class representing the Routine type in your schema. */
class Routine extends amplify_core.Model {
  static const classType = const _RoutineModelType();
  final String id;
  final User? _user;
  final String? _name;
  final List<String>? _procedures;
  final String? _notes;
  final amplify_core.TemporalDateTime? _startTime;
  final amplify_core.TemporalDateTime? _endTime;
  final String? _owner;
  final List<RoutineLog>? _logs;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RoutineModelIdentifier get modelIdentifier {
      return RoutineModelIdentifier(
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
  
  List<String> get procedures {
    try {
      return _procedures!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get notes {
    try {
      return _notes!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get startTime {
    return _startTime;
  }
  
  amplify_core.TemporalDateTime? get endTime {
    return _endTime;
  }
  
  String? get owner {
    return _owner;
  }
  
  List<RoutineLog>? get logs {
    return _logs;
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
  
  const Routine._internal({required this.id, required user, required name, required procedures, required notes, startTime, endTime, owner, logs, required createdAt, required updatedAt}): _user = user, _name = name, _procedures = procedures, _notes = notes, _startTime = startTime, _endTime = endTime, _owner = owner, _logs = logs, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Routine({String? id, required User user, required String name, required List<String> procedures, required String notes, amplify_core.TemporalDateTime? startTime, amplify_core.TemporalDateTime? endTime, String? owner, List<RoutineLog>? logs, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Routine._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      user: user,
      name: name,
      procedures: procedures != null ? List<String>.unmodifiable(procedures) : procedures,
      notes: notes,
      startTime: startTime,
      endTime: endTime,
      owner: owner,
      logs: logs != null ? List<RoutineLog>.unmodifiable(logs) : logs,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Routine &&
      id == other.id &&
      _user == other._user &&
      _name == other._name &&
      DeepCollectionEquality().equals(_procedures, other._procedures) &&
      _notes == other._notes &&
      _startTime == other._startTime &&
      _endTime == other._endTime &&
      _owner == other._owner &&
      DeepCollectionEquality().equals(_logs, other._logs) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Routine {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("user=" + (_user != null ? _user!.toString() : "null") + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("procedures=" + (_procedures != null ? _procedures!.toString() : "null") + ", ");
    buffer.write("notes=" + "$_notes" + ", ");
    buffer.write("startTime=" + (_startTime != null ? _startTime!.format() : "null") + ", ");
    buffer.write("endTime=" + (_endTime != null ? _endTime!.format() : "null") + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Routine copyWith({User? user, String? name, List<String>? procedures, String? notes, amplify_core.TemporalDateTime? startTime, amplify_core.TemporalDateTime? endTime, String? owner, List<RoutineLog>? logs, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Routine._internal(
      id: id,
      user: user ?? this.user,
      name: name ?? this.name,
      procedures: procedures ?? this.procedures,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      owner: owner ?? this.owner,
      logs: logs ?? this.logs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Routine copyWithModelFieldValues({
    ModelFieldValue<User>? user,
    ModelFieldValue<String>? name,
    ModelFieldValue<List<String>?>? procedures,
    ModelFieldValue<String>? notes,
    ModelFieldValue<amplify_core.TemporalDateTime?>? startTime,
    ModelFieldValue<amplify_core.TemporalDateTime?>? endTime,
    ModelFieldValue<String?>? owner,
    ModelFieldValue<List<RoutineLog>?>? logs,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Routine._internal(
      id: id,
      user: user == null ? this.user : user.value,
      name: name == null ? this.name : name.value,
      procedures: procedures == null ? this.procedures : procedures.value,
      notes: notes == null ? this.notes : notes.value,
      startTime: startTime == null ? this.startTime : startTime.value,
      endTime: endTime == null ? this.endTime : endTime.value,
      owner: owner == null ? this.owner : owner.value,
      logs: logs == null ? this.logs : logs.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Routine.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _user = json['user']?['serializedData'] != null
        ? User.fromJson(new Map<String, dynamic>.from(json['user']['serializedData']))
        : null,
      _name = json['name'],
      _procedures = json['procedures']?.cast<String>(),
      _notes = json['notes'],
      _startTime = json['startTime'] != null ? amplify_core.TemporalDateTime.fromString(json['startTime']) : null,
      _endTime = json['endTime'] != null ? amplify_core.TemporalDateTime.fromString(json['endTime']) : null,
      _owner = json['owner'],
      _logs = json['logs'] is List
        ? (json['logs'] as List)
          .where((e) => e?['serializedData'] != null)
          .map((e) => RoutineLog.fromJson(new Map<String, dynamic>.from(e['serializedData'])))
          .toList()
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'user': _user?.toJson(), 'name': _name, 'procedures': _procedures, 'notes': _notes, 'startTime': _startTime?.format(), 'endTime': _endTime?.format(), 'owner': _owner, 'logs': _logs?.map((RoutineLog? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'user': _user,
    'name': _name,
    'procedures': _procedures,
    'notes': _notes,
    'startTime': _startTime,
    'endTime': _endTime,
    'owner': _owner,
    'logs': _logs,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RoutineModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoutineModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER = amplify_core.QueryField(
    fieldName: "user",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'User'));
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PROCEDURES = amplify_core.QueryField(fieldName: "procedures");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final STARTTIME = amplify_core.QueryField(fieldName: "startTime");
  static final ENDTIME = amplify_core.QueryField(fieldName: "endTime");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final LOGS = amplify_core.QueryField(
    fieldName: "logs",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'RoutineLog'));
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Routine";
    modelSchemaDefinition.pluralName = "Routines";
    
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
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userID"], name: "byUser")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: Routine.USER,
      isRequired: true,
      targetNames: ['userID'],
      ofModelName: 'User'
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.PROCEDURES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.NOTES,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.STARTTIME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.ENDTIME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: Routine.LOGS,
      isRequired: false,
      ofModelName: 'RoutineLog',
      associatedKey: RoutineLog.ROUTINE
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Routine.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _RoutineModelType extends amplify_core.ModelType<Routine> {
  const _RoutineModelType();
  
  @override
  Routine fromJson(Map<String, dynamic> jsonData) {
    return Routine.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Routine';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Routine] in your schema.
 */
class RoutineModelIdentifier implements amplify_core.ModelIdentifier<Routine> {
  final String id;

  /** Create an instance of RoutineModelIdentifier using [id] the primary key. */
  const RoutineModelIdentifier({
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
  String toString() => 'RoutineModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RoutineModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}