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


/** This is an auto generated class representing the ActivityDuration type in your schema. */
class ActivityDuration extends amplify_core.Model {
  static const classType = const _ActivityDurationModelType();
  final String id;
  final String? _description;
  final amplify_core.TemporalDateTime? _startTime;
  final amplify_core.TemporalDateTime? _endTime;
  final Activity? _activity;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ActivityDurationModelIdentifier get modelIdentifier {
      return ActivityDurationModelIdentifier(
        id: id
      );
  }
  
  String? get description {
    return _description;
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
  
  Activity get activity {
    try {
      return _activity!;
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
  
  const ActivityDuration._internal({required this.id, description, required startTime, required endTime, required activity, createdAt, updatedAt}): _description = description, _startTime = startTime, _endTime = endTime, _activity = activity, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ActivityDuration({String? id, String? description, required amplify_core.TemporalDateTime startTime, required amplify_core.TemporalDateTime endTime, required Activity activity}) {
    return ActivityDuration._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      description: description,
      startTime: startTime,
      endTime: endTime,
      activity: activity);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActivityDuration &&
      id == other.id &&
      _description == other._description &&
      _startTime == other._startTime &&
      _endTime == other._endTime &&
      _activity == other._activity;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ActivityDuration {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("startTime=" + (_startTime != null ? _startTime!.format() : "null") + ", ");
    buffer.write("endTime=" + (_endTime != null ? _endTime!.format() : "null") + ", ");
    buffer.write("activity=" + (_activity != null ? _activity!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ActivityDuration copyWith({String? description, amplify_core.TemporalDateTime? startTime, amplify_core.TemporalDateTime? endTime, Activity? activity}) {
    return ActivityDuration._internal(
      id: id,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activity: activity ?? this.activity);
  }
  
  ActivityDuration copyWithModelFieldValues({
    ModelFieldValue<String?>? description,
    ModelFieldValue<amplify_core.TemporalDateTime>? startTime,
    ModelFieldValue<amplify_core.TemporalDateTime>? endTime,
    ModelFieldValue<Activity>? activity
  }) {
    return ActivityDuration._internal(
      id: id,
      description: description == null ? this.description : description.value,
      startTime: startTime == null ? this.startTime : startTime.value,
      endTime: endTime == null ? this.endTime : endTime.value,
      activity: activity == null ? this.activity : activity.value
    );
  }
  
  ActivityDuration.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _description = json['description'],
      _startTime = json['startTime'] != null ? amplify_core.TemporalDateTime.fromString(json['startTime']) : null,
      _endTime = json['endTime'] != null ? amplify_core.TemporalDateTime.fromString(json['endTime']) : null,
      _activity = json['activity']?['serializedData'] != null
        ? Activity.fromJson(new Map<String, dynamic>.from(json['activity']['serializedData']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'description': _description, 'startTime': _startTime?.format(), 'endTime': _endTime?.format(), 'activity': _activity?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'description': _description,
    'startTime': _startTime,
    'endTime': _endTime,
    'activity': _activity,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ActivityDurationModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ActivityDurationModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final STARTTIME = amplify_core.QueryField(fieldName: "startTime");
  static final ENDTIME = amplify_core.QueryField(fieldName: "endTime");
  static final ACTIVITY = amplify_core.QueryField(
    fieldName: "activity",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'Activity'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ActivityDuration";
    modelSchemaDefinition.pluralName = "ActivityDurations";
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["activityId"], name: "byActivity")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ActivityDuration.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ActivityDuration.STARTTIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ActivityDuration.ENDTIME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: ActivityDuration.ACTIVITY,
      isRequired: true,
      targetNames: ['activityId'],
      ofModelName: 'Activity'
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

class _ActivityDurationModelType extends amplify_core.ModelType<ActivityDuration> {
  const _ActivityDurationModelType();
  
  @override
  ActivityDuration fromJson(Map<String, dynamic> jsonData) {
    return ActivityDuration.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ActivityDuration';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ActivityDuration] in your schema.
 */
class ActivityDurationModelIdentifier implements amplify_core.ModelIdentifier<ActivityDuration> {
  final String id;

  /** Create an instance of ActivityDurationModelIdentifier using [id] the primary key. */
  const ActivityDurationModelIdentifier({
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
  String toString() => 'ActivityDurationModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ActivityDurationModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}