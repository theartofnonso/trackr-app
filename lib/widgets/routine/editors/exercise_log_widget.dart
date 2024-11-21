import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/sets_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/pickers/exercise_configurations_picker.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_and_reps_set_row.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_dto.dart';
import '../../../dtos/sets_dtos/set_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../chips/squared_chips.dart';

class ExerciseLogWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDTO exerciseLogDto;
  final ExerciseLogDTO? superSet;

  final bool isMinimised;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;
  final VoidCallback? onCache;
  final VoidCallback onResize;
  final void Function(SetDTO setDto) onTapWeightEditor;
  final void Function(SetDTO setDto) onTapRepsEditor;
  final void Function(ExerciseLogDTO exerciseLogDto) onUpdate;

  const ExerciseLogWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      this.onCache,
      required this.onReplaceLog,
      required this.onResize,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor,
      required this.isMinimised,
      required this.onUpdate});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  final List<(TextEditingController, TextEditingController)> _controllers = [];
  final List<DateTime> _durationControllers = [];

  late Map<String, dynamic> _selectedConfigurations;

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: widget.onReplaceLog,
        child: Text(
          "Replace",
          style: GoogleFonts.ubuntu(color: Colors.white),
        ),
      ),
      widget.exerciseLogDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () => widget.onRemoveSuperSet(widget.exerciseLogDto.superSetId),
              child: Text("Remove Super-set", style: GoogleFonts.ubuntu(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: widget.onSuperSet,
              child: Text("Super-set", style: GoogleFonts.ubuntu()),
            ),
      MenuItemButton(
        onPressed: widget.onRemoveLog,
        child: Text(
          "Remove",
          style: GoogleFonts.ubuntu(color: Colors.red),
        ),
      ),
    ];
  }

  void _show1RMRecommendations() {
    final pastExerciseLogs = Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .exerciseLogsById[widget.exerciseLogDto.exerciseVariant.name] ??
        [];
    final completedPastExerciseLogs = completedExercises(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestSetWeightForExerciseLog(exerciseLog: previousLog);
      final oneRepMax =
          average1RM(weight: (heaviestSetWeight as WeightAndRepsSetDTO).weight, reps: (heaviestSetWeight).reps);
      displayBottomSheet(
          context: context,
          child: _OneRepMaxSlider(exercise: widget.exerciseLogDto.exerciseVariant.name, oneRepMax: oneRepMax));
    } else {
      showBottomSheetWithNoAction(
          context: context,
          title: widget.exerciseLogDto.exerciseVariant.name,
          description: "Keep logging to see recommendations.");
    }
  }

  void _updateProcedureNotes({required String value}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogNotes(exerciseId: widget.exerciseLogDto.exerciseVariant.name, value: value);
    _cacheLog();
  }

  void _addSet() {
    if (withDurationOnly(metric: widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type"))) {
      _durationControllers.add(DateTime.now());
    } else {
      _controllers.add((TextEditingController(), TextEditingController()));
    }
    final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exerciseVariant: widget.exerciseLogDto.exerciseVariant);
    Provider.of<ExerciseLogController>(context, listen: false).addSet(
        exerciseId: widget.exerciseLogDto.exerciseVariant.name,
        pastSets: pastSets,
        metric: widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type"));
    _cacheLog();
  }

  void _removeSet({required int index}) {
    if (withDurationOnly(metric: widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type"))) {
      _durationControllers.removeAt(index);
    } else {
      _controllers.removeAt(index);
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index);
    _cacheLog();
  }

  void _updateWeight({required int index, required double weight, required SetDTO setDto}) {
    final updatedSet = (setDto as WeightAndRepsSetDTO).copyWith(weight: weight);
    widget.onTapWeightEditor(updatedSet);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _updateReps({required int index, required int reps, required SetDTO setDto}) {
    final updatedSet =
        setDto is WeightAndRepsSetDTO ? setDto.copyWith(reps: reps) : (setDto as RepsSetDTO).copyWith(reps: reps);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _checkAndUpdateDuration(
      {required int index, required Duration duration, required SetDTO setDto, required bool checked}) {
    if (setDto.checked) {
      final duration = (setDto as DurationSetDTO).duration;
      final startTime = DateTime.now().subtract(duration);
      _durationControllers[index] = startTime;
      _updateSetCheck(index: index, setDto: setDto);
    } else {
      final updatedSet = (setDto as DurationSetDTO).copyWith(duration: duration, checked: checked);
      Provider.of<ExerciseLogController>(context, listen: false).updateDuration(
          exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index, setDto: updatedSet, notify: checked);
      _cacheLog();
    }
  }

  void _updateDuration({required int index, required Duration duration, required SetDTO setDto}) {
    SetDTO updatedSet = setDto;
    if (setDto.checked) {
      updatedSet = (setDto as DurationSetDTO).copyWith(duration: duration);
    } else {
      updatedSet = (setDto as DurationSetDTO).copyWith(duration: duration, checked: true);
    }

    Provider.of<ExerciseLogController>(context, listen: false).updateDuration(
        exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index, setDto: updatedSet, notify: true);
    _cacheLog();
  }

  void _updateSetCheck({required int index, required SetDTO setDto}) {
    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseId: widget.exerciseLogDto.exerciseVariant.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _loadTextEditingControllers() {
    final sets = widget.exerciseLogDto.sets;
    final metric = widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type");
    List<(TextEditingController, TextEditingController)> controllers = [];
    double weight = 0;
    int reps = 0;
    for (var set in sets) {
      if (metric == SetType.reps) {
        reps = (set as RepsSetDTO).reps;
      } else if (metric == SetType.weightsAndReps) {
        weight = (set as WeightAndRepsSetDTO).weight;
        reps = set.reps;
      }
      final value1Controller = TextEditingController(text: weight.toString());
      final value2Controller = TextEditingController(text: reps.toString());
      controllers.add((value1Controller, value2Controller));
    }
    _controllers.addAll(controllers);
  }

  void _loadDurationControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<DateTime> controllers = [];
    for (var set in sets) {
      final duration = (set as DurationSetDTO).duration;
      final startTime = DateTime.now().subtract(duration);
      controllers.add(startTime);
    }
    _durationControllers.addAll(controllers);
  }

  void _onTapWeightEditor({required SetDTO setDto}) {
    widget.onTapWeightEditor(setDto);
  }

  void _onTapRepsEditor({required SetDTO setDto}) {
    widget.onTapRepsEditor(setDto);
  }

  @override
  void initState() {
    super.initState();

    _selectedConfigurations = Map<String, dynamic>.from(widget.exerciseLogDto.exerciseVariant.configurations);

    if (SetType.weightsAndReps == widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type") ||
        SetType.reps == widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type")) {
      _loadTextEditingControllers();
    }
    if (widget.editorType == RoutineEditorMode.log &&
        SetType.duration == widget.exerciseLogDto.exerciseVariant.getSetTypeConfiguration("set_type")) {
      _loadDurationControllers();
    }
  }

  void _cacheLog() {
    final cacheLog = widget.onCache;
    if (cacheLog != null) {
      cacheLog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.exerciseLogDto.sets;

    final superSetExerciseDto = widget.superSet;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context);

    final exerciseVariant = widget.exerciseLogDto.exerciseVariant;

    final exercise = exerciseAndRoutineController.whereExercise(id: exerciseVariant.baseExerciseId);

    final configurationOptionsWidgets = exerciseVariant.configurations.keys.map((String configKey) {
      final configValue = exerciseVariant.configurations[configKey]!;
      final configOptions = exercise.configurationOptions[configKey]!;
      final isConfigurable = configOptions.length > 1;
      return isConfigurable ? OpacityButtonWidget(
        label: configValue.displayName.toLowerCase(),
        buttonColor: vibrantGreen,
        padding: EdgeInsets.symmetric(horizontal: 0),
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 12, color: vibrantGreen),
        onPressed: () => _showConfigurationPicker(configKey: configKey, baseExercise: exercise),
      ) : SquaredChips(
        label: configValue.displayName.toLowerCase(),
        color: Colors.grey,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ExerciseHomeScreen(id: widget.exerciseLogDto.exerciseVariant.baseExerciseId)));
                },
                child: Text(exerciseVariant.name,
                    style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const Spacer(),
              MenuAnchor(
                  style: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(sapphireDark80),
                    surfaceTintColor: WidgetStateProperty.all(sapphireDark),
                  ),
                  builder: (BuildContext context, MenuController controller, Widget? child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          FocusScope.of(context).unfocus();
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: _menuActionButtons())
            ],
          ),
          const SizedBox(height: 6),
          Wrap(runSpacing: 8, spacing: 8, children: configurationOptionsWidgets),
          const SizedBox(height: 8),
          if (superSetExerciseDto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text("with ${superSetExerciseDto.exerciseVariant.name}",
                  style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 12)),
            ),
          TextField(
            controller: TextEditingController(text: widget.exerciseLogDto.notes),
            onChanged: (value) => _updateProcedureNotes(value: value),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
              filled: true,
              fillColor: sapphireDark.withOpacity(0.4),
              hintText: "Enter notes",
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14),
            ),
            maxLines: null,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          switch (exerciseVariant.getSetTypeConfiguration("set_type")) {
            SetType.weightsAndReps => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            SetType.reps => RepsSetHeader(editorType: widget.editorType),
            SetType.duration => DurationSetHeader(editorType: widget.editorType),
          },
          const SizedBox(height: 8),
          if (sets.isNotEmpty)
            if (exerciseVariant.getSetTypeConfiguration("set_type") == SetType.weightsAndReps)
              _WeightAndRepsSetListView(
                sets: sets.map((set) => set as WeightAndRepsSetDTO).toList(),
                editorType: widget.editorType,
                updateSetCheck: _updateSetCheck,
                removeSet: _removeSet,
                updateReps: _updateReps,
                updateWeight: _updateWeight,
                controllers: _controllers,
                onTapWeightEditor: _onTapWeightEditor,
                onTapRepsEditor: _onTapRepsEditor,
              ),
          if (exerciseVariant.getSetTypeConfiguration("set_type") == SetType.reps)
            _RepsSetListView(
              sets: sets.map((set) => set as RepsSetDTO).toList(),
              editorType: widget.editorType,
              updateSetCheck: _updateSetCheck,
              removeSet: _removeSet,
              updateReps: _updateReps,
              controllers: _controllers,
              onTapWeightEditor: _onTapWeightEditor,
              onTapRepsEditor: _onTapRepsEditor,
            ),
          if (exerciseVariant.getSetTypeConfiguration("set_type") == SetType.duration)
            _DurationSetListView(
              sets: sets.map((set) => set as DurationSetDTO).toList(),
              editorType: widget.editorType,
              updateSetCheck: _updateSetCheck,
              removeSet: _removeSet,
              controllers: _controllers,
              onTapWeightEditor: _onTapWeightEditor,
              onTapRepsEditor: _onTapRepsEditor,
              durationControllers: _durationControllers,
              checkAndUpdateDuration: _checkAndUpdateDuration,
              updateDuration: _updateDuration,
            ),
          const SizedBox(height: 8),
          if (withDurationOnly(metric: exerciseVariant.getSetTypeConfiguration("set_type")) && sets.isEmpty)
            Center(
              child: Text("Tap + to add a timer",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white70)),
            ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (withWeightsOnly(metric: exerciseVariant.getSetTypeConfiguration("set_type")))
              IconButton(
                  onPressed: _show1RMRecommendations,
                  icon: const FaIcon(FontAwesomeIcons.solidLightbulb, color: Colors.white, size: 16),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
            const Spacer(),
            IconButton(
              onPressed: widget.onResize,
              icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.white),
              tooltip: 'Maximise card',
            ),
            const SizedBox(
              width: 6,
            ),
            IconButton(
                onPressed: _addSet,
                icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.all(sapphireDark.withOpacity(0.2)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
          ])
        ],
      ),
    );
  }

  void _showConfigurationPicker({required String configKey, required ExerciseDTO baseExercise}) {
    final options = baseExercise.configurationOptions[configKey]!;
    displayBottomSheet(
      context: context,
      height: 300,
      child: ExerciseConfigurationsPicker<dynamic>(
        label: configKey,
        initialConfig: _selectedConfigurations[configKey],
        configurationOptions: options,
        onSelect: (configuration) {
          Navigator.of(context).pop();
          setState(() {
            _selectedConfigurations[configKey] = configuration;
            final newExerciseVariant = baseExercise.createVariant(configurations: _selectedConfigurations);
            final updatedExerciseLog = widget.exerciseLogDto.copyWith(exerciseVariant: newExerciseVariant, sets: configuration is SetType ? [] : null);
            widget.onUpdate(updatedExerciseLog);
          });
        }, // Provide descriptions if available
      ),
    );
  }
  
}

class _WeightAndRepsSetListView extends StatelessWidget {
  final List<WeightAndRepsSetDTO> sets;
  final RoutineEditorMode editorType;
  final List<(TextEditingController, TextEditingController)> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDTO setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDTO setDto}) updateReps;
  final void Function({required int index, required double weight, required SetDTO setDto}) updateWeight;
  final void Function({required SetDTO setDto}) onTapWeightEditor;
  final void Function({required SetDTO setDto}) onTapRepsEditor;

  const _WeightAndRepsSetListView(
      {required this.sets,
      required this.editorType,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.updateWeight,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: WeightsAndRepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
            onChangedWeight: (double value) => updateWeight(index: index, weight: value, setDto: setDto),
            onTapWeightEditor: () => onTapWeightEditor(setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controllers: controllers[index],
          ));
    }).toList();

    return Column(children: children);
  }
}

class _RepsSetListView extends StatelessWidget {
  final List<RepsSetDTO> sets;
  final RoutineEditorMode editorType;
  final List<(TextEditingController, TextEditingController)> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDTO setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDTO setDto}) updateReps;
  final void Function({required SetDTO setDto}) onTapWeightEditor;
  final void Function({required SetDTO setDto}) onTapRepsEditor;

  const _RepsSetListView(
      {required this.sets,
      required this.editorType,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controllers: controllers[index],
          ));
    }).toList();

    return Column(children: children);
  }
}

class _DurationSetListView extends StatelessWidget {
  final List<DurationSetDTO> sets;
  final RoutineEditorMode editorType;
  final List<(TextEditingController, TextEditingController)> controllers;
  final List<DateTime> durationControllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDTO setDto}) updateSetCheck;
  final void Function({required int index, required Duration duration, required SetDTO setDto, required bool checked})
      checkAndUpdateDuration;
  final void Function({required int index, required Duration duration, required SetDTO setDto}) updateDuration;
  final void Function({required SetDTO setDto}) onTapWeightEditor;
  final void Function({required SetDTO setDto}) onTapRepsEditor;

  const _DurationSetListView(
      {required this.sets,
      required this.editorType,
      required this.controllers,
      required this.durationControllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.checkAndUpdateDuration,
      required this.updateDuration,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DurationSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onCheckAndUpdateDuration: (Duration duration, {bool? checked}) =>
                checkAndUpdateDuration(index: index, duration: duration, setDto: setDto, checked: checked ?? false),
            startTime: durationControllers.isNotEmpty ? durationControllers[index] : DateTime.now(),
            onupdateDuration: (Duration duration) => updateDuration(index: index, duration: duration, setDto: setDto),
          ));
    }).toList();

    return Column(children: children);
  }
}

class _OneRepMaxSlider extends StatefulWidget {
  final String exercise;
  final double oneRepMax;

  const _OneRepMaxSlider({required this.exercise, required this.oneRepMax});

  @override
  State<_OneRepMaxSlider> createState() => _OneRepMaxSliderState();
}

class _OneRepMaxSliderState extends State<_OneRepMaxSlider> {
  double _weight = 0.0;
  double _reps = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.exercise,
            style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: "Based on your recent progress, consider",
            style: GoogleFonts.ubuntu(height: 1.5, color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
            children: [
              TextSpan(
                text: "\n",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "$_weight${weightLabel()}",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "for",
                style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "${_reps.toInt()} ${pluralize(word: "rep", count: _reps.toInt())}",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              )
            ],
          ),
        ),
        Slider(value: _reps, onChanged: onChanged, min: 1, max: 20, divisions: 20, thumbColor: vibrantGreen),
      ],
    );
  }

  void onChanged(double value) {
    final weight = _weightForPercentage(reps: value.toInt());
    setState(() {
      _weight = weightWithConversion(value: weight).roundToDouble();
      _reps = value;
    });
  }

  int _percentageForReps(int reps) {
    // Define a map of reps to percentages
    Map<int, int> repToPercentage = {
      1: 100,
      2: 97,
      3: 94,
      4: 92,
      5: 89,
      6: 86,
      7: 83,
      8: 81,
      9: 78,
      10: 75,
      11: 73,
      12: 71,
      13: 70,
      14: 68,
      15: 67,
      16: 65,
      17: 64,
      18: 62,
      19: 61,
      20: 60,
    };

    return repToPercentage[reps] ?? 1;
  }

  double _weightForPercentage({required int reps}) {
    return (widget.oneRepMax * (_percentageForReps(reps) / 100)).roundToDouble();
  }

  @override
  void initState() {
    super.initState();
    _weight = _weightForPercentage(reps: 10);
  }
}
