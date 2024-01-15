// Mocks generated by Mockito 5.4.4 from annotations
// in tracker_app/test/exercise_logs_utils_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i11;
import 'dart:collection' as _i4;
import 'dart:ui' as _i15;

import 'package:flutter/foundation.dart' as _i3;
import 'package:flutter/material.dart' as _i2;
import 'package:flutter/src/widgets/notification_listener.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:tracker_app/dtos/exercise_dto.dart' as _i13;
import 'package:tracker_app/dtos/exercise_log_dto.dart' as _i8;
import 'package:tracker_app/dtos/routine_log_dto.dart' as _i5;
import 'package:tracker_app/dtos/set_dto.dart' as _i12;
import 'package:tracker_app/enums/exercise_type_enums.dart' as _i9;
import 'package:tracker_app/enums/muscle_group_enums.dart' as _i14;
import 'package:tracker_app/models/ModelProvider.dart' as _i10;
import 'package:tracker_app/providers/routine_log_provider.dart' as _i7;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeWidget_0 extends _i1.SmartFake implements _i2.Widget {
  _FakeWidget_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeInheritedWidget_1 extends _i1.SmartFake
    implements _i2.InheritedWidget {
  _FakeInheritedWidget_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_2 extends _i1.SmartFake
    implements _i3.DiagnosticsNode {
  _FakeDiagnosticsNode_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({
    _i3.TextTreeConfiguration? parentConfiguration,
    _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info,
  }) =>
      super.toString();
}

class _FakeUnmodifiableMapView_3<K, V> extends _i1.SmartFake
    implements _i4.UnmodifiableMapView<K, V> {
  _FakeUnmodifiableMapView_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUnmodifiableListView_4<E> extends _i1.SmartFake
    implements _i4.UnmodifiableListView<E> {
  _FakeUnmodifiableListView_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRoutineLogDto_5 extends _i1.SmartFake implements _i5.RoutineLogDto {
  _FakeRoutineLogDto_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BuildContext].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildContext extends _i1.Mock implements _i2.BuildContext {
  MockBuildContext() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Widget get widget => (super.noSuchMethod(
        Invocation.getter(#widget),
        returnValue: _FakeWidget_0(
          this,
          Invocation.getter(#widget),
        ),
      ) as _i2.Widget);

  @override
  bool get mounted => (super.noSuchMethod(
        Invocation.getter(#mounted),
        returnValue: false,
      ) as bool);

  @override
  bool get debugDoingBuild => (super.noSuchMethod(
        Invocation.getter(#debugDoingBuild),
        returnValue: false,
      ) as bool);

  @override
  _i2.InheritedWidget dependOnInheritedElement(
    _i2.InheritedElement? ancestor, {
    Object? aspect,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #dependOnInheritedElement,
          [ancestor],
          {#aspect: aspect},
        ),
        returnValue: _FakeInheritedWidget_1(
          this,
          Invocation.method(
            #dependOnInheritedElement,
            [ancestor],
            {#aspect: aspect},
          ),
        ),
      ) as _i2.InheritedWidget);

  @override
  void visitAncestorElements(_i2.ConditionalElementVisitor? visitor) =>
      super.noSuchMethod(
        Invocation.method(
          #visitAncestorElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void visitChildElements(_i2.ElementVisitor? visitor) => super.noSuchMethod(
        Invocation.method(
          #visitChildElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispatchNotification(_i6.Notification? notification) =>
      super.noSuchMethod(
        Invocation.method(
          #dispatchNotification,
          [notification],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.DiagnosticsNode describeElement(
    String? name, {
    _i3.DiagnosticsTreeStyle? style = _i3.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeElement,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_2(
          this,
          Invocation.method(
            #describeElement,
            [name],
            {#style: style},
          ),
        ),
      ) as _i3.DiagnosticsNode);

  @override
  _i3.DiagnosticsNode describeWidget(
    String? name, {
    _i3.DiagnosticsTreeStyle? style = _i3.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeWidget,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_2(
          this,
          Invocation.method(
            #describeWidget,
            [name],
            {#style: style},
          ),
        ),
      ) as _i3.DiagnosticsNode);

  @override
  List<_i3.DiagnosticsNode> describeMissingAncestor(
          {required Type? expectedAncestorType}) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeMissingAncestor,
          [],
          {#expectedAncestorType: expectedAncestorType},
        ),
        returnValue: <_i3.DiagnosticsNode>[],
      ) as List<_i3.DiagnosticsNode>);

  @override
  _i3.DiagnosticsNode describeOwnershipChain(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeOwnershipChain,
          [name],
        ),
        returnValue: _FakeDiagnosticsNode_2(
          this,
          Invocation.method(
            #describeOwnershipChain,
            [name],
          ),
        ),
      ) as _i3.DiagnosticsNode);
}

/// A class which mocks [RoutineLogProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockRoutineLogProvider extends _i1.Mock
    implements _i7.RoutineLogProvider {
  MockRoutineLogProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.UnmodifiableMapView<String, List<_i8.ExerciseLogDto>>
      get exerciseLogsById => (super.noSuchMethod(
            Invocation.getter(#exerciseLogsById),
            returnValue:
                _FakeUnmodifiableMapView_3<String, List<_i8.ExerciseLogDto>>(
              this,
              Invocation.getter(#exerciseLogsById),
            ),
          ) as _i4.UnmodifiableMapView<String, List<_i8.ExerciseLogDto>>);

  @override
  _i4.UnmodifiableMapView<_i9.ExerciseType, List<_i8.ExerciseLogDto>>
      get exerciseLogsByType => (super.noSuchMethod(
            Invocation.getter(#exerciseLogsByType),
            returnValue: _FakeUnmodifiableMapView_3<_i9.ExerciseType,
                List<_i8.ExerciseLogDto>>(
              this,
              Invocation.getter(#exerciseLogsByType),
            ),
          ) as _i4
              .UnmodifiableMapView<_i9.ExerciseType, List<_i8.ExerciseLogDto>>);

  @override
  _i4.UnmodifiableListView<_i5.RoutineLogDto> get logs => (super.noSuchMethod(
        Invocation.getter(#logs),
        returnValue: _FakeUnmodifiableListView_4<_i5.RoutineLogDto>(
          this,
          Invocation.getter(#logs),
        ),
      ) as _i4.UnmodifiableListView<_i5.RoutineLogDto>);

  @override
  _i4.UnmodifiableMapView<_i2.DateTimeRange, List<_i5.RoutineLogDto>>
      get weekToLogs => (super.noSuchMethod(
            Invocation.getter(#weekToLogs),
            returnValue: _FakeUnmodifiableMapView_3<_i2.DateTimeRange,
                List<_i5.RoutineLogDto>>(
              this,
              Invocation.getter(#weekToLogs),
            ),
          ) as _i4
              .UnmodifiableMapView<_i2.DateTimeRange, List<_i5.RoutineLogDto>>);

  @override
  _i4.UnmodifiableMapView<_i2.DateTimeRange, List<_i5.RoutineLogDto>>
      get monthToLogs => (super.noSuchMethod(
            Invocation.getter(#monthToLogs),
            returnValue: _FakeUnmodifiableMapView_3<_i2.DateTimeRange,
                List<_i5.RoutineLogDto>>(
              this,
              Invocation.getter(#monthToLogs),
            ),
          ) as _i4
              .UnmodifiableMapView<_i2.DateTimeRange, List<_i5.RoutineLogDto>>);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void listLogs({List<_i10.RoutineLog>? logs}) => super.noSuchMethod(
        Invocation.method(
          #listLogs,
          [],
          {#logs: logs},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i11.Future<_i5.RoutineLogDto> saveRoutineLog(
          {required _i5.RoutineLogDto? logDto}) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveRoutineLog,
          [],
          {#logDto: logDto},
        ),
        returnValue: _i11.Future<_i5.RoutineLogDto>.value(_FakeRoutineLogDto_5(
          this,
          Invocation.method(
            #saveRoutineLog,
            [],
            {#logDto: logDto},
          ),
        )),
      ) as _i11.Future<_i5.RoutineLogDto>);

  @override
  _i11.Future<void> updateRoutineLog({required _i5.RoutineLogDto? log}) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateRoutineLog,
          [],
          {#log: log},
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  void cacheRoutineLog({required _i5.RoutineLogDto? logDto}) =>
      super.noSuchMethod(
        Invocation.method(
          #cacheRoutineLog,
          [],
          {#logDto: logDto},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i11.Future<void> removeLog({required String? id}) => (super.noSuchMethod(
        Invocation.method(
          #removeLog,
          [],
          {#id: id},
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i5.RoutineLogDto? whereRoutineLog({required String? id}) =>
      (super.noSuchMethod(Invocation.method(
        #whereRoutineLog,
        [],
        {#id: id},
      )) as _i5.RoutineLogDto?);

  @override
  List<_i12.SetDto> wherePastSets({required _i13.ExerciseDto? exercise}) =>
      (super.noSuchMethod(
        Invocation.method(
          #wherePastSets,
          [],
          {#exercise: exercise},
        ),
        returnValue: <_i12.SetDto>[],
      ) as List<_i12.SetDto>);

  @override
  List<_i12.SetDto> wherePastSetsForExerciseBefore({
    required _i13.ExerciseDto? exercise,
    required DateTime? date,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #wherePastSetsForExerciseBefore,
          [],
          {
            #exercise: exercise,
            #date: date,
          },
        ),
        returnValue: <_i12.SetDto>[],
      ) as List<_i12.SetDto>);

  @override
  List<_i8.ExerciseLogDto> wherePastExerciseLogsBefore({
    required _i13.ExerciseDto? exercise,
    required DateTime? date,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #wherePastExerciseLogsBefore,
          [],
          {
            #exercise: exercise,
            #date: date,
          },
        ),
        returnValue: <_i8.ExerciseLogDto>[],
      ) as List<_i8.ExerciseLogDto>);

  @override
  List<_i12.SetDto> setsForMuscleGroupWhereDateRange({
    required _i14.MuscleGroupFamily? muscleGroupFamily,
    required _i2.DateTimeRange? range,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setsForMuscleGroupWhereDateRange,
          [],
          {
            #muscleGroupFamily: muscleGroupFamily,
            #range: range,
          },
        ),
        returnValue: <_i12.SetDto>[],
      ) as List<_i12.SetDto>);

  @override
  List<_i5.RoutineLogDto> logsWhereDate({required DateTime? dateTime}) =>
      (super.noSuchMethod(
        Invocation.method(
          #logsWhereDate,
          [],
          {#dateTime: dateTime},
        ),
        returnValue: <_i5.RoutineLogDto>[],
      ) as List<_i5.RoutineLogDto>);

  @override
  _i5.RoutineLogDto? logWhereDate({required DateTime? dateTime}) =>
      (super.noSuchMethod(Invocation.method(
        #logWhereDate,
        [],
        {#dateTime: dateTime},
      )) as _i5.RoutineLogDto?);

  @override
  List<_i8.ExerciseLogDto> exerciseLogsWhereDateRange({
    required _i2.DateTimeRange? range,
    required _i13.ExerciseDto? exercise,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #exerciseLogsWhereDateRange,
          [],
          {
            #range: range,
            #exercise: exercise,
          },
        ),
        returnValue: <_i8.ExerciseLogDto>[],
      ) as List<_i8.ExerciseLogDto>);

  @override
  List<_i5.RoutineLogDto> logsWhereDateRange(
          {required _i2.DateTimeRange? range}) =>
      (super.noSuchMethod(
        Invocation.method(
          #logsWhereDateRange,
          [],
          {#range: range},
        ),
        returnValue: <_i5.RoutineLogDto>[],
      ) as List<_i5.RoutineLogDto>);

  @override
  List<_i8.ExerciseLogDto> exerciseLogsForExercise(
          {required _i13.ExerciseDto? exercise}) =>
      (super.noSuchMethod(
        Invocation.method(
          #exerciseLogsForExercise,
          [],
          {#exercise: exercise},
        ),
        returnValue: <_i8.ExerciseLogDto>[],
      ) as List<_i8.ExerciseLogDto>);

  @override
  void reset() => super.noSuchMethod(
        Invocation.method(
          #reset,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i15.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
