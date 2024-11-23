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
import 'package:collection/collection.dart';


/** This is an auto generated class representing the RoutineTemplatePlan type in your schema. */
class RoutineTemplatePlan extends amplify_core.Model {
  static const classType = const _RoutineTemplatePlanModelType();
  final String id;
  final String? _owner;
  final String? _data;
  final List<RoutineTemplate>? _templates;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RoutineTemplatePlanModelIdentifier get modelIdentifier {
      return RoutineTemplatePlanModelIdentifier(
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
  
  List<RoutineTemplate>? get templates {
    return _templates;
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
  
  const RoutineTemplatePlan._internal({required this.id, owner, required data, templates, required createdAt, required updatedAt}): _owner = owner, _data = data, _templates = templates, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory RoutineTemplatePlan({String? id, String? owner, required String data, List<RoutineTemplate>? templates, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return RoutineTemplatePlan._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      owner: owner,
      data: data,
      templates: templates != null ? List<RoutineTemplate>.unmodifiable(templates) : templates,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutineTemplatePlan &&
      id == other.id &&
      _owner == other._owner &&
      _data == other._data &&
      DeepCollectionEquality().equals(_templates, other._templates) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RoutineTemplatePlan {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("owner=" + "$_owner" + ", ");
    buffer.write("data=" + "$_data" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RoutineTemplatePlan copyWith({String? owner, String? data, List<RoutineTemplate>? templates, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return RoutineTemplatePlan._internal(
      id: id,
      owner: owner ?? this.owner,
      data: data ?? this.data,
      templates: templates ?? this.templates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  RoutineTemplatePlan copyWithModelFieldValues({
    ModelFieldValue<String?>? owner,
    ModelFieldValue<String>? data,
    ModelFieldValue<List<RoutineTemplate>?>? templates,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return RoutineTemplatePlan._internal(
      id: id,
      owner: owner == null ? this.owner : owner.value,
      data: data == null ? this.data : data.value,
      templates: templates == null ? this.templates : templates.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  RoutineTemplatePlan.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _owner = json['owner'],
      _data = json['data'],
      _templates = json['templates']  is Map
        ? (json['templates']['items'] is List
          ? (json['templates']['items'] as List)
              .where((e) => e != null)
              .map((e) => RoutineTemplate.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['templates'] is List
          ? (json['templates'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => RoutineTemplate.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'owner': _owner, 'data': _data, 'templates': _templates?.map((RoutineTemplate? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'owner': _owner,
    'data': _data,
    'templates': _templates,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RoutineTemplatePlanModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RoutineTemplatePlanModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final OWNER = amplify_core.QueryField(fieldName: "owner");
  static final DATA = amplify_core.QueryField(fieldName: "data");
  static final TEMPLATES = amplify_core.QueryField(
    fieldName: "templates",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'RoutineTemplate'));
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RoutineTemplatePlan";
    modelSchemaDefinition.pluralName = "RoutineTemplatePlans";
    
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
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineTemplatePlan.OWNER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineTemplatePlan.DATA,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: RoutineTemplatePlan.TEMPLATES,
      isRequired: false,
      ofModelName: 'RoutineTemplate',
      associatedKey: RoutineTemplate.TEMPLATEPLAN
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineTemplatePlan.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: RoutineTemplatePlan.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _RoutineTemplatePlanModelType extends amplify_core.ModelType<RoutineTemplatePlan> {
  const _RoutineTemplatePlanModelType();
  
  @override
  RoutineTemplatePlan fromJson(Map<String, dynamic> jsonData) {
    return RoutineTemplatePlan.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'RoutineTemplatePlan';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [RoutineTemplatePlan] in your schema.
 */
class RoutineTemplatePlanModelIdentifier implements amplify_core.ModelIdentifier<RoutineTemplatePlan> {
  final String id;

  /** Create an instance of RoutineTemplatePlanModelIdentifier using [id] the primary key. */
  const RoutineTemplatePlanModelIdentifier({
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
  String toString() => 'RoutineTemplatePlanModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RoutineTemplatePlanModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}