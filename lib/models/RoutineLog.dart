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


/** This is an auto generated class representing the RoutineLog type in your schema. */
class RoutineLog extends amplify_core.Model {
  static const classType = const _RoutineLogModelType();
  final String id;
  final String? _routineId;
  final amplify_core.TemporalDateTime? _startTime;
  final amplify_core.TemporalDateTime? _endTime;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

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
  
  String get routineId {
    try {
      return _routineId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get startTime {
    try {
      return _startTime!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get endTime {
    try {
      return _endTime!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const RoutineLog._internal({required this.id, required routineId, required startTime, required endTime, createdAt, updatedAt}): _routineId = routineId, _startTime = startTime, _endTime = endTime, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory RoutineLog({String? id, required String routineId, required amplify_core.TemporalDateTime startTime, required amplify_core.TemporalDateTime endTime}) {
    return RoutineLog._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      routineId: routineId,
      startTime: startTime,
      endTime: endTime);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutineLog &&
      id == other.id &&
      _routineId == other._routineId &&
      _startTime == other._startTime &&
      _endTime == other._endTime;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RoutineLog {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("routineId=" + "$_routineId" + ", ");
    buffer.write("startTime=" + (_startTime != null ? _startTime!.format() : "null") + ", ");
    buffer.write("endTime=" + (_endTime != null ? _endTime!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RoutineLog copyWith({String? routineId, amplify_core.TemporalDateTime? startTime, amplify_core.TemporalDateTime? endTime}) {
    return RoutineLog._internal(
      id: id,
      routineId: routineId ?? this.routineId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime);
  }
  
  RoutineLog copyWithModelFieldValues({
    ModelFieldValue<String>? routineId,
    ModelFieldValue<amplify_core.TemporalDateTime>? startTime,
    ModelFieldValue<amplify_core.TemporalDateTime>? endTime
  }) {
    return RoutineLog._internal(
      id: id,
      routineId: routineId == null ? this.routineId : routineId.value,
      startTime: startTime == null ? this.startTime : startTime.value,
      endTime: endTime == null ? this.endTime : endTime.value
    );
  }
  
  RoutineLog.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _routineId = json['routineId'],
      _startTime = json['startTime'] != null ? amplify_core.TemporalDateTime.fromString(json['startTime']) : null,
      _endTime = json['endTime'] != null ? amplify_core.TemporalDateTime.fromString(json['endTime']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'routineId': _routineId, 'startTime': _startTime?.format(), 'endTime': _endTime?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'routineId': _routineId,
    'startTime': _startTime,
    'endTime': _endTime,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RoutineLogModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoutineLogModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final ROUTINEID = amplify_core.QueryField(fieldName: "routineId");
  static final STARTTIME = amplify_core.QueryField(fieldName: "startTime");
  static final ENDTIME = amplify_core.QueryField(fieldName: "endTime");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RoutineLog";
    modelSchemaDefinition.pluralName = "RoutineLogs";
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["routineId"], name: "byRoutine")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.ROUTINEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.STARTTIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineLog.ENDTIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
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