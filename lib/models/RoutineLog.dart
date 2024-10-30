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

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the RoutineLog type in your schema. */
class RoutineLog extends amplify_core.Model {
  static const classType = const _RoutineLogModelType();
  final String id;
  final String? _owner;
  final String? _data;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  final String? _type;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RoutineLogModelIdentifier get modelIdentifier {
      return RoutineLogModelIdentifier(
        id: id
      );
  }
  
  String? get owner {
    return _owner;
  }
  
  String get data {
    try {
      return _data!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  String? get type {
    return _type;
  }
  
  const RoutineLog._internal({required this.id, owner, required data, required createdAt, required updatedAt, type}): _owner = owner, _data = data, _createdAt = createdAt, _updatedAt = updatedAt, _type = type;
  
  factory RoutineLog({String? id, String? owner, required String data, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt, String? type}) {
    return RoutineLog._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      owner: owner,
      data: data,
      createdAt: createdAt,
      updatedAt: updatedAt,
      type: type);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutineLog &&
      id == other.id &&
      _owner == other._owner &&
      _data == other._data &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt &&
      _type == other._type;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RoutineLog {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("data=" + "$_data" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null") + ", ");
    buffer.write("type=" + "$_type");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RoutineLog copyWith({String? owner, String? data, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt, String? type}) {
    return RoutineLog._internal(
      id: id,
      owner: owner ?? this.owner,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type);
  }
  
  RoutineLog copyWithModelFieldValues({
    ModelFieldValue<String?>? owner,
    ModelFieldValue<String>? data,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt,
    ModelFieldValue<String?>? type
  }) {
    return RoutineLog._internal(
      id: id,
      owner: owner == null ? this.owner : owner.value,
      data: data == null ? this.data : data.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      type: type == null ? this.type : type.value
    );
  }
  
  RoutineLog.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _owner = json['owner'],
      _data = json['data'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null,
      _type = json['type'];
  
  Map<String, dynamic> toJson() => {
    'id': id, 'owner': _owner, 'data': _data, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format(), 'type': _type
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'owner': _owner,
    'data': _data,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
    'type': _type
  };

  static final amplify_core.QueryModelIdentifier<RoutineLogModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoutineLogModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final DATA = amplify_core.QueryField(fieldName: "data");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RoutineLog";
    modelSchemaDefinition.pluralName = "RoutineLogs";
    
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
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.IAM,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["type", "createdAt"], name: "routineLogByDate")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.DATA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.TYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}

class _RoutineLogModelType extends amplify_core.ModelType<RoutineLog> {
  const _RoutineLogModelType();
  
  @override
  RoutineLog fromJson(Map<String, dynamic> jsonData) {
    return RoutineLog.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'RoutineLog';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [RoutineLog] in your schema.
 */
class RoutineLogModelIdentifier implements amplify_core.ModelIdentifier<RoutineLog> {
  final String id;

  /** Create an instance of RoutineLogModelIdentifier using [id] the primary key. */
  const RoutineLogModelIdentifier({
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
  String toString() => 'RoutineLogModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RoutineLogModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}